<template>
  <div class="status" :class="type">
    {{ status }}
  </div>
</template>

<script setup>
defineProps({
  status: { type: String, default: '🔗 正在连接后端 API ...' },
  type: { type: String, default: 'info' } // info | success | error
})
</script>

<style scoped>
.status {
  position: absolute;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  color: #aaa;
  font-size: 13px;
  background: rgba(0, 0, 0, 0.6);
  padding: 8px 24px;
  border-radius: 30px;
  border: 1px solid rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(8px);
}
.status.success { color: #00ff88; border-color: rgba(0, 255, 136, 0.2); }
.status.error { color: #ff6b6b; border-color: rgba(255, 107, 107, 0.2); }
</style>