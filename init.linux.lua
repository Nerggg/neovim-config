-- NvimTreeOpen C:\Users\Administrator\AppData\Local\nvim
-- ~/.config/nvim/
-- search for two words = \v(word1|word2)

-- right click, new shortcut, then "C:\path to wezterm\wezterm-gui.exe" start -- "C:\path to neovim\nvim.exe"

-- then put this config in C:\Users\Administrator\.wezterm.lua
-- local wezterm = require 'wezterm'
-- local config = {}
-- config.font_size = 9.0
-- config.initial_rows = 1000
-- config.initial_cols = 1000
-- return config

-- Enable Vim loader for improved performance
vim.loader.enable()

-- Disable built-in netrw plugins to avoid conflicts with nvim-tree
vim.g.loaded_netrw = 1 
vim.g.loaded_netrwPlugin = 1

-- Enable true color support in terminal
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- Initialize Vim-Plug plugin manager
vim.cmd('call plug#begin()')

-- Custom colorscheme
vim.cmd('Plug \'rebelot/kanagawa.nvim\'')
vim.cmd('Plug \'rose-pine/neovim\'')
vim.cmd('Plug \'sainnhe/everforest\'')

-- Plugin configurations
-- Movement and navigation
vim.cmd('Plug \'phaazon/hop.nvim\'') -- Fast navigation within buffer
vim.cmd('Plug \'lukas-reineke/indent-blankline.nvim\'') -- Indentation guides
vim.cmd('Plug \'jiangmiao/auto-pairs\'') -- Automatic bracket pairing

-- File explorer and icons
vim.cmd('Plug \'nvim-tree/nvim-web-devicons\'') -- File icons
vim.cmd('Plug \'nvim-tree/nvim-tree.lua\'') -- File explorer

-- Terminal and indentation
vim.cmd('Plug \'akinsho/toggleterm.nvim\'') -- Terminal integration
vim.cmd('Plug \'NMAC427/guess-indent.nvim\'') -- Automatic indentation detection

-- Git integration
vim.cmd('Plug \'lewis6991/gitsigns.nvim\'') -- Git signs and operations

-- LSP STUFFS BEGIN
-- Linting and LSP plugins
vim.cmd('Plug \'mfussenegger/nvim-lint\'') -- Linting support
vim.cmd('Plug \'williamboman/mason.nvim\'') -- LSP server management
vim.cmd('Plug \'williamboman/mason-lspconfig.nvim\'') -- LSP server configuration
vim.cmd('Plug \'neovim/nvim-lspconfig\'') -- Native LSP client
vim.cmd('Plug \'hrsh7th/nvim-cmp\'') -- Autocompletion engine
vim.cmd('Plug \'hrsh7th/cmp-nvim-lsp\'') -- LSP source for nvim-cmp
vim.cmd('Plug \'hrsh7th/cmp-buffer\'') -- Buffer source for nvim-cmp
vim.cmd('Plug \'hrsh7th/cmp-path\'') -- Path source for nvim-cmp
vim.cmd('Plug \'L3MON4D3/LuaSnip\'') -- Snippet engine
-- LSP STUFFS END

-- Telescope plugins
vim.cmd('Plug \'nvim-lua/plenary.nvim\'') -- Telescope dependency
vim.cmd('Plug \'nvim-telescope/telescope.nvim\'') -- Fuzzy finder
vim.cmd('Plug \'nvim-telescope/telescope-file-browser.nvim\'') -- File browser extension

-- LATEXX Stuffs Start
vim.cmd('Plug \'lervag/vimtex\'')
-- LATEXX Stuffs End

-- Finalize Vim-Plug
vim.cmd('call plug#end()')

-- Plugin Setup Configurations
-- Configure hop.nvim for fast navigation
require 'hop'.setup {}

-- Configure indent-blankline for indentation guides
require("ibl").setup {
  indent = {
    char = "│",
  },
  scope = {
    enabled = true,
  },
}

-- Configure nvim-tree with tab synchronization
require 'nvim-tree'.setup {
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
  git = {
    ignore = false, -- Show files listed in .gitignore
  },
}

-- Configure toggleterm to open in a tab
require('toggleterm').setup {
  direction = 'tab',
}

