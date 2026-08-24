<template>
  <button :type="type" class="btn" :class="[`btn-${variant}`, { 'btn-block': block }]" :disabled="disabled">
    <slot />
    <slot name="icon">
      <svg width="14" height="14" viewBox="0 0 256 256" fill="currentColor">
        <path
          d="M221.66,133.66l-72,72a8,8,0,0,1-11.32-11.32L196.69,136H40a8,8,0,0,1,0-16H196.69L138.34,61.66a8,8,0,0,1,11.32-11.32l72,72A8,8,0,0,1,221.66,133.66Z" />
      </svg>
    </slot>
  </button>
</template>

<script setup>
defineProps({
  type: { type: String, default: 'button' },
  variant: { type: String, default: 'primary' },
  block: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
})
</script>
