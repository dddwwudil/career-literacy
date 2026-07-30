<template>
  <div ref="containerRef" class="three-container">
    <div ref="overlayRef" class="scene-overlay"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import * as THREE from 'three'
import { CSS2DRenderer, CSS2DObject } from 'three/addons/renderers/CSS2DRenderer.js'
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js'
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'
import { TextureLoader, RepeatWrapping } from 'three'

const containerRef = ref(null)
const overlayRef = ref(null)
const emit = defineEmits(['scene-ready', 'interact'])

// ===== 核心变量 =====
let scene, camera, renderer, labelRenderer
let sceneObjects, player, playerMixer
let orbitAngle = 0
let orbitPitch = 0.5
let targetOrbitAngle = 0
let targetOrbitPitch = 0.5
let isDragging = false
let prevMouse = { x: 0, y: 0 }
const keys = { w: false, a: false, s: false, d: false, f: false }
const playerSpeed = 4.5
let isTransitioning = false
let cameraTargetPos = new THREE.Vector3(4, 2.5, 6)
let currentAnim = 'idle'
let modelAnimations = []
let playerGroup = null
let currentSceneId = null
let roomBounds = { minX: -3.5, maxX: 3.5, minZ: -2.5, maxZ: 2.5 }

// ===== F 键交互状态 =====
let interactNpc = null
let interactHintLabel = null
let canInteract = false
const INTERACT_DISTANCE = 2.0

// ===== 碰撞检测系统 =====
// 存储场景中的碰撞体（桌椅等家具）
let collisionBoxes = []
// 玩家碰撞半径（减小到0.2，给玩家更多移动空间）
const PLAYER_RADIUS = 0.2
// GLB模型碰撞体缩放系数，0.6表示只保留模型包围盒60%的大小
// 这样可以只碰撞桌子主体，椅子等次要部分可以穿模
const GLB_COLLISION_SCALE = 0.6

// 添加碰撞体（长方体）
function addCollisionBox(x, z, width, depth) {
  collisionBoxes.push({
    x, z,
    halfWidth: width / 2,
    halfDepth: depth / 2
  })
}

// 检测点是否与碰撞体碰撞
function checkCollision(x, z) {
  for (const box of collisionBoxes) {
    if (Math.abs(x - box.x) < box.halfWidth + PLAYER_RADIUS &&
        Math.abs(z - box.z) < box.halfDepth + PLAYER_RADIUS) {
      return true
    }
  }
  return false
}

// 检测移动是否会碰撞，如果会则返回修正后的移动向量
function applyCollisionMove(startX, startZ, moveX, moveZ) {
  const targetX = startX + moveX
  const targetZ = startZ + moveZ
  
  // 先检测目标位置是否碰撞
  if (!checkCollision(targetX, targetZ)) {
    return { x: moveX, z: moveZ, collided: false }
  }
  
  // 如果碰撞，尝试只沿X轴移动
  if (!checkCollision(targetX, startZ)) {
    return { x: moveX, z: 0, collided: true }
  }
  
  // 如果碰撞，尝试只沿Z轴移动
  if (!checkCollision(startX, targetZ)) {
    return { x: 0, z: moveZ, collided: true }
  }
  
  // 完全碰撞，无法移动
  return { x: 0, z: 0, collided: true }
}

// ===== 工具：清理场景 =====
function clearSceneObjects() {
  scene.remove(sceneObjects)
  sceneObjects.traverse((child) => {
    if (child.isCSS2DObject && child.element) {
      child.element.remove()
    }
  })
  sceneObjects = new THREE.Group()
  scene.add(sceneObjects)
  interactNpc = null
  interactHintLabel = null
  canInteract = false
  // 清空碰撞体数组
  collisionBoxes = []
}

// ============================================================
// 通用家具构建工具函数（避免重复代码）
// ============================================================
// 墙体
function addWall(w, h, d, x, y, z, color = 0xf5f5f5) {
  const texLoader = new TextureLoader()
  const wallTex = texLoader.load('/textures/qiang.jpg')
  wallTex.wrapS = RepeatWrapping
  wallTex.wrapT = RepeatWrapping
  wallTex.repeat.set(8, 4)

  const wall = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({
      color,
      map: wallTex,
      roughness: 0.8
    })
  )
  wall.position.set(x, y, z)
  wall.receiveShadow = true
  sceneObjects.add(wall)
  return wall
}
// 地板
function addFloor(w, d, x, z, color = 0xffffff) {
  const texLoader = new TextureLoader()
  const floorTex = texLoader.load('/textures/di.jpeg')
  floorTex.wrapS = RepeatWrapping
  floorTex.wrapT = RepeatWrapping
  floorTex.repeat.set(12, 9)

  const floor = new THREE.Mesh(
    new THREE.BoxGeometry(w, 0.05, d),
    new THREE.MeshStandardMaterial({
      color,
      map: floorTex,
      roughness: 0.9,
      metalness: 0.1
    })
  )
  floor.position.set(x, -0.025, z)
  floor.receiveShadow = true
  sceneObjects.add(floor)
  return floor
}
// 天花板
function addCeiling(w, d, x, z, color = 0xffffff) {
  const texLoader = new THREE.TextureLoader()
  const ceilTex = texLoader.load('/textures/ceiling.png')
  ceilTex.wrapS = THREE.RepeatWrapping
  ceilTex.wrapT = THREE.RepeatWrapping
  ceilTex.repeat.set(8, 4)

  const ceil = new THREE.Mesh(
    new THREE.BoxGeometry(w, 0.05, d),
    new THREE.MeshStandardMaterial({
      color,
      map: ceilTex,
      roughness: 0.95
    })
  )
  ceil.position.set(x, 2.95, z)
  ceil.receiveShadow = true
  sceneObjects.add(ceil)
  return ceil
}

// 门贴图面板
function addDoorPanel(w, h, d, x, y, z, color = 0xffffff) {
  const texLoader = new THREE.TextureLoader()
  const doorTex = texLoader.load('/textures/door.png')
  doorTex.wrapS = THREE.ClampToEdgeWrapping
  doorTex.wrapT = THREE.ClampToEdgeWrapping

  const panel = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({
      color,
      map: doorTex,
      roughness: 0.8
    })
  )
  panel.position.set(x, y, z)
  panel.receiveShadow = true
  scene.add(panel)

  sceneObjects.add(panel)

  return panel
}

// 场景三专用大门面板 door2.png
function addDoorPanel2(w, h, d, x, y, z, color = 0xffffff) {
  const texLoader = new THREE.TextureLoader()
  const doorTex = texLoader.load('/textures/door2.png')
  doorTex.wrapS = THREE.ClampToEdgeWrapping
  doorTex.wrapT = THREE.ClampToEdgeWrapping

  const panel = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({
      color,
      map: doorTex,
      roughness: 0.8
    })
  )
  panel.position.set(x, y, z)
  panel.receiveShadow = true
  sceneObjects.add(panel)
  return panel
}