-- Configure guess-indent for automatic indentation detection
require 'guess-indent'.setup {}

-- Configure Telescope for fuzzy finding
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-d>"] = "delete_buffer",
      },
    },
    file_ignore_patterns = {
      "node_modules",
      ".gradle",
      ".git",
      "target",
      "build",
      "dist",
      "bin",
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      previewer = false,
    },
    live_grep = {
      theme = "dropdown",
    },
  },
}

-- Load Telescope file browser extension
require('telescope').load_extension('file_browser')

-- LSP STUFFS BEGIN
-- Configure mason.nvim for LSP server management
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Configure mason-lspconfig for automatic LSP server installation
require('mason-lspconfig').setup({
  ensure_installed = {
    -- 'pyright',
    -- 'clangd',
  },
  automatic_installation = true,
})

-- Configure nvim-lint for linting
require('lint').linters_by_ft = {
  --python = {'flake8'},
  --c = {'cpplint'},
  --cpp = {'cpplint'},
  --java = {'checkstyle'},
}

-- Configure flake8 to ignore warnings
local lint = require('lint')
lint.linters.flake8 = {
  cmd = 'flake8',
  args = {
    '--ignore=W', -- Ignore only warnings (W), still show errors (E)
    '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
  },
  stdin = true,
  ignore_exitcode = true,
}

-- Configure cpplint to ignore warnings
lint.linters.cpplint = {
  cmd = 'cpplint',
  args = {
    '--filter=-whitespace,-build,-readability', -- Ignore common warning categories
    '--quiet',
  },
  stdin = false,
  ignore_exitcode = true,
}

-- Configure diagnostic display to show only errors
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN + 1 } -- Only show errors, not warnings
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN + 1 } -- Only show signs for errors, not warnings
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN + 1 } -- Only underline errors, not warnings
  },
  float = {
    severity = { min = vim.diagnostic.severity.WARN + 1 } -- Only show errors in hover window, not warnings
  },
})

-- Automatically run linter on file write or read
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Configure LSP servers
local lspconfig = require('lspconfig')

-- Configure nvim-cmp for autocompletion
local cmp = require('cmp')

-- Setup nvim-cmp with mappings and sources
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    --['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Setup LSP capabilities for autocompletion
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup LSP servers with mason-lspconfig
-- require('mason-lspconfig').setup_handlers({
--   function(server_name)
--     lspconfig[server_name].setup({
--       capabilities = capabilities,
--     })
--   end,

--   -- Custom configuration for lua_ls
--   ["lua_ls"] = function()
--     lspconfig.lua_ls.setup({
--       capabilities = capabilities,
--       settings = {
--         Lua = {
--           diagnostics = {
--             globals = { 'vim' }
--           }
--         }
--       }
--     })
--   end,

--   -- Custom configuration for clangd
--   ["clangd"] = function()
--     lspconfig.clangd.setup({
--       capabilities = capabilities,
--       cmd = {
--         "clangd",
--         "--background-index",
--         "--clang-tidy",
--         "--header-insertion=iwyu",
--         "--completion-style=detailed",
--         "--function-arg-placeholders",
--         "--fallback-style=llvm"
--       },
--       init_options = {
--         usePlaceholders = true,
--         completeUnimported = true,
--         clangdFileStatus = true
--       },
--       filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
--       root_dir = function(fname)
--         return require("lspconfig.util").root_pattern(
--           "compile_commands.json",
--           "compile_flags.txt",
--           ".git",
--           "Makefile"
--         )(fname) or vim.fn.getcwd()
--       end,
--     })
--   end,
-- })

-- LSP keymappings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local function GoToDefinitionInNewTab()
      -- Simpan posisi current window
      local current_win = vim.api.nvim_get_current_win()
      local current_buf = vim.api.nvim_get_current_buf()
      
      -- Go to definition terlebih dahulu
      vim.lsp.buf.definition({
        on_list = function(options)
          if options and options.items and #options.items > 0 then
            local item = options.items[1]
            -- Buat tab baru
            vim.cmd('tabnew')
            -- Buka file di tab baru
            vim.cmd('edit ' .. item.filename)
            -- Jump ke posisi yang tepat
            vim.api.nvim_win_set_cursor(0, {item.lnum, item.col - 1})
          end
        end
      })
    end
    
    local opts = { buffer = ev.buf, noremap = true, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gf', GoToDefinitionInNewTab, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- Rename, format, code actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
    -- Diagnostics
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[[', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']]', vim.diagnostic.goto_next, opts)
  end,
})
-- LSP STUFFS END

