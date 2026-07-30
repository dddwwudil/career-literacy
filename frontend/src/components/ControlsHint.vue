<template>
  <div class="controls-hint">WASD 移动 · 鼠标拖动视角</div>
</template>

<style scoped>
.controls-hint {
  position: absolute;
  bottom: 140px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  color: rgba(255, 255, 255, 0.4);
  font-size: 13px;
  background: rgba(0, 0, 0, 0.3);
  padding: 6px 18px;
  border-radius: 20px;
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  pointer-events: none;
}
</style>