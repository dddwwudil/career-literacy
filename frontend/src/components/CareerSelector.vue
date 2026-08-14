<template>
  <div class="career-selector">
    <button
        v-for="career in careers"
        :key="career.id"
        class="career-btn"
        :class="{ active: career.id === selectedId }"
        :style="{ opacity: career.status === 'active' ? 1 : 0.5 }"
        :disabled="career.status !== 'active'"
        @click="selectCareer(career.id)"
    >
      {{ career.icon || '💼' }} {{ career.name }}
      <span class="badge" :class="career.status === 'active' ? 'active-badge' : 'coming'">
        {{ career.status === 'active' ? '体验中' : '敬请期待' }}
      </span>
    </button>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../composables/useApi.js'

const { getCareers } = useApi()
const careers = ref([])
const selectedId = ref(1)

const emit = defineEmits(['select'])

onMounted(async () => {
  try {
    careers.value = await getCareers()
    if (careers.value.length > 0) {
      selectedId.value = careers.value[0].id
    }
  } catch (e) {
    console.error('加载职业失败:', e)
  }
})

function selectCareer(id) {
  if (selectedId.value === id) return
  selectedId.value = id
  emit('select', id)
}
</script>

<style scoped>
.career-selector {
  position: absolute;
  right: 24px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.career-btn {
  padding: 10px 16px;
  background: rgba(0, 0, 0, 0.65);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  color: #aaa;
  font-size: 13px;
  cursor: pointer;
  backdrop-filter: blur(8px);
  transition: all 0.3s;
  text-align: left;
  min-width: 130px;
  font-family: inherit;
}
.career-btn:hover:not(:disabled) {
  background: rgba(0, 212, 255, 0.12);
  border-color: rgba(0, 212, 255, 0.3);
  color: white;
}
.career-btn.active {
  background: rgba(0, 212, 255, 0.18);
  border-color: #00d4ff;
  color: #00d4ff;
}
.career-btn:disabled {
  cursor: not-allowed;
}
.badge {
  font-size: 10px;
  background: rgba(255, 255, 255, 0.08);
  padding: 2px 12px;
  border-radius: 20px;
  margin-left: 8px;
}
.badge.coming { color: #ffaa44; }
.badge.active-badge { color: #00ff88; }
</style>