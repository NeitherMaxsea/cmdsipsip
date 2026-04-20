const defaultTheme = require('tailwindcss/defaultTheme');

/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: 'class',
    content: [
        './index.html',
        './src/**/*.{js,vue}',
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ['Figtree', ...defaultTheme.fontFamily.sans],
                manrope: ['Manrope', ...defaultTheme.fontFamily.sans],
            },
            keyframes: {
                'lamp-breathe': {
                    '0%, 100%': {
                        boxShadow:
                            '0 14px 30px rgba(250, 245, 212, 0.22), 0 34px 38px rgba(248, 250, 252, 0.12)',
                    },
                    '50%': {
                        boxShadow:
                            '0 18px 36px rgba(250, 245, 212, 0.3), 0 44px 48px rgba(248, 250, 252, 0.2)',
                    },
                },
                'cord-float': {
                    '0%, 100%': { transform: 'translateY(0)' },
                    '50%': { transform: 'translateY(1px)' },
                },
                'cord-glint': {
                    '0%, 100%': { backgroundPosition: '0 0%' },
                    '50%': { backgroundPosition: '0 100%' },
                },
                'knot-idle': {
                    '0%, 100%': { boxShadow: '0 8px 18px rgba(245, 198, 155, 0.5)' },
                    '50%': { boxShadow: '0 10px 24px rgba(245, 198, 155, 0.66)' },
                },
                'auth-panel-drop': {
                    from: { opacity: '0', transform: 'translateY(-24px) scale(0.99)' },
                    to: { opacity: '1', transform: 'translateY(0) scale(1)' },
                },
            },
            animation: {
                'lamp-breathe': 'lamp-breathe 2.6s ease-in-out infinite',
                'cord-float': 'cord-float 2.4s ease-in-out infinite',
                'cord-glint': 'cord-glint 2.3s ease-in-out infinite',
                'knot-idle': 'knot-idle 2.4s ease-in-out infinite',
                'auth-panel-drop': 'auth-panel-drop 360ms cubic-bezier(0.2, 0.7, 0.2, 1)',
            },
        },
    },

    plugins: [require('@tailwindcss/forms')],
};
