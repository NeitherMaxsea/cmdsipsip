const EXTERNAL_FILE_URL_PATTERN = /^(?:https?:|blob:|data:)/i

export const stripFileQuery = (value) => String(value ?? '').split('?')[0].split('#')[0]

export const extractTemporaryFileSource = (value) => {
  const raw = String(value ?? '').trim()
  if (!raw.toLowerCase().startsWith('local://')) return ''

  const query = raw.includes('?') ? raw.slice(raw.indexOf('?') + 1) : ''
  if (!query) return ''

  const params = new URLSearchParams(query)
  const source = String(params.get('src') || params.get('url') || '').trim()
  return EXTERNAL_FILE_URL_PATTERN.test(source) ? source : ''
}

export const resolveStoredFileUrl = (value, defaultFolder = 'files') => {
  const raw = String(value ?? '').trim()
  if (!raw) return ''
  if (EXTERNAL_FILE_URL_PATTERN.test(raw)) return raw

  const fallbackSource = extractTemporaryFileSource(raw)
  if (fallbackSource) return fallbackSource

  let normalized = stripFileQuery(raw)
    .replace(/\\/g, '/')
    .replace(/^\/+/, '')
    .replace(/^storage\/app\/public\//, '')
    .replace(/^public\//, '')
    .replace(/^storage\//, '')

  if (defaultFolder && !normalized.includes('/')) {
    normalized = `${defaultFolder}/${normalized}`
  }

  return `/user/file?path=${encodeURIComponent(normalized)}`
}

export const buildTemporaryFilePath = (folder, uid, fileName, sourceUrl = '') => {
  const safeFolder = String(folder ?? 'files').trim().replace(/[?#]/g, '_') || 'files'
  const safeUid = String(uid ?? 'guest').trim().replace(/[?#]/g, '_') || 'guest'
  const safeFileName = String(fileName ?? 'file.bin')
    .trim()
    .replace(/\\/g, '/')
    .split('/')
    .pop() || 'file.bin'

  const basePath = `local://${safeFolder}/${safeUid}/${safeFileName}`
  return sourceUrl
    ? `${basePath}?src=${encodeURIComponent(sourceUrl)}`
    : basePath
}
