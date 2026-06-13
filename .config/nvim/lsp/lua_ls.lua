return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },

            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },

            diagnostics = {
                globals = {
                    "vim",
                },
            },

            completion = {
                callSnippet = "Replace",
            },
        },
    },
}
