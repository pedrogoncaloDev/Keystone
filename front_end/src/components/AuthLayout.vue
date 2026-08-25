<template>
  <div class="auth-shell">
    <div class="auth-card">
      <div class="auth-brand">Keystone</div>
      <slot />
    </div>
  </div>
</template>

<style scoped>
.auth-shell {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-6);
  font-family: var(--font-body);
  color: var(--color-text);
  background: var(--color-bg);
}

.auth-card {
  width: 100%;
  max-width: 400px;
}

.auth-brand {
  margin-bottom: var(--space-6);
  font-family: var(--font-heading);
  font-weight: 500;
  font-size: 20px;
  letter-spacing: -0.01em;
}
</style>
