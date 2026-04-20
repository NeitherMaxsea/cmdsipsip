import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getDatabase } from 'firebase/database';
import { getStorage } from 'firebase/storage';
import { getFunctions } from 'firebase/functions';

const trimString = (value) => String(value ?? '').trim();
const runtimeEnv = typeof window !== 'undefined'
    ? window.__THESIS_CAPSTONE_ENV__ || {}
    : {};

const resolveConfigValue = (...keys) => {
    for (const key of keys) {
        const runtimeValue = trimString(runtimeEnv?.[key]);
        if (runtimeValue) return runtimeValue;

        const viteValue = trimString(import.meta.env?.[key]);
        if (viteValue) return viteValue;
    }

    return '';
};

const firebaseConfig = {
    apiKey: resolveConfigValue('VITE_FIREBASE_API_KEY'),
    authDomain: resolveConfigValue('VITE_FIREBASE_AUTH_DOMAIN'),
    databaseURL: resolveConfigValue('VITE_FIREBASE_DATABASE_URL'),
    projectId: resolveConfigValue('VITE_FIREBASE_PROJECT_ID'),
    storageBucket: resolveConfigValue('VITE_FIREBASE_STORAGE_BUCKET'),
    messagingSenderId: resolveConfigValue('VITE_FIREBASE_MESSAGING_SENDER_ID'),
    appId: resolveConfigValue('VITE_FIREBASE_APP_ID'),
};
export const firebaseFunctionsRegion = resolveConfigValue('VITE_FIREBASE_FUNCTIONS_REGION') || 'us-central1';

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
export const firebaseFunctions = firebaseApp ? getFunctions(firebaseApp, firebaseFunctionsRegion) : null;
export { firebaseConfig };
