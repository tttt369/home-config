vim.pack.add({
    "https://github.com/phelipetls/jsonpath.nvim"
})

vim.api.nvim_create_user_command(
    "GetPath",
    function()
        local path = require("jsonpath").get()
        vim.fn.setreg("+", path)
        print(path)
    end,
    { desc = "Copy JSON path" }
)
