import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

export function useSidebarAccess() {
  const page = usePage()

  const sidebar = computed(() => page.props?.auth?.sidebar || {})
  const modules = computed(() => {
    const list = sidebar.value?.modules
    return Array.isArray(list) ? list : []
  })

  const workspaceMode = computed(() =>
    String(sidebar.value?.workspace_mode || 'company_with_hr')
  )

  const hrEnabled = computed(() => Boolean(sidebar.value?.hr_enabled))
  const activeModuleMode = computed(() =>
    String(sidebar.value?.active_module_mode || '')
  )

  const hasModule = (key) => modules.value.includes(String(key || '').trim())

  return {
    sidebar,
    modules,
    workspaceMode,
    hrEnabled,
    activeModuleMode,
    hasModule,
  }
}
