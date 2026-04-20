import { reactive } from 'vue'

const MIN_VISIBLE_MS = 260

const now = () => (
  typeof performance !== 'undefined' && typeof performance.now === 'function'
    ? performance.now()
    : Date.now()
)

const resolveLoadingMessage = (rawPath = '') => {
  const normalized = String(rawPath || '/').split('?')[0] || '/'

  if (normalized === '/' || normalized.startsWith('/Public/Welcome')) {
    return 'Opening landing page...'
  }

  if (normalized === '/login' || normalized.startsWith('/Auth/Login')) {
    return 'Opening login...'
  }

  if (normalized === '/register' || normalized.startsWith('/Auth/Register')) {
    return 'Opening registration...'
  }

  if (normalized === '/dashboard') {
    return 'Opening dashboard...'
  }

  if (normalized.includes('Dashboard')) {
    return 'Loading dashboard...'
  }

  return 'Loading page...'
}

export const globalLoadingState = reactive({
  visible: true,
  message: 'Preparing workspace...',
})

let hideTimer = null
let visibleSince = now()
let navigationLoadingInstalled = false

const clearHideTimer = () => {
  if (!hideTimer || typeof window === 'undefined') return
  window.clearTimeout(hideTimer)
  hideTimer = null
}

export const showGlobalLoading = (message = 'Loading page...') => {
  clearHideTimer()
  globalLoadingState.visible = true
  globalLoadingState.message = message
  visibleSince = now()
}

export const hideGlobalLoading = (extraDelay = 0) => {
  if (typeof window === 'undefined') {
    globalLoadingState.visible = false
    return
  }

  clearHideTimer()
  const remaining = Math.max(0, MIN_VISIBLE_MS - (now() - visibleSince))
  hideTimer = window.setTimeout(() => {
    globalLoadingState.visible = false
    hideTimer = null
  }, remaining + Math.max(0, Number(extraDelay) || 0))
}

export const completeInitialGlobalLoading = () => {
  hideGlobalLoading(80)
}

export const installGlobalNavigationLoading = (router) => {
  if (typeof window === 'undefined' || navigationLoadingInstalled || !router) {
    return
  }

  navigationLoadingInstalled = true
}
