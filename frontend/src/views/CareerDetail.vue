<template>
  <div class="detail-page" v-if="career">
    <!-- ===== 顶部导航 ===== -->
    <header class="detail-header">
      <div class="header-title">
        <span class="header-icon">{{ career.icon || '💼' }}</span>
        <h1>{{ career.name }}</h1>
        <span class="header-status" :class="career.status === 'active' ? 'status-active' : 'status-coming'">
          {{ career.status === 'active' ? '✅ 可体验' : '⏳ 即将上线' }}
        </span>
      </div>
      <button class="btn-back" @click="goBack">
        ← 返回职业平台
      </button>
    </header>

    <!-- ===== 主体 ===== -->
    <main class="detail-body">
      <!-- 左栏：职业信息 -->
      <div class="detail-main">
        <!-- 简介 -->
        <section class="info-section">
          <h2>📖 职业简介</h2>
          <p class="info-desc">{{ career.description }}</p>
          <div class="info-meta">
            <span>🏢 场景数：{{ career.totalScenes || 0 }}</span>
            <span>🎨 主题色：<span class="color-dot" :style="{ background: career.themeColor || '#00d4ff' }"></span></span>
          </div>
        </section>

        <!-- 工作场景 -->
        <section class="scene-section" v-if="career.totalScenes > 0">
          <h2>🏢 工作场景</h2>
          <div class="scene-list">
            <div
                v-for="(scene, idx) in sceneList"
                :key="scene.id"
                class="scene-item"
                @click="goToScene(scene.id)"
            >
              <div class="scene-order">{{ idx + 1 }}</div>
              <div class="scene-info">
                <h4>{{ scene.sceneName }}</h4>
                <p>{{ scene.sceneSubtitle }}</p>
              </div>
              <span class="scene-arrow">→</span>
            </div>
          </div>
          <p v-if="sceneList.length === 0" class="loading-text">加载场景中...</p>
        </section>
        <!-- 成长路线 -->
        <section class="growth-section" v-if="growthPath && growthPath.length > 0">
          <h2>📈 成长路线</h2>
          <div class="growth-path">
            <template v-for="(item, idx) in growthPath" :key="idx">
              <div class="growth-item">
                <span class="growth-level">{{ item.level }}</span>
                <span class="growth-desc">{{ item.desc }}</span>
              </div>
              <div v-if="idx < growthPath.length - 1" class="growth-arrow">↓</div>
            </template>
          </div>
        </section>
      </div>

      <!-- ===== 右栏：体验入口 ===== -->
      <aside class="detail-sidebar">
        <div class="action-card" v-if="career.status === 'active'">
          <div class="action-icon">🚀</div>
          <h3>开始沉浸式体验</h3>
          <p>进入 3D 职场场景，<br>真实感受该职业的日常工作</p>
          <button class="btn-experience" @click="goToExperience">
            立即体验 →
          </button>
        </div>

        <div class="action-card coming" v-else>
          <div class="action-icon">⏳</div>
          <h3>即将上线</h3>
          <p>该职业的 3D 体验场景<br>正在精心筹备中</p>
          <button class="btn-coming" disabled>敬请期待</button>
        </div>
      </aside>
    </main>
  </div>

  <!-- 加载状态 -->
  <div v-else class="loading-page">
    <div class="loading-spinner">⏳</div>
    <p>加载中...</p>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApi } from '../composables/useApi'

const route = useRoute()
const router = useRouter()
const { getCareers, getScenes, getQuests } = useApi()

const career = ref(null)
const sceneList = ref([])
const tasks = ref([])
const allCareers = ref([])

const careerId = computed(() => parseInt(route.params.id))

// 解析成长路线
const growthPath = computed(() => {
  if (!career.value?.growthPath) return []
  try {
    return typeof career.value.growthPath === 'string'
        ? JSON.parse(career.value.growthPath)
        : career.value.growthPath
  } catch {
    return []
  }
})

async function loadData() {
  try {
    const careers = await getCareers()
    allCareers.value = careers || []

    const current = allCareers.value.find(c => c.id === careerId.value)
    if (current) {
      career.value = current
    }

    const scenes = await getScenes(careerId.value)
    sceneList.value = scenes || []

    if (sceneList.value.length > 0) {
      const quests = await getQuests(sceneList.value[0].id)
      tasks.value = quests || []
    }
  } catch (error) {
    console.error('加载职业详情失败:', error)
  }
}

function goBack() {
  router.push('/')
}

function goToScene(sceneId) {
  router.push(`/experience?scene=${sceneId}`)
}