function addMonitor(x, y, z, screenColor = 0x00d4ff, glowIntensity = 0.6) {
  const group = new THREE.Group()
  // 屏幕主体（边框）
  const screenFrame = new THREE.Mesh(
    new THREE.BoxGeometry(0.7, 0.42, 0.04),
    new THREE.MeshStandardMaterial({ color: 0x111122, roughness: 0.4, metalness: 0.7 })
  )
  group.add(screenFrame)
  // 屏幕画面
  const screen = new THREE.Mesh(
    new THREE.PlaneGeometry(0.62, 0.36),
    new THREE.MeshStandardMaterial({
      color: screenColor,
      emissive: screenColor,
      emissiveIntensity: glowIntensity,
      roughness: 0.2
    })
  )
  screen.position.z = 0.022
  group.add(screen)
  // 底座杆
  const stand = new THREE.Mesh(
    new THREE.CylinderGeometry(0.04, 0.08, 0.18, 6),
    new THREE.MeshStandardMaterial({ color: 0x222233, metalness: 0.6 })
  )
  stand.position.y = -0.32
  group.add(stand)
  // 底座盘
  const base = new THREE.Mesh(
    new THREE.BoxGeometry(0.2, 0.02, 0.15),
    new THREE.MeshStandardMaterial({ color: 0x222233, metalness: 0.6 })
  )
  base.position.y = -0.42
  group.add(base)

  group.position.set(x, y, z)
  sceneObjects.add(group)
  return group
}

function addKeyboard(x, y, z) {
  const kb = new THREE.Mesh(
    new THREE.BoxGeometry(0.5, 0.02, 0.15),
    new THREE.MeshStandardMaterial({ color: 0x111122, roughness: 0.6 })
  )
  kb.position.set(x, y, z)
  sceneObjects.add(kb)
  // 键帽点缀
  const dotMat = new THREE.MeshBasicMaterial({ color: 0x4488ff })
  for (let i = -0.2; i <= 0.2; i += 0.06) {
    for (let j = -0.04; j <= 0.04; j += 0.04) {
      const dot = new THREE.Mesh(new THREE.BoxGeometry(0.04, 0.01, 0.03), dotMat)
      dot.position.set(x + i, y + 0.015, z + j)
      sceneObjects.add(dot)
    }
  }
  return kb
}

function addMouse(x, y, z) {
  const mouse = new THREE.Mesh(
    new THREE.BoxGeometry(0.06, 0.025, 0.1),
    new THREE.MeshStandardMaterial({ color: 0x111122, roughness: 0.5 })
  )
  mouse.position.set(x, y, z)
  sceneObjects.add(mouse)
  return mouse
}

function addCoffeeCup(x, y, z) {
  const cup = new THREE.Mesh(
    new THREE.CylinderGeometry(0.04, 0.035, 0.08, 12),
    new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.4 })
  )
  cup.position.set(x, y, z)
  sceneObjects.add(cup)
  const coffee = new THREE.Mesh(
    new THREE.CylinderGeometry(0.035, 0.035, 0.01, 12),
    new THREE.MeshStandardMaterial({ color: 0x3a2010, roughness: 0.2 })
  )
  coffee.position.set(x, y + 0.04, z)
  sceneObjects.add(coffee)
  return cup
}

function addPlant(x, z) {
  const pot = new THREE.Mesh(
    new THREE.CylinderGeometry(0.15, 0.12, 0.25, 8),
    new THREE.MeshStandardMaterial({ color: 0x6a3a20, roughness: 0.7 })
  )
  pot.position.set(x, 0.125, z)
  pot.castShadow = true
  sceneObjects.add(pot)
  // 叶子
  for (let i = 0; i < 5; i++) {
    const leaf = new THREE.Mesh(
      new THREE.SphereGeometry(0.12, 6, 6),
      new THREE.MeshStandardMaterial({ color: 0x2a8a3a, roughness: 0.7 })
    )
    leaf.position.set(
      x + (Math.random() - 0.5) * 0.2,
      0.35 + Math.random() * 0.15,
      z + (Math.random() - 0.5) * 0.2
    )
    leaf.castShadow = true
    sceneObjects.add(leaf)
  }
}

function addWhiteboard(x, y, z, w = 1.8, h = 1.0) {
  const board = new THREE.Mesh(
    new THREE.BoxGeometry(w, h, 0.05),
    new THREE.MeshStandardMaterial({ color: 0xeeeeee, roughness: 0.4 })
  )
  board.position.set(x, y, z)
  sceneObjects.add(board)
  // 写字感（青色线条）
  const lineMat = new THREE.MeshBasicMaterial({ color: 0x003366 })
  for (let i = 0; i < 8; i++) {
    const line = new THREE.Mesh(
      new THREE.BoxGeometry(w * 0.7, 0.01, 0.01),
      lineMat
    )
    line.position.set(x, y - h * 0.35 + i * 0.08, z + 0.03)
    sceneObjects.add(line)
  }
  return board
}

// 通用 NPC 构造（参数化）
function createNPC({
  x = 0, z = 0, color = 0x2a4a7a, name = 'NPC', labelColor = '#88ddff',
  borderColor = 'rgba(0,212,255,0.15)', interactive = false, npcId = null,
  facing = 0,
  // 加载GLB模型
  useGLB = false,
  glbUrl = "",
  modelScale = 1 // GLB模型缩放，太大太小在这里调
} = {}) {

  // ========== 使用外部GLB人物模型 ==========
  if (useGLB && glbUrl) {
    const npc = new THREE.Group();
    npc.position.set(x, 0, z);
    npc.rotation.y = facing;
    sceneObjects.add(npc);

    // 加载GLB
    const gltfLoader = new GLTFLoader();
    gltfLoader.load(glbUrl, (gltf) => {
      const model = gltf.scene;
      // 缩放模型，根据人物高矮微调 modelScale
      model.scale.set(modelScale, modelScale, modelScale);
      model.position.y = 0;
      model.castShadow = true;
      npc.add(model);
    }, undefined, (err) => {
      console.error("GLB模型加载失败：", err);
    });

    // ---------- 挂载头顶名字标签----------
    const labelDiv = document.createElement('div')
    labelDiv.textContent = name
    labelDiv.style.cssText = `color:${labelColor};font-size:14px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(0,0,0,0.5);padding:2px 12px;border-radius:20px;border:1px solid ${borderColor};backdrop-filter:blur(4px);letter-spacing:1px;text-shadow:0 0 20px rgba(0,0,0,0.9),0 0 10px rgba(0,0,0,0.8)`
    const label = new CSS2DObject(labelDiv)
    // GLB模型更高，标签往上抬到2.3，不合适自己改成2.0/2.5
    label.position.set(0, 2.3, 0)
    npc.add(label)

    // ---------- 挂载F交谈交互提示 ----------
    if (interactive) {
      const hintDiv = document.createElement('div')
      hintDiv.textContent = '▶ 按 F 交谈'
      hintDiv.style.cssText = 'color:#00ff88;font-size:12px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(0,40,20,0.85);padding:3px 10px;border-radius:14px;border:1px solid rgba(0,255,136,0.5);backdrop-filter:blur(4px);box-shadow:0 0 20px rgba(0,255,136,0.4);display:none;'
      const hint = new CSS2DObject(hintDiv)
      hint.position.set(0, 2.55, 0)
      npc.add(hint)
      interactHintLabel = hint
      interactNpc = npc
      if (npcId !== null) {
        npc.userData.npcId = npcId
      }
    }

    return npc;
  }

  // ========== 原有默认圆柱+圆球简易小人（不走GLB时执行） ==========
  const npc = new THREE.Group()
  npc.position.set(x, 0, z)
  npc.rotation.y = facing
  sceneObjects.add(npc)

  const body = new THREE.Mesh(
    new THREE.CylinderGeometry(0.22, 0.28, 0.5, 10),
    new THREE.MeshStandardMaterial({ color, roughness: 0.5 })
  )
  body.position.y = 0.65
  body.castShadow = true
  npc.add(body)

  const head = new THREE.Mesh(
    new THREE.SphereGeometry(0.18, 12, 12),
    new THREE.MeshStandardMaterial({ color: 0xffddbb, roughness: 0.6 })
  )
  head.position.y = 1.05
  head.castShadow = true
  npc.add(head)

  // 名字标签
  const labelDiv = document.createElement('div')
  labelDiv.textContent = name
  labelDiv.style.cssText = `color:${labelColor};font-size:14px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(0,0,0,0.5);padding:2px 12px;border-radius:20px;border:1px solid ${borderColor};backdrop-filter:blur(4px);letter-spacing:1px;text-shadow:0 0 20px rgba(0,0,0,0.9),0 0 10px rgba(0,0,0,0.8)`
  const label = new CSS2DObject(labelDiv)
  label.position.set(0, 1.5, 0)
  npc.add(label)

  // 交互提示气泡（默认隐藏）
  if (interactive) {
    const hintDiv = document.createElement('div')
    hintDiv.textContent = '▶ 按 F 交谈'
    hintDiv.style.cssText = 'color:#00ff88;font-size:12px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(0,40,20,0.85);padding:3px 10px;border-radius:14px;border:1px solid rgba(0,255,136,0.5);backdrop-filter:blur(4px);box-shadow:0 0 20px rgba(0,255,136,0.4);display:none;'
    const hint = new CSS2DObject(hintDiv)
    hint.position.set(0, 1.75, 0)
    npc.add(hint)
    interactHintLabel = hint
    interactNpc = npc
    if (npcId !== null) {
      npc.userData.npcId = npcId
    }
  }

  return npc
}



