<template>
  <div class="field">
    <label :for="id">{{ label }}</label>
    <input
      :id="id"
      class="input"
      :type="type"
      :placeholder="placeholder"
      :required="required"
      v-model="model"
    />
  </div>
</template>

<script setup>
const model = defineModel({ type: String, default: '' })

defineProps({
  id: { type: String, required: true },
  label: { type: String, required: true },
  type: { type: String, default: 'text' },
  placeholder: { type: String, default: '' },
  required: { type: Boolean, default: false },
})
</script>
