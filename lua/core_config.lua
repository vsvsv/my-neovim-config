--
-- core_config.lua - Core neovim config (without 3rd party packages)
--
-- Useful links (set cursor on a link and type 'gx' to open in browser):
--   * Netrw cheatsheet - https://gist.github.com/t-mart/610795fcf7998559ea80
--   * Quick netrw guide - https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer
--

vim.wo.number = true;              -- enable line numbers
vim.opt.cursorline = false;        -- highlight current line (where the cursor is)
vim.wo.relativenumber = true;      -- relative numbers by default (has toggle keymap)
vim.g.mapleader = " ";
vim.opt.fillchars = { eob = " " }; -- disable '~' at the end of buffer
vim.loader.enable();
vim.opt.signcolumn = "yes";

vim.o.mousemoveevent = true; -- for plugins which rely on mouse position

vim.opt.list = true;  -- show tabs, end-of-line spaces, etc. with special characters
vim.opt.listchars = { -- 'special characters' settings
    trail = '~',
    tab = "~>",
    nbsp = '␣', -- non-breaking space
    lead = '·', -- leading spaces
};

vim.o.tabstop = 4;                     -- display TAB character as 4 spaces
vim.o.expandtab = true;                -- pressing tab key will insert spaces instead of TAB character
vim.o.softtabstop = 4;                 -- number of spaces that will be inserted instead of TAB char
vim.o.shiftwidth = 4;                  -- Indent lines with 4 spaces
vim.o.breakindent = true;              -- Wrap long lines with proper indentation level
vim.o.pumheight = 16;                  -- Maximum items (height) in the popup menus

vim.g.netrw_preview = 1;               -- Open netrw preview on the right split side
vim.g.netrw_liststyle = 1;             -- By default show files with ls-like table
vim.g.netrw_sort_options = "i";        -- Sort ignoring case
vim.g.netrw_localcopydircmd = 'cp -r'; -- Enable recursive copying by default
vim.g.netrw_sort_sequence = [[[\/]\s]] -- Show directories first (sorting)
vim.g.netrw_sizestyle = "H";           -- Human-readable files sizes

-- Disable netrw (in favor of installed neo-tree)
vim.g.loaded_netrw = 1;
vim.g.loaded_netrwPlugin = 1;

vim.keymap.set('n', ',', '@=\'mqYp`qj\'<cr>');                                                  -- Duplicate line __preserving__ cursor position on the line
vim.keymap.set('v', 'y', 'ygv<Esc>');                                                           -- Yank in visual mode without the cursor moving to the top of the block
vim.keymap.set('n', '<Leader>n', '<cmd>noh<cr>');                                               -- Reset current search pattern with Spc-h
vim.keymap.set('n', '<Leader>o', ':<c-u>call append(line("."), repeat([""], v:count1))<cr>');   -- Insert blank line after
vim.keymap.set('n', '<Leader>O', ':<c-u>call append(line(".")-1, repeat([""], v:count1))<cr>'); -- Insert blank line before
vim.keymap.set('n', '<c-u>', '<c-u>zz');                                                        -- Always center cursor after half-page scroll
vim.keymap.set('n', '<c-d>', '<c-d>zz');                                                        -- Always center cursor after half-page scroll
vim.keymap.set('n', '<Leader>vn',
    function()                                                                                  -- Leader-[v]isual-[n]umber – toggle relative line numbers
        vim.wo.relativenumber = not vim.wo.relativenumber;
    end);

-- Remap Ctrl+HJKL to arrows in insert mode
vim.keymap.set('i', '<c-h>', '<Left>');
vim.keymap.set('i', '<c-l>', '<Right>');
vim.keymap.set('i', '<c-j>', '<Down>');
vim.keymap.set('i', '<c-k>', '<Up>');

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    float = {
        border = 'rounded',
        source = true,
    },
});

-- Setup code folding based on Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()";
vim.opt.foldlevel = 99;
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    pattern = { "*.*" },
    desc = "save view (folds), when closing file",
    command = "mkview",
});
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    pattern = { "*.*" },
    desc = "load view (folds), when opening file",
    command = "silent! loadview",
});

-- Custom filetypes
vim.filetype.add({
    extension = {
        sapf = 'scheme' -- For SAPF (Sound as pure form)
    }
})


-- Quickfix list key mappings
-- Note: ':cc' jumps to the current selected QF line in the editor
vim.keymap.set('n', '<Leader>cn', '<cmd>cnext<cr>'); -- Open next file in quickfix list
vim.keymap.set('n', '<Leader>cp', '<cmd>cprev<cr>'); -- Open previous file in quickfix list
vim.keymap.set('n', '<Leader>cq', '<cmd>cclose<cr>'); -- Close quickfix list

-- Search related bindings
vim.keymap.set('v', '<Leader>s', 'y/\\V<C-R>"<CR>'); -- Search forward for selected text
vim.keymap.set('v', '<Leader>S', 'y?\\V<C-R>"<CR>'); -- Search forward for selected text

-- Yank/paste/cut related bindings
vim.keymap.set({ 'n', 'v' }, 'my', '"*y');
vim.keymap.set({ 'n' }, 'mY', '^v$"*y');

vim.keymap.set({ 'v' }, 'p', 'P');
vim.keymap.set({ 'n', 'v' }, 'P', '"*p');
vim.api.nvim_set_keymap('t', '<Leader><ESC>', '<C-\\><C-n>', { noremap = true })

-- Define a shortcut to forcefully set filetype of the current buffer
vim.keymap.set("n", "<Leader>st", function()
    local bufnr = vim.api.nvim_get_current_buf();
    vim.ui.input({
        prompt = "Set filetype to: ",
        default = "",
        completion = "filetype",
    }, function(input)
        if not input or input == "" then return end
        vim.api.nvim_buf_set_option(bufnr, "filetype", input);
        vim.notify("Filetype set to: " .. input, vim.log.levels.INFO);
    end)
end)

-- Create command aliases for common mistyped commands (capital first letter)
vim.api.nvim_create_user_command('W', 'write<bang>', {bang = true, range = true})
vim.api.nvim_create_user_command('Wa', 'wall<bang>', {bang = true})
vim.api.nvim_create_user_command('Wq', 'wq<bang>', {bang = true, range = true})
vim.api.nvim_create_user_command('Wqa', 'wqa<bang>', {bang = true})
vim.api.nvim_create_user_command('Q', 'quit<bang>', {bang = true})
vim.api.nvim_create_user_command('Qa', 'qa<bang>', {bang = true})
vim.api.nvim_create_user_command('Qall', 'qall<bang>', {bang = true})
vim.api.nvim_create_user_command('E', 'edit<bang>', {bang = true, nargs = '?'})
