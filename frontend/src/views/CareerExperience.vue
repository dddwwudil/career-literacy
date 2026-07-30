<template>
  <div class="experience-container">
    <ThreeScene ref="threeSceneRef" @scene-ready="onSceneReady" @interact="onInteract" />
    <SceneIndicator :scene-name="currentSceneName" :scene-time="currentSceneTime" />
    <TaskPanel
        v-model:visible="taskVisible"
        :task="currentTask"
        :current-index="currentTaskIndex"
        :total-tasks="quests.length"
        :total-score="currentSceneScore"
        :has-more="currentTaskIndex < quests.length - 1"
        :locked="isSceneLocked"
        @complete="onTaskComplete"
        @answer="onAnswer"
    />
    <SceneNavigator
        :current-index="currentSceneIndex"
        :total="totalScenes"
        @prev="goPrevScene"
        @next="goNextScene"
    />
    <StatusBar :status="statusMessage" :type="statusType" />
    <ControlsHint />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'  // 🔥 新增：用于解析 URL 参数
import ThreeScene from '../components/ThreeScene.vue'
import SceneIndicator from '../components/SceneIndicator.vue'
import TaskPanel from '../components/TaskPanel.vue'
import SceneNavigator from '../components/SceneNavigator.vue'
import StatusBar from '../components/StatusBar.vue'
import ControlsHint from '../components/ControlsHint.vue'
import { useApi } from '../composables/useApi'

const route = useRoute()  // 🔥 新增
const { getScenes, getQuests } = useApi()

const threeSceneRef = ref(null)
const sceneList = ref([])
const currentSceneIndex = ref(0)
const currentSceneName = ref('加载中...')
const currentSceneTime = ref('')
const currentTask = ref(null)
const currentTaskIndex = ref(0)
const quests = ref([])
const taskVisible = ref(false)
const totalScenes = ref(0)

const currentSceneScore = ref(0)
const totalScoreAll = ref(0)

const sceneAnswered = ref({})
const sceneCompleted = ref({})
const sceneScoreRecord = ref({})

const isSceneLocked = ref(false)
const statusMessage = ref('🔗 正在连接后端 API ...')
const statusType = ref('info')

// 调试监听
watch(taskVisible, (newVal) => {
  console.log('🔍 taskVisible 变化:', newVal)
})

watch(currentTask, (newVal) => {
  console.log('🔍 currentTask 变化:', newVal?.title || 'null')
})

async function onSceneReady() {
  console.log('✅ 场景准备就绪')
  await loadScenes(5)
}

async function loadScenes(careerId) {
  console.log('📡 开始加载场景, careerId:', careerId)
  try {
    const data = await getScenes(careerId)
    console.log('📋 场景数据:', data)

    if (data && data.length > 0) {
      sceneList.value = data
      totalScenes.value = data.length
      sceneAnswered.value = {}
      sceneCompleted.value = {}
      sceneScoreRecord.value = {}
      totalScoreAll.value = 0

      // 🔥🔥🔥 核心修改：从 URL 解析 scene 参数，跳转到指定场景
      const targetSceneId = parseInt(route.query.scene)
      console.log('🎯 URL 中的场景 ID:', targetSceneId)

      let targetIndex = 0
      if (targetSceneId) {
        const foundIndex = data.findIndex(s => s.id === targetSceneId)
        if (foundIndex !== -1) {
          targetIndex = foundIndex
          console.log('✅ 找到目标场景, 索引:', targetIndex, '名称:', data[targetIndex].sceneName)
        } else {
          console.warn('⚠️ 未找到场景 ID:', targetSceneId, '，使用第一个场景')
        }
      }

      await loadScene(targetIndex)
      statusMessage.value = '✅ 已连接后端'
      statusType.value = 'success'
    } else {
      console.warn('⚠️ 没有场景数据')
      statusMessage.value = '❌ 没有场景数据'
      statusType.value = 'error'
    }
  } catch (e) {
    console.error('❌ 加载场景失败:', e)
    statusMessage.value = '❌ 加载场景失败'
    statusType.value = 'error'
  }
}

