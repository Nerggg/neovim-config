-- C:\Users\Administrator\AppData\Local\nvim
-- ~/.config/nvim/
-- Enable Vim loader for improved performance
vim.loader.enable()

-- Disable built-in netrw plugins to avoid conflicts with nvim-tree
vim.g.loaded_netrw = 1 
vim.g.loaded_netrwPlugin = 1

-- Enable true color support in terminal
vim.opt.termguicolors = true

-- Initialize Vim-Plug plugin manager
vim.cmd('call plug#begin()')

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
vim.cmd('Plug \'saadparwaiz1/cmp_luasnip\'') -- Luasnip source for nvim-cmp
vim.cmd('Plug \'rafamadriz/friendly-snippets\'') -- Predefined snippets
-- LSP STUFFS END

-- Telescope plugins
vim.cmd('Plug \'nvim-lua/plenary.nvim\'') -- Telescope dependency
vim.cmd('Plug \'nvim-telescope/telescope.nvim\'') -- Fuzzy finder
vim.cmd('Plug \'nvim-telescope/telescope-file-browser.nvim\'') -- File browser extension

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
      ".git",
      "target",
      "build",
      "dist",
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
    'pyright',
    'clangd',
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
local luasnip = require('luasnip')

-- Load VSCode-style snippets
require('luasnip.loaders.from_vscode').lazy_load()

-- Setup nvim-cmp with mappings and sources
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
    --['<CR>'] = cmp.mapping.confirm({ select = true }),
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

-- Setup LSP capabilities for autocompletion
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup LSP servers with mason-lspconfig
require('mason-lspconfig').setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      capabilities = capabilities,
    })
  end,

  -- Custom configuration for lua_ls
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

  -- Custom configuration for clangd
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

-- LSP keymappings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local function GoToDefinitionInNewTab()
      vim.lsp.buf.definition()
      vim.cmd('tabnew')
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
vim.cmd('colorscheme lunaperche') -- Set default colorscheme

-- Hopper Highlight settings for hop.nvim
vim.cmd('hi HopNextKey guifg=#FFFFFF')
vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
vim.cmd('hi HopNextKey2 guifg=#00FF00')

-- Keymap Configurations
-- Basic commands
vim.api.nvim_set_keymap('n', ':W', ':w', { noremap = true }) -- Save file
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true }) -- Exit terminal mode

-- Copy pasting helper
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-x>', '"+d', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-a>', 'G<S-$>v0gg', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-a>', 'gg0v<S-$>Gh', { noremap = true })

-- Move to end or beginning of line
vim.api.nvim_set_keymap('n', '-', '<S-$>', { noremap = true })
vim.api.nvim_set_keymap('v', '-', '<S-$>', { noremap = true })

-- Open new view
vim.api.nvim_set_keymap('n', '<C-A-x>', ':new<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-A-v>', ':botright vnew<CR>', { noremap = true, silent = true })

-- Navigation and plugin keymaps
vim.api.nvim_set_keymap('n', '<F1>', ':HopWord<CR>', { noremap = true }) -- Hop to word
vim.api.nvim_set_keymap('i', '<F1>', '', { noremap = true }) -- Disable help
vim.api.nvim_set_keymap('n', '<F2>', ':nohlsearch<CR>', { noremap = true }) -- Clear search highlights
vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeOpen<CR>', { noremap = true }) -- Open nvim-tree
vim.api.nvim_set_keymap('n', '<F4>', ':Mason<CR>', { noremap = true }) -- Open Mason
vim.api.nvim_set_keymap('n', '<F5>', ':GuessIndent<CR>', { noremap = true }) -- Run guess-indent
vim.api.nvim_set_keymap('n', '<F6>', ':lua require("lint").try_lint()<CR>', { noremap = true }) -- Run linter
vim.api.nvim_set_keymap('n', '<F7>', ':Gitsigns toggle_signs<CR>', { noremap = true, silent = true }) -- Toggle git signs
vim.api.nvim_set_keymap('n', '<F8>', ':Gitsigns toggle_current_line_blame<CR>', { noremap = true, silent = true }) -- Toggle git blame
vim.api.nvim_set_keymap('n', '<F11>', ':source $MYVIMRC<CR>', { noremap = true }) -- Reload config
vim.api.nvim_set_keymap('n', '<F12>', ':e $MYVIMRC<CR>', { noremap = true }) -- Edit config

-- Window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-W>h', { noremap = true }) -- Move to left window
vim.api.nvim_set_keymap('n', '<C-l>', '<C-W>l', { noremap = true }) -- Move to right window
vim.api.nvim_set_keymap('n', '<C-k>', '<C-W>k', { noremap = true }) -- Move to upper window
vim.api.nvim_set_keymap('n', '<C-j>', '<C-W>j', { noremap = true }) -- Move to lower window

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

  -- Reapply hop.nvim highlight settings after colorscheme change
  vim.cmd('hi HopNextKey guifg=#FFFFFF')
  vim.cmd('hi HopNextKey1 guifg=#FFFFFF')
  vim.cmd('hi HopNextKey2 guifg=#00FF00')
end

-- Colorscheme keymaps
vim.api.nvim_set_keymap('n', '<Leader>1',
  [[<Cmd>lua set_colorscheme_and_highlight('lunaperche')<CR>]],
  { noremap = true, silent = true }) -- Switch to lunaperche
vim.api.nvim_set_keymap('n', '<Leader>2',
  [[<Cmd>lua set_colorscheme_and_highlight('slate')<CR>]],
  { noremap = true, silent = true }) -- Switch to slate
vim.api.nvim_set_keymap('n', '<Leader>3',
  [[<Cmd>lua set_colorscheme_and_highlight('industry')<CR>]],
  { noremap = true, silent = true }) -- Switch to industry

-- Tab Navigation
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew<CR>', { noremap = true, silent = true }) -- Create new tab
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

-- Override the :q and :Q commands to use the custom function
vim.api.nvim_set_keymap('n', ':Q', ':lua _G.close_window_and_buffer()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ':q', ':lua _G.close_window_and_buffer()<CR>', { noremap = true, silent = true })

-- Override the <A-w> keymap to use the custom tab close function
vim.api.nvim_set_keymap('n', '<A-w>', ':lua _G.close_tab_and_buffer()<CR>', { noremap = true, silent = true })
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
