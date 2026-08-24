import { reactive } from 'vue'

const STORAGE_KEY = 'nocturne.auth.user'

function loadUser() {
  try {
    const raw = sessionStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

const state = reactive({
  user: loadUser(),
})

export function useAuth() {
  return state
}

export function setUser(user) {
  state.user = user
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(user))
}

export function clearUser() {
  state.user = null
  sessionStorage.removeItem(STORAGE_KEY)
}
