importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCg3euTUFfVnCrsTVhTpQa0XjIareaU3r8',
  appId: '1:377342984195:web:2fa5fe8d0152a5f6604e36',
  messagingSenderId: '377342984195',
  projectId: 'loan-app1123',
  authDomain: 'loan-app1123.firebaseapp.com',
  storageBucket: 'loan-app1123.firebasestorage.app',
});

firebase.messaging();
