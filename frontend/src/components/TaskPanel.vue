http://localhost:5177/<template>
  <Transition name="slide-up">
    <div v-if="visible && task" class="task-panel">
      <!-- 头部 -->
      <div class="task-header">
        <span class="progress">📋 任务 {{ currentIndex + 1 }}/{{ totalTasks }}</span>
        <span class="score">⭐ 得分: {{ totalScore }}</span>
        <span v-if="locked" class="locked-badge">🔒 已答题</span>
      </div>

      <div class="npc-name">👤 {{ task.npcName || '导师王工' }}</div>
      <div class="task-title">{{ task.title }}</div>
      <div class="task-desc">{{ task.description }}</div>

      <!-- 选项 -->
      <div class="options">
        <button
            v-for="(opt, idx) in optionsList"
            :key="idx"
            @click="handleAnswer(idx)"
            :class="{
              correct: (answered || locked) && idx === task.correctIndex,
              wrong: (answered || locked) && idx === selectedIndex && idx !== task.correctIndex,
              disabled: answered || locked,
              selected: (answered || locked) && idx === selectedIndex
            }"
            :disabled="answered || locked"
        >
          <span class="option-letter">{{ String.fromCharCode(65 + idx) }}.</span>
          {{ opt }}
          <span v-if="(answered || locked) && idx === task.correctIndex" class="check-mark"> ✅</span>
          <span v-if="(answered || locked) && idx === selectedIndex && idx !== task.correctIndex" class="wrong-mark"> ❌</span>
        </button>
      </div>

      <!-- 反馈区域 -->
      <div v-if="answered || locked" class="feedback" :class="isCorrect ? 'correct-feedback' : 'wrong-feedback'">
        <div class="feedback-icon">{{ isCorrect ? '✅' : '❌' }}</div>
        <div class="feedback-content">
          <div class="feedback-text">
            {{ isCorrect ? '🎉 回答正确！太棒了！' : '😅 回答错误，来看看解析吧！' }}
          </div>
          <div class="knowledge-point">
            <span class="label">📖 知识点：</span>
            {{ task.knowledgePoint }}
          </div>
          <div v-if="!isCorrect" class="correct-answer">
            💡 正确答案是 <strong>{{ String.fromCharCode(65 + task.correctIndex) }}</strong>
          </div>
          <div v-if="isCorrect" class="reward-text">
            {{ task.rewardText || '继续加油！' }}
          </div>
        </div>
      </div>

      <!-- 按钮 -->
      <button class="btn-next" :disabled="!answered" @click="onNext">
        {{ hasMore ? '下一题 →' : '🎉 完成实习' }}
      </button>
    </div>
  </Transition>

  <!-- ============================================================
  🎨 独立全屏总结弹窗（放在 task-panel 外面，用 fixed 定位）
  ============================================================ -->
  <Transition name="summary-overlay">
    <div v-if="showSummary" class="summary-overlay" @click.self="onSummaryConfirm">
      <div class="summary-modal">
        <button class="summary-close" @click="onSummaryConfirm">✕</button>

        <div class="summary-title">🎉 实习总结</div>

        <!-- 得分环 -->
        <div class="summary-score-ring">
          <svg viewBox="0 0 140 140" class="score-ring">
            <circle cx="70" cy="70" r="60" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="6"/>
            <circle
                cx="70" cy="70" r="60"
                fill="none"
                stroke="#ffd93d"
                stroke-width="6"
                stroke-linecap="round"
                :stroke-dasharray="376.99"
                :stroke-dashoffset="376.99 * (1 - (totalTasks > 0 ? totalScore / totalTasks : 0))"
                class="ring-progress"
            />
          </svg>
          <div class="score-number">
            {{ totalScore }}
            <span class="score-total">/{{ totalTasks }}</span>
          </div>
        </div>

        <!-- 星级 -->
        <div class="summary-stars">{{ summaryStars }}</div>

        <!-- 评价 -->
        <div class="summary-message">{{ summaryMessage }}</div>

        <!-- 详情 -->
        <div class="summary-detail">
          答对 <strong>{{ totalScore }}</strong> 题，共 {{ totalTasks }} 题
          <span class="detail-ratio">
            （{{ Math.round((totalTasks > 0 ? totalScore / totalTasks : 0) * 100) }}%）
          </span>
        </div>

        <!-- 鼓励语 -->
        <div class="summary-encourage">{{ summaryEncourage }}</div>

        <!-- 按钮 -->
        <button class="btn-summary" @click="onSummaryConfirm">
          🚀 继续探索
        </button>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  visible: Boolean,
  task: Object,
  currentIndex: { type: Number, default: 0 },
  totalTasks: { type: Number, default: 0 },
  totalScore: { type: Number, default: 0 },
  hasMore: { type: Boolean, default: true },
  locked: { type: Boolean, default: false }
})

const emit = defineEmits(['update:visible', 'complete', 'answer'])

const selectedIndex = ref(-1)
const answered = ref(false)
const showSummary = ref(false)

const optionsList = computed(() => JSON.parse(props.task?.options || '[]'))
const isCorrect = computed(() => {
  if (selectedIndex.value === -1) return false
  return selectedIndex.value === props.task?.correctIndex
})