function goToExperience() {
  router.push('/experience')
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
/* ===== 整体布局 ===== */
.detail-page {
  width: 100vw;
  min-height: 100vh;
  background: linear-gradient(160deg, #0a0a1a 0%, #0d0d2b 50%, #0a0a1a 100%);
  color: #fff;
  padding: 0 32px 40px;
  font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif;
  overflow-y: auto;
}
.detail-page::-webkit-scrollbar {
  width: 4px;
}
.detail-page::-webkit-scrollbar-thumb {
  background: rgba(0, 212, 255, 0.2);
  border-radius: 4px;
}

/* ===== 顶部导航 ===== */
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  position: sticky;
  top: 0;
  background: rgba(10, 10, 26, 0.85);
  backdrop-filter: blur(12px);
  z-index: 10;
}
.btn-back {
  padding: 8px 22px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 30px;
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s;
  font-family: inherit;
  white-space: nowrap;
}
.btn-back:hover {
  background: rgba(0, 212, 255, 0.06);
  color: #fff;
  border-color: rgba(0, 212, 255, 0.1);
}
.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}
.header-icon {
  font-size: 32px;
}
.header-title h1 {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
}
.header-status {
  font-size: 12px;
  padding: 3px 14px;
  border-radius: 20px;
}
.status-active {
  color: #00ff88;
  background: rgba(0, 255, 136, 0.08);
  border: 1px solid rgba(0, 255, 136, 0.1);
}
.status-coming {
  color: #ffaa44;
  background: rgba(255, 170, 68, 0.08);
  border: 1px solid rgba(255, 170, 68, 0.1);
}

/* ===== 主体 ===== */
.detail-body {
  display: flex;
  gap: 32px;
  margin-top: 24px;
  align-items: flex-start;
}

.detail-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 28px;
}

section h2 {
  font-size: 17px;
  font-weight: 600;
  color: #00d4ff;
  margin-bottom: 12px;
  letter-spacing: 1px;
}

/* ===== 简介 ===== */
.info-desc {
  font-size: 15px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.7);
  max-width: 700px;
}
.info-meta {
  display: flex;
  gap: 24px;
  margin-top: 10px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
}
.color-dot {
  display: inline-block;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  vertical-align: middle;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

/* ===== 场景列表 ===== */
.scene-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.scene-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.04);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
}
.scene-item:hover {
  background: rgba(0, 212, 255, 0.04);
  border-color: rgba(0, 212, 255, 0.1);
  transform: translateX(4px);
}
.scene-order {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 212, 255, 0.06);
  border-radius: 50%;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
  flex-shrink: 0;
}
.scene-info {
  flex: 1;
}
.scene-info h4 {
  font-size: 14px;
  color: #fff;
  font-weight: 500;
}
.scene-info p {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
}
.scene-arrow {
  color: rgba(255, 255, 255, 0.2);
  font-size: 18px;
}

/* ===== 成长路线 ===== */
.growth-path {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}
.growth-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 20px;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.04);
  border-radius: 10px;
  min-width: 100px;
}
.growth-level {
  font-size: 14px;
  font-weight: 600;
  color: #00d4ff;
}
.growth-desc {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.4);
  text-align: center;
  margin-top: 4px;
}
.growth-arrow {
  color: rgba(255, 255, 255, 0.1);
  font-size: 20px;
}

/* ===== 右侧边栏 ===== */
.detail-sidebar {
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  position: sticky;
  top: 80px;
}

.action-card {
  background: linear-gradient(145deg, rgba(0, 212, 255, 0.04), rgba(0, 102, 255, 0.04));
  border: 1px solid rgba(0, 212, 255, 0.12);
  border-radius: 16px;
  padding: 24px 20px;
  text-align: center;
}
.action-card.coming {
  opacity: 0.5;
}
.action-icon {
  font-size: 40px;
  margin-bottom: 8px;
}
.action-card h3 {
  font-size: 18px;
  color: #fff;
  margin-bottom: 4px;
}
.action-card p {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.4);
  line-height: 1.5;
  margin-bottom: 16px;
}
.btn-experience {
  width: 100%;
  padding: 12px 0;
  background: linear-gradient(135deg, #00d4ff, #0066ff);
  border: none;
  border-radius: 10px;
  color: #0a0a1a;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s;
  font-family: inherit;
}
.btn-experience:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 40px rgba(0, 212, 255, 0.25);
}
.btn-coming {
  width: 100%;
  padding: 12px 0;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 10px;
  color: rgba(255, 255, 255, 0.2);
  font-size: 15px;
  cursor: not-allowed;
  font-family: inherit;
}

/* ===== 加载状态 ===== */
.loading-page {
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #0a0a1a;
  color: #fff;
}
.loading-spinner {
  font-size: 48px;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.loading-page p {
  color: rgba(255, 255, 255, 0.3);
  margin-top: 12px;
}

/* ===== 响应式 ===== */
@media (max-width: 1024px) {
  .detail-sidebar {
    width: 220px;
  }
}
@media (max-width: 768px) {
  .detail-page {
    padding: 0 16px 24px;
  }
  .detail-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }
  .header-title {
    justify-content: center;
  }
  .btn-back {
    align-self: center;
    width: 100%;
    text-align: center;
  }
  .detail-body {
    flex-direction: column;
  }
  .detail-sidebar {
    width: 100%;
    position: static;
  }
  .growth-path {
    flex-direction: column;
    align-items: stretch;
  }
  .growth-arrow {
    transform: rotate(90deg);
    text-align: center;
  }
  .growth-item {
    min-width: unset;
  }
}
</style>