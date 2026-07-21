vim.pack.add({
    "https://github.com/Saghen/blink.lib",
    "https://github.com/Saghen/blink.cmp",
})

require("blink.cmp").setup({
    fuzzy = {
        implementation = "lua"
    }
})
