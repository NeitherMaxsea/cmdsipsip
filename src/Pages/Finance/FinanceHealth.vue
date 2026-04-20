<template>
  <FinanceShell
    title="Finance System Health"
    subtitle="Check if each finance module has the required database tables."
    active-path="/finance/health"
  >
    <div class="stats-grid">
      <div class="stat-card">
        <p>Modules Ready</p>
        <h3>{{ summary.modules_ready }} / {{ summary.modules_total }}</h3>
      </div>
      <div class="stat-card">
        <p>Tables Ready</p>
        <h3>{{ summary.tables_ready }} / {{ summary.tables_total }}</h3>
      </div>
    </div>

    <div class="panel">
      <h3>Module Readiness</h3>
      <table>
        <thead>
          <tr>
            <th>Module</th>
            <th>Status</th>
            <th>Required Tables</th>
            <th>Recommended Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="mod in modules" :key="mod.module">
            <td>{{ mod.module }}</td>
            <td>
              <span class="badge" :class="mod.healthy ? 'paid' : 'failed'">
                {{ mod.healthy ? 'Ready' : 'Missing Tables' }}
              </span>
            </td>
            <td>
              <div class="grid gap-1.5">
                <div v-for="tbl in mod.tables" :key="`${mod.module}-${tbl.name}`" class="flex items-start justify-between gap-2.5">
                  <div class="inline-flex flex-col gap-0.5">
                    <span>{{ tbl.name }}</span>
                    <small class="text-[0.72rem] leading-[1.25] text-slate-500">{{ tbl.suggestion }}</small>
                  </div>
                  <span :class="tbl.exists ? 'font-bold text-emerald-700' : 'font-bold text-red-700'">
                    {{ tbl.exists ? `OK (${tbl.row_count})` : 'Missing' }}
                  </span>
                </div>
              </div>
            </td>
            <td>
              <ul class="m-0 grid list-disc gap-1 pl-[18px]">
                <li
                  v-for="(action, index) in mod.recommended_actions || []"
                  :key="`${mod.module}-action-${index}`"
                  class="text-slate-700"
                >
                  {{ action }}
                </li>
              </ul>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </FinanceShell>
</template>

<script setup>
import { computed } from 'vue'
import FinanceShell from './FinanceShell.vue'

const props = defineProps({
  summary: {
    type: Object,
    default: () => ({
      modules_total: 0,
      modules_ready: 0,
      tables_total: 0,
      tables_ready: 0,
    }),
  },
  modules: {
    type: Array,
    default: () => [],
  },
})

const summary = computed(() => props.summary)
const modules = computed(() => props.modules)
</script>
