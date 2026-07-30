<template>
  <div class="scene-indicator">
    <strong>{{ sceneName }}</strong>
    <span>{{ sceneTime }}</span>
  </div>
</template>

<script setup>
defineProps({
  sceneName: { type: String, default: '加载中...' },
  sceneTime: { type: String, default: '' }
})
</script>

<style scoped>
.scene-indicator {
  position: absolute;
  top: 90px;
  left: 24px;
  z-index: 10;
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  background: rgba(0, 0, 0, 0.5);
  padding: 10px 18px;
  border-radius: 12px;
  border-left: 3px solid #00d4ff;
  backdrop-filter: blur(8px);
  pointer-events: none;
}
.scene-indicator strong {
  color: #00d4ff;
  display: block;
  font-size: 18px;
}
</style>