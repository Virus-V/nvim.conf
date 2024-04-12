local global = vim.g
local opt = vim.opt
local o = vim.o
local wo = vim.wo

-- Map <leader> = the space key

-- global.mapleader = " "
-- global.maplocalleader = " "

-- Editor options
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
-- set tab to space
-- o.expandtab = false
-- set space to tab
-- change at runtime:  :lua vim.o.expandtab = false
o.expandtab = true

o.autoindent = true
--o.copyindent = true
o.clipboard = "unnamedplus"

o.list = true
o.hidden = true
o.number = true
o.relativenumber = false
o.showcmd = true
o.cursorline = true
o.cursorcolumn = true
o.wildmenu = true
o.showmatch = true
o.laststatus = 2

o.backup = false
o.swapfile = false

o.wrap = false
o.mouse = "v"
--o.scrolloff = 12
--o.updatetime = 10
--o.nofsync = true
--o.undofile = true
--o.undodir = "~/.vim/undodir"
o.syntax = "on"
o.encoding = "UTF-8"
o.ruler = true
o.title = true
o.inccommand = "split"
-- o.splitbelow = "splitright"
o.autoread = true
opt.colorcolumn = "79"

-- set termguicolors to enable highlight groups
opt.termguicolors = true

--Relative line number
wo.relativenumber = false

-- disable auto new comment line when o
-- 在Normal模式下，输入o新起一行，不要自动根据上一行添加注释符
vim.api.nvim_create_autocmd(
  "FileType",
  {pattern = "*", callback = function(ev)
    -- print(string.format('event fired: %s', vim.inspect(ev)))
    -- :verb set formatoptions  -- show who last touch the veriable
    vim.opt.formatoptions:remove({ 'o' })
  end}
)

-- 加载lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Toggle tab and space
-- 切换Tab键输出\t还是空格，在空白风格不统一且需要修改代码的时候很有用
-- <leader>是\字符（backspace下面），<tab>就是Tab键
-- lualine 插件右下角里会显示当前是tab还是space
vim.keymap.set('n', '<leader><tab>', function ()
  o.expandtab = not o.expandtab
  require('lualine').refresh()
end, { noremap=true, silent=true })

