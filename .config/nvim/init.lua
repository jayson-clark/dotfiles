vim.g.mapleader = " " -- Now <leader> is the spacebar

-- Packer Plugin Manager
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer manages itself
    use 'nvim-treesitter/nvim-treesitter' -- Syntax highlighting
    use 'neovim/nvim-lspconfig' -- LSP support
    use 'hrsh7th/nvim-cmp' -- Autocompletion
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'nvim-lualine/lualine.nvim' -- Status line
    use 'nvim-telescope/telescope.nvim' -- Fuzzy finder
    use 'nvim-tree/nvim-tree.lua' -- File explorer
    use 'nvim-tree/nvim-web-devicons' -- File icons
    use 'folke/tokyonight.nvim' -- Colorscheme
    use 'nvim-lua/plenary.nvim' -- Dependency for null-ls and other plugins
    use 'jose-elias-alvarez/null-ls.nvim' -- Formatting
end)

-- Basic Settings
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Relative line numbers
vim.o.syntax = 'on' -- Enable syntax highlighting
vim.o.clipboard = 'unnamedplus' -- System clipboard
-- vim.o.mouse = 'a' -- Enable mouse
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftwidth = 4 -- Indentation level
vim.o.tabstop = 4 -- Tab width
vim.o.wrap = false -- Disable line wrap
vim.o.cursorline = true -- Highlight current line

-- Treesitter for syntax highlighting
require('nvim-treesitter.configs').setup {
    ensure_installed = { "lua", "python", "c", "cpp", "javascript", "typescript" }, -- Add your languages
    highlight = { enable = true },
}

-- LSP Config
local lspconfig = require('lspconfig')
lspconfig.pyright.setup{} -- Python LSP
lspconfig.clangd.setup{} -- C/C++ LSP

local lspconfig = require('lspconfig')

-- TypeScript/JavaScript LSP
lspconfig.ts_ls.setup {
    on_attach = function(client, bufnr)
        -- Optional: Disable formatting for ts_ls if you're using Prettier
        client.server_capabilities.documentFormattingProvider = false

        -- Keybindings for LSP actions
        local bufmap = vim.api.nvim_buf_set_keymap
        local opts = { noremap = true, silent = true }
        bufmap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts) -- Go to definition
        bufmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts) -- Hover information
        bufmap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts) -- Go to implementation
        bufmap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts) -- Rename
        bufmap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts) -- Code actions
        bufmap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- Previous diagnostic
        bufmap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts) -- Next diagnostic
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(), -- Enable nvim-cmp capabilities
}

-- ts_ls integration for nvim-cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- Use luasnip for snippets
        end,
    },
    mapping = {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
})

-- Formatting Setup
local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            extra_args = { "--tab-width", "4", "--use-tabs", "false" }, -- Force 4 spaces
        }),
        null_ls.builtins.formatting.clang_format.with({
            extra_args = { "--style", "IndentWidth: 4" },
        }),
        null_ls.builtins.formatting.stylua.with({
            extra_args = { "--indent-width", "4" },
        }),
    },
    on_attach = function(client, bufnr)
        -- Keybinding for formatting
        local bufmap = vim.api.nvim_buf_set_keymap
        local opts = { noremap = true, silent = true }
        bufmap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
    end,
})

-- Telescope Keybindings
vim.api.nvim_set_keymap('n', '<Leader>f', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>g', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- Nvim Tree Setup
require('nvim-tree').setup()
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Lualine Setup
require('lualine').setup()

-- Colorscheme
vim.cmd[[colorscheme tokyonight]]