async function loadScene(index) {
  const sceneData = sceneList.value[index]
  if (!sceneData) {
    console.warn('⚠️ sceneData 为空')
    return
  }

  const sceneId = sceneData.id
  console.log(`📂 加载场景: ${sceneData.sceneName} (ID: ${sceneId})`)

  currentSceneIndex.value = index
  currentSceneName.value = sceneData.sceneName
  currentSceneTime.value = sceneData.sceneSubtitle || ''
  statusMessage.value = `📂 加载 ${sceneData.sceneName}...`
  statusType.value = 'info'

  if (threeSceneRef.value) {
    console.log('🔄 调用 threeSceneRef.switchScene')
    threeSceneRef.value.switchScene(sceneData)
  } else {
    console.warn('⚠️ threeSceneRef 尚未初始化')
  }

  const isAnswered = sceneAnswered.value[sceneId] || false
  const isCompleted = sceneCompleted.value[sceneId] || false

  if (isAnswered || isCompleted) {
    isSceneLocked.value = true
    currentSceneScore.value = sceneScoreRecord.value[sceneId] || 0
    taskVisible.value = false
    const status = isCompleted ? '✅ 已完成' : '📌 已答题'
    statusMessage.value = `${status} ${sceneData.sceneName} (得分: ${currentSceneScore.value})`
    statusType.value = 'success'
    console.log(`🔒 场景已锁定: ${status}`)
    return
  }

  isSceneLocked.value = false
  currentSceneScore.value = 0

  try {
    console.log(`📡 获取任务, sceneId: ${sceneId}`)
    const data = await getQuests(sceneId)
    console.log('📋 任务数据:', data)

    quests.value = data || []
    currentTaskIndex.value = 0

    if (quests.value.length > 0) {
      currentTask.value = quests.value[0]
      taskVisible.value = false  // 默认隐藏任务面板，靠近NPC按F键才显示
      console.log('✅ 任务已设置, 标题:', currentTask.value.title)
      console.log('✅ taskVisible:', taskVisible.value)
      statusMessage.value = `� ${sceneData.sceneName} - 找到工作人员按 F 键开始任务`
      statusType.value = 'info'
    } else {
      console.warn('⚠️ 没有任务数据')
      taskVisible.value = false
      statusMessage.value = `📋 ${sceneData.sceneName} - 暂无任务`
      statusType.value = 'info'
    }
  } catch (e) {
    console.error('❌ 加载任务失败:', e)
    statusMessage.value = `❌ 加载任务失败`
    statusType.value = 'error'
  }
}

function onAnswer(data) {
  const sceneId = sceneList.value[currentSceneIndex.value]?.id
  if (!sceneId) {
    console.warn('⚠️ 没有场景ID，忽略答题')
    return
  }

  if (sceneAnswered.value[sceneId] || sceneCompleted.value[sceneId]) {
    console.warn('⚠️ 场景已答题或已完成，忽略')
    return
  }

  console.log('📊 答题结果:', data)

  if (data.isCorrect) {
    currentSceneScore.value += 1
    totalScoreAll.value += 1
  }
  sceneScoreRecord.value[sceneId] = currentSceneScore.value

  sceneAnswered.value[sceneId] = true
  isSceneLocked.value = true

  statusMessage.value = `📌 已答题，点击"完成实习"结束本场景`
  statusType.value = 'info'
}

function onInteract(data) {
  console.log('🤝 触发NPC交互:', data)
  if (!isSceneLocked.value && quests.value.length > 0) {
    taskVisible.value = true
    statusMessage.value = `📋 ${currentSceneName.value} - 任务 ${currentTaskIndex.value + 1}/${quests.value.length}`
    statusType.value = 'info'
  }
}

function onTaskComplete() {
  const sceneId = sceneList.value[currentSceneIndex.value]?.id
  if (!sceneId) return

  if (!sceneCompleted.value[sceneId]) {
    sceneCompleted.value[sceneId] = true
    sceneScoreRecord.value[sceneId] = currentSceneScore.value
  }
  isSceneLocked.value = true
  taskVisible.value = false

  statusMessage.value = `✅ ${sceneList.value[currentSceneIndex.value].sceneName} 完成！得分: ${currentSceneScore.value}`
  statusType.value = 'success'
}

function goPrevScene() {
  if (currentSceneIndex.value > 0) loadScene(currentSceneIndex.value - 1)
}

function goNextScene() {
  if (currentSceneIndex.value < sceneList.value.length - 1) loadScene(currentSceneIndex.value + 1)
}

defineExpose({ loadScenes })
</script>

<style scoped>
.experience-container {
  width: 100vw;
  height: 100vh;
  position: relative;
  overflow: hidden;
}
</style>
