// Fisco.io - Vitest: tests para Stimulus en app/javascript
import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "jsdom",
    include: ["spec/javascript/**/*.test.js"],
    coverage: {
      provider: "v8",
      reports: ["html", "text"],
      include: ["app/javascript/**/*.js"],
      exclude: ["app/javascript/application.js", "app/javascript/controllers/index.js", "**/*.test.js"],
    },
    globals: false,
  },
})
