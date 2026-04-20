const STORAGE_KEY = 'thesis_capstone_profile_resubmissions'

const normalizeIdentity = (profileOrId = {}) => {
  if (typeof profileOrId === 'string') {
    const raw = profileOrId.trim()
    return {
      id: raw,
      email: raw.includes('@') ? raw.toLowerCase() : '',
    }
  }

  if (!profileOrId || typeof profileOrId !== 'object') {
    return { id: '', email: '' }
  }

  const id = String(profileOrId.id || profileOrId.uid || '').trim()
  const email = String(profileOrId.email || '').trim().toLowerCase()
  return { id, email }
}

const readResubmissionMap = () => {
  if (typeof window === 'undefined') return {}
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY)
    if (!raw) return {}
    const parsed = JSON.parse(raw)
    return parsed && typeof parsed === 'object' ? parsed : {}
  } catch {
    return {}
  }
}

const writeResubmissionMap = (map) => {
  if (typeof window === 'undefined') return
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(map || {}))
  } catch {
    // Ignore storage failures.
  }
}

export const markProfileResubmitted = (profileOrId, timestamp = new Date().toISOString()) => {
  const { id, email } = normalizeIdentity(profileOrId)
  const key = email || id
  if (!key || typeof window === 'undefined') return null

  const map = readResubmissionMap()
  map[key] = { at: timestamp }
  writeResubmissionMap(map)
  return map[key]
}

export const hasLocalResubmission = (profileOrId, reviewAt = '') => {
  if (typeof window === 'undefined') return false
  const { id, email } = normalizeIdentity(profileOrId)
  const key = email || id
  if (!key) return false

  const map = readResubmissionMap()
  const entry = map[key]
  if (!entry?.at) return false
  if (!reviewAt) return true

  const reviewTime = new Date(reviewAt).getTime()
  const resubTime = new Date(entry.at).getTime()
  if (Number.isNaN(reviewTime) || Number.isNaN(resubTime)) return true
  return resubTime >= reviewTime
}

export const clearProfileResubmission = (profileOrId) => {
  if (typeof window === 'undefined') return false
  const { id, email } = normalizeIdentity(profileOrId)
  const key = email || id
  if (!key) return false

  const map = readResubmissionMap()
  if (map[key]) {
    delete map[key]
    writeResubmissionMap(map)
  }
  return true
}