function addScreenParticle(color = 0x44ff88, count = 200, area = { x: 4, y: 2.5, z: 3 }) {
  const geo = new THREE.BufferGeometry()
  const pos = new Float32Array(count * 3)
  for (let i = 0; i < count; i++) {
    pos[i * 3] = (Math.random() - 0.5) * area.x
    pos[i * 3 + 1] = Math.random() * area.y + 0.2
    pos[i * 3 + 2] = (Math.random() - 0.5) * area.z
  }
  geo.setAttribute('position', new THREE.BufferAttribute(pos, 3))
  const mat = new THREE.PointsMaterial({
    color, size: 0.015, transparent: true, opacity: 0.4,
    blending: THREE.AdditiveBlending
  })
  const points = new THREE.Points(geo, mat)
  sceneObjects.add(points)
  return points
}

// ============================================================
// 场景1：后端工程师工作室（替换原 buildReception）
// ============================================================
function buildBackendStudio() {
  console.log('🏢 构建后端工程师工作室...')
  clearSceneObjects()
  currentSceneId = 1
  roomBounds = { minX: -11.0, maxX: 11.0, minZ: -8.0, maxZ: 8.0 }

  // 房间：24m × 18m × 3m 高
  addFloor(24, 18, 0, 0)
  addCeiling(24, 18, 0, 0)
  // 四面墙
  addWall(24, 3, 0.1, 0, 1.5, -9)      // 后墙
  addWall(0.1, 3, 18, -12, 1.5, 0)     // 左墙
  addWall(0.1, 3, 18, 12, 1.5, 0)      // 右墙
// 前墙整面墙体
addWall(24, 3, 0.1, 0, 1.5, 9)
// 中间8米大门贴图面板，厚度0.11
addDoorPanel(8, 3, 0.11, 0, 1.5, 9)

//地板与墙面贴图



  // === 工程师 NPC（坐姿面向屏幕，可交互） ===
  // 改用person_man.glb模型替换王工
 createNPC({
  x: -6.7, 
  z: 0, 
  name: '👤 王工',
  labelColor: '#88ddff', 
  borderColor: 'rgba(0,212,255,0.2)',
  interactive: true, 
  npcId: 1, 
  facing: Math.PI,

  // 启用GLB模型
  useGLB: true,
  glbUrl: "/models/person_man.glb",
  modelScale: 0.8  // 模型偏大就改成0.8，偏小改成1.2
})


  // =====================================================================

  // === 白板（左侧墙边） ===
  addWhiteboard(-11.8, 1.6, 0, 1.6, 1.0)
  const chairMat = new THREE.MeshStandardMaterial({ color: 0x3a4a5a })
  const chair = new THREE.Mesh(new THREE.CylinderGeometry(0.22, 0.25, 0.08, 10), chairMat)
  chair.position.set(-10.5, 0.4, 0)
  chair.castShadow = true
  sceneObjects.add(chair)
  const backrest = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.4, 0.4), chairMat)
  backrest.position.set(-10.28, 0.6, 0)
  sceneObjects.add(backrest)

    // === 加载自定义GLB模型-右侧 ===
// 新起变量名 gltfLoader10
const gltfLoader10 = new GLTFLoader()
// 路径文件名对应 Untitled_10.glb
gltfLoader10.load('/models/Untitled_10.glb', (gltf) => {
  const model = gltf.scene
  model.position.set(18.0, 0, -2.2)
  model.scale.set(1, 1, 1)
  model.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true
      child.receiveShadow = true
      if (child.material) {
        child.material.roughness = 0.6
        child.material.metalness = 0.2
      }
    }
  })
  sceneObjects.add(model)
  
  // ===== 自动添加碰撞体 =====
  // 根据模型实际包围盒添加碰撞体（使用包围盒中心点，支持旋转模型）
  const box = new THREE.Box3().setFromObject(model)
  const center = new THREE.Vector3()
  box.getCenter(center)
  const size = new THREE.Vector3()
  box.getSize(size)
  console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
  addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
},(err)=>console.error(err))


