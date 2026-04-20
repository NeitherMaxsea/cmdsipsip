<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const form = useForm({
    password: '',
});

const submit = () => {
    form.post('/confirm-password', {
        onFinish: () => form.reset(),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Confirm Password" />

        <div class="space-y-3">
            <div class="flex items-center justify-between gap-3">
                <Link href="/login" class="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 shadow-sm transition hover:border-slate-300 hover:text-slate-900">
                    <span aria-hidden="true">&larr;</span>
                    <span>Back to Login</span>
                </Link>
            </div>

            <p class="text-[0.72rem] font-bold uppercase tracking-[0.24em] text-teal-700/80">Secure Confirmation</p>
            <h1 class="text-[clamp(2.15rem,4vw,3.15rem)] font-black leading-[0.94] tracking-[-0.05em] text-slate-900">Confirm your password</h1>
            <p class="text-[0.98rem] leading-7 text-slate-600">
                This action requires one more password check before you can continue inside the secured part of the system.
            </p>
        </div>

        <form class="mt-6 grid gap-4" @submit.prevent="submit">
            <div>
                <label for="password" class="mb-2 block text-[0.76rem] font-semibold uppercase tracking-[0.16em] text-slate-500">Password</label>
                <input
                    id="password"
                    type="password"
                    v-model="form.password"
                    required
                    autocomplete="current-password"
                    autofocus
                    placeholder="Enter your password"
                    class="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3.5 text-[1rem] text-slate-900 shadow-sm shadow-slate-100 transition duration-150 placeholder:text-slate-400 focus:border-teal-500 focus:outline-none focus:ring-4 focus:ring-teal-100"
                />
                <InputError class="mt-2" :message="form.errors.password" />
            </div>

            <button
                type="submit"
                class="mt-2 w-full rounded-2xl bg-[linear-gradient(135deg,#0f766e,#0891b2)] px-5 py-3.5 text-[1rem] font-black uppercase tracking-[0.14em] text-white shadow-[0_16px_32px_rgba(8,145,178,0.22)] transition duration-150 hover:-translate-y-[1px] hover:shadow-[0_22px_38px_rgba(8,145,178,0.26)] disabled:cursor-not-allowed disabled:opacity-60 disabled:shadow-none"
                :disabled="form.processing"
            >
                {{ form.processing ? 'Confirming...' : 'Confirm Password' }}
            </button>
        </form>
    </GuestLayout>
</template>
