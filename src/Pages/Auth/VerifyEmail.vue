<script setup>
import { computed } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const props = defineProps({
    status: String,
});

const form = useForm({});

const submit = () => {
    form.post('/email/verification-notification');
};

const verificationLinkSent = computed(() => props.status === 'verification-link-sent');
</script>

<template>
    <GuestLayout>
        <Head title="Email Verification" />

        <div class="space-y-3">
            <p class="text-[0.72rem] font-bold uppercase tracking-[0.24em] text-teal-700/80">Email Verification</p>
            <h1 class="text-[clamp(2.15rem,4vw,3.15rem)] font-black leading-[0.94] tracking-[-0.05em] text-slate-900">Verify your email address</h1>
            <p class="text-[0.98rem] leading-7 text-slate-600">
                Before you continue, please confirm your email address using the verification link sent to your inbox. If it has not arrived yet, you may request another link below.
            </p>
        </div>

        <div class="mt-6 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700" v-if="verificationLinkSent">
            A new verification link has been sent to the email address you provided during registration.
        </div>

        <form class="mt-6 grid gap-4" @submit.prevent="submit">
            <button
                type="submit"
                class="w-full rounded-2xl bg-[linear-gradient(135deg,#0f766e,#0891b2)] px-5 py-3.5 text-[1rem] font-black uppercase tracking-[0.14em] text-white shadow-[0_16px_32px_rgba(8,145,178,0.22)] transition duration-150 hover:-translate-y-[1px] hover:shadow-[0_22px_38px_rgba(8,145,178,0.26)] disabled:cursor-not-allowed disabled:opacity-60 disabled:shadow-none"
                :disabled="form.processing"
            >
                {{ form.processing ? 'Sending Verification...' : 'Resend Verification Email' }}
            </button>

            <div class="flex items-center justify-center">
                <Link
                    :href="route('logout')"
                    method="post"
                    as="button"
                    class="text-sm font-semibold text-slate-500 underline-offset-4 transition hover:text-slate-900 hover:underline"
                    >Log Out</Link
                >
            </div>
        </form>
    </GuestLayout>
</template>
