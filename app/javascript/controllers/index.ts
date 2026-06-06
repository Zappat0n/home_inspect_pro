/// <reference types="webpack-env" />

// Import and register all your controllers via webpack require.context
import { application } from "./application"

const context = require.context("./", true, /_controller\.(ts|js)$/)

context.keys().forEach((filename: string) => {
  const name = filename
    .replace(/^\.\//, "")
    .replace(/_controller\.(ts|js)$/, "")
    .replace(/\//g, "--")
    .replace(/_/g, "-")

  const controllerModule = context(filename)
  if (controllerModule.default) {
    application.register(name, controllerModule.default)
  }
})
