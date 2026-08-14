<template>
  <div class="landing-page" :class="{ hidden: isHidden }">
    <!-- 背景粒子 -->
    <canvas ref="particleCanvas" class="particle-canvas"></canvas>

    <!-- 主内容 -->
    <div class="landing-content">
      <!-- Logo -->
      <div class="landing-logo">
        <span class="logo-icon">⚡</span>
        <span class="logo-text">极客科技</span>
      </div>

      <!-- 主标题 -->
      <h1 class="landing-title">
        全职业沉浸式科普平台
        <span class="title-sub">—— 探索真实职场 · 让职业选择更清晰</span>
      </h1>

      <!-- 描述 -->
      <p class="landing-desc">
        本平台致力于构建<span class="highlight">真实虚拟工作场景</span>，
        覆盖 <span class="highlight">IT、金融、医疗、教育、法律、艺术</span> 等 <span class="highlight">十大行业</span>，<br>
        通过沉浸式 3D 技术，让你 <span class="highlight">深度了解</span> 目标职业的 <span class="highlight">工作任务、日常流程、技能要求</span> 及 <span class="highlight">完整成长路线</span>，<br>
        为你的职业选择提供 <span class="highlight">真实、直观、有温度</span> 的参考依据。
      </p>

      <!-- 三大核心板块 -->
      <div class="landing-features">
        <div class="feature-card">
          <div class="feature-icon">🏢</div>
          <h3>真实工作场景</h3>
          <p>基于 WebGL 构建的 3D 职场环境，<br>还原各行业真实工作流程与职场氛围，<br>让你身临其境感受职业日常。</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">📚</div>
          <h3>完整职业认知</h3>
          <p>深入了解职业的工作任务、<br>核心技能要求、团队协作模式、<br>行业现状与发展趋势，建立立体职业认知。</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">📈</div>
          <h3>清晰成长路线</h3>
          <p><strong>横向发展：</strong>跨领域技能拓展与多元路径<br>
            <strong>纵向发展：</strong>职业阶梯晋升与核心能力跃迁<br>
            为你的职业规划提供清晰方向。</p>
        </div>
      </div>

      <!-- 行业标签 -->
      <div class="industry-tags">
        <span>💻 信息技术</span>
        <span>🏦 金融</span>
        <span>🏥 医疗健康</span>
        <span>📚 教育</span>
        <span>⚖️ 法律</span>
        <span>🎨 艺术设计</span>
        <span>📱 市场营销</span>
        <span>🏗️ 工程建筑</span>
        <span>🎤 传媒新闻</span>
        <span>🏨 服务管理</span>
      </div>

      <!-- 进入按钮 -->
      <button class="btn-enter" @click="enterExperience">
        开始探索 →
      </button>

      <!-- 底部提示 -->
      <p class="landing-footer">
        🖱️ 浏览职业 · 点击详情 · 3D 沉浸式体验
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'

const emit = defineEmits(['enter'])

const isHidden = ref(false)
const particleCanvas = ref(null)
let ctx = null
let particles = []
let animationId = null
let canvasWidth = 0
let canvasHeight = 0

// --- 粒子背景 ---
function resizeCanvas() {
  if (!particleCanvas.value) return
  const canvas = particleCanvas.value
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  canvasWidth = canvas.width
  canvasHeight = canvas.height
  createParticles()
}

function createParticles() {
  const count = Math.min(80, Math.floor((canvasWidth * canvasHeight) / 15000))
  particles = []
  for (let i = 0; i < count; i++) {
    particles.push({
      x: Math.random() * canvasWidth,
      y: Math.random() * canvasHeight,
      size: Math.random() * 2 + 0.5,
      speedX: (Math.random() - 0.5) * 0.3,
      speedY: (Math.random() - 0.5) * 0.3,
      opacity: Math.random() * 0.5 + 0.2
    })
  }
}

function drawParticles() {
  if (!ctx) return
  ctx.clearRect(0, 0, canvasWidth, canvasHeight)

  particles.forEach(p => {
    p.x += p.speedX
    p.y += p.speedY

    if (p.x < 0 || p.x > canvasWidth) p.speedX *= -1
    if (p.y < 0 || p.y > canvasHeight) p.speedY *= -1

    ctx.beginPath()
    ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2)
    ctx.fillStyle = `rgba(0, 212, 255, ${p.opacity})`
    ctx.fill()
  })

  // 连线
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x
      const dy = particles[i].y - particles[j].y
      const dist = Math.sqrt(dx * dx + dy * dy)
      if (dist < 150) {
        ctx.beginPath()
        ctx.moveTo(particles[i].x, particles[i].y)
        ctx.lineTo(particles[j].x, particles[j].y)
        ctx.strokeStyle = `rgba(0, 212, 255, ${0.08 * (1 - dist / 150)})`
        ctx.lineWidth = 0.5
        ctx.stroke()
      }
    }
  }

  animationId = requestAnimationFrame(drawParticles)
}

function startParticles() {
  const canvas = particleCanvas.value
  if (!canvas) return
  ctx = canvas.getContext('2d')
  resizeCanvas()
  drawParticles()
}

