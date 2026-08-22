vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.undofile = true
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.shiftwidth = 4

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<Esc>", ":noh<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>R", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "Q", ":q<CR>")
vim.keymap.set("n", "<C-s>", ":w<CR>")

vim.api.nvim_set_keymap("n", "<leader>h", ":HopWordCurrentLineAC<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>H", ":HopWordCurrentLineBC<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>r", ":RnvimrToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", ":MyToggleTerm<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>T", ":TSinstallAuto<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>:MyTermCd<CR>a", { noremap = true, silent = true })

vim.api.nvim_create_user_command("TSinstallAuto", function()
    local ft = vim.bo.filetype

    if ft == "" then
        vim.notify("Current buffer has no filetype.", vim.log.levels.WARN)
        return
    end

    local ok, ts = pcall(require, "nvim-treesitter")
    if not ok then
        vim.notify("nvim-treesitter is not available.", vim.log.levels.ERROR)
        return
    end

    local lang = vim.treesitter.language.get_lang(ft) or ft
    local available = vim.tbl_contains(ts.get_available(), lang)

    if not available then
        vim.notify(
            string.format("No Treesitter parser is available for %s.", lang),
            vim.log.levels.WARN
        )
        return
    end

    local installed = vim.tbl_contains(ts.get_installed(), lang)

    if installed then
        vim.notify(
            string.format("Treesitter parser (%s) is already installed.", lang),
            vim.log.levels.INFO
        )
        pcall(vim.treesitter.start, 0)
        return
    end

    local choice = vim.fn.confirm(
        string.format(
            "Treesitter parser (%s) isn't installed yet, do you want to install?",
            lang
        ),
        "&Yes\n&No",
        2
    )

    if choice ~= 1 then
        return
    end

    vim.notify(string.format("Installing parser (%s) ...", lang))

    local success, err = pcall(function()
        ts.install({ lang }):wait(30000)
    end)

    if success then
        vim.notify(
            string.format("Treesitter parser (%s) installed.", lang),
            vim.log.levels.INFO
        )
        pcall(vim.treesitter.start, 0)
    else
        vim.notify(
            string.format(
                "Failed or timed out installing parser (%s): %s",
                lang,
                tostring(err)
            ),
            vim.log.levels.ERROR
        )
    end
end, {})

local plugins_dir = vim.fn.stdpath("config") .. "/plugins"
for name, type_ in vim.fs.dir(plugins_dir) do
    if type_ == "file" and name:match("%.lua$") then
        local full_path = plugins_dir .. "/" .. name
        dofile(full_path)
    end
end

vim.lsp.enable({ "lua_ls", "pyright", "clangd", "ts_ls" })
