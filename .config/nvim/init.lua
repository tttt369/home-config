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
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<Esc>", ":noh<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("i", "<C-Space>", function() vim.lsp.completion.get() end)
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
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>:MyTermCd<CR>a", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
     
        if client
            and client:supports_method("textDocument/completion")
        then
            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
            })
        end
    end,
})

local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
for name, type_ in vim.fs.dir(lsp_dir) do
    if type_ == "file"
        and name:sub(-4) == ".lua"
        and name:sub(1, 1) ~= "."
    then
        local server = name:gsub("%.lua$", "")
        
        local full_path = lsp_dir .. "/" .. name
        local config = dofile(full_path)
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
    end
end

local plugins_dir = vim.fn.stdpath("config") .. "/plugins"
for name, type_ in vim.fs.dir(plugins_dir) do
    if type_ == "file" and name:match("%.lua$") then
        local full_path = plugins_dir .. "/" .. name
        dofile(full_path)
    end
end

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})

local timer = vim.uv.new_timer()
local just_entered_insert = false

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        just_entered_insert = true

        vim.defer_fn(function()
            just_entered_insert = false
        end, 100)
    end,
})

vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
        if just_entered_insert or not timer then
            return
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()

        if col == 0 then
            return
        end

        local prev = line:sub(col, col)

        if not prev:match("[%w_]") then
            return
        end

        timer:stop()
        timer:start(120, 0, vim.schedule_wrap(function()
            if vim.fn.pumvisible() == 0 then
                vim.lsp.completion.get()
            end
        end))
    end,
})
