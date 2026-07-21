import '@fastify/jwt';

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: {
      sub: string;
      role: 'CUSTOMER' | 'STAFF' | 'ADMIN';
      email: string;
    };
    user: {
      sub: string;
      role: 'CUSTOMER' | 'STAFF' | 'ADMIN';
      email: string;
    };
  }
}
