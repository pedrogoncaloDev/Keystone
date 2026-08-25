<template>
  <div class="toast-container">
    <transition-group name="toast" tag="div" class="toast-stack">
      <div
        v-for="t in toasts"
        :key="t.id"
        class="toast"
        :class="t.type"
        role="status"
        @click="remove(t.id)"
      >
        {{ t.message }}
      </div>
    </transition-group>
  </div>
</template>

<script setup>
import { useToast } from '../stores/toast'

const { toasts, remove } = useToast()
</script>

<style scoped>
.toast-container {
  position: fixed;
  top: var(--space-4);
  right: var(--space-4);
  z-index: 1000;
  pointer-events: none;
}

.toast-stack {
  display: grid;
  gap: var(--space-2);
}

.toast {
  pointer-events: auto;
  cursor: pointer;
  min-width: 220px;
  max-width: 340px;
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  font-size: 13px;
  color: var(--color-text);
  background: var(--color-surface);
  border: 1px solid var(--color-divider);
  border-left: 3px solid var(--color-divider);
  box-shadow: var(--shadow-md);
}

.toast.success {
  color: #4ade80;
  border-left-color: #4ade80;
  background: color-mix(in srgb, #4ade80 12%, var(--color-surface));
}

.toast.error {
  color: #f87171;
  border-left-color: #f87171;
  background: color-mix(in srgb, #f87171 12%, var(--color-surface));
}

.toast-enter-active,
.toast-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
