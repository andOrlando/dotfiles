local Plug = vim.fn['plug#']
local keymap = vim.api.nvim_set_keymap
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}
local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= 'o' then scopes['o'][key] = value end
end


vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'ms-jpq/chadtree'
Plug 'lervag/vimtex'
Plug 'kaicataldo/material.vim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'AndrewRadev/bufferize.vim'
Plug 'terrortylor/nvim-comment'
Plug 'gpanders/editorconfig.nvim'

Plug 'kabouzeid/nvim-lspinstall'
Plug 'neovim/nvim-lspconfig'

Plug 'glepnir/lspsaga.nvim'
Plug 'ms-jpq/coq_nvim'
Plug 'nvim-treesitter/nvim-treesitter'

vim.call('plug#end')

--chadtree config
keymap("n", "<c-n>", "<cmd>CHADopen<cr>", {noremap=true})
vim.g.chadtree_settings = {
	["view.width"] = 30,
	["keymap.tertiary"] = {"t"},
	["keymap.trash"] = {"<c-t>"}
}

--colorscheme config
vim.g.material_theme_style = 'palenight'
vim.g.material_terminal_italics = 1
vim.cmd 'colorscheme material'

--vimtex config
vim.g.vimtex_view_general_viewer = 'zathura'
vim.g.vimtex_vold_enabled = 1
vim.g.vimtex_compiler_progname = 'nvr'
vim.cmd "au BufNewFile,BufRead *.tex exec 'setl indentexpr= | setl tw=80'"

--colorizer config
require('colorizer').setup()

--lspconfig config
require 'lsp'

--lspsaga config
require('lspsaga').init_lsp_saga()

--treesitter config
require("nvim-treesitter.configs").setup {
	ensure_installed = "maintained",
		highlight = {
			enable = true,
			use_languagetree = true
	},
	autotag = {enable = true},
	rainbow = {enable = true},
}

--opt('w', 'foldlevel', 20)
opt('w', 'foldmethod', 'expr')
opt('o', 'foldexpr', 'nvim_treesitter#foldexpr()')

---@diagnostic disable: undefined-global
--[[require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use {'ms-jpq/chadtree', config=function()
			vim.api.nvim_set_keymap("n", "<c-n>", "<cmd>CHADopen<cr>", {noremap=true})
			vim.g.chadtree_settings = {
				["view.width"] = 30,
				["keymap.tertiary"] = {"t"},
				["keymap.trash"] = {"<c-t>"}
			}
		end
	}

    use {'lervag/vimtex', config=function()
            vim.g.vimtex_view_general_viewer = 'zathura'
            vim.g.vimtex_vold_enabled = 1
            vim.g.vimtex_compiler_progname = 'nvr'
            vim.cmd "au BufNewFile,BufRead *.tex exec 'setl indentexpr= | setl tw=80'"
        end
    }

    use {'kaicataldo/material.vim',
        config=function()
            vim.g.material_theme_style = 'palenight'
            vim.g.material_terminal_italics = 1
            vim.cmd 'colorscheme material'
        end,
        disable=false
    }
    use {'haishanh/night-owl.vim',
        config=function()
            vim.cmd 'colorscheme night-owl'
        end,
        disable=true
    }

    use {'norcalli/nvim-colorizer.lua', config=function() require('colorizer').setup() end}


    use 'AndrewRadev/bufferize.vim'
    use 'craigemery/vim-autotag'
    use 'terrortylor/nvim-comment'
	use 'gpanders/editorconfig.nvim'

	use "kabouzeid/nvim-lspinstall"
    use {'neovim/nvim-lspconfig',
		config=function() require 'lsp' end,
		--after="kabouzeid/nvim-lspinstall"
    }

    use {'glepnir/lspsaga.nvim', config=function() require('lspsaga').init_lsp_saga() end}
    use 'ms-jpq/coq_nvim'

    use {'nvim-treesitter/nvim-treesitter',
        run=':TSUpdate',
        config=function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = "maintained",
                highlight = {
                    enable = true,
                    use_languagetree = true
                },
				autotag = {enable = true},
				rainbow = {enable = true},
            }
        end
    }

    use {'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
        config=function()
            --keymap("n", "", "<cmd>Telescope find_file<cr>", {silent=true, noremap=true})
            --keymap("n", "", "<cmd>Telescope live_grep<cr>", {silent=true, noremap=true})
        end
    }
end)]]

