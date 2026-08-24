<template>
  <AuthLayout>
    <h1 class="title">Bem-vindo{{ greetingSuffix }}</h1>
    <p class="subtitle">Você está autenticado no Nocturne.</p>

    <div class="card user-card">
      <div class="user-row">
        <span class="user-label">Nome</span>
        <span class="user-value">{{ auth.user?.first_name }} {{ auth.user?.last_name }}</span>
      </div>
      <div class="user-row">
        <span class="user-label">E-mail</span>
        <span class="user-value">{{ auth.user?.email }}</span>
      </div>
    </div>

    <AppButton variant="ghost" block @click="handleLogout">
      Sair
      <template #icon></template>
    </AppButton>
  </AuthLayout>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '../components/AuthLayout.vue'
import AppButton from '../components/AppButton.vue'
import { useAuth, clearUser } from '../stores/auth'

const auth = useAuth()
const router = useRouter()

const greetingSuffix = computed(() => (auth.user?.first_name ? `, ${auth.user.first_name}` : ''))

function handleLogout() {
  clearUser()
  router.push({ name: 'login' })
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

.user-card {
  margin-bottom: var(--space-6);
}

.user-row {
  display: flex;
  justify-content: space-between;
  gap: var(--space-4);
  font-size: 14px;
}

.user-label {
  opacity: 0.6;
}
</style>
