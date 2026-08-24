<template>
  <AuthLayout>
    <h1 class="title">Criar conta</h1>
    <p class="subtitle">Preencha os dados abaixo para começar.</p>

    <form class="form" @submit.prevent="handleSubmit">
      <div class="name-grid">
        <div class="field">
          <label for="signup-first-name">Nome</label>
          <input class="input" id="signup-first-name" type="text" v-model="form.firstName" placeholder="Maria"
            required />
        </div>
        <div class="field">
          <label for="signup-last-name">Sobrenome</label>
          <input class="input" id="signup-last-name" type="text" v-model="form.lastName" placeholder="Silva" required />
        </div>
      </div>
      <div class="field">
        <label for="signup-email">E-mail</label>
        <input class="input" id="signup-email" type="email" v-model="form.email" placeholder="voce@exemplo.com"
          required />
      </div>
      <div class="field">
        <label for="signup-password">Senha</label>
        <input class="input" id="signup-password" type="password" v-model="form.password" placeholder="••••••••"
          required />
      </div>
      <div class="field">
        <label for="signup-password-confirmation">Confirmar senha</label>
        <input class="input" id="signup-password-confirmation" type="password" v-model="form.passwordConfirmation"
          placeholder="••••••••" required />
      </div>
      <p v-if="mismatchError" class="error">As senhas não coincidem.</p>
      <button type="submit" class="btn btn-primary btn-block submit-btn">
        Criar conta
        <svg width="14" height="14" viewBox="0 0 256 256" fill="currentColor">
          <path
            d="M221.66,133.66l-72,72a8,8,0,0,1-11.32-11.32L196.69,136H40a8,8,0,0,1,0-16H196.69L138.34,61.66a8,8,0,0,1,11.32-11.32l72,72A8,8,0,0,1,221.66,133.66Z" />
        </svg>
      </button>
    </form>

    <p class="switch-row">
      Já tem uma conta? <router-link to="/login">Entrar</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive, ref } from 'vue'
import AuthLayout from '../components/AuthLayout.vue'

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  passwordConfirmation: '',
})
const mismatchError = ref(false)

function handleSubmit() {
  mismatchError.value = form.password !== form.passwordConfirmation
  if (mismatchError.value) return
  // TODO: integrar com API de cadastro
  console.log('signup', { ...form })
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

.name-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.submit-btn {
  margin-top: var(--space-2);
}

.error {
  color: var(--color-accent-300);
  font-size: 13px;
  margin: calc(var(--space-2) * -1) 0 0;
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
