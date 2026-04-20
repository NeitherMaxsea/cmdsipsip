import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getDatabase } from 'firebase/database';
import { getStorage } from 'firebase/storage';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
    apiKey: String(import.meta.env.VITE_FIREBASE_API_KEY || '').trim(),
    authDomain: String(import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || '').trim(),
    databaseURL: String(import.meta.env.VITE_FIREBASE_DATABASE_URL || '').trim(),
    projectId: String(import.meta.env.VITE_FIREBASE_PROJECT_ID || '').trim(),
    storageBucket: String(import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || '').trim(),
    messagingSenderId: String(import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '').trim(),
    appId: String(import.meta.env.VITE_FIREBASE_APP_ID || '').trim(),
};

export const firebaseConfigReady = [
    firebaseConfig.apiKey,
    firebaseConfig.authDomain,
    firebaseConfig.projectId,
    firebaseConfig.storageBucket,
    firebaseConfig.appId,
].every(Boolean);

export const firebaseApp = firebaseConfigReady ? initializeApp(firebaseConfig) : null;
export const firebaseAuth = firebaseApp ? getAuth(firebaseApp) : null;
export const realtimeDb = firebaseApp ? getDatabase(firebaseApp) : null;
export const storage = firebaseApp ? getStorage(firebaseApp) : null;
export const firebaseFunctions = firebaseApp ? getFunctions(firebaseApp) : null;
export { firebaseConfig };
