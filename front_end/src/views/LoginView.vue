<template>
  <AuthLayout>
    <h1 class="title">Entrar</h1>
    <p class="subtitle">Acesse sua conta para continuar.</p>

    <form class="form" @submit.prevent="handleSubmit">
      <div class="field">
        <label for="login-email">E-mail</label>
        <input class="input" id="login-email" type="email" v-model="form.email" placeholder="voce@exemplo.com"
          required />
      </div>
      <div class="field">
        <label for="login-password">Senha</label>
        <input class="input" id="login-password" type="password" v-model="form.password" placeholder="••••••••"
          required />
      </div>
      <div class="forgot-row">
        <a href="#">Esqueceu a senha?</a>
      </div>
      <button type="submit" class="btn btn-primary btn-block">
        Entrar
        <svg width="14" height="14" viewBox="0 0 256 256" fill="currentColor">
          <path
            d="M221.66,133.66l-72,72a8,8,0,0,1-11.32-11.32L196.69,136H40a8,8,0,0,1,0-16H196.69L138.34,61.66a8,8,0,0,1,11.32-11.32l72,72A8,8,0,0,1,221.66,133.66Z" />
        </svg>
      </button>
    </form>

    <p class="switch-row">
      Não tem uma conta? <router-link to="/criar-conta">Criar conta</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive } from 'vue'
import AuthLayout from '../components/AuthLayout.vue'

const form = reactive({ email: '', password: '' })

function handleSubmit() {
  // TODO: integrar com API de autenticação
  console.log('login', { ...form })
}
</script>

<style scoped>
.title {
  font-family: var(--font-heading);
  font-weight: 500;
  font-size: 28px;
  margin: 0 0 var(--space-2);
}

.subtitle {
  opacity: 0.6;
  font-size: 14px;
  margin: 0 0 var(--space-6);
}

.form {
  display: grid;
  gap: var(--space-4);
}

.forgot-row {
  display: flex;
  justify-content: flex-end;
  margin-top: calc(var(--space-2) * -1);
}

.forgot-row a {
  font-size: 13px;
  text-decoration: none;
}

.switch-row {
  font-size: 14px;
  opacity: 0.75;
  margin-top: var(--space-6);
  text-align: center;
}

.switch-row a {
  text-decoration: none;
}
</style>
