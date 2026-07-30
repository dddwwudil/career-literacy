import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../views/HomePage.vue'
import CareerDetail from '../views/CareerDetail.vue'
import CareerExperience from '../views/CareerExperience.vue'

const routes = [
    {
        path: '/',
        name: 'Home',
        component: HomePage
    },
    {
        path: '/career/:id',
        name: 'CareerDetail',
        component: CareerDetail
    },
    {
        path: '/experience',
        name: 'Experience',
        component: CareerExperience
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router