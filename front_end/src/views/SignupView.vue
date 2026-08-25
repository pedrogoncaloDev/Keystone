<template>
  <AuthLayout>
    <h1 class="title">Criar conta</h1>
    <p class="subtitle">Preencha os dados abaixo para começar.</p>

    <form class="form" @submit.prevent="handleSubmit">
      <div class="name-grid">
        <FormField id="signup-first-name" label="Nome" v-model="form.firstName" placeholder="Maria" required />
        <FormField id="signup-last-name" label="Sobrenome" v-model="form.lastName" placeholder="Silva" required />
      </div>
      <FormField id="signup-email" label="E-mail" type="email" v-model="form.email" placeholder="voce@exemplo.com"
        required />
      <FormField id="signup-password" label="Senha" type="password" v-model="form.password" placeholder="••••••••"
        required />
      <FormField id="signup-password-confirmation" label="Confirmar senha" type="password"
        v-model="form.passwordConfirmation" placeholder="••••••••" required />
      <p v-if="mismatchError" class="error">As senhas não coincidem.</p>
      <p v-else-if="errorMessage" class="error">{{ errorMessage }}</p>
      <p v-if="successMessage" class="success">{{ successMessage }}</p>
      <AppButton type="submit" block :disabled="loading">{{ loading ? 'Enviando...' : 'Criar conta' }}</AppButton>
    </form>

    <p class="switch-row">
      Já tem uma conta? <router-link to="/login">Entrar</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive, ref } from 'vue'
import AuthLayout from '../components/AuthLayout.vue'
import FormField from '../components/FormField.vue'
import AppButton from '../components/AppButton.vue'
import { registerUser } from '../services/api'

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  passwordConfirmation: '',
})
const mismatchError = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const loading = ref(false)

async function handleSubmit() {
  errorMessage.value = ''
  successMessage.value = ''
  mismatchError.value = form.password !== form.passwordConfirmation
  if (mismatchError.value) return

  loading.value = true
  try {
    await registerUser(form)
    successMessage.value = 'Cadastro concluído! Você já pode entrar.'
    form.firstName = ''
    form.lastName = ''
    form.email = ''
    form.password = ''
    form.passwordConfirmation = ''
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
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

.error {
  color: var(--color-accent-300);
  font-size: 13px;
  margin: calc(var(--space-2) * -1) 0 0;
}

.success {
  color: var(--color-text);
  opacity: 0.75;
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
