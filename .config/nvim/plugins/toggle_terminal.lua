vim.pack.add({
    "https://github.com/tttt369/nvim-toggle-terminal"
})

local M = require("toggle-terminal")
vim.api.nvim_create_user_command(
    "MyToggleTerm",
    function()
        M.toggle_terminal()
    end,
    {}
)
vim.api.nvim_create_user_command(
    "MyTermCd",
    function()
        M.change_to_file_dir()
    end,
    {}
)
