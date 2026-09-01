/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        "primary": "#000000",
        "on-primary": "#ffffff",
        "on-primary-container": "#858383",
        "primary-fixed": "#e5e2e1",
        "primary-container": "#1c1b1b",
        "surface": "#f9f9f9",
        "on-surface": "#1a1c1c",
        "on-surface-variant": "#444748",
        "surface-container-lowest": "#ffffff",
        "surface-container-low": "#f3f3f3",
        "surface-container": "#eeeeee",
        "surface-container-high": "#e8e8e8",
        "surface-container-highest": "#e2e2e2",
        "surface-variant": "#e2e2e2",
        "surface-dim": "#dadada",
        "surface-bright": "#f9f9f9",
        "outline": "#747878",
        "outline-variant": "#c4c7c7",
        "error": "#ba1a1a",
        "error-container": "#ffdad6",
        "on-error": "#ffffff",
        "on-error-container": "#93000a",
        "inverse-surface": "#2f3131",
        "inverse-on-surface": "#f1f1f1",
        "secondary": "#5e5e5e",
        "secondary-container": "#e1dfdf",
        "on-secondary-container": "#626262"
      },
      borderRadius: {
        "DEFAULT": "0.125rem",
        "lg": "0.25rem",
        "xl": "0.5rem",
        "full": "0.75rem"
      },
      spacing: {
        "xs": "4px",
        "sm": "8px",
        "md": "16px",
        "lg": "24px",
        "xl": "40px",
        "margin-mobile": "16px",
        "margin-desktop": "48px"
      },
      fontFamily: {
        "sans": ["Inter", "sans-serif"],
        "display": ["Inter", "sans-serif"],
        "headline-lg": ["Inter", "sans-serif"],
        "headline-md": ["Inter", "sans-serif"],
        "body-lg": ["Inter", "sans-serif"],
        "body-md": ["Inter", "sans-serif"],
        "label-caps": ["Inter", "sans-serif"],
        "mono-sm": ["monospace"]
      },
      fontSize: {
        "display": ["32px", { lineHeight: "40px", letterSpacing: "-0.02em", fontWeight: "600" }],
        "headline-lg": ["24px", { lineHeight: "32px", letterSpacing: "-0.01em", fontWeight: "600" }],
        "headline-md": ["20px", { lineHeight: "28px", letterSpacing: "-0.01em", fontWeight: "500" }],
        "body-lg": ["16px", { lineHeight: "24px", letterSpacing: "0", fontWeight: "400" }],
        "body-md": ["14px", { lineHeight: "20px", letterSpacing: "0", fontWeight: "400" }],
        "label-caps": ["11px", { lineHeight: "16px", letterSpacing: "0.06em", fontWeight: "700" }],
        "mono-sm": ["12px", { lineHeight: "16px", letterSpacing: "0", fontWeight: "400" }]
      }
    },
  },
  plugins: [],
}
