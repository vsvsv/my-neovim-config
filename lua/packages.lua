-- packages.lua - all additional packages and their config
--

-- Installs Lazy.nvim if not installed
local function ensureLazyPmInstalled()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim";
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        });
    end
    vim.opt.rtp:prepend(lazypath);
end

ensureLazyPmInstalled();

local getHlColor = function(hlstr, attr)
    ---@diagnostic disable-next-line: deprecated
    return string.format("#%06x", vim.api.nvim_get_hl_by_name(hlstr, true)[attr]);
end

local lazyPmOptions = {
    defaults = {
        lazy = true,
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
};

-- Lazy.nvim documentation: https://github.com/folke/lazy.nvim
require("lazy").setup({
    {
        -- https://github.com/nvim-tree/nvim-web-devicons
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
    {
        -- https://github.com/prichrd/netrw.nvim
        "prichrd/netrw.nvim",
        lazy = true,
        event = "UIEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("netrw").setup({
                use_devicons = true,
            });
        end,
    },
    {
        -- https://github.com/nvim-treesitter/nvim-treesitter
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = "all",
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            });
        end
    },
    {
        -- https://github.com/folke/flash.nvim
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,     desc = "Toggle Flash Search" },
        },
    },
    {
        -- https://github.com/numToStr/Comment.nvim -- comment and uncomment with "gc"
        "numToStr/Comment.nvim",
        lazy = true,
        event = "VeryLazy",
        opts = {
            padding = true,
            sticky = true,
        },
        config = function()
            require("Comment").setup(); -- "gcc" - toggle line comment; "gbc" - toggle block comment
        end
    },
    {
        -- https://github.com/nvim-lualine/lualine.nvim
        "nvim-lualine/lualine.nvim",
        lazy = true,
        event = { "UIEnter" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local colors = {
                fg     = getHlColor("@variable", "foreground"),
                bg     = "NONE",
                green  = getHlColor("String", "foreground"),
                purple = getHlColor("Function", "foreground"),
                red1   = getHlColor("ErrorMsg", "foreground"),
                gray1  = getHlColor("StatusLineNC", "foreground"),
                gray2  = getHlColor("EndOfBuffer", "foreground"),
                gray3  = getHlColor("SpecialKey", "foreground"),
            };
            local my_theme = {
                normal = {
                    a = { fg = colors.bg, bg = colors.gray3, gui = "bold" },
                    b = { fg = "#ffffff", bg = colors.gray1 },
                    c = { fg = colors.fg, bg = colors.gray3 },
                },
                insert = {
                    a = { fg = colors.gray3, bg = colors.green, gui = "bold" },
                },
                visual = {
                    a = { fg = colors.gray3, bg = colors.purple, gui = "bold" },
                },
                replace = {
                    a = { fg = colors.gray3, bg = colors.red1, gui = "bold" },
                },
                inactive = {
                    a = { fg = colors.gray1, bg = colors.gray3, gui = "bold" },
                    b = { fg = colors.gray1, bg = colors.gray3, gui = "bold" },
                    c = { fg = colors.gray1, bg = colors.gray3, gui = "bold" },
                },
            };
            local showGitStatus = function()
                if vim.b.gitsigns_status == nil then return "" else return vim.b.gitsigns_status end;
            end

            local my_fn = require("lualine.components.filename"):extend();
            my_fn.apply_icon = require("lualine.components.filetype").apply_icon;
            my_fn.icon_hl_cache = {};

            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    theme = my_theme,
                    -- theme = "catppuccin",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", showGitStatus, "diagnostics" },
                    lualine_c = { {
                        my_fn,
                        path = 1,
                        symbols = { modified = "", readonly = "", unnamed = " " },
                        colored = true,
                    } },
                    lualine_x = { "encoding", "fileformat" },
                    lualine_y = { "filetype" },
                    lualine_z = { { "datetime", style = "%H:%M" }, },
                },
            });
        end
    },
    {
        -- https://github.com/nvim-telescope/telescope.nvim
        "nvim-telescope/telescope.nvim",
        lazy = true,
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_strategy = "vertical",
                },
            });
            local builtin = require("telescope.builtin");
            vim.keymap.set("n", "<leader>ff", function() builtin.find_files() end, {});
            vim.keymap.set("n", "<leader>fg", function() builtin.live_grep() end, {});
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {});
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {});
            vim.keymap.set("n", "<leader>ft", builtin.diagnostics, {});     -- "t" for trouble
            vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions, {}); -- "d" for definitions
            vim.keymap.set("n", "<leader>fl", builtin.lsp_document_symbols, {});
            vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {});  -- "r" for references
            vim.keymap.set({ "n", "v" }, "<leader>fs", builtin.grep_string, {});
        end
    },
    {
        -- https://github.com/lewis6991/gitsigns.nvim
        "lewis6991/gitsigns.nvim",
        lazy = true,
        event = "VeryLazy",
        config = function()
            require("gitsigns").setup({});
        end
    },
    {
        -- https://github.com/sindrets/diffview.nvim
        "sindrets/diffview.nvim",
        lazy = true,
        event = "VeryLazy",
        config = function()
            local dw = require("diffview");
            dw.setup({
                view = {
                    default = { layout = "diff2_vertical" },
                },
                file_panel = {
                    win_config = {
                        position = "bottom",
                    },
                },
            });
            vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", {});
            vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", {});
        end
    },
    {
        -- https://github.com/NeogitOrg/neogit
        "NeogitOrg/neogit",
        lazy = true,
        event = "VeryLazy",
        branch = "nightly",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local ng = require("neogit");
            ng.setup({
                graph_style = "unicode",
            });
            vim.keymap.set("n", "<leader>gg", ng.open, {});
        end
    },
    {
        -- https://github.com/ThePrimeagen/harpoon
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        commit = "a38be6e", -- TODO: change this when harpoon2 branch stabilizes
        lazy = true,
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon");
            harpoon:setup({});

            vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
            vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
            vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        end
    },
    {
        -- https://github.com/hrsh7th/nvim-cmp
        "hrsh7th/nvim-cmp",
        lazy = true,
        event = { "VeryLazy" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "onsails/lspkind.nvim",
            "windwp/nvim-autopairs",
        },
        config = function()
            local cmp = require("cmp");
            local lspkind = require("lspkind");
            local border = {
                { "┌", "FloatBorder" },
                { "─", "FloatBorder" },
                { "┐", "FloatBorder" },
                { "│", "FloatBorder" },
                { "┘", "FloatBorder" },
                { "─", "FloatBorder" },
                { "└", "FloatBorder" },
                { "│", "FloatBorder" },
            };

            local has_mdlink, mdlink = pcall(require, "nvim-mdlink.cmp");
            if has_mdlink then
                cmp.register_source("mdlink", mdlink.new());
            end
            cmp.setup({
                snippet = {
                    expand = function(args)            -- REQUIRED
                        -- require("luasnip").lsp_expand(args.body)
                        vim.snippet.expand(args.body); -- Native nvim snippets
                    end,
                },
                window = {
                    completion = {
                        border = nil,
                        zindex = 999,
                        winhighlight = "Normal:MyCmpFloatingWindow,FloatBorder:MyCmpFloatingWindow,Search:None",
                    },
                    documentation = {
                        max_width = 0,
                        max_height = 0,
                        border = border,
                        winhighlight = "Normal:MyCmpFloatingWindow,FloatBorder:MyCmpFloatingWindow,Search:None",
                    },
                },
                mapping = cmp.mapping({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if vim.snippet.jumpable(1) then
                            vim.snippet.jump(1)
                        else
                            fallback();
                        end
                    end, { "i", "s", "c", }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if vim.snippet.jumpable(-1) then
                            vim.snippet.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-u>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                vim.keymap.set('n', '<C-c>', cmp.mapping.complete),
                sources = cmp.config.sources({
                    {
                        name = "nvim_lsp",
                        option = {
                            markdown_oxide = {
                                keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
                            },
                        },
                    },
                    { name = "nvim_lsp_sinature_help" },
                    -- { name = "luasnip" }, -- For luasnip users.
                    { name = "buffer" },
                    { name = "mdlink" },
                }, {
                    { name = "buffer" },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        if vim_item.menu ~= nil then
                            -- vim_item.menu = string.sub(vim_item.menu, 1, 16);
                            vim_item.menu = nil;
                        end
                        return lspkind.cmp_format({
                            mode = "symbol",
                            maxwidth = 25, -- prevent the popup from showing more than 20 chars
                            ellipsis_char = "…",
                        })(entry, vim_item);
                    end,
                    expandable_indicator = false,
                },
                completion = {
                    completeopt = "menu,menuone,noinsert",
                }
            });
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            });
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    { { name = "path" } },
                    { { name = "cmdline" } }
                ),
                matching = { disallow_symbol_nonprefix_matching = false },
            })
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on(
                "confirm_done",
                cmp_autopairs.on_confirm_done()
            );

            ---@diagnostic disable-next-line: duplicate-set-field
            vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
                contents = vim.lsp.util._normalize_markdown(contents, {
                    width = vim.lsp.util._make_floating_popup_size(contents, opts),
                })
                vim.bo[bufnr].filetype = 'markdown'
                vim.treesitter.start(bufnr);
                vim.lsp.buf_attach_client(bufnr, 0);
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

                return contents
            end
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = "single"
                }
            );
        end
    },
    {
        -- https://github.com/williamboman/mason-lspconfig.nvim
        "neovim/nvim-lspconfig",
        lazy = true,
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "folke/neodev.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig");
            local mason = require("mason");
            local mason_lspconfig = require("mason-lspconfig");
            local registry = require("mason-registry");
            local neodev = require("neodev");
            local nvim_cmp_lsp = require("cmp_nvim_lsp");
            local capabilities = nvim_cmp_lsp.default_capabilities();

            local required_lsps = {
                "lua_ls",
                "tsserver",
                -- "zls",
                "markdown_oxide",
            };

            mason.setup({
                registries = {
                    "github:mason-org/mason-registry",
                    -- add local registry with nightly version of ZLS
                    "file:~/.config/nvim/mason-custom-registry"
                },
            });

            registry.refresh(function()
                if not registry.is_installed("yq") then
                    vim.cmd("MasonInstall yq"); -- needed for local mason registry
                end
                if not registry.is_installed("zls_master") then
                    vim.cmd("MasonInstall zls_master"); -- nigtly ZLS from local registry
                end
            end);

            mason_lspconfig.setup({ ensure_installed = required_lsps });
            neodev.setup({
                library = { plugins = { "nvim-dap-ui" }, types = true },
            });

            lspconfig.zls.setup({ capabilities = capabilities });

            for _, lsp_name in ipairs(required_lsps) do
                local settingsObj = { capabilities = capabilities };
                if string.find(lsp_name, "lua_ls") then
                    settingsObj.settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            diagnostics = {
                                disable = { "missing-fields" },
                            }
                        }
                    };
                end
                lspconfig[lsp_name].setup(settingsObj);
            end
        end
    },
    {
        -- https://github.com/mfussenegger/nvim-dap
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            "neovim/nvim-lspconfig", --to configure Mason first
            "jay-babu/mason-nvim-dap.nvim",
            "Weissle/persistent-breakpoints.nvim",
        },
        lazy = true,
        event = "VeryLazy",
        config = function()
            local dap = require("dap");
            local dapui = require("dapui");
            local mason_nvim_dap = require("mason-nvim-dap");

            dapui.setup({
                layouts = {
                    {
                        elements = {
                            {
                                id = "scopes",
                                size = 1,
                            },
                        },
                        position = "top",
                        size = 8,
                    }, {
                    elements = {
                        {
                            id = "console",
                            size = 0.6
                        }
                    },
                    position = "bottom",
                    size = 8
                },
                },
                mappings = {
                    edit = "e",
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    repl = "r",
                    toggle = "t"
                },
            });

            dap.listeners.before.attach.dapui_config = function()
                dapui.open();
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            mason_nvim_dap.setup({
                ensure_installed = { "codelldb" },
                handlers = {
                    function(config)
                        -- all sources with no handler get passed here
                        mason_nvim_dap.default_setup(config)
                    end,
                    codelldb = function(config)
                        config.adapters = {
                            type = "server",
                            port = "${port}",
                            executable = {
                                command = vim.fn.exepath("codelldb"),
                                args = { "--port", "${port}" },
                            },
                        }
                        mason_nvim_dap.default_setup(config);
                    end,
                },
            });

            require('persistent-breakpoints').setup({
                load_breakpoints_event = { "BufReadPost" },
            });

            dap.configurations.zig = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = "${workspaceFolder}/zig-out/bin/${workspaceFolderBasename}",
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            };

            vim.fn.sign_define("DapBreakpoint", { text = "⊙", texthl = "ErrorMsg", linehl = "", numhl = "" });
            vim.fn.sign_define("DapBreakpointCondition", { text = "⧀", texthl = "ErrorMsg", linehl = "", numhl = "" });

            vim.keymap.set("n", "<Leader>dd", function() require("dap").continue() end)
            vim.keymap.set("n", "<Leader>dn", function() require("dap").step_over() end)
            vim.keymap.set("n", "<Leader>di", function() require("dap").step_into() end)
            vim.keymap.set("n", "<Leader>do", function() require("dap").step_out() end)
            vim.keymap.set("n", "<Leader>dc", function() require("dap").terminate() end)
            vim.keymap.set(
                "n",
                "<Leader>db",
                function() require('persistent-breakpoints.api').toggle_breakpoint() end
            );
            vim.keymap.set(
                "n",
                "<Leader>dx",
                function() require('persistent-breakpoints.api').clear_all_breakpoints() end
            );
            vim.keymap.set("n", "<Leader>dr", function() require("dap").repl.toggle() end)
            local hover = nil;
            vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
                if hover == nil then
                    hover = require("dap.ui.widgets").hover()
                else
                    hover.toggle();
                end
            end)
            vim.keymap.set({ "n", "v" }, "<Leader>ds", function()
                require("dapui").float_element("stacks", {
                    width = 75,
                    height = 20,
                    enter = true,
                    position = "center",
                });
            end)
        end
    },
    {
        -- https://github.com/folke/trouble.nvim
        "folke/trouble.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        lazy = true,
        event = { "VeryLazy" },
        config = function()
            local trouble = require("trouble");
            vim.keymap.set("n", "<leader>lt", function() trouble.toggle("document_diagnostics") end);
            vim.keymap.set("n", "<leader>lw", function() trouble.toggle("workspace_diagnostics") end);
            vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end);
            vim.keymap.set("n", "<leader>lr", function() trouble.toggle("lsp_references") end);
            vim.keymap.set("n", "<leader>ls", function() vim.lsp.buf.rename() end);
            vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format() end);
            vim.keymap.set("n", "<leader>i", function() vim.lsp.buf.hover() end);
        end
    },
    {
        -- https://github.com/ray-x/lsp_signature.nvim
        "ray-x/lsp_signature.nvim",
        lazy = true,
        event = "VeryLazy",
        opts = {
            bind = true,
            hint_enable = false,
            doc_lines = 16,
            handler_opts = {
                border = "single",
            }
        },
        config = function(_, opts) require("lsp_signature").setup(opts); end
    },
    {
        -- https://github.com/Zeioth/garbage-day.nvim
        "zeioth/garbage-day.nvim",
        dependencies = "neovim/nvim-lspconfig",
        lazy = true,
        event = "VeryLazy",
    },
    {
        -- https://github.com/windwp/nvim-autopairs
        "windwp/nvim-autopairs",
        lazy = true,
        event = "InsertEnter",
        config = true,
    },
    {
        -- https://github.com/petertriho/nvim-scrollbar
        "petertriho/nvim-scrollbar",
        lazy = true,
        event = { "VeryLazy" },
        dependencies = {
            "lewis6991/gitsigns.nvim",
        },
        config = function()
            require("scrollbar").setup({
                handlers = {
                    gitsigns = true,
                },
                marks = {
                    GitAdd = {
                        color = getHlColor("MySbGitSignsAdd", "foreground"),
                        color_nr = "LightGreen",
                    },
                    GitChange = {
                        color = getHlColor("MySbGitSignsChange", "foreground"),
                        color_nr = "LightBlue",
                    },
                    GitDelete = {
                        color = getHlColor("MySbGitSignsDelete", "foreground"),
                        color_nr = "Red",
                    },
                },
            });
        end,
    },
    {
        -- https://github.com/iamcco/markdown-preview.nvim
        "iamcco/markdown-preview.nvim",
        lazy = true,
        event = "VeryLazy",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
        config = function()
            vim.api.nvim_create_user_command("MdOpen", "MarkdownPreviewToggle", {});
        end
    },
    {
        -- https://github.com/NvChad/nvim-colorizer.lua
        "NvChad/nvim-colorizer.lua",
        lazy = true,
        event = "VeryLazy",
        config = function()
            require("colorizer").setup({});
        end
    },
    {
        -- https://github.com/akinsho/bufferline.nvim
        "akinsho/bufferline.nvim",
        lazy = true,
        event = "TabNew",
        dependencies = {
            "lewis6991/gitsigns.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        version = "*",
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "tabs",
                    always_show_bufferline = false,
                },
            });
        end
    },
    {
        -- https://github.com/f-person/git-blame.nvim
        "f-person/git-blame.nvim",
        lazy = true,
        event = "VeryLazy",
        config = function()
            require('gitblame').setup({
                enabled = false,
            });
            vim.keymap.set("n", "<leader>gb", "<cmd>GitBlameToggle<cr>");
        end,
    },
    {
        -- https://github.com/willothy/moveline.nvim
        'willothy/moveline.nvim',
        lazy = true,
        event = "VeryLazy",
        build = 'make',
        config = function()
            local moveline = require('moveline')
            vim.keymap.set('n', '<C-k>', moveline.up)
            vim.keymap.set('n', '<C-j>', moveline.down)
            vim.keymap.set('v', '<C-k>', moveline.block_up)
            vim.keymap.set('v', '<C-j>', moveline.block_down)
        end,
    },
    {
        -- https://github.com/Wansmer/treesj
        'Wansmer/treesj',
        lazy = true,
        event = "VeryLazy",
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            local treesj = require('treesj');
            local lang_utils = require('treesj.langs.utils');
            treesj.setup({
                use_default_keymaps = false,
                langs = {
                    javascript = { array_pattern = { join = { space_in_brackets = false } } },
                    zig = {
                        InitList = lang_utils.set_preset_for_list(),
                        FnCallArguments = lang_utils.set_preset_for_args({ split = { last_separator = true } }),
                        ParamDeclList = lang_utils.set_preset_for_args({ split = { last_separator = true } }),
                        Block = lang_utils.set_preset_for_statement(),
                        ContainerDecl = lang_utils.set_preset_for_list({
                            both = {
                                non_bracket_node = true,
                                shrink_node = { from = '{', to = '}' },
                            },
                        }),
                    },
                },
            })
            vim.keymap.set('n', '<Leader>\\', treesj.toggle);
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        lazy = true,
        event = "VeryLazy",
        opts = {
            size = 16,
            open_mapping = "<Leader>t",
            direction = "horizontal",
            insert_mappings = false,
        },
    },
    {
        -- https://github.com/catppuccin/nvim
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = {
            flavour = "mocha",
            transparent_background = true,
            no_italic = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                treesitter = true,
                flash = true,
                harpoon = true,
                mason = true,
                neogit = true,
                dap = true,
                dap_ui = true,
                lsp_trouble = true,
            },
            color_overrides = {
                all = {
                    text = "#dff0ff",
                },
            },
            highlight_overrides = {
                all = function( --[[ colors ]])
                    return {
                        -- Operator = { fg = colors.text, bold = true },
                    }
                end,
            },
        },
    },
    {
        'NlGHT/vim-eel',
        version = "*",
        lazy = true,
        event = "UIEnter",
    }
}, lazyPmOptions);
