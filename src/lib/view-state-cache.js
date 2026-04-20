const CACHE_PREFIX = 'thesis:view-cache:'
const DEFAULT_MAX_AGE_MS = 5 * 60 * 1000

const getCacheKey = (key) => `${CACHE_PREFIX}${String(key || '').trim()}`

export const readCachedViewState = (key, fallback = null, { maxAgeMs = DEFAULT_MAX_AGE_MS } = {}) => {
  if (typeof window === 'undefined') return fallback

  try {
    const raw = window.sessionStorage.getItem(getCacheKey(key))
    if (!raw) return fallback

    const parsed = JSON.parse(raw)
    const savedAt = Number(parsed?.savedAt || 0)
    if (maxAgeMs > 0 && (!savedAt || Date.now() - savedAt > maxAgeMs)) {
      window.sessionStorage.removeItem(getCacheKey(key))
      return fallback
    }

    return parsed?.value ?? fallback
  } catch {
    return fallback
  }
}

export const writeCachedViewState = (key, value) => {
  if (typeof window === 'undefined') return

  try {
    window.sessionStorage.setItem(getCacheKey(key), JSON.stringify({
      savedAt: Date.now(),
      value,
    }))
  } catch {
    // Ignore cache write failures.
  }
}
