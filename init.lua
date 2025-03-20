-- C:\Users\Administrator\AppData\Local\nvim
vim.loader.enable()
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

-- Call plug#begin()
vim.cmd('call plug#begin()')

-- Add plugin configurations
vim.cmd('Plug \'phaazon/hop.nvim\'')
vim.cmd('Plug \'lukas-reineke/indent-blankline.nvim\'')
vim.cmd('Plug \'jiangmiao/auto-pairs\'')
vim.cmd('Plug \'nvim-tree/nvim-web-devicons\'')
vim.cmd('Plug \'nvim-tree/nvim-tree.lua\'')
vim.cmd('Plug \'akinsho/toggleterm.nvim\'')
vim.cmd('Plug \'NMAC427/guess-indent.nvim\'')

-- LSP STUFFS BEGIN 
vim.cmd('Plug \'mfussenegger/nvim-lint\'')
vim.cmd('Plug \'williamboman/mason.nvim\'')
vim.cmd('Plug \'williamboman/mason-lspconfig.nvim\'')
vim.cmd('Plug \'neovim/nvim-lspconfig\'')
vim.cmd('Plug \'hrsh7th/nvim-cmp\'')
vim.cmd('Plug \'hrsh7th/cmp-nvim-lsp\'')
vim.cmd('Plug \'hrsh7th/cmp-buffer\'')
vim.cmd('Plug \'hrsh7th/cmp-path\'')
vim.cmd('Plug \'L3MON4D3/LuaSnip\'')
vim.cmd('Plug \'saadparwaiz1/cmp_luasnip\'')
vim.cmd('Plug \'rafamadriz/friendly-snippets\'')
-- LSP STUFFS END

-- Call plug#end()
vim.cmd('call plug#end()')

-- Setup plugins
require'hop'.setup {}
--require'indent_blankline'.setup {
--    show_current_context = true,
--    show_current_context_start = true,
--}
require("ibl").setup {
    indent = {
        char = "│",
    },
    scope = {
        enabled = true,
    },
}

-- Setup nvim-tree with tab support
require'nvim-tree'.setup {
    view = {
        width = 30,
    },
    actions = {
        open_file = {
            quit_on_open = false,
        },
    },
    tab = {
        sync = {
            open = true,
            close = true,
        },
    },
}

require('toggleterm').setup {}
require'guess-indent'.setup {}

-- LSP STUFFS BEGIN
-- Setup mason.nvim
require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
require('mason-lspconfig').setup({
    ensure_installed = {
      'pyright',
      'clangd',
    },
    automatic_installation = true,
})
-- Setup nvim-lint
require('lint').linters_by_ft = {
  --python = {'flake8'},
  --c = {'cpplint'},
  --cpp = {'cpplint'},
}

-- ignore linter warning
local lint = require('lint')

-- Configure flake8 to ignore only warnings (codes starting with W)
lint.linters.flake8 = {
  cmd = 'flake8',
  args = {
    '--ignore=W', -- Ignore only warnings (W), still show errors (E)
    '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
  },
  stdin = true,
  ignore_exitcode = true,
}

-- Configure cpplint to ignore warnings but keep errors
lint.linters.cpplint = {
  cmd = 'cpplint',
  args = {
    '--filter=-whitespace,-build,-readability', -- Ignore common warning categories
    '--quiet',
  },
  stdin = false,
  ignore_exitcode = true,
}

-- Add this to disable diagnostic virtual text for warnings but keep errors
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN + 1 }  -- Only show errors, not warnings
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN + 1 }  -- Only show signs for errors, not warnings
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN + 1 }  -- Only underline errors, not warnings
  },
  float = {
    severity = { min = vim.diagnostic.severity.WARN + 1 }  -- Only show errors in hover window, not warnings
  },
})

-- Jalankan linter secara otomatis saat menulis atau membuka file
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

local lspconfig = require('lspconfig')

-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Setup capabilities (for autocompletion)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup each language server
require('mason-lspconfig').setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = capabilities,
    })
  end,
  
  -- Custom config untuk language server tertentu jika diperlukan
  ["lua_ls"] = function()
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          }
        }
      }
    })
  end,

  -- additional settings for lsp
  ["clangd"] = function()
      lspconfig.clangd.setup({
          capabilities = capabilities,
          cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm"
          },
          init_options = {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
          root_dir = function(fname)
              return require("lspconfig.util").root_pattern(
                  "compile_commands.json",
                  "compile_flags.txt",
                  ".git",
                  "Makefile"
              )(fname) or vim.fn.getcwd()
          end,
      })
  end,
})