-- LATEXX Stuffs Start
vim.g.tex_flavor = 'latex'
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_quickfix_mode = 2
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
  options = {
    '-pdf',
    '-shell-escape',
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}
vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_complete_close_braces = 1

vim.keymap.set('n', '<leader>lc', ':VimtexCompile<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lv', ':VimtexView<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lt', ':VimtexTocToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>lx', ':VimtexClean<CR>', { noremap = true, silent = true })
-- LATEXX Stuffs End

-- Basic Neovim Settings
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Show relative line numbers

-- Ensure terminal buffers show line numbers
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("TerminalRelativeNumber", { clear = true }),
  callback = function()
    vim.wo.relativenumber = true
    vim.wo.number = true
  end
})

vim.o.linebreak = true -- Wrap lines at convenient points
vim.o.laststatus = 2 -- Always show status line
vim.o.shiftwidth = 4 -- Indentation width
vim.g.mapleader = " " -- Set leader key to space
vim.cmd('colorscheme rose-pine') -- Set default colorscheme
vim.cmd('hi LineNr guifg=#FFFF00')

-- Hopper Highlight settings for hop.nvim
vim.cmd('hi HopNextKey guifg=#FFFFFF')
vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
vim.cmd('hi HopNextKey2 guifg=#00FF00')

-- Keymap Configurations
-- Basic commands
vim.api.nvim_set_keymap('n', ':W', ':w', { noremap = true }) -- Save file
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true }) -- Exit terminal mode

-- Move quickly
vim.api.nvim_set_keymap('n', ',', '5l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'm', '5h', { noremap = true, silent = true })

-- Copy pasting helper
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-x>', '"+d', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-a>', 'gg0v<S-$>Gh', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-a>', '<Esc>gg0v<S-$>Gh', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-v>', '<Esc>"+p', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-v>', 'c<Esc>"+p', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-v>', '<C-\\><C-n>"+pa', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-b>', '<Esc>p', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-b>', 'c<Esc>p', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-b>', '<C-\\><C-n>pa', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-v>', '0v<A-$>h', { noremap = true })

-- Navigate with hjkl in insert mode
vim.api.nvim_set_keymap('i', '<A-h>', '<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-j>', '<Down>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-k>', '<Up>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-l>', '<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-a>', '<End>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-i>', '<Home>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-s>', '<Esc>viw', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-s>', 'viw', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-BS>', '<C-w>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<A-w>', '<Esc>wa', { noremap = true, silent = true })

-- Quick tabbing
vim.keymap.set('v', '<Tab>', '>gv', { noremap = true })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true })

-- Disable recording
vim.api.nvim_set_keymap('n', 'q', '<Nop>', { noremap = true, silent = true })

-- Move to end or beginning of line
vim.api.nvim_set_keymap('n', '-', '<S-$>', { noremap = true })
vim.api.nvim_set_keymap('v', '-', '<S-$>h', { noremap = true })

-- Open new view
vim.api.nvim_set_keymap('n', '<C-A-x>', ':new<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-A-v>', ':botright vnew<CR>', { noremap = true, silent = true })

-- Save file and exit shortcut
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-A-q>', ':lua _G.close_window_and_buffer()<CR>', { noremap = true, silent = true })

-- Function to check if current buffer is a terminal
local function is_terminal_tab()
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
  return buftype == 'terminal'
end

-- Function to open nvim-tree
local function open_nvim_tree()
  if not is_terminal_tab() then
    vim.cmd('NvimTreeOpen')
  end
end

-- Function to close nvim-tree
local function close_nvim_tree()
    vim.cmd('NvimTreeClose')
end

-- Autocommand to toggle nvim-tree on BufEnter
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    if is_terminal_tab() then
      vim.o.number = true -- Show line numbers
      vim.o.relativenumber = true -- Show relative line numbers
      close_nvim_tree()
    end
  end,
  group = vim.api.nvim_create_augroup('NvimTreeAutoToggle', { clear = true }),
})