watch(() => props.task, (newTask, oldTask) => {
  if (props.locked) return
  if (newTask?.id !== oldTask?.id) {
    selectedIndex.value = -1
    answered.value = false
    showSummary.value = false
  }
}, { immediate: true })

const summaryMessage = computed(() => {
  const score = props.totalScore
  const total = props.totalTasks
  const ratio = total > 0 ? score / total : 0
  if (ratio >= 0.9) return '🌟 卓越！你已经是后端开发小专家了！'
  if (ratio >= 0.75) return '👏 优秀！你对后端开发的理解非常到位！'
  if (ratio >= 0.6) return '👍 不错！继续加油，你会成为一名优秀的后端工程师！'
  if (ratio >= 0.4) return '📚 还可以多了解一些，后端开发的知识体系很丰富！'
  return '💪 别灰心，后端开发需要时间积累，多学多练！'
})

const summaryStars = computed(() => {
  const score = props.totalScore
  const total = props.totalTasks
  const ratio = total > 0 ? score / total : 0
  if (ratio >= 0.9) return '🌟🌟🌟🌟🌟'
  if (ratio >= 0.7) return '🌟🌟🌟🌟'
  if (ratio >= 0.5) return '🌟🌟🌟'
  if (ratio >= 0.3) return '🌟🌟'
  return '🌟'
})

const summaryEncourage = computed(() => {
  const score = props.totalScore
  const total = props.totalTasks
  const ratio = total > 0 ? score / total : 0
  if (ratio >= 0.9) return '你展现了出色的学习能力，继续保持！'
  if (ratio >= 0.7) return '基础扎实，再接再厉，未来可期！'
  if (ratio >= 0.5) return '每个知识点都是进步的阶梯！'
  if (ratio >= 0.3) return '每一次尝试都是学习，继续加油！'
  return '后端开发需要时间积累，多学多练！'
})

function handleAnswer(idx) {
  if (answered.value || props.locked) return
  selectedIndex.value = idx
  answered.value = true
  const isCorrectAns = idx === props.task.correctIndex
  emit('answer', {
    questId: props.task.id,
    selectedIndex: idx,
    isCorrect: isCorrectAns
  })
}

function onNext() {
  if (props.hasMore) {
    answered.value = false
    selectedIndex.value = -1
    emit('complete')
  } else {
    showSummary.value = true
  }
}

function onSummaryConfirm() {
  showSummary.value = false
  emit('update:visible', false)
  emit('complete')
}
</script>

<style scoped>
/* ===== 原有样式 ===== */
.slide-up-enter-active,
.slide-up-leave-active {
  transition: all 0.3s ease;
}
.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

.task-panel {
  position: absolute;
  left: 24px;
  bottom: 100px;
  z-index: 20;
  background: rgba(10, 10, 30, 0.92);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(0, 212, 255, 0.2);
  border-radius: 16px;
  padding: 20px 24px;
  max-width: 400px;
  width: 90%;
  color: white;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.8);
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  font-size: 13px;
}
.progress {
  color: rgba(255, 255, 255, 0.6);
}
.score {
  color: #ffd93d;
}
.locked-badge {
  color: #ffaa44;
  font-size: 11px;
  background: rgba(255, 170, 68, 0.15);
  padding: 2px 10px;
  border-radius: 12px;
  border: 1px solid rgba(255, 170, 68, 0.2);
}

.npc-name {
  color: #00d4ff;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 4px;
}
.task-title {
  font-size: 17px;
  font-weight: 600;
  margin-bottom: 6px;
}
.task-desc {
  font-size: 13px;
  opacity: 0.8;
  margin-bottom: 14px;
  line-height: 1.5;
}

