local cmd = vim.cmd

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= 'o' then scopes['o'][key] = value end
end

cmd 'syntax enable'
cmd 'filetype plugin indent on'

opt('b', 'smartindent', true)
opt('b', 'shiftwidth', 4)
opt('b', 'tabstop', 4)
opt('b', 'autoindent', true)
opt('b', 'expandtab', false)
opt('o', 'ignorecase', true)
opt('o', 'smartcase', true)
opt('o', 'splitbelow', true)
opt('o', 'splitright', true)
opt('o', 'termguicolors', true)
opt('o', 'showmode', false)
opt('o', 'showmatch', true)
opt('o', 'ruler', true)
opt('o', 'laststatus', 2)
opt('o', 'showtabline', 2)
opt('o', 'startofline', false)
opt('o', 'hidden', true)
opt('o', 'backup', false)
opt('o', 'writebackup', false)
opt('o', 'cmdheight', 1)
opt('o', 'updatetime', 300)
opt('o', 'completeopt', "menuone,noinsert,noselect")
opt('o', 'shortmess', "c")
opt('w', 'number', true)
opt('w', 'cursorline', true)
opt('w', 'signcolumn', 'number')

--opt('w', 'foldlevel', 20)
--opt('w', 'foldmethod', 'expr')
--opt('o', 'foldexpr', 'nvim_treesitter#foldexpr()')
