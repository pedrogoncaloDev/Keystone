<template>
  <AuthLayout>
    <h1 class="title">Entrar</h1>
    <p class="subtitle">Acesse sua conta para continuar.</p>

    <form class="form" @submit.prevent="handleSubmit">
      <FormField id="login-email" label="E-mail" type="email" v-model="form.email" placeholder="voce@exemplo.com"
        required />
      <FormField id="login-password" label="Senha" type="password" v-model="form.password" placeholder="••••••••"
        required />
      <div class="forgot-row">
        <a href="#">Esqueceu a senha?</a>
      </div>
      <AppButton type="submit" block>Entrar</AppButton>
    </form>

    <p class="switch-row">
      Não tem uma conta? <router-link to="/criar-conta">Criar conta</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive } from 'vue'
import AuthLayout from '../components/AuthLayout.vue'
import FormField from '../components/FormField.vue'
import AppButton from '../components/AppButton.vue'

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
