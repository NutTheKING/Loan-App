import '@fastify/jwt';
import 'fastify';

declare module 'fastify' {
  interface FastifyRequest {
    permissions: string[];
  }
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: {
      sub: string;
      sid: string;
      role: 'CUSTOMER' | 'STAFF' | 'ADMIN';
      email: string;
    };
    user: {
      sub: string;
      sid: string;
      role: 'CUSTOMER' | 'STAFF' | 'ADMIN';
      email: string;
    };
  }
}