plugins = {
  -- scheme
  -- 主题，这个颜色柔和不伤眼，长时间看不累
  {
    "sainnhe/gruvbox-material",
    config = function()
      vim.cmd("colorscheme gruvbox-material")
    end
  },

  -- Treesitter
  -- 语法高亮插件
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter.configs").setup {
        -- One of "all", "maintained" (parsers with maintainers), or a list of languages
        ensure_installed = { "c", "cpp", "make", "vim", "go" },

        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- List of parsers to ignore installing
        ignore_install = { "javascript" },

        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- list of language that will be disabled
          -- disable = { "c", "rust" },

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }
    end,
    config = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
  },

  -- LSP(Language Server Protocol)
  -- 替代Cscope的新一代代码跳转工具，有一系列快捷键，看下面的配置
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      'hrsh7th/nvim-cmp',
    },
    lazy = true,
    ft = {"c", 'h', 'cpp', 'hpp', 'go'},
    config = function()
      -- Mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      local opts = { noremap=true, silent=true }
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

      --[[
      local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
      ]]

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts) -- 跳转到声明，一般在头文件中
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts) -- 跳转到定义
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts) -- 显示当前符号的信息（如函数签名，可以看到什么参数，返回值及其各自的类型等）
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts) -- 跳到实现（C中不常用，go语言或者C++中一般会对interface，跳到其实现的地方）
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts) -- Ctrl+k 不常用（不知道是啥）
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts) -- 下面三个不常用，好像和clangd的检索目录有关系
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts) --
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts) -- 重命名一个符号，很强大的功能，可以把一个函数或者变量全部改名字，用到的地方自动修改
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts) --
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts) -- 查看哪里使用了当前的符号
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts) -- 对代码进行格式化
      end

      -- vim.lsp.set_log_level 'debug'

      -- Set up lspconfig.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
      require('lspconfig')['clangd'].setup({
        --cmd = { 'nc', '127.0.0.1', '1234' },
        cmd = { 'clangd', '--query-driver=**' }, -- clangd 代码解析器的路径
        on_attach = on_attach,
        capabilities = capabilities
      })

      require('lspconfig')['gopls'].setup({
        on_attach = on_attach,
        capabilities = capabilities
      })

    end,
  },

  -- golang
  -- go语言开发环境
  {
    "ray-x/go.nvim",
    lazy = true,
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
         require('go.format').goimport()
        end,
        group = format_sync_grp,
      })
    end,
    --event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = function()
      require("go.install").update_all_sync()
    end,

  },

  -- myword
  -- 单词高亮，可以对多个单词用不同颜色高亮
  {
    "dwrdx/mywords.nvim",
    keys = {
      {
        "<leader>m", -- <leader>m，对当前光标的单词进行高亮，再按一次取消高亮
        function ()
          require'mywords'.hl_toggle()
        end,
        desc = "toggle highlight a word"
      },
      {
        "<leader>c", -- 取消全部高亮
        function ()
          require'mywords'.uhl_all()
          vim.cmd([[nohlsearch]])
        end,
        desc = "Highlight clear all"
      },
    },
  },

  -- status line
  -- lualine状态栏，在nvim的最下面一行，显示当前状态的，可以定制
  {
    'nvim-lualine/lualine.nvim',
    --dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
    config = function()
      local function get_expandtab() -- 比如可以显示当前是tab还是空格
        if (o.expandtab) then
          return [[space]]
        else
          return [[tab]]
        end
      end
      require('lualine').setup({
        options = {
          icons_enabled = false,
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
        sections = {
          lualine_x = {'encoding', 'fileformat', 'filetype', get_expandtab},
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 1,
              shorting_target = 40,
              symbols = {
               modified = '[+]',
               readonly = '[-]',
               unnamed = '[No Name]',
               newfile = '[New]',
              }
            }
          },
        }
      })
    end,
  },

  -- A completion engine plugin for neovim written in Lua.
  -- 基于LSP的自动补全工具
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip'
    },
    lazy = true,
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
          end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        -- 快捷键在这里，可以试试看
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<S-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' }, -- For vsnip users.
          -- { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
          { name = "codeium" }
        }, {
          { name = 'buffer' },
        })
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = 'buffer' },
        })
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end,
  },

  -- telescope
  -- 文件搜索/内容搜索工具，非常有用
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'gbrlsnchs/telescope-lsp-handlers.nvim'
    },

    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- 查找文件，类似于fzf
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {}) -- 在当前目录全局查找字符串
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {}) -- 查找nvim打开的buffer
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {}) -- 查找有哪些help，全局检索帮助文档
      vim.keymap.set('n', '<leader>fp', builtin.builtin, {}) -- 列出内置的检索器

      local telescope = require("telescope")
      local telescopeConfig = require("telescope.config")

      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      local ignore_file_suffix = "!*.{o,elf,i,s,d,ninja,cmake}"

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      table.insert(vimgrep_arguments, "--no-ignore")

      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!.cache/*")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")

      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, ignore_file_suffix)

      telescope.setup({
        defaults = {
          -- `hidden = true` is not supported in text grep commands.
          vimgrep_arguments = vimgrep_arguments,
          layout_strategy='vertical',
          layout_config = {
            -- other layout configuration here
          },
        },
        pickers = {
          find_files = {
            --theme = "dropdown",
            find_command = { "rg", "--files", "--hidden", "--no-ignore",
              "--glob", "!.cache/*",
              "--glob", "!**/.git/*",
              "--glob", ignore_file_suffix,
            },
          },
          live_grep = {
            --theme = "dropdown",
          },
        },
      })

      telescope.load_extension('lsp_handlers')
    end
  },

  -- This plugin trims trailing whitespace and lines.
  -- 在保存的时候，自动去掉文件头尾的空行，以及行尾的空格
  {
    "cappyzawa/trim.nvim",
    config = function()
      require("trim").setup({
        ft_blocklist = {"markdown"},
      })
    end
  },

  -- Native Codeium plugin for Neovim.
  {
    "Exafunction/codeium.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({
        })
    end
  },
}

require("lazy").setup(plugins, opts)
