<template>
  <div class="home-page">
    <!-- ===== 顶部：Logo + 搜索 ===== -->
    <header class="home-header">
      <div class="header-left">
        <span class="logo-icon">⚡</span>
        <span class="logo-text">极客科技 · 全职业科普平台</span>
      </div>
      <div class="header-right">
        <div class="search-box">
          <span class="search-icon">🔍</span>
          <input
              type="text"
              v-model="searchQuery"
              placeholder="搜索职业、行业、关键词..."
              class="search-input"
          />
        </div>
      </div>
    </header>

    <!-- ===== 导航栏：行业分类 ===== -->
    <nav class="category-nav">
      <button
          v-for="cat in categories"
          :key="cat.key"
          class="category-btn"
          :class="{ active: activeCategory === cat.key }"
          @click="activeCategory = cat.key"
      >
        {{ cat.icon }} {{ cat.name }}
      </button>
    </nav>

    <!-- ===== 主体 ===== -->
    <div class="home-body">
      <main class="career-grid-wrap">
        <div class="grid-header">
          <h2>{{ activeCategoryLabel }}</h2>
          <span class="grid-count">{{ filteredCareers.length }} 个职业</span>
        </div>

        <div class="career-grid">
          <div
              v-for="career in filteredCareers"
              :key="career.id"
              class="career-card"
              @click="showCareerDetail(career)"
          >
            <div class="card-icon">{{ career.icon || '💼' }}</div>
            <h3 class="card-name">{{ career.name }}</h3>
            <p class="card-desc">{{ career.description }}</p>
            <div class="card-footer">
              <span class="card-status" :class="career.status === 'active' ? 'status-active' : 'status-coming'">
                {{ career.status === 'active' ? '✅ 可体验' : '⏳ 即将上线' }}
              </span>
              <span v-if="career.total_scenes > 0" class="card-scenes">
                🏢 {{ career.total_scenes }} 个场景
              </span>
            </div>
          </div>
        </div>

        <div v-if="filteredCareers.length === 0" class="empty-state">
          <span class="empty-icon">🔍</span>
          <p>未找到匹配的职业，试试其他关键词</p>
        </div>
      </main>

      <!-- 🔥 右侧已删除 -->
    </div>

    <!-- ===== 底部 ===== -->
    <footer class="home-footer">
      <p>© 2026 极客科技 · 全职业科普平台 &nbsp;|&nbsp; 让职业选择更清晰</p>
    </footer>
  </div>
</template>

<script setup>
import {ref, computed, onMounted} from 'vue'
import {useRouter} from 'vue-router'
import {useApi} from '../composables/useApi'

const router = useRouter()
const {getCareers} = useApi()

// ===== 数据 =====
const careers = ref([])
const searchQuery = ref('')
const activeCategory = ref('all')

// ===== 行业分类（全职业覆盖） =====
const categories = [
  {key: 'all', name: '全部', icon: '📋'},
  {key: 'it', name: '信息技术', icon: '💻'},
  {key: 'finance', name: '金融', icon: '🏦'},
  {key: 'medical', name: '医疗健康', icon: '🏥'},
  {key: 'education', name: '教育', icon: '📚'},
  {key: 'law', name: '法律', icon: '⚖️'},
  {key: 'art', name: '艺术设计', icon: '🎨'},
  {key: 'marketing', name: '市场营销', icon: '📱'},
  {key: 'engineering', name: '工程建筑', icon: '🏗️'},
  {key: 'media', name: '传媒新闻', icon: '🎤'},
  {key: 'service', name: '服务管理', icon: '🏨'},
]

// ===== 分类关键词映射 =====
const categoryMap = {
  it: ['后端开发', '前端开发', '运维', '数据分析', 'AI', '机器学习', '网络安全', '移动开发', '云计算', '区块链'],
  finance: ['银行', '证券', '保险', '投资', '风控', '财务'],
  medical: ['医生', '护理', '药剂', '公共卫生', '医疗影像'],
  education: ['教师', '教育管理', '教育技术', '课程设计'],
  law: ['律师', '法务', '知识产权'],
  art: ['平面设计', 'UI', 'UX', '插画', '动画'],
  marketing: ['品牌', '数字营销', '市场分析'],
  engineering: ['土木', '电气', '机械', '建筑'],
  media: ['新闻', '新媒体', '视频编导'],
  service: ['酒店', '旅游', '餐饮', '人力资源', '项目管理'],
}

// ===== 计算属性 =====
const activeCategoryLabel = computed(() => {
  const cat = categories.find(c => c.key === activeCategory.value)
  return cat ? cat.icon + ' ' + cat.name : '全部职业'
})

const filteredCareers = computed(() => {
  let result = careers.value

  if (activeCategory.value !== 'all') {
    const keywords = categoryMap[activeCategory.value] || []
    result = result.filter(c =>
        keywords.some(kw => c.name.includes(kw))
    )
  }

  if (searchQuery.value.trim()) {
    const query = searchQuery.value.trim().toLowerCase()
    result = result.filter(c =>
        c.name.includes(query) ||
        c.description?.toLowerCase().includes(query)
    )
  }

  return result
})

