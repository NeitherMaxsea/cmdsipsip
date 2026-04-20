import fs from 'fs';
import { initializeApp } from 'firebase/app';
import { getFunctions, httpsCallable } from 'firebase/functions';

const envLines = fs.readFileSync('.env', 'utf8').split(/\r?\n/);
const env = Object.fromEntries(envLines.map((line) => {
  const match = line.match(/^([A-Z0-9_]+)=(.*)$/);
  return match ? [match[1], match[2]] : null;
}).filter(Boolean));

const app = initializeApp({
  apiKey: env.VITE_FIREBASE_API_KEY,
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
  databaseURL: env.VITE_FIREBASE_DATABASE_URL,
  projectId: env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: env.VITE_FIREBASE_APP_ID,
});

const functions = getFunctions(app);
const call = httpsCallable(functions, 'pingOtp');

try {
  const res = await call({});
  console.log('OK', JSON.stringify(res.data));
} catch (err) {
  console.error('ERR', err?.code, err?.message, err?.details);
  process.exit(1);
}
