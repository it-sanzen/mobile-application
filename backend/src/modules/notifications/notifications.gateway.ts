import { SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({ cors: true })
export class NotificationsGateway {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);

  // Send a real-time notification to a specific user's room
  notifyUser(userId: string, payload: any) {
    this.logger.log(`Emitting notification to user room: ${userId}`);
    this.server.to(`user_${userId}`).emit('notification', payload);
  }

  @SubscribeMessage('joinRoom')
  handleJoinRoom(client: any, userId: string) {
    client.join(`user_${userId}`);
    this.logger.log(`Client joined room: user_${userId}`);
  }
}