-- Function to toggle nvim-tree manually
_G.open_nvim_tree_conditional = function()
  if is_terminal_tab() then
    print("Cannot open NvimTree in a terminal tab.")
  else
    open_nvim_tree()
  end
end

-- Navigation and plugin keymaps
vim.api.nvim_set_keymap('n', '<F1>', ':HopWord<CR>', { noremap = true }) -- Hop to word in normal mode
vim.api.nvim_set_keymap('i', '<F1>', '<Esc>:HopWord<CR>', { noremap = true }) -- Hop to word in insert mode
vim.api.nvim_set_keymap('v', '<F1>', '<Esc>:HopWord<CR>', { noremap = true }) -- Hop to word in insert mode
vim.api.nvim_set_keymap('n', '<F2>', ':nohlsearch<CR>', { noremap = true }) -- Clear search highlights
vim.api.nvim_set_keymap('i', '<F2>', '<Esc>:nohlsearch<CR>', { noremap = true }) -- Clear search highlights
vim.api.nvim_set_keymap('v', '<F2>', '<Esc>:nohlsearch<CR>', { noremap = true }) -- Clear search highlights
vim.api.nvim_set_keymap('t', '<F2>', '<C-\\><C-n>:nohlsearch<CR>', { noremap = true }) -- Clear search highlights
-- Keymap to toggle nvim-tree conditionally
vim.api.nvim_set_keymap('n', '<F3>', ':lua _G.open_nvim_tree_conditional()<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeOpen<CR>', { noremap = true }) -- Open nvim-tree
vim.api.nvim_set_keymap('n', '<F4>', ':Mason<CR>', { noremap = true }) -- Open Mason
vim.api.nvim_set_keymap('n', '<F5>', ':GuessIndent<CR>', { noremap = true }) -- Run guess-indent
vim.api.nvim_set_keymap('n', '<F6>', ':lua require("lint").try_lint()<CR>', { noremap = true }) -- Run linter
vim.api.nvim_set_keymap('n', '<F7>', ':Gitsigns toggle_signs<CR>', { noremap = true, silent = true }) -- Toggle git signs
-- vim.api.nvim_set_keymap('n', '<F8>', ':Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true }) -- Toggle git blame
vim.api.nvim_set_keymap('n', '<F8>', ':Gitsigns blame<CR>', { noremap = true, silent = true }) -- Toggle git blame
vim.api.nvim_set_keymap('n', '<F11>', ':source $MYVIMRC<CR>', { noremap = true }) -- Reload config
vim.api.nvim_set_keymap('n', '<F12>', ':e $MYVIMRC<CR>', { noremap = true }) -- Edit config

-- Window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-W>h', { noremap = true }) -- Move to left window
vim.api.nvim_set_keymap('n', '<C-l>', '<C-W>l', { noremap = true }) -- Move to right window
vim.api.nvim_set_keymap('n', '<C-k>', '<C-W>k', { noremap = true }) -- Move to upper window
vim.api.nvim_set_keymap('n', '<C-j>', '<C-W>j', { noremap = true }) -- Move to lower window
vim.api.nvim_set_keymap('n', ':NTO', ':NvimTreeOpen', { noremap = true, silent = true })

-- Toggleterm keymaps
vim.api.nvim_set_keymap('n', '<A-1>', ':ToggleTerm 1<CR>', { noremap = true }) -- Open terminal 1
vim.api.nvim_set_keymap('n', '<A-2>', ':ToggleTerm 2<CR>', { noremap = true }) -- Open terminal 2
vim.api.nvim_set_keymap('n', '<A-3>', ':ToggleTerm 3<CR>', { noremap = true }) -- Open terminal 3
vim.api.nvim_set_keymap('n', '<A-4>', ':ToggleTerm 4<CR>', { noremap = true }) -- Open terminal 4
vim.api.nvim_set_keymap('n', '<A-5>', ':ToggleTerm 5<CR>', { noremap = true }) -- Open terminal 5
vim.api.nvim_set_keymap('n', '<A-6>', ':ToggleTerm 6<CR>', { noremap = true }) -- Open terminal 6
vim.api.nvim_set_keymap('n', '<A-7>', ':ToggleTerm 7<CR>', { noremap = true }) -- Open terminal 7
vim.api.nvim_set_keymap('n', '<A-8>', ':ToggleTerm 8<CR>', { noremap = true }) -- Open terminal 8

-- Colorscheme switching function
_G.set_colorscheme_and_highlight = function(colorscheme)
  -- Set colorscheme
  vim.cmd('colorscheme ' .. colorscheme)

  -- Set LineNr color based on colorscheme for high contrast
  if colorscheme == 'kanagawa' then
    vim.cmd('hi LineNr guifg=#FFFF00') -- Soft off-white from Kanagawa for high contrast against dark background
  elseif colorscheme == 'rose-pine' then
    vim.cmd('hi LineNr guifg=#FFFF00') -- Subtle lavender from Rose Pine for contrast and harmony
  elseif colorscheme == 'everforest' then
    vim.cmd('hi LineNr guifg=#00FF00') -- Warm off-white from Everforest for clear visibility
  else
    vim.cmd('hi LineNr guifg=#FFFFFF') -- Fallback to white
  end

  -- Reapply hop.nvim highlight settings after colorscheme change
  vim.cmd('hi HopNextKey guifg=#FFFFFF')
  vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
  vim.cmd('hi HopNextKey2 guifg=#00FF00')
end

-- Colorscheme keymaps
vim.api.nvim_set_keymap('n', '<leader>1',
  [[<Cmd>lua set_colorscheme_and_highlight('kanagawa')<CR>]],
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>2',
  [[<Cmd>lua set_colorscheme_and_highlight('rose-pine')<CR>]],
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>3',
  [[<Cmd>lua set_colorscheme_and_highlight('everforest')<CR>]],
  { noremap = true, silent = true })

-- Tab Navigation
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew<CR>', { noremap = true, silent = true }) -- Create new tab
vim.api.nvim_set_keymap('i', '<C-t>', '<Esc>:tabnew<CR>', { noremap = true, silent = true }) -- Create new tab
vim.api.nvim_set_keymap('i', '<C-d>', '', { noremap = true, silent = true }) -- Create new tab
vim.api.nvim_set_keymap('n', '<A-Left>', ':tabprevious<CR>', { noremap = true, silent = true }) -- Previous tab
vim.api.nvim_set_keymap('n', '<A-Right>', ':tabnext<CR>', { noremap = true, silent = true }) -- Next tab

-- vim.api.nvim_set_keymap('n', '<A-h>', ':tabprevious<CR>', { noremap = true, silent = true }) -- Previous tab (vim-style)
-- vim.api.nvim_set_keymap('n', '<A-l>', ':tabnext<CR>', { noremap = true, silent = true }) -- Next tab (vim-style)
vim.api.nvim_set_keymap('n', '<A-l>', ':normal <C-l><CR>:tabnext<CR>:normal <C-l><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-h>', ':normal <C-l><CR>:tabprevious<CR>:normal <C-l><CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<S-A-Left>', ':tabmove -1<CR>', { noremap = true, silent = true }) -- Move tab left
vim.api.nvim_set_keymap('n', '<S-A-Right>', ':tabmove +1<CR>', { noremap = true, silent = true }) -- Move tab right
vim.api.nvim_set_keymap('n', '<S-A-h>', ':tabmove -1<CR>', { noremap = true, silent = true }) -- Move tab left (vim-style)
vim.api.nvim_set_keymap('n', '<S-A-l>', ':tabmove +1<CR>', { noremap = true, silent = true }) -- Move tab right (vim-style)

-- Function to close tab and delete buffer with unsaved changes warning
_G.close_tab_and_buffer = function()
  local buf = vim.api.nvim_get_current_buf()
  local buf_modified = vim.api.nvim_buf_get_option(buf, 'modified')

  -- Check if the buffer has unsaved changes
  if buf_modified then
    local choice = vim.fn.confirm(
      "File has unsaved changes. Close without saving? (y/n)",
      "&Yes\n&No",
      2, -- Set Cancel as the default choice
      "Warn"
    )
    if choice ~= 1 then
      print("Tab close cancelled")
      return
    end
  end

  -- Check if the current buffer is a terminal
  local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
  if buftype == 'terminal' then
    local choice = vim.fn.confirm(
      "Are you sure you want to close the terminal? (y/n)",
      "&Yes\n&No",
      2, -- Set Cancel as the default choice
      "Warn"
    )
    if choice ~= 1 then
      print("Terminal close cancelled")
      return
    end
  end

  -- Close the tab and delete the buffer
  vim.cmd('tabclose')
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

-- Function to close window and delete buffer with unsaved changes warning
_G.close_window_and_buffer = function()
  local buf = vim.api.nvim_get_current_buf()
  local buf_modified = vim.api.nvim_buf_get_option(buf, 'modified')

  -- Check if the buffer has unsaved changes
  if buf_modified then
    local choice = vim.fn.confirm(
      "File has unsaved changes. Close without saving? (y/n)",
      "&Yes\n&No",
      2, -- Set Cancel as the default choice
      "Warn"
    )
    if choice ~= 1 then
      print("Quit cancelled")
      return
    end
  end

  -- Check if the current buffer is a terminal
  local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
  if buftype == 'terminal' then
    local choice = vim.fn.confirm(
      "Are you sure you want to close the terminal? (y/n)",
      "&Yes\n&No",
      2, -- Set Cancel as the default choice
      "Warn"
    )
    if choice ~= 1 then
      print("Terminal close cancelled")
      return
    end
  end

  -- Close the window and delete the buffer
  vim.cmd('q!')
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

-- Function to handle <A-w> based on the number of tabs
_G.handle_alt_w = function()
  local tab_count = #vim.api.nvim_list_tabpages()
  if tab_count > 1 then
    _G.close_tab_and_buffer()
  else
    _G.close_window_and_buffer()
  end
end

-- Override the :q and :Q commands to use the custom function
vim.api.nvim_set_keymap('n', ':Q', ':lua _G.close_window_and_buffer()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ':q', ':lua _G.close_window_and_buffer()<CR>', { noremap = true, silent = true })

-- Override the <A-w> keymap to use the conditional function
vim.api.nvim_set_keymap('n', '<A-w>', ':lua _G.handle_alt_w()<CR>', { noremap = true, silent = true })
-- Close tab without deleting from buffer
vim.api.nvim_set_keymap('n', '<C-A-w>', ':tabclose<CR>', { noremap = true, silent = true })

-- Configure gitsigns for git integration
require('gitsigns').setup {
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  -- Keymaps for git signs operations
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    -- Actions
    map('n', '<leader>td', gs.toggle_deleted) -- Toggle deleted lines
  end
}

-- Telescope Keymaps
vim.api.nvim_set_keymap('n', '<C-A-f>', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true }) -- Live grep
vim.api.nvim_set_keymap('n', '<C-A-p>', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true }) -- Find files
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true }) -- List buffers
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true }) -- Help tags
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope git_files<CR>', { noremap = true, silent = true }) -- Git files
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { noremap = true, silent = true }) -- Recent files

-- Gitsigns navigation
vim.api.nvim_set_keymap('n', '<C-n>', ':Gitsigns next_hunk<CR>', { noremap = true, silent = true }) -- Next git hunk
vim.api.nvim_set_keymap('n', '<C-p>', ':Gitsigns prev_hunk<CR>', { noremap = true, silent = true }) -- Previous git hunk

-- notes
-- 1. install xclip di linux kalo gabisa pake clipboard
-- 2. cara install nvim versi baru di linux
-- tar -xzf nvim-linux-x86_64.tar.gz
-- sudo mv nvim-linux-x86_64 /usr/local/nvim
-- sudo ln -s /usr/local/nvim/bin/nvim /usr/local/bin/nvim

-- installed lsp 
--  Installed
--    ✓ clangd
--    ✓ docker-compose-language-service docker_compose_language_service
--    ✓ dockerfile-language-server dockerls
--    ✓ pyright
--    ✓ typescript-language-server ts_ls
--    ✓ tailwindcss-language-server tailwindcss
--
--  Installed
--    ✓ pyright
--    ✓ tailwindcss-language-server tailwindcss
--    ✓ clangd
--    ✓ typescript-language-server ts_ls