const gltfLoader10_2 = new GLTFLoader()
// 路径文件名对应 Untitled_10.glb
gltfLoader10_2.load('/models/Untitled_10.glb', (gltf) => {
  const model = gltf.scene
  model.position.set(18.0, 0, 1.5)
  model.scale.set(1, 1, 1)
  model.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true
      child.receiveShadow = true
      if (child.material) {
        child.material.roughness = 0.6
        child.material.metalness = 0.2
      }
    }
  })
  sceneObjects.add(model)
  
  // ===== 自动添加碰撞体 =====
  // 关键：必须先更新世界矩阵，否则包围盒计算会使用过时的矩阵
  model.updateWorldMatrix(true, true)
  const box = new THREE.Box3().setFromObject(model)
  const center = new THREE.Vector3()
  box.getCenter(center)
  const size = new THREE.Vector3()
  box.getSize(size)
  console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
  addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
},(err)=>console.error(err))


  // === 绿植（角落） ===
  addPlant(-11.0, -8.5)
  addPlant(11.0, 8.5)
  addPlant(-11.0, 8.5)
  addPlant(11.0, -8.5)
  addPlant(0, -8.5)


  // === 加载自定义GLB模型——左侧===
  //启动GLTFLoader加载器，加载自定义Untitled.glb模型
  const gltfLoader = new GLTFLoader()
  gltfLoader.load('/models/Untitled.glb', (gltf) => {
    const model = gltf.scene
    model.position.set(0, 0, 0)
    model.scale.set(1, 1, 1)
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
        if (child.material) {
          child.material.roughness = 0.6
          child.material.metalness = 0.2
        }
      }
    })
    sceneObjects.add(model)
    console.log('✅ 自定义GLB模型加载完成！')
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, undefined, (error) => {
    console.error('❌ GLB模型加载失败:', error)
  })

  // === 后端氛围光 ===
  const screenLight = new THREE.PointLight(0x00d4ff, 0.8, 10)
  screenLight.position.set(0, 1.4, -6.2)
  sceneObjects.add(screenLight)
  const screenLight2 = new THREE.PointLight(0x44ff88, 0.6, 8)
  screenLight2.position.set(9.0, 1.4, -5.2)
  sceneObjects.add(screenLight2)
  const screenLight3 = new THREE.PointLight(0xaa66ff, 0.6, 8)
  screenLight3.position.set(-9.0, 1.4, -5.2)
  sceneObjects.add(screenLight3)
  const screenLight4 = new THREE.PointLight(0xffdd44, 0.6, 8)
  screenLight4.position.set(8.0, 1.4, 3.2)
  sceneObjects.add(screenLight4)
  const screenLight5 = new THREE.PointLight(0x44ffff, 0.6, 8)
  screenLight5.position.set(-8.0, 1.4, 3.2)
  sceneObjects.add(screenLight5)
  const lampLight = new THREE.PointLight(0xffaa66, 0.7, 6)
  lampLight.position.set(-0.7, 1.3, -5.7)
  sceneObjects.add(lampLight)
  const ambientLight = new THREE.PointLight(0x4466aa, 0.4, 20)
  ambientLight.position.set(0, 2, 0)
  sceneObjects.add(ambientLight)

  // // === 代码粒子氛围 ===
  // addScreenParticle(0x44ff88, 500, { x: 14, y: 2.5, z: 10 })

  // === 墙上贴纸（技术栈） ===
  const stickers = [
    { text: '☕ Java', color: 0xff8844, x: -9.0, y: 2.4, z: -8.9 },
    { text: '🍃 Spring', color: 0x44dd44, x: -6.0, y: 2.4, z: -8.9 },
    { text: '🐬 MySQL', color: 0x4477ff, x: -3.0, y: 2.4, z: -8.9 },
    { text: '🔴 Redis', color: 0xff4444, x: 0, y: 2.4, z: -8.9 },
    { text: '🐳 Docker', color: 0x44aaff, x: 3.0, y: 2.4, z: -8.9 },
    { text: '☸️ K8s', color: 0x3366ff, x: 6.0, y: 2.4, z: -8.9 },
    { text: '🐙 Git', color: 0xff4488, x: 9.0, y: 2.4, z: -8.9 }
  ]
  stickers.forEach(s => {
    const div = document.createElement('div')
    div.textContent = s.text
    const r = (s.color >> 16) & 255, g = (s.color >> 8) & 255, b = s.color & 255
    div.style.cssText = `color:#fff;font-size:14px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(${r},${g},${b},0.2);padding:3px 10px;border-radius:8px;border:1px solid rgba(255,255,255,0.2);`
    const obj = new CSS2DObject(div)
    obj.position.set(s.x, s.y, s.z)
    sceneObjects.add(obj)
  })

  // ===== 场景1碰撞体 =====
  // 白板椅子区域（缩小范围，只碰撞椅子底座）
  addCollisionBox(-10.5, 0, 0.4, 0.4)
  // GLB模型碰撞体由模型加载时自动添加，此处不再手动添加
  // 绿植碰撞体（代码创建的对象，保留手动碰撞体）
  addCollisionBox(-11.0, -8.5, 0.5, 0.5)
  addCollisionBox(11.0, 8.5, 0.5, 0.5)
  addCollisionBox(-11.0, 8.5, 0.5, 0.5)
  addCollisionBox(11.0, -8.5, 0.5, 0.5)
  addCollisionBox(0, -8.5, 0.5, 0.5)
  addCollisionBox(0, 8.5, 0.5, 0.5)

  // 玩家出生点：进门位置
  if (player) player.position.set(0, 0.1, 7.0)
  console.log('✅ 后端工程师工作室构建完成！')
}

// ============================================================
// 场景2：会议室·需求评审（增强版）
// ============================================================
function buildConferenceRoom() {
  console.log('🏢 构建会议室场景...')
  clearSceneObjects()
  currentSceneId = 2
  roomBounds = { minX: -6.5, maxX: 6.5, minZ: -4.5, maxZ: 4.5 }

  // 房间：14m × 10m × 3m
  addFloor(14, 10, 0, 0)
  addCeiling(14, 10, 0, 0)
  addWall(14, 3, 0.1, 0, 1.5, -5)
  addWall(0.1, 3, 10, -7, 1.5, 0)
  addWall(0.1, 3, 10, 7, 1.5, 0)
  addWall(14, 3, 0.1, 0, 1.5, 5)


// 加载自定义GLB模型——白板加会议
const gltfLoader19 = new GLTFLoader();
let whiteboardTexture = null;
let targetBoardMesh = null;

// 白板按键统一处理函数
function boardKeyHandle(e) {
  // 1. 不是E键 / 白板不存在 / 当前不是场景2 → 直接拦截
  if (e.key.toLowerCase() !== 'e' || !targetBoardMesh || currentSceneId !== 2) return;

  const interactRange = 15;
  // 只计算水平XZ平面距离，忽略上下高度差
  const playerPos = player.position.clone();
  const boardPos = targetBoardMesh.position.clone();
  playerPos.y = 0;
  boardPos.y = 0;
  const distance = playerPos.distanceTo(boardPos);

  // 超出10米范围拦截
  if (distance > interactRange) return;

  const inputText = prompt('输入白板文字 斜杠加n 换行：');
  if (!inputText) return;
  targetBoardMesh.material.map = genBoardTexture(inputText);
  targetBoardMesh.material.needsUpdate = true;
}
// 生成白板显示
function genBoardTexture(inputText) {
  const canvas = document.createElement('canvas');
  canvas.width = 1200;
  canvas.height = 700;
  const ctx = canvas.getContext('2d');

  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = '#222222';
  ctx.font = '30px Consolas,微软雅黑';
  ctx.textBaseline = 'top';

  const lineHeight = 42;
  // 把你输入的字面 \n 解析成换行
  const realText = inputText.replace(/\\n/g, '\n');
  const lines = realText.split('\n');
  lines.forEach((line, idx) => {
    ctx.fillText(line, 40, 30 + idx * lineHeight);
  });

  whiteboardTexture = new THREE.CanvasTexture(canvas);
  // UV坐标平移：把纹理左上角挪到模型UV左上角
  whiteboardTexture.offset.set(0,1);
  whiteboardTexture.repeat.set(1,-1);
  whiteboardTexture.needsUpdate = true;
  return whiteboardTexture;
}

gltfLoader19.load('/models/Untitled_19.glb', (gltf) => {
  const model = gltf.scene;
  model.position.set(14, 0, 1);
  model.scale.set(1, 1, 1);

  model.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = true;
      child.receiveShadow = true;
      // 匹配名称前缀「素白艺术」，兼容后缀 __suby_cn_1 这类变化
      if (child.name.includes('素白艺术')) {
        targetBoardMesh = child;
        console.log("✅成功找到白板Mesh", targetBoardMesh);
      }
      if (child.material) {
        child.material.roughness = 0.6;
        child.material.metalness = 0.2;
      }
    }
  });

  // 重点：先移除旧监听，再绑定新监听，防止重复叠加
  window.removeEventListener('keydown', boardKeyHandle);
  window.addEventListener('keydown', boardKeyHandle);

  sceneObjects.add(model);
  
  // ===== 自动添加碰撞体 =====
  // 关键：必须先更新世界矩阵，否则包围盒计算会使用过时的矩阵
  model.updateWorldMatrix(true, true)
  const box = new THREE.Box3().setFromObject(model)
  const center = new THREE.Vector3()
  box.getCenter(center)
  const size = new THREE.Vector3()
  box.getSize(size)
  console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
  addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)

},
// 加载进度空占位
()=>void(0),
// 加载错误捕获
(err) => console.error('模型加载失败：', err));


  // 白板（写满需求文档）
  addWhiteboard(-3.5, 1.6, -4.8, 3.5, 1.5)
  // 白板上的高亮红框（重点需求）
  const redBox = new THREE.Mesh(
    new THREE.BoxGeometry(0.5, 0.2, 0.02),
    new THREE.MeshBasicMaterial({ color: 0xff4488 })
  )
  redBox.position.set(-3.2, 1.8, -4.77)
  sceneObjects.add(redBox)

  // PM Lisa NPC（站姿，面向桌子，可交互）
  createNPC({
    x: -1.5, z: 1.5, color: 0xd44a6a, name: '👩\u200d💼 Lisa',
    labelColor: '#ff88aa', borderColor: 'rgba(255,136,170,0.2)',
    interactive: true, npcId: 2, facing: Math.PI ,
    useGLB: true,
    glbUrl: "/models/person_woman.glb",
    modelScale: 0.8
    
  })



  // 绿植（角落）
  addPlant(-6.0, -4.5)
  addPlant(6.0, 4.5)

  // 氛围光
  const warmLight = new THREE.PointLight(0xffaa66, 0.5, 8)
  warmLight.position.set(0, 2.5, 0)
  sceneObjects.add(warmLight)
  const ambientLight = new THREE.PointLight(0x4466aa, 0.3, 14)
  ambientLight.position.set(0, 2, 0)
  sceneObjects.add(ambientLight)

  addScreenParticle(0xff88aa, 250, { x: 10, y: 2.5, z: 8 })

  // ===== 场景2碰撞体 =====
  // 会议室桌子区域（缩小范围，只碰撞桌子主体）
  addCollisionBox(0, 0, 2.0, 1.0)
  // 白板区域（缩小范围）
  addCollisionBox(-3.5, -4.8, 1.5, 0.3)
  // 绿植碰撞体（代码创建的对象，保留手动碰撞体）
  addCollisionBox(-6.0, -4.5, 0.5, 0.5)
  addCollisionBox(6.0, 4.5, 0.5, 0.5)
  // GLB模型碰撞体由模型加载时自动添加，此处不再手动添加

  if (player) player.position.set(0, 0.1, 3.5)
  console.log('✅ 会议室场景构建完成！')
}

