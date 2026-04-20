import { ref } from 'vue'

const THEME_STORAGE_KEY = 'thesis-theme'
const isDark = ref(false)
let initialized = false

const applyTheme = (theme) => {
  if (typeof document === 'undefined') return
  const root = document.documentElement
  const dark = theme === 'dark'

  root.classList.toggle('dark', dark)
  root.style.colorScheme = dark ? 'dark' : 'light'
  isDark.value = dark
}

const initTheme = () => {
  if (initialized || typeof window === 'undefined') return

  const saved = window.localStorage.getItem(THEME_STORAGE_KEY)
  const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
  const theme = saved === 'dark' || saved === 'light' ? saved : (prefersDark ? 'dark' : 'light')

  applyTheme(theme)
  initialized = true
}

const disableTheme = () => {
  if (typeof document === 'undefined') return
  const root = document.documentElement
  root.classList.remove('dark')
  root.style.colorScheme = 'light'
  isDark.value = false
  initialized = false
}

const setTheme = (theme) => {
  if (theme !== 'dark' && theme !== 'light') return
  applyTheme(theme)
  if (typeof window !== 'undefined') {
    window.localStorage.setItem(THEME_STORAGE_KEY, theme)
  }
}

const toggleTheme = () => {
  const next = isDark.value ? 'light' : 'dark'
  setTheme(next)
}

export const useTheme = () => ({
  isDark,
  initTheme,
  disableTheme,
  setTheme,
  toggleTheme,
})