-- lsp keymapping
-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true }
    
    -- Navigasi ke definisi, referensi, dll
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    
    -- Rename, format, code actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
    
    -- Diagnostics
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  end,
})

-- LSP STUFFS END

-- Basic settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.linebreak = true
vim.o.laststatus = 2
vim.o.shiftwidth = 4
vim.g.mapleader = " "
vim.cmd('colorscheme slate')
-- Hopper Highlight settings
vim.cmd('hi HopNextKey guifg=#FFFFFF')
vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
vim.cmd('hi HopNextKey2 guifg=#00FF00')
-- Keymaps
vim.api.nvim_set_keymap('n', ':W', ':w', {noremap = true})
vim.api.nvim_set_keymap('n', ':Q', ':q', {noremap = true})
-- vim.api.nvim_set_keymap('n', '<F2>', ':HopAnywhere<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F1>', ':HopWord<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F2>', ':nohlsearch<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeOpen<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F4>', ':Mason<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F5>', ':GuessIndent<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F6>', ':lua require("lint").try_lint()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<F12>', ':e $MYVIMRC<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-h>', '<C-W>h', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-l>', '<C-W>l', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-k>', '<C-W>k', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-j>', '<C-W>j', {noremap = true})

vim.api.nvim_set_keymap('n', '<A-1>', ':ToggleTerm 1<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-2>', ':ToggleTerm 2<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-3>', ':ToggleTerm 3<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-4>', ':ToggleTerm 4<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-5>', ':ToggleTerm 5<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-6>', ':ToggleTerm 6<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-7>', ':ToggleTerm 7<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-8>', ':ToggleTerm 8<CR>', {noremap = true})

-- Tambahkan keymap untuk Mason
-- Tambahkan keymap untuk menjalankan linter secara manual
-- change theme lol
-- Buat fungsi menjadi global agar bisa diakses dari keymap
_G.set_colorscheme_and_highlight = function(colorscheme)
  -- Set colorscheme
  vim.cmd('colorscheme ' .. colorscheme)
  
  -- Selalu jalankan pengaturan highlight Hop setelah perubahan colorscheme
  vim.cmd('hi HopNextKey guifg=#FFFFFF')
  vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
  vim.cmd('hi HopNextKey2 guifg=#00FF00')
end

-- Keymap untuk setiap colorscheme
vim.api.nvim_set_keymap('n', '<Leader>1', 
  [[<Cmd>lua set_colorscheme_and_highlight('lunaperche')<CR>]], 
  {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<Leader>2', 
  [[<Cmd>lua set_colorscheme_and_highlight('slate')<CR>]], 
  {noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<Leader>3', 
  [[<Cmd>lua set_colorscheme_and_highlight('industry')<CR>]], 
  {noremap = true, silent = true})

-- Tab navigation keybindings
-- Create new tab with Ctrl+t
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew<CR>', {noremap = true, silent = true})

-- Navigate between tabs with Alt+left/right arrow keys
vim.api.nvim_set_keymap('n', '<A-Left>', ':tabprevious<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<A-Right>', ':tabnext<CR>', {noremap = true, silent = true})

-- Navigate with Alt+h/l (vim-style navigation)
vim.api.nvim_set_keymap('n', '<A-h>', ':tabprevious<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<A-l>', ':tabnext<CR>', {noremap = true, silent = true})

-- Navigate with Alt+number to jump to specific tab
--vim.api.nvim_set_keymap('n', '<A-1>', '1gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-2>', '2gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-3>', '3gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-4>', '4gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-5>', '5gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-6>', '6gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-7>', '7gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-8>', '8gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-9>', '9gt', {noremap = true, silent = true})
--vim.api.nvim_set_keymap('n', '<A-0>', ':tablast<CR>', {noremap = true, silent = true})

-- Move tabs with Shift+Alt+left/right
vim.api.nvim_set_keymap('n', '<S-A-Left>', ':tabmove -1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-A-Right>', ':tabmove +1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-A-h>', ':tabmove -1<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<S-A-l>', ':tabmove +1<CR>', {noremap = true, silent = true})

-- Close tab with Alt+w
vim.api.nvim_set_keymap('n', '<A-w>', ':tabclose<CR>', {noremap = true, silent = true})


-- notes 
-- 1. install xclip di linux kalo gabisa pake clipboard
-- 2. cara install nvim versi baru di linux
-- tar -xzf nvim-linux-x86_64.tar.gz
-- sudo mv nvim-linux-x86_64 /usr/local/nvim
-- sudo ln -s /usr/local/nvim/bin/nvim /usr/local/bin/nvim
