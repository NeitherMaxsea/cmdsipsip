<template>
  <div class="flex min-h-screen bg-slate-50">
    <HrSidebarNav :active-menu="activeMenu" @navigate="navigateTo" />

    <div class="flex flex-1 flex-col">
      <HrTopbar @logout="logout" />

      <div class="hr-content p-6 max-md:p-4">
        <div class="flex flex-col gap-6">
          <section class="overflow-hidden rounded-2xl border-t-4 border-t-emerald-600 bg-gradient-to-b from-white to-slate-50 p-6 shadow-sm ring-1 ring-slate-200">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-emerald-700">HR Workspace</p>
                <h1 class="mt-1 text-4xl font-extrabold leading-none tracking-tight text-slate-900">Team Assignment</h1>
                <p class="mt-2 text-sm text-slate-600">Approved employees grouped by team or accredited partner for staffing and workforce oversight.</p>
              </div>
              <div class="flex flex-wrap items-center gap-3">
                <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-600">
                  {{ filteredEmployees.length }} listed
                </span>
                <button
                  type="button"
                  class="rounded-full border border-slate-300 bg-white px-4 py-2.5 text-xs font-bold text-slate-700 shadow-md shadow-slate-900/10 transition hover:-translate-y-0.5 hover:border-slate-400 hover:text-slate-900"
                  @click="fetchLinkedEmployees"
                >
                  Refresh List
                </button>
              </div>
            </div>
          </section>

          <section class="rounded-2xl bg-white p-6 shadow-sm ring-1 ring-slate-200">
            <div class="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
              <div>
                <p class="text-sm font-semibold text-slate-900">Assigned Team Records</p>
                <p class="text-xs text-slate-500">Approved employees are shown here. Link them to an accredited partner in Employee Management to appear as assigned.</p>
              </div>
              <input
                v-model="search"
                type="text"
                placeholder="Search employee, team, or partner..."
                class="w-full rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-700 focus:border-slate-400 focus:outline-none focus:ring-2 focus:ring-slate-200 md:w-80"
              />
            </div>

            <div class="mt-5 w-full overflow-hidden rounded-2xl border border-slate-200 bg-white">
              <table class="w-full min-w-[880px] text-sm">
                <thead class="bg-white text-left text-xs uppercase tracking-wide text-slate-500">
                  <tr>
                    <th class="px-4 py-3">Employee</th>
                    <th class="px-4 py-3">Email</th>
                    <th class="px-4 py-3">Accredited Partner</th>
                    <th class="px-4 py-3">Role</th>
                    <th class="px-4 py-3">Start Date</th>
                    <th class="px-4 py-3">Status</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                  <tr v-if="loading">
                    <td colspan="6" class="px-4 py-6 text-center text-slate-500">Loading team assignment records...</td>
                  </tr>
                  <tr v-else-if="!filteredEmployees.length">
                    <td colspan="6" class="px-4 py-6 text-center text-slate-500">No approved team assignment records found.</td>
                  </tr>
                  <tr v-for="employee in filteredEmployees" :key="employee.id" class="bg-white">
                    <td class="px-4 py-3 font-semibold text-slate-900">{{ employee.name || 'N/A' }}</td>
                    <td class="px-4 py-3 text-slate-600">{{ employee.email || 'No email' }}</td>
                    <td class="px-4 py-3 text-slate-700">
                      <div class="flex flex-wrap items-center gap-2">
                        <span>{{ providerLabel(employee) }}</span>
                        <span
                          v-if="providerCapacityLabel(employee)"
                          class="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide"
                          :class="providerIsFull(employee) ? 'bg-rose-100 text-rose-700' : 'bg-slate-100 text-slate-600'"
                        >
                          {{ providerCapacityLabel(employee) }}{{ providerIsFull(employee) ? ' full' : '' }}
                        </span>
                      </div>
                    </td>
                    <td class="px-4 py-3 text-slate-600">{{ employee.role || 'N/A' }}</td>
                    <td class="px-4 py-3 text-slate-600">{{ employee.start_date || '-' }}</td>
                    <td class="px-4 py-3">
                      <span class="rounded-full bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-700">
                        {{ employee.status || 'Active' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { router } from "@inertiajs/vue3";
import axios from "axios";
import Swal from "@/lib/sweetalert-toast-shim";
import HrSidebarNav from "@/Components/HrSidebarNav.vue";
import HrTopbar from "@/Components/HrTopbar.vue";
import { confirmAndLogout } from "@/lib/auth-flow";

const activeMenu = ref("Team Assignment");
const loading = ref(false);
const rows = ref([]);
const search = ref("");

const normalizeText = (value) => String(value || "").trim();
const PROVIDER_EMPLOYEE_LIMIT = 3;

const isApproved = (employee) => {
  const approval = normalizeText(employee?.approval_status).toLowerCase();
  if (approval !== "") return approval === "approved";
  const status = normalizeText(employee?.status).toLowerCase();
  return status !== "pending approval" && status !== "rejected";
};

const isEligibleForCapacity = (employee) => {
  const approval = normalizeText(employee?.approval_status).toLowerCase();
  if (approval !== "") return approval === "approved" || approval === "pending";
  const status = normalizeText(employee?.status).toLowerCase();
  return status !== "rejected";
};

const isLinked = (employee) => Number(employee?.service_provider_id || 0) > 0;

const providerLabel = (employee) => {
  const providerName = normalizeText(employee?.service_provider_name);
  if (providerName !== "") return providerName;
  const providerId = Number(employee?.service_provider_id || 0);
  return providerId > 0 ? `Partner #${providerId}` : "Unassigned";
};

const approvedRows = computed(() =>
  rows.value.filter((employee) => isApproved(employee))
);

const providerCounts = computed(() => {
  const counts = new Map();
  for (const employee of rows.value) {
    const providerId = Number(employee?.service_provider_id || 0);
    if (!providerId) continue;
    if (!isEligibleForCapacity(employee)) continue;
    counts.set(providerId, (counts.get(providerId) || 0) + 1);
  }
  return counts;
});

const providerCapacityLabel = (employee) => {
  const providerId = Number(employee?.service_provider_id || 0);
  if (!providerId) return "";
  const count = providerCounts.value.get(providerId) || 0;
  return `${count}/${PROVIDER_EMPLOYEE_LIMIT}`;
};

const providerIsFull = (employee) => {
  const providerId = Number(employee?.service_provider_id || 0);
  if (!providerId) return false;
  const count = providerCounts.value.get(providerId) || 0;
  return count >= PROVIDER_EMPLOYEE_LIMIT;
};

const filteredEmployees = computed(() => {
  const keyword = normalizeText(search.value).toLowerCase();
  if (keyword === "") return approvedRows.value;

  return approvedRows.value.filter((employee) => {
    const name = normalizeText(employee?.name).toLowerCase();
    const email = normalizeText(employee?.email).toLowerCase();
    const provider = providerLabel(employee).toLowerCase();
    return name.includes(keyword) || email.includes(keyword) || provider.includes(keyword);
  });
});

const fetchLinkedEmployees = async () => {
  loading.value = true;
  try {
    const res = await axios.get("/hr/employees", {
      params: { _ts: Date.now() },
    });
    rows.value = Array.isArray(res.data) ? res.data : [];
  } catch (error) {
    Swal.fire("Error", error?.response?.data?.message || "Failed to load team assignment records.", "error");
  } finally {
    loading.value = false;
  }
};

function navigateTo(menu, url) {
  activeMenu.value = menu;
  router.visit(url);
}

const logout = async () => {
  await confirmAndLogout();
};

onMounted(fetchLinkedEmployees);
</script>


