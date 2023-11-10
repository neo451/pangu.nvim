local pangu = require("pangu")
local ut = require("jb_utils")
print(pangu.spacing("ni你好"))

vim.api.nvim_create_autocmd({ "BufWritePost" },
  { pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    local tab = {}
    for _,j in pairs(lines) do
      tab[#tab+1] = pangu.spacing(j)
    end
    vim.api.nvim_buf_set_text(0, 0, 0, -1, -1, tab)
  end
})
