local lspconfig = require("lspconfig")
local lspinstall = require("lspinstall")
local coq = require("coq")

---@diagnostic disable-next-line: unused-local
local function common_on_attach(client, bufnr)

	--lsp keybinds
	local keymap = vim.api.nvim_set_keymap
	local opts = {silent=true, noremap=true}

	keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
	keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
	keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
	keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
	keymap("n", "ca", "<cmd>Lspsaga code_action<cr>", opts)
	keymap("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
	keymap("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
	--keymap("n", "<c-p>", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
	--keymap("n", "<c-n>", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)

	keymap("n", "<c-f>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", opts)
	keymap("n", "<c-b>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", opts)

	vim.cmd('command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()')

	local function lspSymbol(name, icon)
	   vim.fn.sign_define("LspDiagnosticsSign" .. name, { text = icon, numhl = "LspDiagnosticsDefaul" .. name })
	end

	lspSymbol("Error", "")
	lspSymbol("Information", "")
	lspSymbol("Hint", "")
	lspSymbol("Warning", "")

	vim.cmd('COQnow')

end

local function setup_servers()
   lspinstall.setup()
   local servers = lspinstall.installed_servers()

   for _, lang in pairs(servers) do
      if lang ~= "lua" then
         lspconfig[lang].setup(coq.lsp_ensure_capabilities {
            on_attach = common_on_attach,
            --capabilities = capabilities,
            -- root_dir = vim.loop.cwd,
         })
      elseif lang == "lua" then
         lspconfig[lang].setup(coq.lsp_ensure_capabilities {
            on_attach = common_on_attach,
            --capabilities = capabilities,
            settings = {
               Lua = {
                  diagnostics = {
                     globals = { "vim" },
                  },
                  workspace = {
                     library = {
                        [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                        [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                     },
                     maxPreload = 100000,
                     preloadFileSize = 10000,
                  },
                  telemetry = {
                     enable = false,
                  },
               },
            },
         })
      end
   end
end

setup_servers()

