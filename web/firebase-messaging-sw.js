importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCPaif4jyDTxPLT4zjEU1KuKuimSwMH70Y',
  appId: '1:314856867568:web:0f2df80ea93131b8922435',
  messagingSenderId: '314856867568',
  projectId: 'loan-app-3d70e',
  authDomain: 'loan-app-3d70e.firebaseapp.com',
  storageBucket: 'loan-app-3d70e.firebasestorage.app',
});

firebase.messaging();
