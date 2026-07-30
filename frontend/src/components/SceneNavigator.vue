<template>
  <div class="nav-buttons">
    <button :disabled="currentIndex === 0" @click="$emit('prev')">← 上一场景</button>
    <button :disabled="currentIndex >= total - 1" @click="$emit('next')">下一场景 →</button>
  </div>
</template>

<script setup>
defineProps({
  currentIndex: { type: Number, default: 0 },
  total: { type: Number, default: 0 }
})
defineEmits(['prev', 'next'])
</script>

<style scoped>
.nav-buttons {
  position: absolute;
  bottom: 80px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  display: flex;
  gap: 12px;
}
.nav-buttons button {
  padding: 10px 24px;
  background: rgba(0, 0, 0, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: white;
  font-size: 14px;
  cursor: pointer;
  backdrop-filter: blur(8px);
  transition: all 0.3s;
  font-family: inherit;
}
.nav-buttons button:hover:not(:disabled) {
  background: rgba(0, 212, 255, 0.15);
  border-color: #00d4ff;
}
.nav-buttons button:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}
</style>