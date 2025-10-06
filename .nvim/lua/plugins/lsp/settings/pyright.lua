local opts = {
  settings = {
    python = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic", -- "basic" / "strict" / "off"
      },
    },
  },
}

return opts
