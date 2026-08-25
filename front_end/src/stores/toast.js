import { reactive } from 'vue'

const state = reactive({ toasts: [] })
let nextId = 1

function remove(id) {
  const index = state.toasts.findIndex((t) => t.id === id)
  if (index !== -1) state.toasts.splice(index, 1)
}

function push(message, type, duration = 4000) {
  const id = nextId++
  state.toasts.push({ id, message, type })
  setTimeout(() => remove(id), duration)
}

export const toast = {
  success: (message) => push(message, 'success'),
  error: (message) => push(message, 'error'),
}

export function useToast() {
  return { toasts: state.toasts, remove }
}
