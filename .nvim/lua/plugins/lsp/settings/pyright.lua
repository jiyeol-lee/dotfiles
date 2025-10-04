local opts = {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "workspace",
        typeCheckingMode = "basic",          -- "basic" / "strict" / "off"
      },
    },
  },
}

return opts
