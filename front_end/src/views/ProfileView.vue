<template>
  <AuthLayout>
    <h1 class="title">Editar perfil</h1>
    <p class="subtitle">Atualize seus dados ou exclua sua conta.</p>

    <form class="form" @submit.prevent="handleUpdate">
      <div class="name-grid">
        <FormField id="profile-first-name" label="Nome" v-model="form.firstName" required />
        <FormField id="profile-last-name" label="Sobrenome" v-model="form.lastName" required />
      </div>
      <FormField id="profile-email" label="E-mail" type="email" v-model="form.email" required />
      <FormField id="profile-new-password" label="Nova senha (opcional)" type="password"
        v-model="form.newPassword" placeholder="Deixe em branco para manter a atual" />
      <FormField id="profile-current-password" label="Senha atual" type="password"
        v-model="form.currentPassword" placeholder="••••••••" required />

      <p v-if="updateError" class="error">{{ updateError }}</p>
      <p v-if="updateSuccess" class="success">{{ updateSuccess }}</p>
      <AppButton type="submit" block :disabled="updateLoading">
        {{ updateLoading ? 'Salvando...' : 'Salvar alterações' }}
      </AppButton>
    </form>

    <div class="danger-zone">
      <p class="danger-title">Zona de perigo</p>

      <template v-if="!confirmingDelete">
        <AppButton variant="ghost" block @click="confirmingDelete = true">Excluir conta</AppButton>
      </template>
      <template v-else>
        <p class="danger-text">Essa ação não pode ser desfeita. Confirme sua senha para excluir a conta.</p>
        <FormField id="profile-delete-password" label="Senha atual" type="password"
          v-model="deletePassword" placeholder="••••••••" required />
        <p v-if="deleteError" class="error">{{ deleteError }}</p>
        <div class="danger-actions">
          <AppButton variant="ghost" block @click="cancelDelete">Cancelar</AppButton>
          <AppButton block :disabled="deleteLoading" @click="handleDelete">
            {{ deleteLoading ? 'Excluindo...' : 'Confirmar exclusão' }}
          </AppButton>
        </div>
      </template>
    </div>

    <p class="switch-row">
      <router-link to="/home">Voltar</router-link>
    </p>
  </AuthLayout>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import AuthLayout from '../components/AuthLayout.vue'
import FormField from '../components/FormField.vue'
import AppButton from '../components/AppButton.vue'
import { updateUser, deleteUser } from '../services/api'
import { useAuth, setUser, clearUser } from '../stores/auth'

const auth = useAuth()
const router = useRouter()

const form = reactive({
  firstName: auth.user?.first_name ?? '',
  lastName: auth.user?.last_name ?? '',
  email: auth.user?.email ?? '',
  newPassword: '',
  currentPassword: '',
})
const updateError = ref('')
const updateSuccess = ref('')
const updateLoading = ref(false)

async function handleUpdate() {
  updateError.value = ''
  updateSuccess.value = ''
  updateLoading.value = true
  try {
    const currentEmail = auth.user.email
    await updateUser({
      currentEmail,
      currentPassword: form.currentPassword,
      firstName: form.firstName,
      lastName: form.lastName,
      email: form.email,
      password: form.newPassword || form.currentPassword,
    })
    setUser({ first_name: form.firstName, last_name: form.lastName, email: form.email })
    form.newPassword = ''
    form.currentPassword = ''
    updateSuccess.value = 'Dados atualizados com sucesso.'
  } catch (error) {
    updateError.value = error.message
  } finally {
    updateLoading.value = false
  }
}

const confirmingDelete = ref(false)
const deletePassword = ref('')
const deleteError = ref('')
const deleteLoading = ref(false)

function cancelDelete() {
  confirmingDelete.value = false
  deletePassword.value = ''
  deleteError.value = ''
}

async function handleDelete() {
  deleteError.value = ''
  deleteLoading.value = true
  try {
    await deleteUser(auth.user.email, deletePassword.value)
    clearUser()
    router.push({ name: 'login' })
  } catch (error) {
    deleteError.value = error.message
  } finally {
    deleteLoading.value = false
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

.danger-zone {
  margin-top: var(--space-6);
  padding-top: var(--space-6);
  border-top: 1px solid var(--color-divider);
  display: grid;
  gap: var(--space-4);
}

.danger-title {
  font-size: 13px;
  font-weight: 500;
  opacity: 0.6;
  margin: 0;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.danger-text {
  font-size: 13px;
  opacity: 0.75;
  margin: 0;
}

.danger-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
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
