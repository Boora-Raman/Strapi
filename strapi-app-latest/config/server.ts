// config/server.ts

export default ({ env }) => ({
  host: env('HOST', '0.0.0.0'),
  port: env.int('PORT', 1337),
  app: {
    keys: env.array('APP_KEYS'),
  },
  // 👇 Add this block:
  webhooks: {
    populateRelations: env.bool('WEBHOOKS_POPULATE_RELATIONS', false),
  },
  admin: {
    auth: {
      secret: env('ADMIN_JWT_SECRET'),
    },
  },
  // 👇 Here is the fix
  allowedHosts: [
    // 'strapi-test-lb-tf-1458014364.us-east-1.elb.amazonaws.com',
    '*'
  ],
});
