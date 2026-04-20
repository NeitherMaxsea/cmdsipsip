  <template>
  <div class="flex min-h-screen bg-slate-50">
    <HrSidebarNav :active-menu="activeMenu" @navigate="navigateTo" />

    <!-- Main -->
    <div class="flex flex-1 flex-col">
      <HrTopbar @logout="logout" />

      <div class="hr-content p-6">
          <!-- Payroll Section -->
          <section v-if="activeMenu==='Payroll'" class="overflow-hidden rounded-2xl border-t-4 border-t-emerald-600 bg-gradient-to-b from-white to-slate-50 p-6 shadow-sm ring-1 ring-slate-200">
            <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between mb-6">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-emerald-700">HR Workspace</p>
                <h2 class="mt-1 text-4xl font-extrabold leading-none tracking-tight text-slate-900">Payroll</h2>
                <p class="mt-2 text-sm text-slate-600">Review attendance, deductions, and payroll readiness for employees.</p>
              </div>
              <span class="text-xs font-medium px-2.5 py-1 rounded-full bg-slate-100 text-slate-600">{{ currentPayrollMonthLabel }}</span>
            </div>

          <!-- **INSERT: Employee Selection Button & Modal** -->
          <div class="flex items-center gap-3">
            <button @click="showEmployeeModal = true" class="rounded-full border border-slate-300 bg-white px-4 py-2.5 text-xs font-bold text-slate-700 shadow-md shadow-slate-900/10 transition hover:-translate-y-0.5 hover:border-slate-400 hover:text-slate-900">
              Select Employee
            </button>
            <span v-if="selectedEmployee" class="text-sm text-slate-600">
              Selected: <span class="font-semibold text-slate-900">{{ selectedEmployee.name }}</span>
            </span>
          </div>

          <div v-if="showEmployeeModal" class="fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center px-4">
            <div class="bg-white rounded-2xl shadow-xl w-full max-w-sm p-5">
              <div class="flex items-center justify-between mb-4">
                <h3 class="text-base font-semibold">Select Employee</h3>
                <button @click="showEmployeeModal = false" class="text-slate-400 hover:text-slate-600 text-sm">Close</button>
              </div>
              <ul class="space-y-2">
                <li v-for="employee in employees" :key="employee.id">
                  <button @click="selectEmployee(employee)" class="w-full text-left px-3 py-2 rounded-lg bg-white hover:bg-slate-100 border border-slate-200 transition text-sm">
                    {{ employee.name }}
                  </button>
                </li>
              </ul>
            </div>
          </div>
          <!-- **END INSERT** -->

          <!-- Rest of Payroll Section (Attendance, Income, Deductions, Net Pay) -->
          <div v-if="selectedEmployee" class="mt-6 space-y-8">
            <h4 class="text-base font-semibold">Payroll for {{ selectedEmployee.name }}</h4>
            <div class="bg-white border border-slate-200 rounded-xl p-4">
              <label class="text-xs text-slate-500 block mb-2">Pay Date</label>
              <input
                type="date"
                v-model="payDate"
                :min="payDateMin"
                :max="payDateMax"
                required
                class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
              />
            </div>
            <div class="grid grid-cols-1 gap-4 md:grid-cols-4">
              <div class="rounded-xl border border-slate-200 bg-white p-4">
                <p class="text-xs uppercase tracking-wide text-slate-500">Payroll Period</p>
                <p class="mt-1 text-sm font-semibold text-slate-900">{{ payrollPeriodSummary.label }}</p>
                <p class="mt-1 text-xs text-slate-500">{{ payrollPeriodSummary.rangeLabel }}</p>
              </div>
              <div class="rounded-xl border border-slate-200 bg-emerald-50 p-4">
                <p class="text-xs uppercase tracking-wide text-emerald-700">Gross Pay</p>
                <p class="mt-1 text-xl font-bold text-emerald-800">{{ totalIncome.toFixed(2) }}</p>
              </div>
              <div class="rounded-xl border border-slate-200 bg-rose-50 p-4">
                <p class="text-xs uppercase tracking-wide text-rose-700">Deductions</p>
                <p class="mt-1 text-xl font-bold text-rose-800">{{ totalDeductions.toFixed(2) }}</p>
              </div>
              <div class="rounded-xl border border-slate-200 bg-slate-900 p-4 text-white">
                <p class="text-xs uppercase tracking-wide text-white/70">Net Pay</p>
                <p class="mt-1 text-xl font-bold">{{ netPay.toFixed(2) }}</p>
              </div>
            </div>
            <!-- Attendance Input -->
            <div>
              <p class="text-sm font-semibold text-slate-700 mb-3">Attendance</p>
                <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  <div class="bg-white border border-slate-200 rounded-xl p-3">
                    <label class="block text-xs font-large text-slate-900 mb-2">Days Present</label>
                    <input
                      type="number"
                      v-model.number="attendance.daysPresent"
                      @input="limitDays('daysPresent')"
                      class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
                    />
                  </div>
                  <div class="bg-white border border-slate-200 rounded-xl p-3">
                    <label class="block text-xs font-medium text-slate-500 mb-2">Days Absent</label>
                    <input
                      type="number"
                      v-model.number="attendance.daysAbsent"
                      @input="limitDays('daysAbsent')"
                      class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
                    />
                  </div>
                  <div class="bg-white border border-slate-200 rounded-xl p-3">
                    <label class="block text-xs font-medium text-slate-500 mb-2">Late Days</label>
                    <input
                      type="number"
                      v-model.number="attendance.lateDays"
                      @input="limitDays('lateDays')"
                      class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
                    />
                  </div>
                    <div class="bg-white border border-slate-200 rounded-xl p-4 flex flex-col justify-center">
                      <span class="text-xs text-slate-500">TOTAL WORKING DAYS</span>
                      <span class="text-2xl font-bold text-slate-900">
                        {{ attendance.daysPresent }} / {{ totalWorkingDays }}
                      </span>
                    </div>
                </div>
            </div>

            <!-- Income / Salary Section -->
            <div>
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-sm font-semibold text-slate-700">Income / Salary</h3>
                <span class="text-xs text-slate-500">Computed fields</span>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Daily Rate</label>
                  <p class="text-lg font-semibold mt-1">{{ dailyRate }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Basic Salary</label>
                  <p class="text-lg font-semibold mt-1">{{ basicSalary.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Overtime & Holiday</label>
                  <p class="text-lg font-semibold mt-1">{{ overtimeHoliday.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Bonuses & Incentives</label>
                  <p class="text-lg font-semibold mt-1">{{ bonuses.toFixed(2) }}</p>
                </div>

                <div class="bg-white border border-slate-200 rounded-xl p-3">
                  <label class="block text-xs font-medium text-slate-500 mb-2">Transport Allowance</label>
                  <p class="text-lg font-semibold text-slate-900">{{ transportAllowance }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-3">
                  <label class="block text-xs font-medium text-slate-500 mb-2">Meal Allowance</label>
                  <p class="text-lg font-semibold text-slate-900">{{ mealAllowance }}</p>
                </div>

                <div class="bg-emerald-50 border border-emerald-200 rounded-xl p-4">
        <span class="text-sm font-semibold">Total Income</span>
        <p class="text-2xl font-bold text-emerald-700">
          {{ totalIncome.toFixed(2) }}
        </p>
      </div>
              </div>
            </div>

            <!-- Deductions Section -->
            <div>
              <h3 class="text-sm font-semibold text-slate-700 mb-3">Deductions</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">SSS</label>
                  <p class="text-lg font-semibold mt-1">{{ deductions.sss.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Pag-IBIG</label>
                  <p class="text-lg font-semibold mt-1">{{ deductions.pagibig.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">PhilHealth</label>
                  <p class="text-lg font-semibold mt-1">{{ deductions.philhealth.toFixed(2) }}</p>
                </div>

                <div class="bg-white border border-slate-200 rounded-xl p-3">
                  <label class="block text-xs font-medium text-slate-500 mb-2">Salary Loan</label>
                  <input
                    type="number"
                    v-model.number="loans.salary"
                    @input="limit9999('salary')"
                    class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
                  />
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-3">
                  <label class="block text-xs font-medium text-slate-500 mb-2">SSS Loan</label>
                  <input
                    type="number"
                    v-model.number="loans.sss"
                    @input="limit9999('sss')"
                    class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-slate-900/20"
                  />
                </div>
      <div class="bg-white border border-slate-200 rounded-xl p-3">
  <label class="block text-xs font-medium text-slate-500 mb-2">
    Health Insurance
  </label>
  <input
    type="number"
    v-model.number="insurance.health"
    @input="limitInsurance('health')"
    class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm
           focus:outline-none focus:ring-2 focus:ring-slate-900/20"
  />
</div>
                <div class="bg-white border border-slate-200 rounded-xl p-3">
  <label class="block text-xs font-medium text-slate-500 mb-2">
    Life Insurance
  </label>
  <input
    type="number"
    v-model.number="insurance.life"
    @input="limitInsurance('life')"
    class="w-full rounded-lg border border-slate-200 px-3 py-2 text-sm
           focus:outline-none focus:ring-2 focus:ring-slate-900/20"
  />
</div>

                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Leave Without Pay</label>
                  <p class="text-lg font-semibold mt-1">{{ penalties.leaveWithoutPay.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Tardiness / Late Arrival</label>
                  <p class="text-lg font-semibold mt-1">{{ penalties.tardiness.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Union / Cooperative Fees</label>
                  <p class="text-lg font-semibold mt-1">{{ deductions.union.toFixed(2) }}</p>
                </div>
                <div class="bg-white border border-slate-200 rounded-xl p-4">
                  <label class="text-xs text-slate-500">Other Deductions</label>
                  <p class="text-lg font-semibold mt-1">{{ deductions.others.toFixed(2) }}</p>
                </div>

                <div class="bg-rose-50 border border-rose-200 rounded-xl p-4">
        <span class="text-sm font-semibold text-rose-600">Total Deductions</span>
        <p class="text-2xl font-bold text-rose-700">
          {{ totalDeductions.toFixed(2) }}
        </p>
      </div>
              </div>
            </div>

            <!-- Net Pay -->
            <div class="bg-white border border-slate-200 rounded-2xl p-6 flex justify-between items-center">
      <span class="text-lg font-semibold text-slate-700">NET PAY</span>
      <span class="text-3xl font-bold text-slate-900">
        {{ netPay.toFixed(2) }}
      </span>
    </div>

            <!-- Generate & Clear Payroll -->
            <div class="flex flex-wrap gap-3">
              <button @click="generatePayroll" class="rounded-full border border-slate-900 bg-gradient-to-br from-slate-900 to-slate-800 px-4 py-2.5 text-xs font-bold text-white shadow-lg shadow-slate-900/20 transition hover:-translate-y-0.5 hover:brightness-105">
                Generate Payroll
              </button>
            </div>
          </div>

          </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { router } from "@inertiajs/vue3";
import axios from "axios";
import Swal from "@/lib/sweetalert-toast-shim";
import HrSidebarNav from "@/Components/HrSidebarNav.vue";
import HrTopbar from '@/Components/HrTopbar.vue'
import { confirmAndLogout } from '@/lib/auth-flow'

/* ---------------- SIDEBAR ---------------- */
const activeMenu = ref("Payroll");

function navigateTo(menu, url) {
  activeMenu.value = menu;
  router.visit(url);
}

const logout = async () => {
  await confirmAndLogout()
};

/* ---------------- EMPLOYEES ---------------- */
const showEmployeeModal = ref(false);
const selectedEmployee = ref(null);
const employees = ref([]);
const payDate = ref("");
const payDateMin = ref("");
const payDateMax = ref("");

function selectEmployee(emp){
  selectedEmployee.value = emp;
  showEmployeeModal.value = false;
  syncPayDateBounds();
}

/* ---------------- PAYROLL DATA ---------------- */
const mealAllowance = 200;
const transportAllowance = 200;
const dailyRate = computed(() => num(selectedEmployee.value?.daily_rate || selectedEmployee.value?.salary_rate || 500));
const overtimeHoliday = ref(150);

/* Attendance */
const attendance = ref({
  daysPresent: 0,
  daysAbsent: 0,
  lateDays: 0
});

/* Allowances */
const allowances = mealAllowance + transportAllowance;

/* Loans */
const loans = ref({
  salary: 0,
  sss: 0
});

/* Insurance */
const insurance = ref({
  health: 0,
  life: 0
});

const lastValid = ref({
  attendance: { ...attendance.value },
  loans: { ...loans.value },
  insurance: { ...insurance.value }
});

const showCardModal = ref(false);
const cardModal = ref({ title: "", value: "" });

const num = (value) => {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
};

const formatDisplayDate = (value) => {
  const parsed = value ? new Date(`${value}T00:00:00`) : null;
  if (!parsed || Number.isNaN(parsed.getTime())) return "Not set";
  return parsed.toLocaleDateString("en-US", { month: "long", day: "numeric", year: "numeric" });
};

/* ---------------- COMPUTED ---------------- */
const payrollPeriodSummary = computed(() => {
  if (!payDate.value) {
    return {
      label: "Kinsenas not selected",
      start: "",
      end: "",
      totalDays: 15,
      rangeLabel: "Choose a pay date to generate the payroll period.",
    };
  }
  const parsed = new Date(`${payDate.value}T00:00:00`);
  if (Number.isNaN(parsed.getTime())) {
    return {
      label: "Invalid period",
      start: "",
      end: "",
      totalDays: 15,
      rangeLabel: "Pay date is invalid.",
    };
  }
  const year = parsed.getFullYear();
  const month = parsed.getMonth();
  const day = parsed.getDate();
  const lastDay = new Date(year, month + 1, 0).getDate();
  const isFirstHalf = day <= 15;
  const startDay = isFirstHalf ? 1 : 16;
  const endDay = isFirstHalf ? 15 : lastDay;
  const start = formatLocalDate(new Date(year, month, startDay));
  const end = formatLocalDate(new Date(year, month, endDay));
  return {
    label: isFirstHalf ? "1st Kinsenas" : "2nd Kinsenas",
    start,
    end,
    totalDays: (endDay - startDay) + 1,
    rangeLabel: `${formatDisplayDate(start)} to ${formatDisplayDate(end)}`,
  };
});
const currentPayrollMonthLabel = computed(() => {
  const anchor = payDate.value ? new Date(`${payDate.value}T00:00:00`) : new Date();
  return anchor.toLocaleDateString("en-US", { month: "long", year: "numeric" });
});
const totalWorkingDays = computed(() => payrollPeriodSummary.value.totalDays);
const basicSalary = computed(() =>
  num(attendance.value.daysPresent) * dailyRate.value
);

const bonuses = computed(() =>
  num(attendance.value.daysPresent) * 100
);

const penalties = computed(() => ({
  leaveWithoutPay: num(attendance.value.daysAbsent) * 150,
  tardiness: num(attendance.value.lateDays) * 100
}));

const deductions = computed(() => ({
  sss: basicSalary.value * 0.055,
  pagibig: basicSalary.value * 0.02,
  philhealth: basicSalary.value * 0.035,
  union: 100,
  others: 50
}));

const totalIncome = computed(() =>
  basicSalary.value +
  overtimeHoliday.value +
  bonuses.value +
  allowances
);

const totalDeductions = computed(() => {
  const gov =
    deductions.value.sss +
    deductions.value.pagibig +
    deductions.value.philhealth;

  const misc =
    deductions.value.union +
    deductions.value.others;

  const loan =
    num(loans.value.salary) +
    num(loans.value.sss);

  const insure =
    num(insurance.value.health) +
    num(insurance.value.life);

  const penalty =
    penalties.value.leaveWithoutPay +
    penalties.value.tardiness;

  return gov + misc + loan + insure + penalty;
});

const netPay = computed(() =>
  totalIncome.value - totalDeductions.value
);

/* ---------------- LIMITERS ---------------- */
function limitDays(field){
  const current = Number(attendance.value[field]);
  if (!Number.isFinite(current)) {
    attendance.value[field] = 0;
    lastValid.value.attendance[field] = 0;
    return;
  }
  if (current < 0) attendance.value[field] = 0;
  if (current > totalWorkingDays.value)
    attendance.value[field] = totalWorkingDays.value;
  lastValid.value.attendance[field] = attendance.value[field];
}
function limit9999(field){
  const current = Number(loans.value[field]);
  if (!Number.isFinite(current)) {
    loans.value[field] = 0;
    lastValid.value.loans[field] = 0;
    return;
  }
  if (current < 0) loans.value[field] = 0;
  if (current > 9999) loans.value[field] = 9999;
  lastValid.value.loans[field] = loans.value[field];
}

function limitInsurance(field){
  const current = Number(insurance.value[field]);
  if (!Number.isFinite(current)) {
    insurance.value[field] = 0;
    lastValid.value.insurance[field] = 0;
    return;
  }
  if (current < 0) insurance.value[field] = 0;
  if (current > 999) insurance.value[field] = 999;
  lastValid.value.insurance[field] = insurance.value[field];
}

function openCardModal(title, value){
  cardModal.value = { title, value };
  showCardModal.value = true;
}

/* ---------------- ACTIONS ---------------- */
async function generatePayroll(){
  if (!payDate.value) {
    await Swal.fire({
      icon: "warning",
      title: "Missing Pay Date",
      text: "Please select a pay date before generating payroll.",
      confirmButtonText: "OK"
    });
    return;
  }
  if (netPay.value < 0) {
    await Swal.fire({
      icon: "warning",
      title: "Negative Net Pay",
      text: "Please review deductions before generating payroll.",
      confirmButtonText: "OK"
    });
    return;
  }
  if (payDate.value && (payDate.value < payDateMin.value || payDate.value > payDateMax.value)) {
    await Swal.fire({
      icon: "warning",
      title: "Invalid Pay Date",
      text: "Pay Date must stay within the current payroll month.",
      confirmButtonText: "OK"
    });
    return;
  }
  if (!selectedEmployee.value) {
    await Swal.fire({
      icon: "warning",
      title: "Select an employee",
      text: "Please choose an employee before generating payroll.",
      confirmButtonText: "OK"
    });
    return;
  }

  await Swal.fire({
    title: "Generating Payroll...",
    text: "Please wait.",
    allowOutsideClick: false,
    timer: 800,
    timerProgressBar: true,
    didOpen: () => {
      Swal.showLoading();
    }
  });
  try {
    await axios.post("/hr/payrolls", {
      employee_id: selectedEmployee.value.id,
      days_present: attendance.value.daysPresent,
      days_absent: attendance.value.daysAbsent,
      late_days: attendance.value.lateDays,
      daily_rate: dailyRate.value,
      basic_salary: basicSalary.value,
      overtime_holiday: overtimeHoliday.value,
      bonuses_incentives: bonuses.value,
      transport_allowance: transportAllowance,
      meal_allowance: mealAllowance,
      total_income: totalIncome.value,
      sss_amount: deductions.value.sss,
      pagibig_amount: deductions.value.pagibig,
      philhealth_amount: deductions.value.philhealth,
      union_fee: deductions.value.union,
      other_deductions: deductions.value.others,
      leave_without_pay: penalties.value.leaveWithoutPay,
      tardiness_deduction: penalties.value.tardiness,
      salary_loan: loans.value.salary,
      sss_loan: loans.value.sss,
      health_insurance: insurance.value.health,
      life_insurance: insurance.value.life,
      total_deductions: totalDeductions.value,
      net_pay: netPay.value,
      compensation_model: "semi_monthly",
      salary_basis: "fixed_employee_salary",
      payroll_period_label: payrollPeriodSummary.value.label,
      payroll_period_start: payrollPeriodSummary.value.start,
      payroll_period_end: payrollPeriodSummary.value.end,
      pay_date: payDate.value || null,
    });

    await Swal.fire({
      icon: "success",
      title: "Payroll Generated",
      text: "Payroll saved successfully.",
      confirmButtonText: "OK"
    });
    clearPayroll();
  } catch (error) {
    await Swal.fire({
      icon: "error",
      title: "Save failed",
      text: "Unable to save payroll.",
      confirmButtonText: "OK"
    });
  }
}

function clearPayroll(){
  attendance.value = { daysPresent:0, daysAbsent:0, lateDays:0 };
  loans.value = { salary:0, sss:0 };
  insurance.value = { health:0, life:0 };
  payDate.value = "";
  lastValid.value = {
    attendance: { ...attendance.value },
    loans: { ...loans.value },
    insurance: { ...insurance.value }
  };
}

const fetchEmployees = async () => {
  try {
    const res = await axios.get("/hr/employees");
    employees.value = (res.data || [])
      .filter((employee) => (employee.approval_status || "approved") === "approved")
      .map((employee) => ({
        ...employee,
        id: employee.id,
        name: employee.name,
      }));
  } catch {
    Swal.fire("Error", "Failed to load employees", "error");
  }
};

onMounted(() => {
  syncPayDateBounds();
  fetchEmployees();
});

const formatLocalDate = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const syncPayDateBounds = () => {
  const now = new Date();
  payDateMin.value = formatLocalDate(new Date(now.getFullYear(), now.getMonth(), 1));
  payDateMax.value = formatLocalDate(new Date(now.getFullYear(), now.getMonth() + 1, 0));
  if (payDate.value && (payDate.value < payDateMin.value || payDate.value > payDateMax.value)) {
    payDate.value = "";
  }
};
</script>