// ===== 方法 =====
async function loadCareers() {
  try {
    const data = await getCareers()
    careers.value = data || []
  } catch (error) {
    console.error('加载职业数据失败:', error)
  }
}

function showCareerDetail(career) {
  router.push(`/career/${career.id}`)
}

function goTo3DExperience() {
  router.push('/experience')
}

onMounted(() => {
  loadCareers()
})
</script>

<style scoped>
/* ===== 整体布局 ===== */
.home-page {
  width: 100vw;
  height: 100vh;
  background: linear-gradient(160deg, #0a0a1a 0%, #0d0d2b 50%, #0a0a1a 100%);
  color: #fff;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif;
}

/* ===== 顶部 ===== */
.home-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 32px;
  background: rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  font-size: 26px;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: #00d4ff;
  letter-spacing: 1px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.search-box {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 30px;
  padding: 5px 16px;
  transition: all 0.3s;
}

.search-box:focus-within {
  border-color: rgba(0, 212, 255, 0.3);
  box-shadow: 0 0 20px rgba(0, 212, 255, 0.04);
}

.search-icon {
  font-size: 14px;
  opacity: 0.5;
  margin-right: 8px;
}

.search-input {
  background: none;
  border: none;
  outline: none;
  color: #fff;
  font-size: 13px;
  padding: 6px 0;
  width: 200px;
  font-family: inherit;
}

.search-input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

/* ===== 导航栏 ===== */
.category-nav {
  display: flex;
  gap: 4px;
  padding: 10px 32px;
  background: rgba(255, 255, 255, 0.01);
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  flex-shrink: 0;
  overflow-x: auto;
  flex-wrap: nowrap;
}

.category-nav::-webkit-scrollbar {
  height: 2px;
}

.category-nav::-webkit-scrollbar-thumb {
  background: rgba(0, 212, 255, 0.2);
  border-radius: 2px;
}

.category-btn {
  padding: 5px 14px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 18px;
  color: rgba(255, 255, 255, 0.5);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s;
  white-space: nowrap;
  font-family: inherit;
}

.category-btn:hover {
  background: rgba(0, 212, 255, 0.06);
  color: #fff;
}

.category-btn.active {
  background: rgba(0, 212, 255, 0.12);
  border-color: rgba(0, 212, 255, 0.25);
  color: #00d4ff;
}

/* ===== 主体 ===== */
.home-body {
  flex: 1;
  display: flex;
  gap: 24px;
  padding: 16px 32px 12px;
  overflow: hidden;
}

/* ===== 左侧：职业网格 ===== */
.career-grid-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.grid-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  flex-shrink: 0;
}

.grid-header h2 {
  font-size: 17px;
  font-weight: 600;
  color: #fff;
}

.grid-count {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
}

.career-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 14px;
  overflow-y: auto;
  padding-bottom: 8px;
  flex: 1;
  align-content: start;
}

.career-grid::-webkit-scrollbar {
  width: 4px;
}

.career-grid::-webkit-scrollbar-thumb {
  background: rgba(0, 212, 255, 0.2);
  border-radius: 4px;
}

.career-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 16px 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.career-card:hover {
  transform: translateY(-3px);
  border-color: rgba(0, 212, 255, 0.2);
  background: rgba(255, 255, 255, 0.05);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.3);
}

.card-icon {
  font-size: 28px;
  margin-bottom: 6px;
}

.card-name {
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 4px;
}

.card-desc {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.45);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 34px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
  padding-top: 8px;
  border-top: 1px solid rgba(255, 255, 255, 0.04);
}

.card-status {
  font-size: 10px;
  padding: 2px 10px;
  border-radius: 12px;
}

.status-active {
  color: #00ff88;
  background: rgba(0, 255, 136, 0.08);
}

.status-coming {
  color: #ffaa44;
  background: rgba(255, 170, 68, 0.08);
}

.card-scenes {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.3);
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 40px 0;
  color: rgba(255, 255, 255, 0.3);
}

.empty-icon {
  font-size: 36px;
  display: block;
  margin-bottom: 8px;
}

/* ===== 🔥 右侧体验入口已删除 ===== */

/* ===== 底部 ===== */
.home-footer {
  padding: 10px 32px;
  text-align: center;
  border-top: 1px solid rgba(255, 255, 255, 0.03);
  flex-shrink: 0;
}

.home-footer p {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.12);
  letter-spacing: 1px;
}

/* ===== 响应式 ===== */
@media (max-width: 768px) {
  .home-header {
    flex-direction: column;
    gap: 10px;
    padding: 10px 16px;
  }

  .search-input {
    width: 120px;
  }

  .category-nav {
    padding: 6px 16px;
    gap: 4px;
  }

  .category-btn {
    font-size: 11px;
    padding: 4px 10px;
  }

  .home-body {
    flex-direction: column;
    padding: 10px 16px;
    gap: 14px;
  }

  .career-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }

  .home-footer p {
    font-size: 10px;
  }
}
</style>