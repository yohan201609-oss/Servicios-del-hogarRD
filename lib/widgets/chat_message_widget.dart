import 'package:flutter/material.dart';
import '../models/chat.dart';

class ChatMessageWidget extends StatelessWidget {
  final Mensaje message;
  final bool isFromCurrentUser;
  final VoidCallback? onTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: isFromCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isFromCurrentUser) ...[
              _buildAvatar(message.remitenteNombre, theme),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isFromCurrentUser
                      ? theme.colorScheme.primary
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
                    bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFromCurrentUser) ...[
                      Text(
                        message.remitenteNombre,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    _buildMessageContent(context, theme),
                    const SizedBox(height: 4),
                    _buildMessageFooter(context, theme),
                  ],
                ),
              ),
            ),
            if (isFromCurrentUser) ...[
              const SizedBox(width: 8),
              _buildAvatar(message.remitenteNombre, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, ThemeData theme) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.secondary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme) {
    switch (message.tipo) {
      case TipoMensaje.texto:
        return Text(
          message.contenido,
          style: TextStyle(
            fontSize: 16,
            color: isFromCurrentUser ? Colors.white : Colors.black87,
          ),
        );

      case TipoMensaje.imagen:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📷 Imagen',
              style: TextStyle(
                fontSize: 14,
                color: isFromCurrentUser ? Colors.white70 : Colors.black54,
              ),
            ),
            if (message.archivoUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.archivoUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            ],
          ],
        );

      case TipoMensaje.documento:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              size: 16,
              color: isFromCurrentUser ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              message.nombreArchivo ?? 'Documento',
              style: TextStyle(
                fontSize: 14,
                color: isFromCurrentUser ? Colors.white70 : Colors.black54,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        );

      case TipoMensaje.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.audiotrack,
              size: 16,
              color: isFromCurrentUser ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              '🎵 Audio',
              style: TextStyle(
                fontSize: 14,
                color: isFromCurrentUser ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        );

      case TipoMensaje.ubicacion:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: isFromCurrentUser ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              '📍 Ubicación',
              style: TextStyle(
                fontSize: 14,
                color: isFromCurrentUser ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildMessageFooter(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.fechaEnvio),
          style: TextStyle(
            fontSize: 12,
            color: isFromCurrentUser
                ? Colors.white.withOpacity(0.7)
                : Colors.grey[600],
          ),
        ),
        if (isFromCurrentUser) ...[
          const SizedBox(width: 4),
          Icon(_getStatusIcon(), size: 16, color: _getStatusColor(theme)),
        ],
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (message.estado) {
      case EstadoMensaje.enviado:
        return Icons.done;
      case EstadoMensaje.entregado:
        return Icons.done_all;
      case EstadoMensaje.leido:
        return Icons.done_all;
      case EstadoMensaje.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (message.estado) {
      case EstadoMensaje.enviado:
        return Colors.white.withOpacity(0.7);
      case EstadoMensaje.entregado:
        return Colors.white.withOpacity(0.7);
      case EstadoMensaje.leido:
        return Colors.blue[300] ?? theme.colorScheme.primary;
      case EstadoMensaje.error:
        return Colors.red[300] ?? Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isFromCurrentUser;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: isFromCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isFromCurrentUser
                      ? theme.colorScheme.primary
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
                    bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isFromCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