function stopParticles() {
  if (animationId) {
    cancelAnimationFrame(animationId)
    animationId = null
  }
}

// --- 进入按钮 ---
function enterExperience() {
  isHidden.value = true
  stopParticles()
  setTimeout(() => {
    emit('enter')
  }, 800)
}

// --- 生命周期 ---
onMounted(() => {
  nextTick(() => {
    startParticles()
    window.addEventListener('resize', resizeCanvas)
  })
})

onBeforeUnmount(() => {
  stopParticles()
  window.removeEventListener('resize', resizeCanvas)
})
</script>

<style scoped>
.landing-page {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 9999;
  background: linear-gradient(160deg, #06061a 0%, #0a0a2e 40%, #0d0d3a 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Microsoft YaHei', 'PingFang SC', sans-serif;
  transition: opacity 0.8s ease, transform 0.8s ease;
  overflow: hidden;
}
.landing-page.hidden {
  opacity: 0;
  transform: scale(1.05);
  pointer-events: none;
}

.particle-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.landing-content {
  position: relative;
  z-index: 1;
  max-width: 1100px;
  width: 92%;
  padding: 40px 32px;
  text-align: center;
  color: #fff;
}

.landing-logo {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  background: rgba(0, 212, 255, 0.06);
  padding: 8px 24px 8px 16px;
  border-radius: 60px;
  border: 1px solid rgba(0, 212, 255, 0.1);
  backdrop-filter: blur(4px);
}
.logo-icon {
  font-size: 28px;
}
.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: #00d4ff;
  letter-spacing: 2px;
}

.landing-title {
  font-size: 42px;
  font-weight: 700;
  margin-bottom: 8px;
  background: linear-gradient(135deg, #ffffff 0%, #88ddff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  letter-spacing: 2px;
}
.title-sub {
  display: block;
  font-size: 20px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.5);
  -webkit-text-fill-color: rgba(255, 255, 255, 0.5);
  margin-top: 4px;
  letter-spacing: 4px;
}

.landing-desc {
  font-size: 16px;
  line-height: 1.8;
  color: rgba(255, 255, 255, 0.75);
  max-width: 820px;
  margin: 16px auto 28px;
  padding: 0 8px;
}
.landing-desc .highlight {
  color: #00d4ff;
  font-weight: 600;
  -webkit-text-fill-color: #00d4ff;
}

.landing-features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin: 20px 0 24px;
}
.feature-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 16px;
  padding: 22px 18px 18px;
  transition: all 0.3s ease;
  backdrop-filter: blur(8px);
}
.feature-card:hover {
  transform: translateY(-4px);
  border-color: rgba(0, 212, 255, 0.2);
  box-shadow: 0 12px 40px rgba(0, 212, 255, 0.05);
}
.feature-icon {
  font-size: 34px;
  margin-bottom: 6px;
}
.feature-card h3 {
  font-size: 17px;
  font-weight: 600;
  color: #00d4ff;
  margin-bottom: 6px;
  letter-spacing: 1px;
}
.feature-card p {
  font-size: 13px;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.55);
}
.feature-card p strong {
  color: rgba(255, 255, 255, 0.85);
}

.industry-tags {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
  margin: 8px 0 20px;
}
.industry-tags span {
  padding: 4px 14px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 20px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
  letter-spacing: 0.5px;
  transition: all 0.3s;
}
.industry-tags span:hover {
  background: rgba(0, 212, 255, 0.04);
  border-color: rgba(0, 212, 255, 0.1);
  color: rgba(255, 255, 255, 0.7);
}

.btn-enter {
  padding: 16px 60px;
  font-size: 18px;
  font-weight: 700;
  color: #0a0a1a;
  background: linear-gradient(135deg, #00d4ff, #0066ff);
  border: none;
  border-radius: 60px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 40px rgba(0, 212, 255, 0.25);
  font-family: inherit;
  letter-spacing: 2px;
}
.btn-enter:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 60px rgba(0, 212, 255, 0.35);
}
.btn-enter:active {
  transform: translateY(0) scale(0.98);
}

.landing-footer {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.2);
  margin-top: 18px;
  letter-spacing: 1px;
}

/* 响应式 */
@media (max-width: 768px) {
  .landing-title {
    font-size: 28px;
  }
  .title-sub {
    font-size: 16px;
  }
  .landing-features {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  .landing-desc {
    font-size: 14px;
  }
  .btn-enter {
    padding: 14px 40px;
    font-size: 16px;
  }
  .landing-content {
    padding: 24px 16px;
  }
  .industry-tags span {
    font-size: 11px;
    padding: 3px 10px;
  }
}
@media (max-width: 480px) {
  .landing-title {
    font-size: 22px;
  }
  .title-sub {
    font-size: 13px;
  }
  .feature-card {
    padding: 16px;
  }
  .feature-card h3 {
    font-size: 15px;
  }
  .btn-enter {
    padding: 12px 32px;
    font-size: 14px;
  }
}
</style>