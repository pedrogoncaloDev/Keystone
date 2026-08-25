<template>
  <AuthLayout>
    <h1 class="title">Entrar</h1>
    <p class="subtitle">Acesse sua conta para continuar.</p>

    <form class="form" @submit.prevent="handleSubmit">
      <FormField id="login-email" label="E-mail" type="email" v-model="form.email" placeholder="voce@exemplo.com"
        required />
      <FormField id="login-password" label="Senha" type="password" v-model="form.password" placeholder="••••••••"
        required />
      <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
      <AppButton type="submit" block :disabled="loading">{{ loading ? 'Entrando...' : 'Entrar' }}</AppButton>
    </form>

    <p class="switch-row">
      Não tem uma conta? <router-link to="/criar-conta">Criar conta</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '../components/AuthLayout.vue'
import FormField from '../components/FormField.vue'
import AppButton from '../components/AppButton.vue'
import { loginUser } from '../services/api'
import { setUser } from '../stores/auth'

const form = reactive({ email: '', password: '' })
const errorMessage = ref('')
const loading = ref(false)
const router = useRouter()

async function handleSubmit() {
  errorMessage.value = ''
  loading.value = true
  try {
    const authenticatedUser = await loginUser(form.email, form.password)
    setUser(authenticatedUser)
    router.push({ name: 'home' })
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
