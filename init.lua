local global = vim.g
local opt = vim.opt
local o = vim.o

-- Map <leader> = the space key

-- global.mapleader = " "
-- global.maplocalleader = " "

-- Editor options
o.tabstop = 2
o.softtabstop = 2
o.shiftwidth = 2
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

-- automatically install and set up packer.nvim
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        vim.notify("Cloning Pakcer.nvim, waitting...")
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.notify("Installing Pakcer.nvim ...")
        vim.cmd [[packadd packer.nvim]]
        vim.notify("Pakcer.nvim installed finished")
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- Use a protected call so we don't error out on first
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    vim.notify("packer not installed")
    return
end

-- Automatically run: PackerCompile
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("PACKER", { clear = true }),
  pattern = "init.lua",
  command = "source <afile> | PackerCompile",
})

packer.startup({
  function()
    -- Packer
    use({"wbthomason/packer.nvim"})

    -- scheme
    use({
      "sainnhe/gruvbox-material",
      config = function()
        vim.cmd("colorscheme gruvbox-material")
      end
    })

    -- Treesitter
    use({
      "nvim-treesitter/nvim-treesitter",
      run = function()
        require("nvim-treesitter.install").update({ with_sync = true })
      end,
      config = function()
        require("nvim-treesitter.configs").setup {
          -- One of "all", "maintained" (parsers with maintainers), or a list of languages
          ensure_installed = { "c", "cpp", "make", "vim" },

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
    })

    -- LSP
    use({
      "neovim/nvim-lspconfig",
      requires = {
        'hrsh7th/nvim-cmp',
      },

      config = function()
        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = { noremap=true, silent=true }
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local bufopts = { noremap=true, silent=true, buffer=bufnr }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, bufopts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
        end

        -- vim.lsp.set_log_level 'debug'

        -- Set up lspconfig.
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
        require('lspconfig')['clangd'].setup({
          cmd = { 'clangd12', "-j 32" },
          on_attach = on_attach,
          capabilities = capabilities
        })

        require('lspconfig')['gopls'].setup({
          on_attach = on_attach,
          capabilities = capabilities
        })

      end,
    })

    use({
      "ray-x/go.nvim",
      requires = {
        "ray-x/guihua.lua",
      },
      run = function()
        require("go.install").update_all_sync()
        local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.go",
          callback = function()
           require('go.format').goimport()
          end,
          group = format_sync_grp,
        })
      end,
      config = function ()
        require("go").setup()
      end,
    })

    -- myword
    use({
      "dwrdx/mywords.nvim",
      config = function()
        vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>lua require'mywords'.hl_toggle()<CR>", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("n", "<leader>c", "<CMD>lua require'mywords'.uhl_all()<CR>", { noremap = true, silent = true })
      end
    })

    -- status line
    use ({
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true },
      config = function()
        require('lualine').setup({
          options = {
            icons_enabled = false,
            theme = "gruvbox-material",
            component_separators = { left = "", right = "|" },
            section_separators = { left = "", right = "" },
          },
          sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
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
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
          },
          tabline = {
            lualine_a = {'buffers'},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {'tabs'}
          }
        })
      end,
    })

    -- A completion engine plugin for neovim written in Lua.
    use ({
      'hrsh7th/nvim-cmp',
      requires = {
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-vsnip',
        'hrsh7th/vim-vsnip'
      },
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
    })

    -- telescope
    use({
      'nvim-telescope/telescope.nvim', tag = '0.1.1',
      requires = {
        'nvim-lua/plenary.nvim',
        'gbrlsnchs/telescope-lsp-handlers.nvim'
      },

      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fp', builtin.builtin, {})

        local telescope = require("telescope")
        local telescopeConfig = require("telescope.config")

        -- Clone the default Telescope configuration
        local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

        -- I want to search in hidden/dot files.
        table.insert(vimgrep_arguments, "--hidden")
        table.insert(vimgrep_arguments, "--no-ignore")

        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!.cache/*")
        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!**/.git/*")

        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!*.{o,elf}")

        telescope.setup({
          defaults = {
            -- `hidden = true` is not supported in text grep commands.
            vimgrep_arguments = vimgrep_arguments,
          },
          pickers = {
            find_files = {
              find_command = { "rg", "--files", "--hidden", "--no-ignore",
                "--glob", "!.cache/*",
                "--glob", "!**/.git/*",
                "--glob", "!*.{o,elf}",
              },
            },
          },
        })

        telescope.load_extension('lsp_handlers')
      end
    })

    -- This plugin trims trailing whitespace and lines.
    use({
      "cappyzawa/trim.nvim",
      config = function()
        require("trim").setup({})
      end
    })

    -- Automatically set up your configuration after cloning packer.nvim
    if packer_bootstrap then
        require('packer').sync()
    end
  end,

  config = {
    display = {
      open_fn = function()
        return require("packer.util").float({border = "rounded"})
      end,
    },
  }
})
