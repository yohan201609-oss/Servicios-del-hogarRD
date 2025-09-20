// Firebase configuration for web
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyBrNEHuA2-FCt3tzL9UI6JKK3hGLqXqaJ4", // Reemplaza con la clave real de tu proyecto
  authDomain: "servicios-hogar-rd-dev.firebaseapp.com", // Cambia según el entorno
  projectId: "servicios-hogar-rd-dev", // Cambia según el entorno
  storageBucket: "servicios-hogar-rd-dev.firebasestorage.app", // Cambia según el entorno
  messagingSenderId: "607113121137", // Reemplaza con el ID real
  appId: "1:607113121137:web:servicios-hogar-rd-dev" // Reemplaza con el App ID real
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);

// Initialize Cloud Firestore and get a reference to the service
export const db = getFirestore(app);
