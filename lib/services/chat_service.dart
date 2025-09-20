import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/chat.dart';
import '../models/user_profile.dart';
import '../models/service_request.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  static ChatService get instance => _instance;

  final Logger _logger = Logger();
  List<Chat> _chats = [];
  Map<String, List<Mensaje>> _mensajes = {};

  static const String _chatsKey = 'chats_data';
  static const String _mensajesKey = 'mensajes_data';

  Future<void> initialize() async {
    await _loadData();
  }

  Future<void> initializeWithUser(String userId) async {
    await _loadData();
    _createSampleData(userId);
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load chats
      final chatsJson = prefs.getString(_chatsKey);
      if (chatsJson != null) {
        final List<dynamic> chatsList = json.decode(chatsJson);
        _chats = chatsList.map((json) => Chat.fromJson(json)).toList();
      }

      // Load messages
      final mensajesJson = prefs.getString(_mensajesKey);
      if (mensajesJson != null) {
        final Map<String, dynamic> mensajesMap = json.decode(mensajesJson);
        _mensajes = mensajesMap.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((json) => Mensaje.fromJson(json)).toList(),
          ),
        );
      }

      _logger.i(
        'Chat data loaded: ${_chats.length} chats, ${_mensajes.length} message threads',
      );
    } catch (e) {
      _logger.e('Error loading chat data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save chats
      final chatsJson = json.encode(
        _chats.map((chat) => chat.toJson()).toList(),
      );
      await prefs.setString(_chatsKey, chatsJson);

      // Save messages
      final mensajesJson = json.encode(
        _mensajes.map(
          (key, value) =>
              MapEntry(key, value.map((msg) => msg.toJson()).toList()),
        ),
      );
      await prefs.setString(_mensajesKey, mensajesJson);

      _logger.i('Chat data saved successfully');
    } catch (e) {
      _logger.e('Error saving chat data: $e');
    }
  }

  // Create or get existing chat
  Future<Chat> crearObtenerChat({
    required String clienteId,
    required String clienteNombre,
    required String proveedorId,
    required String proveedorNombre,
    String? servicioId,
    String? tituloServicio,
  }) async {
    // Check if chat already exists
    final chatExistente = _chats
        .where(
          (chat) =>
              chat.clienteId == clienteId && chat.proveedorId == proveedorId,
        )
        .firstOrNull;

    if (chatExistente != null) {
      return chatExistente;
    }

    // Create new chat
    final nuevoChat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clienteId: clienteId,
      clienteNombre: clienteNombre,
      proveedorId: proveedorId,
      proveedorNombre: proveedorNombre,
      servicioId: servicioId,
      tituloServicio: tituloServicio,
      fechaCreacion: DateTime.now(),
      ultimaActividad: DateTime.now(),
      clienteActivo: true,
      proveedorActivo: true,
      mensajesNoLeidosCliente: 0,
      mensajesNoLeidosProveedor: 0,
    );

    _chats.add(nuevoChat);
    _mensajes[nuevoChat.id] = [];
    await _saveData();

    _logger.i('New chat created: ${nuevoChat.id}');
    return nuevoChat;
  }

  // Send message
  Future<Mensaje> enviarMensaje({
    required String chatId,
    required String remitenteId,
    required String remitenteNombre,
    required String contenido,
    TipoMensaje tipo = TipoMensaje.texto,
    String? archivoUrl,
    String? nombreArchivo,
    Map<String, dynamic>? metadata,
  }) async {
    final mensaje = Mensaje(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      remitenteId: remitenteId,
      remitenteNombre: remitenteNombre,
      contenido: contenido,
      tipo: tipo,
      fechaEnvio: DateTime.now(),
      estado: EstadoMensaje.enviado,
      archivoUrl: archivoUrl,
      nombreArchivo: nombreArchivo,
      metadata: metadata,
    );

    // Add message to chat
    if (_mensajes[chatId] == null) {
      _mensajes[chatId] = [];
    }
    _mensajes[chatId]!.add(mensaje);

    // Update chat with last message and activity
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final chat = _chats[chatIndex];

      // Determine who should get unread count
      final esCliente = remitenteId == chat.clienteId;
      final nuevosNoLeidosCliente = esCliente
          ? chat.mensajesNoLeidosCliente
          : chat.mensajesNoLeidosCliente + 1;
      final nuevosNoLeidosProveedor = !esCliente
          ? chat.mensajesNoLeidosProveedor
          : chat.mensajesNoLeidosProveedor + 1;

      _chats[chatIndex] = chat.copyWith(
        ultimaActividad: DateTime.now(),
        ultimoMensaje: mensaje,
        mensajesNoLeidosCliente: nuevosNoLeidosCliente,
        mensajesNoLeidosProveedor: nuevosNoLeidosProveedor,
      );
    }

    await _saveData();
    _logger.i('Message sent: ${mensaje.id}');

    return mensaje;
  }

  // Get chats for user
  List<Chat> getChatsUsuario(String usuarioId) {
    return _chats
        .where(
          (chat) =>
              chat.clienteId == usuarioId || chat.proveedorId == usuarioId,
        )
        .toList()
      ..sort((a, b) => b.ultimaActividad.compareTo(a.ultimaActividad));
  }

  // Get messages for chat
  List<Mensaje> getMensajesChat(String chatId) {
    return _mensajes[chatId] ?? [];
  }

  // Mark messages as read
  Future<void> marcarMensajesComoLeidos(String chatId, String usuarioId) async {
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex == -1) return;

    final chat = _chats[chatIndex];
    final esCliente = usuarioId == chat.clienteId;

    if (esCliente) {
      _chats[chatIndex] = chat.copyWith(mensajesNoLeidosCliente: 0);
    } else {
      _chats[chatIndex] = chat.copyWith(mensajesNoLeidosProveedor: 0);
    }

    await _saveData();
    _logger.i('Messages marked as read for user $usuarioId in chat $chatId');
  }

  // Get unread messages count for user
  int getMensajesNoLeidosTotal(String usuarioId) {
    return _chats
        .where(
          (chat) =>
              chat.clienteId == usuarioId || chat.proveedorId == usuarioId,
        )
        .fold(0, (total, chat) => total + chat.getMensajesNoLeidos(usuarioId));
  }

  // Delete chat
  Future<void> eliminarChat(String chatId) async {
    _chats.removeWhere((chat) => chat.id == chatId);
    _mensajes.remove(chatId);
    await _saveData();
    _logger.i('Chat deleted: $chatId');
  }

  // Clear old data
  Future<void> limpiarDatosAntiguos() async {
    final fechaLimite = DateTime.now().subtract(const Duration(days: 90));

    _chats.removeWhere((chat) => chat.ultimaActividad.isBefore(fechaLimite));
    _mensajes.removeWhere((chatId, mensajes) {
      final chat = _chats.any((c) => c.id == chatId);
      return !chat;
    });

    await _saveData();
    _logger.i('Old chat data cleaned');
  }

  // Create chat from service request
  Future<Chat> crearChatDesdeServicio(SolicitudServicio servicio) async {
    return await crearObtenerChat(
      clienteId: servicio.clienteId,
      clienteNombre:
          'Cliente ${servicio.clienteId.substring(0, 8)}', // Simplified for demo
      proveedorId: servicio.proveedorId,
      proveedorNombre:
          'Proveedor ${servicio.proveedorId.substring(0, 8)}', // Simplified for demo
      servicioId: servicio.id,
      tituloServicio: servicio.tipoServicio.displayName,
    );
  }

  // Helper method to get chat by service ID
  Chat? getChatPorServicio(String servicioId) {
    return _chats.where((chat) => chat.servicioId == servicioId).firstOrNull;
  }

  // Helper method to get chat by participants
  Chat? getChatPorParticipantes(String usuarioId1, String usuarioId2) {
    return _chats
        .where(
          (chat) =>
              (chat.clienteId == usuarioId1 &&
                  chat.proveedorId == usuarioId2) ||
              (chat.clienteId == usuarioId2 && chat.proveedorId == usuarioId1),
        )
        .firstOrNull;
  }

  // Create sample data for demonstration
  void _createSampleData(String userId) {
    // Only create sample data if no chats exist
    if (_chats.isNotEmpty) return;

    _logger.i('Creating sample chat data...');

    // Sample chat 1
    final chat1 = Chat(
      id: 'chat_1',
      clienteId: userId,
      clienteNombre: 'María González',
      proveedorId: 'provider_1',
      proveedorNombre: 'Juan Pérez - Plomero',
      tituloServicio: 'Plomería',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
      ultimaActividad: DateTime.now().subtract(const Duration(hours: 1)),
      clienteActivo: true,
      proveedorActivo: true,
      mensajesNoLeidosCliente: 0,
      mensajesNoLeidosProveedor: 2,
    );

    // Sample chat 2
    final chat2 = Chat(
      id: 'chat_2',
      clienteId: userId,
      clienteNombre: 'María González',
      proveedorId: 'provider_2',
      proveedorNombre: 'Carlos Rodríguez - Electricista',
      tituloServicio: 'Electricidad',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
      ultimaActividad: DateTime.now().subtract(const Duration(minutes: 30)),
      clienteActivo: true,
      proveedorActivo: true,
      mensajesNoLeidosCliente: 1,
      mensajesNoLeidosProveedor: 0,
    );

    // Sample chat 3
    final chat3 = Chat(
      id: 'chat_3',
      clienteId: userId,
      clienteNombre: 'María González',
      proveedorId: 'provider_3',
      proveedorNombre: 'Ana López - Limpieza',
      tituloServicio: 'Limpieza',
      fechaCreacion: DateTime.now().subtract(const Duration(hours: 6)),
      ultimaActividad: DateTime.now().subtract(const Duration(hours: 2)),
      clienteActivo: true,
      proveedorActivo: true,
      mensajesNoLeidosCliente: 0,
      mensajesNoLeidosProveedor: 0,
    );

    _chats.addAll([chat1, chat2, chat3]);

    // Sample messages for chat 1
    _mensajes['chat_1'] = [
      Mensaje(
        id: 'msg_1',
        chatId: 'chat_1',
        remitenteId: userId,
        remitenteNombre: 'María González',
        contenido:
            'Hola, necesito reparar un grifo que está goteando en mi cocina.',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(days: 2)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_2',
        chatId: 'chat_1',
        remitenteId: 'provider_1',
        remitenteNombre: 'Juan Pérez - Plomero',
        contenido:
            'Hola María, con gusto te ayudo. ¿Podrías enviarme una foto del grifo para ver el problema?',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_3',
        chatId: 'chat_1',
        remitenteId: userId,
        remitenteNombre: 'María González',
        contenido: 'Perfecto, te envío la foto ahora.',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(hours: 3)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_4',
        chatId: 'chat_1',
        remitenteId: 'provider_1',
        remitenteNombre: 'Juan Pérez - Plomero',
        contenido:
            'Veo el problema. Es una reparación sencilla. ¿Cuándo te conviene que vaya?',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(hours: 1)),
        estado: EstadoMensaje.enviado,
      ),
    ];

    // Sample messages for chat 2
    _mensajes['chat_2'] = [
      Mensaje(
        id: 'msg_5',
        chatId: 'chat_2',
        remitenteId: 'provider_2',
        remitenteNombre: 'Carlos Rodríguez - Electricista',
        contenido:
            'Hola María, vi tu solicitud de instalación eléctrica. ¿Cuántos tomas necesitas instalar?',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(days: 1)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_6',
        chatId: 'chat_2',
        remitenteId: userId,
        remitenteNombre: 'María González',
        contenido: 'Hola Carlos, necesito 3 tomas adicionales en mi sala.',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(hours: 2)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_7',
        chatId: 'chat_2',
        remitenteId: 'provider_2',
        remitenteNombre: 'Carlos Rodríguez - Electricista',
        contenido:
            'Perfecto, el costo sería de \$2,500 pesos por toma. ¿Te parece bien?',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(minutes: 30)),
        estado: EstadoMensaje.enviado,
      ),
    ];

    // Sample messages for chat 3
    _mensajes['chat_3'] = [
      Mensaje(
        id: 'msg_8',
        chatId: 'chat_3',
        remitenteId: userId,
        remitenteNombre: 'María González',
        contenido:
            'Hola Ana, gracias por el servicio de limpieza de ayer. Quedó perfecto!',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(hours: 6)),
        estado: EstadoMensaje.leido,
      ),
      Mensaje(
        id: 'msg_9',
        chatId: 'chat_3',
        remitenteId: 'provider_3',
        remitenteNombre: 'Ana López - Limpieza',
        contenido:
            '¡Muchas gracias María! Me alegra saber que quedaste satisfecha. No dudes en contactarme cuando necesites otro servicio.',
        tipo: TipoMensaje.texto,
        fechaEnvio: DateTime.now().subtract(const Duration(hours: 2)),
        estado: EstadoMensaje.leido,
      ),
    ];

    // Update chats with last messages
    final chat1Index = _chats.indexWhere((chat) => chat.id == 'chat_1');
    if (chat1Index != -1) {
      _chats[chat1Index] = chat1.copyWith(
        ultimoMensaje: _mensajes['chat_1']!.last,
      );
    }

    final chat2Index = _chats.indexWhere((chat) => chat.id == 'chat_2');
    if (chat2Index != -1) {
      _chats[chat2Index] = chat2.copyWith(
        ultimoMensaje: _mensajes['chat_2']!.last,
      );
    }

    final chat3Index = _chats.indexWhere((chat) => chat.id == 'chat_3');
    if (chat3Index != -1) {
      _chats[chat3Index] = chat3.copyWith(
        ultimoMensaje: _mensajes['chat_3']!.last,
      );
    }

    _saveData();
    _logger.i('Sample chat data created successfully');
  }
}
