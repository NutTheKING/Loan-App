import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';

import { prisma } from './prisma.js';

function configureFirebase() {
  if (getApps().length > 0) {
    return getApps()[0];
  }
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!serviceAccountJson) {
    return null;
  }
  const serviceAccount = JSON.parse(serviceAccountJson) as {
    project_id: string;
    client_email: string;
    private_key: string;
  };
  return initializeApp({
    credential: cert({
      projectId: serviceAccount.project_id,
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key.replaceAll('\\n', '\n'),
    }),
  });
}

export async function sendPushToUsers(
  userIds: string[],
  notification: { title: string; body: string; payload?: string },
): Promise<void> {
  const app = configureFirebase();
  if (!app || userIds.length === 0) {
    return;
  }
  const devices = await prisma.deviceToken.findMany({ where: { userId: { in: userIds } } });
  if (devices.length === 0) {
    return;
  }

  for (let index = 0; index < devices.length; index += 500) {
    const batch = devices.slice(index, index + 500);
    const response = await getMessaging(app).sendEachForMulticast({
      tokens: batch.map((device) => device.token),
      notification: { title: notification.title, body: notification.body },
      data: { payload: notification.payload ?? '/' },
    });
    const invalidTokens = response.responses
      .map((result, resultIndex) => ({ result, token: batch[resultIndex].token }))
      .filter(({ result }) =>
        result.error?.code === 'messaging/registration-token-not-registered' ||
        result.error?.code === 'messaging/invalid-registration-token',
      )
      .map(({ token }) => token);
    if (invalidTokens.length > 0) {
      await prisma.deviceToken.deleteMany({ where: { token: { in: invalidTokens } } });
    }
  }
}
