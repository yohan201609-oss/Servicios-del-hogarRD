import 'package:flutter/material.dart';
import '../models/provider.dart';
import '../services/chat_service.dart';
import '../services/app_service.dart';
import 'chat_detail_screen.dart';

class StartChatScreen extends StatefulWidget {
  final Provider provider;

  const StartChatScreen({super.key, required this.provider});

  @override
  State<StartChatScreen> createState() => _StartChatScreenState();
}

class _StartChatScreenState extends State<StartChatScreen> {
  final ChatService _chatService = ChatService.instance;
  final AppService _appService = AppService.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isCreatingChat = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    final currentUserId = _appService.currentUserId;
    final currentUser = _appService.auth.currentUser;

    if (currentUserId == null || currentUser == null) {
      _showErrorDialog('No se pudo obtener la información del usuario');
      return;
    }

    setState(() {
      _isCreatingChat = true;
    });

    try {
      // Create or get existing chat
      final chat = await _chatService.crearObtenerChat(
        clienteId: currentUserId,
        clienteNombre: currentUser.displayName ?? 'Cliente',
        proveedorId: widget.provider.id,
        proveedorNombre: widget.provider.name,
        tituloServicio: widget.provider.category,
      );

      // Send initial message if provided
      if (_messageController.text.trim().isNotEmpty) {
        await _chatService.enviarMensaje(
          chatId: chat.id,
          remitenteId: currentUserId,
          remitenteNombre: currentUser.displayName ?? 'Cliente',
          contenido: _messageController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ChatDetailScreen(chat: chat)),
        );
      }
    } catch (e) {
      _showErrorDialog('Error al iniciar la conversación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingChat = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Conversación'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider info card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        widget.provider.name.isNotEmpty
                            ? widget.provider.name[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.provider.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.provider.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.provider.ratingText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message input section
            Text(
              'Mensaje inicial (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText:
                      'Escribe un mensaje para iniciar la conversación...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 24),

            // Service info
            if (widget.provider.description.isNotEmpty) ...[
              Text(
                'Sobre este servicio',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  widget.provider.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isCreatingChat
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isCreatingChat ? null : _startChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isCreatingChat
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Iniciar Conversación',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
