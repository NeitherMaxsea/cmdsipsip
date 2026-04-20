import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: "AIzaSyBRfMgPpuVBCwameAsCd5NKAagdcq9WbWU",
  authDomain: "thesiscapstone-785e2.firebaseapp.com",
  databaseURL: "https://thesiscapstone-785e2-default-rtdb.firebaseio.com",
  projectId: "thesiscapstone-785e2",
  storageBucket: "thesiscapstone-785e2.firebasestorage.app",
  messagingSenderId: "483411650427",
  appId: "1:483411650427:web:440fdeccb8a6a0ea7f7fde",
  measurementId: "G-HBJVR4Q76W"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);