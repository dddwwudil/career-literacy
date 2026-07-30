<template>
  <div id="app">
    <!-- 初始访问页（只有首次访问显示） -->
    <LandingPage v-if="showLanding" @enter="onEnter" />

    <!-- 路由出口：HomePage / CareerDetail / CareerExperience -->
    <router-view v-else />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LandingPage from './components/LandingPage.vue'

const showLanding = ref(true)

function onEnter() {
  setTimeout(() => {
    showLanding.value = false
  }, 100)
}
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { overflow: hidden; font-family: 'Microsoft YaHei', sans-serif; background: #0a0a1a; }
#app { width: 100vw; height: 100vh; }
</style>