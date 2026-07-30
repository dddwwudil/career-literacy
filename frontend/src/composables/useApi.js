import axios from 'axios'

const api = axios.create({
    baseURL: '/api',
    timeout: 10000
})

export function useApi() {
    const getCareers = async () => {
        const res = await api.get('/careers')
        return res.data.data
    }

    const getScenes = async (careerId) => {
        const res = await api.get(`/scenes?careerId=${careerId}`)
        return res.data.data
    }

    const getQuests = async (sceneId) => {
        const res = await api.get(`/quests?sceneId=${sceneId}`)
        return res.data.data
    }

    return { getCareers, getScenes, getQuests }
}