-- ~/.config/lvim/config.lua
-- Configuração LunarVim para Python/Django, JavaScript e Go

-- ===========================
-- CONFIGURAÇÕES GERAIS
-- ===========================
lvim.log.level = "warn"
lvim.colorscheme = "dracula"

-- Leader key
lvim.leader = "space"

-- Configurações do editor
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.timeoutlen = 200
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- ===========================
-- PLUGINS
-- ===========================
lvim.plugins = {
    -- Python
    {
        "AckslD/swenv.nvim",
        config = function()
            require('swenv').setup({
                post_set_venv = function()
                    vim.cmd("LspRestart")
                end,
            })
        end
    },

    -- Go
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                lsp_codelens = false,
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go" },
    },

    -- JavaScript/TypeScript
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },

    -- Testes (com dependência nvim-nio)
    {
        "nvim-neotest/nvim-nio",
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-go",
            "haydenmeade/neotest-jest",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        args = { "--log-level", "DEBUG" },
                        runner = "pytest",
                    }),
                    require("neotest-go"),
                    require("neotest-jest")({
                        jestCommand = "npm test --",
                        env = { CI = true },
                        cwd = function()
                            return vim.fn.getcwd()
                        end,
                    }),
                }
            })
        end,
    },

    -- Git
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
    },

    -- Melhorias gerais
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    {
        "folke/todo-comments.nvim",
        event = "BufRead",
        config = function()
            require("todo-comments").setup()
        end
    },
    { "dracula/vim" },
    -- GitHub Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = "<M-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
                panel = {
                    enabled = true,
                    auto_refresh = false,
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<M-CR>"
                    },
                    layout = {
                        position = "bottom",
                        ratio = 0.4
                    },
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                },
            })
        end,
    },

}

-- ===========================
-- LSP CONFIGURAÇÃO
-- ===========================

-- Python (Pyright)
require("lvim.lsp.manager").setup("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
            }
        }
    }
})

-- Go (gopls)
require("lvim.lsp.manager").setup("gopls", {
    settings = {
        gopls = {
            gofumpt = true,
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
        }
    }
})

-- JavaScript/TypeScript
require("lvim.lsp.manager").setup("tsserver", {
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
            }
        }
    }
})

-- ESLint
require("lvim.lsp.manager").setup("eslint", {
    settings = {
        workingDirectory = { mode = "auto" }
    }
})

-- HTML/CSS
require("lvim.lsp.manager").setup("html")
require("lvim.lsp.manager").setup("cssls")

-- ===========================
-- FORMATTERS & LINTERS
-- ===========================
-- Comentado temporariamente devido a bug no none-ls.nvim
--[[
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  { command = "gofumpt", filetypes = { "go" } },
  { command = "goimports", filetypes = { "go" } },
  { command = "prettier", filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "markdown" } },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "ruff", filetypes = { "python" } },
  { command = "eslint_d", filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" } },
  { command = "golangci_lint", filetypes = { "go" } },
}
]]

-- ===========================
-- TREESITTER
-- ===========================
lvim.builtin.treesitter.ensure_installed = {
    "python",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "css",
    "json",
    "yaml",
    "toml",
    "lua",
    "vim",
    "markdown",
}

-- Desabilitar Treesitter para Go (conflito de versão)
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.highlight.disable = { "go" }

-- ===========================
-- KEYMAPS PERSONALIZADOS
-- ===========================

-- Python
lvim.builtin.which_key.mappings["P"] = {
    name = "Python",
    v = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Select VirtualEnv" },
    r = { "<cmd>!python %<cr>", "Run Python File" },
    d = { "<cmd>!python manage.py runserver<cr>", "Django Runserver" },
    m = { "<cmd>!python manage.py makemigrations<cr>", "Django Makemigrations" },
    g = { "<cmd>!python manage.py migrate<cr>", "Django Migrate" },
}

-- Go
lvim.builtin.which_key.mappings["G"] = {
    name = "Go",
    r = { "<cmd>GoRun<cr>", "Run" },
    t = { "<cmd>GoTest<cr>", "Test" },
    c = { "<cmd>GoCoverage<cr>", "Coverage" },
    f = { "<cmd>GoFmt<cr>", "Format" },
    i = { "<cmd>GoImpl<cr>", "Implement Interface" },
    a = { "<cmd>GoAlt<cr>", "Alternate File" },
    d = { "<cmd>GoDoc<cr>", "Documentation" },
}

-- Testes
lvim.builtin.which_key.mappings["t"] = {
    name = "Test",
    t = { "<cmd>lua require('neotest').run.run()<cr>", "Test Nearest" },
    f = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Test File" },
    d = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Debug Test" },
    s = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" },
    o = { "<cmd>lua require('neotest').output.open({ enter = true })<cr>", "Test Output" },
    r = { "<cmd>TroubleToggle<cr>", "Trouble" },
}

-- LazyGit
lvim.builtin.which_key.mappings["g"].g = { "<cmd>LazyGit<cr>", "LazyGit" }

-- GitHub Copilot
lvim.builtin.which_key.mappings["C"] = {
    name = "Copilot",
    s = { "<cmd>Copilot status<cr>", "Status" },
    p = { "<cmd>Copilot panel<cr>", "Panel" },
    d = { "<cmd>Copilot disable<cr>", "Disable" },
    e = { "<cmd>Copilot enable<cr>", "Enable" },
}

-- ===========================
-- AUTO COMMANDS
-- ===========================

-- Python: configurar indentação para 4 espaços
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})

-- JavaScript/TypeScript: configurar indentação para 2 espaços
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- Go: configurar tabs
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})

-- Django templates
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.html",
    callback = function()
        vim.bo.filetype = "htmldjango"
    end,
})

-- ===========================
-- CONFIGURAÇÕES ADICIONAIS
-- ===========================

-- Telescope
lvim.builtin.telescope.on_config_done = function(telescope)
    pcall(telescope.load_extension, "fzf")
end

-- Alpha (dashboard)
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"

-- Terminal
lvim.builtin.terminal.active = true

-- Nvim-tree
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- Desabilitar illuminate (conflito com null-ls)
lvim.builtin.illuminate.active = false
