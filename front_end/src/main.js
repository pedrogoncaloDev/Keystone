import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import LoginView from './views/LoginView.vue'
import SignupView from './views/SignupView.vue'
import './assets/styles.css'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/login' },
    { path: '/login', name: 'login', component: LoginView },
    { path: '/criar-conta', name: 'signup', component: SignupView },
  ],
})

createApp(App).use(router).mount('#app')
