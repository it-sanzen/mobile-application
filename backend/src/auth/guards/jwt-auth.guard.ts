import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
    handleRequest(err, user, info) {
        if (err || !user) {
            console.log('JWT_AUTH_GUARD_ERROR_DUMP:', { err, info: info?.message || info, user });
            throw err || new UnauthorizedException();
        }
        return user;
    }
}