// ============================================================
// 场景3：工位·编码开发（增强版）
// ============================================================
function buildWorkstation() {
  console.log('🏢 构建工位场景...')
  clearSceneObjects()
  currentSceneId = 3
  roomBounds = { minX: -7.0, maxX: 7.0, minZ: -5.0, maxZ: 5.0 }

  // 房间：16m × 12m × 3m 墙体地板天花板全部保留
  addFloor(16, 12, 0, 0)
  addCeiling(16, 12, 0, 0)
  addWall(16, 3, 0.1, 0, 1.5, -6)
  addWall(0.1, 3, 12, -8, 1.5, 0)
  addWall(0.1, 3, 12, 8, 1.5, 0)

// 前墙完整铺满墙体
addWall(16, 3, 0.1, 0, 1.5, 6)
// 中间叠加 door2 大门面板，宽度6米，厚度0.11
addDoorPanel2(3, 2.8, 0.11, 0, 1.5, 6)
//addDoorPanel2(宽度, 高度, 厚度, x, y, z)

  // ========== 此处写入你的工位GLB加载代码（照搬会议室白板格式即可）==========
  
  const gltfLoaderWork = new GLTFLoader();
  gltfLoaderWork.load('/models/Untitled_16.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(11, 0, -7);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    // 以模型位置为中心，添加一个小范围碰撞体（1.5x1.5的小方块）
    addCollisionBox(model.position.x, model.position.z, 1.5, 1.5)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

//左下工作台
    const gltfLoaderWork1 = new GLTFLoader();
  gltfLoaderWork1.load('/models/Untitled_16_2.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(3, 0, -7);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    addCollisionBox(model.position.x, model.position.z, 1.5, 1.5)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

  //左下中作台
    const gltfLoaderWork2 = new GLTFLoader();
  gltfLoaderWork2.load('/models/Untitled_16_2.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(3, 0, -10);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    addCollisionBox(model.position.x, model.position.z, 1.5, 1.5)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))
  
  //左上工作台
    const gltfLoaderWork3 = new GLTFLoader();
  gltfLoaderWork3.load('/models/Untitled_16_2.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(3, 0, -13);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    addCollisionBox(model.position.x, model.position.z, 1.5, 1.5)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))
  
  // ==========================================================================

  // 王工 NPC 保留不动
  createNPC({
    x: 0, z: -3.0, color: 0x2a4a7a, name: '👨\u200d💻 王工',
    labelColor: '#88ddff', borderColor: 'rgba(0,212,255,0.2)',
    interactive: true, npcId: 3, facing: 0,
    //启动GLTFLoader加载器，加载自定义person_man.glb人物模型
    useGLB: true,
    glbUrl: "/models/person_man.glb",
    modelScale: 0.8
  })

  // 墙边白板、四周绿植 保留
  addWhiteboard(-7.8, 1.6, 0, 1.6, 1.0)
  addPlant(-7.0, 5.0)
  addPlant(7.0, -5.0)
  addPlant(-7.0, -5.0)
  addPlant(7.0, 5.0)

  // 环境光、粒子效果保留
  const ambientLight = new THREE.PointLight(0x4466aa, 0.3, 16)
  ambientLight.position.set(0, 2, 0)
  sceneObjects.add(ambientLight)
  addScreenParticle(0x44ff88, 500, { x: 10, y: 2.5, z: 8 })

  // ===== 场景3碰撞体 =====
  // 白板区域（缩小范围）
  addCollisionBox(-7.8, 0, 0.8, 0.3)
  // 绿植碰撞体（代码创建的对象，保留手动碰撞体）
  addCollisionBox(-7.0, 5.0, 0.5, 0.5)
  addCollisionBox(7.0, -5.0, 0.5, 0.5)
  addCollisionBox(-7.0, -5.0, 0.5, 0.5)
  addCollisionBox(7.0, 5.0, 0.5, 0.5)
  // 工作台碰撞体由GLB模型加载时自动添加，此处不再手动添加

  // 玩家出生点位不变
  if (player) player.position.set(0, 0.1, 4.0)
  console.log('✅ 工位场景构建完成！')
}

// ============================================================
// 场景4：联调区·对接测试（增强版）
// ============================================================
function buildIntegrationZone() {
  console.log('🏢 构建联调区场景...')
  clearSceneObjects()
  currentSceneId = 4
  roomBounds = { minX: -6.5, maxX: 6.5, minZ: -4.5, maxZ: 4.5 }

  // 房间：14m × 10m × 3m
  addFloor(14, 10, 0, 0)
  addCeiling(14, 10, 0, 0)
  addWall(14, 3, 0.1, 0, 1.5, -5)
  addWall(0.1, 3, 10, -7, 1.5, 0)
  addWall(0.1, 3, 10, 7, 1.5, 0)
  addWall(14, 3, 0.1, 0, 1.5, 5)


// 加载自定义GLB模型——工位桌椅
    const scene_qd_4 = new GLTFLoader();
  scene_qd_4.load('/models/Untitled14.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(4, 0, -8);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

      const scene_qd_4_2 = new GLTFLoader();
  scene_qd_4_2.load('/models/Untitled_8.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(10, 0, -8);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(50);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))


  // 小陈 NPC（左侧，面对玩家，可交互）
  createNPC({
    x: -1, z: 2, color: 0x44aa66, name: '🧪 小陈',
    labelColor: '#88ff88', borderColor: 'rgba(136,255,136,0.2)',
    interactive: true, npcId: 4, facing: 0.3,
        //启动GLTFLoader加载器，加载自定义person_woman_2.glb人物模型
    useGLB: true,
    glbUrl: "/models/person_woman_2.glb",
    modelScale: 0.8
  })
  // 前端同事 NPC（右侧，不可交互，背景）
  createNPC({
    x: 4.5, z: 2, color: 0xaa66dd, name: '💻 前端同事',
    labelColor: '#cc88ff', borderColor: 'rgba(204,136,255,0.2)',
    interactive: false, facing: -0.3,
    //启动GLTFLoader加载器，加载自定义person_woman_3.glb人物模型
    useGLB: true,
    glbUrl: "/models/person_woman_3.glb",
    modelScale: 0.8
  })

  // 绿植（角落）
  addPlant(-6.0, -4.5)
  addPlant(6.0, 4.5)

  // 氛围光
  const blueLight = new THREE.PointLight(0x00d4ff, 0.6, 6)
  blueLight.position.set(-0.8, 1.4, 0)
  sceneObjects.add(blueLight)
  const orangeLight = new THREE.PointLight(0xff8844, 0.6, 6)
  orangeLight.position.set(0.8, 1.4, 0)
  sceneObjects.add(orangeLight)
  const ambientLight = new THREE.PointLight(0x4466aa, 0.3, 14)
  ambientLight.position.set(0, 2, 0)
  sceneObjects.add(ambientLight)

  // ===== 场景4碰撞体 =====
  // 工位桌椅碰撞体由GLB模型加载时自动添加，此处不再手动添加
  // 绿植碰撞体（代码创建的对象，保留手动碰撞体）
  addCollisionBox(-6.0, -4.5, 0.5, 0.5)
  addCollisionBox(6.0, 4.5, 0.5, 0.5)

  if (player) player.position.set(0, 0.1, 3.5)
  console.log('✅ 联调区场景构建完成！')
}

// ============================================================
// 场景5：监控大屏·上线（增强版）
// ============================================================
function buildMonitoringRoom() {
  console.log('🏢 构建监控大屏场景...')
  clearSceneObjects()
  currentSceneId = 5
  roomBounds = { minX: -7.0, maxX: 7.0, minZ: -5.0, maxZ: 5.0 }

  // 房间：16m × 12m × 3m
  addFloor(16, 12, 0, 0)
  addCeiling(16, 12, 0, 0)
  addWall(16, 3, 0.1, 0, 1.5, -6)
  addWall(0.1, 3, 12, -8, 1.5, 0)
  addWall(0.1, 3, 12, 8, 1.5, 0)

  // 前墙完整铺满墙体
  addWall(16, 3, 0.1, 0, 1.5, 6)
// 中间叠加 door2 大门面板，宽度6米，厚度0.11
  addDoorPanel2(3, 2.8, 0.11, 0, 1.5, 6)
//addDoorPanel2(宽度, 高度, 厚度, x, y, z)


  //上线监控大屏
    const qd_5 = new GLTFLoader();
  qd_5.load('/models/qd_4.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(7, 0, -4);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(27);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

      const qd_5_1 = new GLTFLoader();
  qd_5_1.load('/models/qd_4.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(12, 0, 0);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(27);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

      const qd_5_2 = new GLTFLoader();
  qd_5_2.load('/models/qd_4.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(12, 0, -4);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(27);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

// 监控大屏,第一个屏幕
      const qd_5_screen = new GLTFLoader();
  qd_5_screen.load('/models/screen.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(2, 0.15, -6);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(40);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))

  // 监控大屏,第二个屏幕
      const qd_5_screen_2 = new GLTFLoader();
  qd_5_screen_2.load('/models/screen.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(2, 0.15, -10);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(40);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))
//主工作台
      const table_chair = new GLTFLoader();
  table_chair.load('/models/table_chair.glb', (gltf) => {
    const model = gltf.scene;
    model.position.set(7, 0, -11);  // 自行修改摆放坐标
    model.scale.set(1, 1, 1);     // 自行修改缩放大小
      // 绕Y轴（竖直轴）旋转90度（转成弧度），让模型和目标方向垂直
  model.rotation.y = THREE.MathUtils.degToRad(40);
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true;
        child.receiveShadow = true;
      }
    })
    sceneObjects.add(model);
    
    // ===== 自动添加碰撞体 =====
    model.updateWorldMatrix(true, true)
    const box = new THREE.Box3().setFromObject(model)
    const center = new THREE.Vector3()
    box.getCenter(center)
    const size = new THREE.Vector3()
    box.getSize(size)
    console.log('📦 GLB模型碰撞体: 中心=', center, '尺寸=', size)
    addCollisionBox(center.x, center.z, size.x * GLB_COLLISION_SCALE, size.z * GLB_COLLISION_SCALE)
  }, () => void 0, (err) => console.error('工位模型加载失败', err))


  // 运维大哥 NPC（站姿，可交互）
  createNPC({
    x: -4.4,y:1.4, z: -4, color: 0x445577, name: '🔧 运维大哥',
    labelColor: '#ffaa44', borderColor: 'rgba(255,170,68,0.2)',
    interactive: true, npcId: 5, facing: 0,
    //启动GLTFLoader加载器，加载自定义person_settingman.glb人物模型
    useGLB: true,
    glbUrl: "/models/person_settingman.glb",
    modelScale: 1.3
  })

    // 同事 NPC（右侧，不可交互，背景）
  createNPC({
    x: 2, z: 2, color: 0xaa66dd, name: ' 同事',
    labelColor: '#cc88ff', borderColor: 'rgba(204,136,255,0.2)',
    interactive: false, facing: -0.3,
    //启动GLTFLoader加载器，加载自定义person_man_woman.glb人物模型
    useGLB: true,
    glbUrl: "/models/person_man_woman.glb",
    modelScale: 0.8
  })

  // 大屏辉光
  const mainLight = new THREE.PointLight(0x00d4ff, 0.8, 10)
  mainLight.position.set(0, 1.8, -4.0)
  sceneObjects.add(mainLight)
  const greenLight = new THREE.PointLight(0x44ff88, 0.5, 8)
  greenLight.position.set(-2.5, 1.5, -3.5)
  sceneObjects.add(greenLight)
  const orangeLight = new THREE.PointLight(0xffaa44, 0.5, 8)
  orangeLight.position.set(2.5, 1.5, -3.5)
  sceneObjects.add(orangeLight)
  const purpleLight = new THREE.PointLight(0xaa66ff, 0.5, 8)
  purpleLight.position.set(5.0, 1.5, -3.5)
  sceneObjects.add(purpleLight)
  const pinkLight = new THREE.PointLight(0xff4488, 0.5, 8)
  pinkLight.position.set(-5.0, 1.5, -3.5)
  sceneObjects.add(pinkLight)

  // 环境光
  const ambientLight = new THREE.PointLight(0x4466aa, 0.3, 16)
  ambientLight.position.set(0, 2, 0)
  sceneObjects.add(ambientLight)

  // 地面反射光
  const glowMat = new THREE.MeshBasicMaterial({
    color: 0x00d4ff, transparent: true, opacity: 0.08
  })
  const glow = new THREE.Mesh(new THREE.PlaneGeometry(10, 8), glowMat)
  glow.rotation.x = -Math.PI / 2
  glow.position.set(0, 0.01, -2)
  sceneObjects.add(glow)

  // 绿植（角落）
  addPlant(-7.0, -5.0)
  addPlant(7.0, 5.0)

  // ===== 场景5碰撞体 =====
  // 监控大屏、屏幕区域、主工作台碰撞体由GLB模型加载时自动添加，此处不再手动添加
  // 绿植碰撞体（代码创建的对象，保留手动碰撞体）
  addCollisionBox(-7.0, -5.0, 0.5, 0.5)
  addCollisionBox(7.0, 5.0, 0.5, 0.5)

  if (player) player.position.set(0, 0.1, 4.0)
  console.log('✅ 监控大屏场景构建完成！')
}

// ============================================================
// 默认场景
// ============================================================
function buildDefaultScene() {
  console.log('📦 构建默认场景')
  clearSceneObjects()
  const box = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1, 1),
    new THREE.MeshStandardMaterial({ color: 0x00d4ff, emissive: 0x004466, emissiveIntensity: 0.3 })
  )
  box.position.y = 0.5
  box.castShadow = true
  sceneObjects.add(box)
  if (player) player.position.set(0, 0.1, 2)
}

// ===== 创建玩家（FBX 模型） =====
function createPlayer() {
  const group = new THREE.Group()
  group.position.set(0, 0.1, 0)
  scene.add(group)
  playerGroup = group

  // 占位几何体
  const tempBody = new THREE.Mesh(
    new THREE.CylinderGeometry(0.25, 0.3, 0.5, 8),
    new THREE.MeshStandardMaterial({ color: 0x3388ff, roughness: 0.3 })
  )
  tempBody.position.y = 0.65
  tempBody.castShadow = true
  group.add(tempBody)
  const tempHead = new THREE.Mesh(
    new THREE.SphereGeometry(0.18, 8, 8),
    new THREE.MeshStandardMaterial({ color: 0xffddbb, roughness: 0.6 })
  )
  tempHead.position.y = 1.05
  tempHead.castShadow = true
  group.add(tempHead)

  // 名字标签
  const labelDiv = document.createElement('div')
  labelDiv.textContent = '🧑\u200d💻 主角'
  labelDiv.style.cssText = 'color:#88ddff;font-size:16px;font-weight:bold;font-family:Microsoft YaHei,sans-serif;background:rgba(0,0,0,0.5);padding:2px 14px;border-radius:20px;border:1px solid rgba(0,212,255,0.15);backdrop-filter:blur(4px);letter-spacing:1px;text-shadow:0 0 20px rgba(0,0,0,0.9),0 0 10px rgba(0,0,0,0.8)'
  const label = new CSS2DObject(labelDiv)
  label.position.set(0, 1.5, 0)
  group.add(label)

  const loader = new FBXLoader()
  loader.load('/models/Hip Hop Dancing.fbx', (fbx) => {
    const model = fbx
    model.scale.set(0.007, 0.007, 0.007)
    model.position.set(0, 0, 0)
    model.traverse((child) => {
      if (child.isMesh) {
        child.castShadow = true
        child.receiveShadow = true
      }
    })

    const toRemove = []
    group.children.forEach(child => {
      if (!child.isCSS2DObject) toRemove.push(child)
    })
    toRemove.forEach(child => group.remove(child))
    group.add(model)

    if (fbx.animations && fbx.animations.length > 0) {
      modelAnimations = fbx.animations
      playerMixer = new THREE.AnimationMixer(model)
      const idleClip = modelAnimations.find(c =>
        c.name.toLowerCase().includes('idle') ||
        c.name.toLowerCase().includes('stand') ||
        c.name.toLowerCase().includes('loop') ||
        c.name.toLowerCase().includes('take')
      ) || modelAnimations[0]
      if (idleClip) {
        const action = playerMixer.clipAction(idleClip)
        action.play()
        currentAnim = 'idle'
        console.log('✅ 播放 idle 动画:', idleClip.name)
      }
    } else {
      console.warn('⚠️ FBX 文件没有动画')
    }
    console.log('✅ FBX 模型加载成功！')
  }, undefined, (error) => {
    console.warn('⚠️ FBX 模型加载失败，使用几何体:', error.message)
  })

  return group
}

function switchAnimation(animName) {
  if (!playerMixer || !modelAnimations.length || currentAnim === animName) return
  const clip = modelAnimations.find(c => c.name.toLowerCase().includes(animName))
  if (!clip) return
  currentAnim = animName
  playerMixer.stopAllAction()
  const action = playerMixer.clipAction(clip)
  action.reset()
  action.fadeIn(0.2)
  action.play()
}

// ===== 初始化 =====
function initThree() {
  const container = containerRef.value
  const width = container.clientWidth
  const height = container.clientHeight

  scene = new THREE.Scene()
  scene.background = new THREE.Color(0xfafafa)
  scene.fog = new THREE.Fog(0xfafafa, 20, 50)

  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 80)
  camera.position.set(4, 2.5, 6)

  renderer = new THREE.WebGLRenderer({ antialias: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  container.appendChild(renderer.domElement)

  labelRenderer = new CSS2DRenderer()
  labelRenderer.setSize(width, height)
  labelRenderer.domElement.style.position = 'absolute'
  labelRenderer.domElement.style.top = '0px'
  labelRenderer.domElement.style.left = '0px'
  labelRenderer.domElement.style.pointerEvents = 'none'
  container.appendChild(labelRenderer.domElement)

  // 灯光
  const ambient = new THREE.AmbientLight(0xffffff, 0.8)
  scene.add(ambient)
  const mainLight = new THREE.DirectionalLight(0xffffff, 2.0)
  mainLight.position.set(5, 10, 6)
  mainLight.castShadow = true
  scene.add(mainLight)
  const fillLight = new THREE.DirectionalLight(0x88ccff, 0.35)
  fillLight.position.set(-4, 3, 5)
  scene.add(fillLight)

  // 地面网格（隐藏在房间地板下面）
  const grid = new THREE.GridHelper(20, 20, 0x00d4ff, 0x1a3a5a)
  grid.position.y = -0.1
  grid.material.opacity = 0.15
  grid.material.transparent = true
  scene.add(grid)

  sceneObjects = new THREE.Group()
  scene.add(sceneObjects)

  player = createPlayer()
  buildBackendStudio()

  bindEvents()
  emit('scene-ready')
}

// ===== 事件绑定（含 F 键交互） =====
function bindEvents() {
  document.addEventListener('keydown', (e) => {
    switch (e.code) {
      case 'KeyW': keys.w = true; e.preventDefault(); break
      case 'KeyA': keys.a = true; e.preventDefault(); break
      case 'KeyS': keys.s = true; e.preventDefault(); break
      case 'KeyD': keys.d = true; e.preventDefault(); break
      case 'KeyF':
        if (canInteract && interactNpc) {
          console.log('🤝 触发交互, npcId:', interactNpc.userData.npcId, 'sceneId:', currentSceneId)
          emit('interact', {
            sceneId: currentSceneId,
            npcId: interactNpc.userData.npcId
          })
        } else {
          console.log('⚠️ 暂无可交互对象')
        }
        e.preventDefault()
        break
    }
  })
  document.addEventListener('keyup', (e) => {
    switch (e.code) {
      case 'KeyW': keys.w = false; e.preventDefault(); break
      case 'KeyA': keys.a = false; e.preventDefault(); break
      case 'KeyS': keys.s = false; e.preventDefault(); break
      case 'KeyD': keys.d = false; e.preventDefault(); break
    }
  })

  renderer.domElement.addEventListener('mousedown', (e) => {
    isDragging = true
    prevMouse.x = e.clientX
    prevMouse.y = e.clientY
  })
  window.addEventListener('mouseup', () => { isDragging = false })
  window.addEventListener('mousemove', (e) => {
    if (!isDragging) return
    const dx = e.clientX - prevMouse.x
    const dy = e.clientY - prevMouse.y
    targetOrbitAngle -= dx * 0.005
    targetOrbitPitch = Math.max(0.1, Math.min(1.2, targetOrbitPitch + dy * 0.005))
    prevMouse.x = e.clientX
    prevMouse.y = e.clientY
  })
  window.addEventListener('resize', onResize)
}

function onResize() {
  const container = containerRef.value
  const width = container.clientWidth
  const height = container.clientHeight
  camera.aspect = width / height
  camera.updateProjectionMatrix()
  renderer.setSize(width, height)
  if (labelRenderer) labelRenderer.setSize(width, height)
}

// ===== 距离检测：每帧检查是否靠近交互 NPC =====
function checkInteraction() {
  if (!player || !interactNpc || !interactHintLabel) {
    canInteract = false
    return
  }
  const d = player.position.distanceTo(interactNpc.position)
  canInteract = d < INTERACT_DISTANCE
  interactHintLabel.element.style.display = canInteract ? 'block' : 'none'
}

// ===== 场景切换 =====
function switchScene(sceneData) {
  if (!sceneData || isTransitioning) return
  isTransitioning = true

  const overlay = overlayRef.value
  if (!overlay) {
    doSwitchScene(sceneData)
    isTransitioning = false
    return
  }

  overlay.style.transition = 'opacity 0.3s ease'
  overlay.style.opacity = '1'

  setTimeout(() => {
    doSwitchScene(sceneData)
    overlay.style.transition = 'opacity 0.3s ease'
    overlay.style.opacity = '0'
    setTimeout(() => { isTransitioning = false }, 350)
  }, 350)
}

function doSwitchScene(sceneData) {
  console.log(`🔄 切换到场景: ${sceneData.sceneName} (ID: ${sceneData.id})`)
  switch (sceneData.id) {
    case 1: buildBackendStudio(); break
    case 2: buildConferenceRoom(); break
    case 3: buildWorkstation(); break
    case 4: buildIntegrationZone(); break
    case 5: buildMonitoringRoom(); break
    default: buildDefaultScene()
  }

  const targets = {
    1: new THREE.Vector3(4, 2.5, 6),
    2: new THREE.Vector3(3, 2.5, 5),
    3: new THREE.Vector3(4, 3, 6),
    4: new THREE.Vector3(3, 2.5, 5),
    5: new THREE.Vector3(4, 2.5, 6)
  }
  cameraTargetPos = targets[sceneData.id] || new THREE.Vector3(4, 2.5, 6)
}

// ===== 动画循环 =====
function animate() {
  requestAnimationFrame(animate)

  const lerpFactor = 0.15
  orbitAngle += (targetOrbitAngle - orbitAngle) * lerpFactor
  orbitPitch += (targetOrbitPitch - orbitPitch) * lerpFactor

  if (player) {
    const targetQuat = new THREE.Quaternion().setFromEuler(
      new THREE.Euler(0, orbitAngle + Math.PI, 0, 'YXZ')
    )
    player.quaternion.slerp(targetQuat, 0.1)

    const camForward = new THREE.Vector3(0, 0, -1)
    const camQuat = new THREE.Quaternion().setFromEuler(
      new THREE.Euler(0, orbitAngle, 0, 'YXZ')
    )
    camForward.applyQuaternion(camQuat)
    camForward.y = 0
    camForward.normalize()

    const camRight = new THREE.Vector3(1, 0, 0)
    camRight.applyQuaternion(camQuat)
    camRight.y = 0
    camRight.normalize()

    const move = new THREE.Vector3(0, 0, 0)
    if (keys.w) move.add(camForward)
    if (keys.s) move.sub(camForward)
    if (keys.a) move.sub(camRight)
    if (keys.d) move.add(camRight)

    const isMoving = move.length() > 0
    if (isMoving) {
      move.normalize().multiplyScalar(playerSpeed * 0.016)
      
      // 应用碰撞检测：计算修正后的移动向量
      const startX = player.position.x
      const startZ = player.position.z
      const collisionResult = applyCollisionMove(startX, startZ, move.x, move.z)
      
      // 使用修正后的移动向量更新位置
      player.position.x += collisionResult.x
      player.position.z += collisionResult.z
      
      // 边界限制：不出场景范围
      player.position.x = Math.max(roomBounds.minX, Math.min(roomBounds.maxX, player.position.x))
      player.position.z = Math.max(roomBounds.minZ, Math.min(roomBounds.maxZ, player.position.z))
      
      if (modelAnimations.length > 0) switchAnimation('walk')
    } else {
      if (modelAnimations.length > 0) switchAnimation('idle')
    }

    if (playerMixer) playerMixer.update(0.016)

    // 每帧检测交互距离
    checkInteraction()
  }

  if (player) {
    const offset = new THREE.Vector3(0, 2.2, 3.0)
    const rot = new THREE.Quaternion().setFromEuler(
      new THREE.Euler(orbitPitch, orbitAngle, 0, 'YXZ')
    )
    offset.applyQuaternion(rot)
    let targetPos = player.position.clone().add(offset)

    targetPos.x = Math.max(roomBounds.minX + 0.5, Math.min(roomBounds.maxX - 0.5, targetPos.x))
    targetPos.z = Math.max(roomBounds.minZ + 0.5, Math.min(roomBounds.maxZ - 0.5, targetPos.z))

    camera.position.lerp(targetPos, 0.08)
    if (camera.position.distanceTo(targetPos) > 2) {
      camera.position.copy(targetPos)
    }
    camera.lookAt(player.position.x, player.position.y + 0.8, player.position.z)
  }

  renderer.render(scene, camera)
  if (labelRenderer) labelRenderer.render(scene, camera)
}

defineExpose({ switchScene })

onMounted(() => {
  initThree()
  animate()
})

onBeforeUnmount(() => {
  renderer?.dispose()
  if (labelRenderer) labelRenderer.domElement?.remove()
})
</script>

<style scoped>
.three-container {
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
}

.scene-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: #0a0a1a;
  z-index: 100;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.3s ease;
}
</style>