.options {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.options button {
  padding: 10px 14px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  color: white;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.25s;
  text-align: left;
  font-family: inherit;
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
}
.options button:hover:not(.disabled) {
  background: rgba(0, 212, 255, 0.12);
  border-color: rgba(0, 212, 255, 0.3);
}
.options button .option-letter {
  color: rgba(255, 255, 255, 0.5);
  font-weight: 600;
  min-width: 24px;
}
.options button.correct {
  background: rgba(0, 255, 136, 0.15);
  border-color: #00ff88;
  color: #00ff88;
}
.options button.correct .option-letter {
  color: #00ff88;
}
.options button.wrong {
  background: rgba(255, 107, 107, 0.15);
  border-color: #ff6b6b;
  color: #ff6b6b;
}
.options button.wrong .option-letter {
  color: #ff6b6b;
}
.options button.selected {
  border-color: rgba(255, 255, 255, 0.3);
}
.options button.disabled {
  cursor: not-allowed;
  opacity: 0.85;
}
.check-mark {
  color: #00ff88;
  font-weight: bold;
}
.wrong-mark {
  color: #ff6b6b;
  font-weight: bold;
}

.feedback {
  margin-top: 14px;
  padding: 14px 16px;
  border-radius: 10px;
  display: flex;
  gap: 12px;
  align-items: flex-start;
  font-size: 13px;
  line-height: 1.6;
}
.feedback.correct-feedback {
  background: rgba(0, 255, 136, 0.08);
  border: 1px solid rgba(0, 255, 136, 0.2);
}
.feedback.wrong-feedback {
  background: rgba(255, 107, 107, 0.08);
  border: 1px solid rgba(255, 107, 107, 0.2);
}
.feedback-icon {
  font-size: 20px;
  flex-shrink: 0;
  margin-top: 2px;
}
.feedback-content {
  flex: 1;
}
.feedback-text {
  font-weight: 600;
  margin-bottom: 6px;
  font-size: 14px;
}
.knowledge-point {
  opacity: 0.9;
  margin-bottom: 4px;
}
.knowledge-point .label {
  color: #ffd93d;
}
.correct-answer {
  color: #ffd93d;
  font-size: 14px;
  margin-top: 4px;
  padding: 4px 10px;
  background: rgba(255, 217, 61, 0.08);
  border-radius: 6px;
  display: inline-block;
}
.reward-text {
  color: #00d4ff;
  font-style: italic;
  margin-top: 4px;
  font-size: 13px;
}

.btn-next {
  margin-top: 14px;
  padding: 10px 24px;
  background: #00d4ff;
  border: none;
  border-radius: 8px;
  color: #0a0a1a;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: opacity 0.2s;
  font-family: inherit;
  width: 100%;
}
.btn-next:hover:not(:disabled) {
  opacity: 0.8;
}
.btn-next:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* ============================================================
  🎨 独立全屏总结弹窗样式
============================================================ */

/* 遮罩层 */
.summary-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(10, 10, 30, 0.75);
  backdrop-filter: blur(16px);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 弹窗主体 */
.summary-modal {
  position: relative;
  background: linear-gradient(160deg, #0d0d2b, #1a1a3e);
  border-radius: 32px;
  padding: 40px 48px 36px;
  width: 420px;
  max-width: 92vw;
  border: 1px solid rgba(0, 212, 255, 0.12);
  box-shadow: 0 40px 100px rgba(0, 0, 0, 0.7), 0 0 80px rgba(0, 212, 255, 0.04);
  text-align: center;
}

/* 关闭按钮 */
.summary-close {
  position: absolute;
  top: 12px;
  right: 16px;
  background: none;
  border: none;
  color: rgba(255, 255, 255, 0.3);
  font-size: 20px;
  cursor: pointer;
  transition: color 0.2s;
  font-family: inherit;
}
.summary-close:hover {
  color: rgba(255, 255, 255, 0.7);
}

/* 标题 */
.summary-title {
  font-size: 28px;
  font-weight: 700;
  background: linear-gradient(135deg, #ffd93d, #ff6b6b);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  letter-spacing: 2px;
  margin-bottom: 8px;
}

/* 得分环 */
.summary-score-ring {
  position: relative;
  width: 160px;
  height: 160px;
  margin: 12px auto 12px;
}
.score-ring {
  transform: rotate(-90deg);
}
.ring-progress {
  transition: stroke-dashoffset 1.5s cubic-bezier(0.4, 0, 0.2, 1);
}
.summary-score-ring .score-number {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 44px;
  font-weight: 800;
  color: #fff;
  letter-spacing: 1px;
}
.summary-score-ring .score-number .score-total {
  font-size: 20px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.3);
}

/* 星星 */
.summary-stars {
  font-size: 34px;
  letter-spacing: 6px;
  margin: 4px 0 10px;
  text-shadow: 0 0 40px rgba(255, 217, 61, 0.2);
}

/* 评价消息 */
.summary-message {
  font-size: 18px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.92);
  margin-bottom: 4px;
}

/* 详情 */
.summary-detail {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.4);
  margin-bottom: 2px;
}
.summary-detail strong {
  color: #ffd93d;
  font-weight: 600;
}
.summary-detail .detail-ratio {
  color: #ffd93d;
  font-weight: 600;
}

/* 鼓励语 */
.summary-encourage {
  font-size: 15px;
  color: rgba(255, 255, 255, 0.5);
  font-style: italic;
  margin: 10px 0 18px;
}

/* 按钮 */
.btn-summary {
  padding: 12px 48px;
  background: linear-gradient(135deg, #00d4ff, #0066ff);
  border: none;
  border-radius: 14px;
  color: #fff;
  font-size: 17px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 30px rgba(0, 212, 255, 0.25);
  font-family: inherit;
  letter-spacing: 0.5px;
}
.btn-summary:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 45px rgba(0, 212, 255, 0.35);
}
.btn-summary:active {
  transform: translateY(0);
}

/* 过渡动画 */
.summary-overlay-enter-active,
.summary-overlay-leave-active {
  transition: all 0.4s ease;
}
.summary-overlay-enter-from,
.summary-overlay-leave-to {
  opacity: 0;
}
.summary-overlay-enter-from .summary-modal,
.summary-overlay-leave-to .summary-modal {
  transform: scale(0.92) translateY(20px);
  opacity: 0;
}
.summary-overlay-enter-to .summary-modal,
.summary-overlay-leave-from .summary-modal {
  transform: scale(1) translateY(0);
  opacity: 1;
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
</style>