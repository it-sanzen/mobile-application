import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

@Injectable()
export class AdminGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean {
        // Ensure JwtAuthGuard has attached the user to the request object
        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user) {
            throw new ForbiddenException('User identity cannot be verified.');
        }

        if (user.isAdmin !== true) {
            throw new ForbiddenException('You do not have administrative privileges to access this endpoint.');
        }

        return true;
    }
}
