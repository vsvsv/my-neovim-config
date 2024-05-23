--
-- core_config.lua - Core neovim config (without 3rd party packages)
--
-- Useful links (set cursor on a link and type 'gx' to open in browser):
--   * Netrw cheatsheet - https://gist.github.com/t-mart/610795fcf7998559ea80
--   * Quick netrw guide - https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer
--

vim.wo.number = true; -- enable line numbers
vim.opt.cursorline = false; -- highlight current line (where the cursor is)
vim.wo.relativenumber = false; -- no relative numbers by default (has toggle keymap)
vim.g.mapleader = " ";
vim.opt.fillchars = {eob = " "}; -- disable '~' at the end of buffer
vim.loader.enable();
vim.opt.signcolumn = "yes";

vim.opt.list = true;  -- show tabs, end-of-line spaces, etc. with special characters
vim.opt.listchars = { -- 'special characters' settings
    trail = '~',
    tab = "~>",
    nbsp = '␣', -- non-breaking space
    lead = '·', -- leading spaces
};

vim.o.tabstop = 4; -- display TAB character as 4 spaces
vim.o.expandtab = true; -- pressing tab key will insert spaces instead of TAB character
vim.o.softtabstop = 4;  -- number of spaces that will be inserted instead of TAB char
vim.o.shiftwidth = 4; -- Indent lines with 4 spaces
vim.o.breakindent = true; -- Wrap long lines with proper indentation level
vim.o.pumheight = 16; -- Maximum items (height) in the popup menus

vim.g.netrw_preview = 1; -- Open netrw preview on the right split side
vim.g.netrw_liststyle = 1; -- By default show files with ls-like table
vim.g.netrw_sort_options = "i"; -- Sort ignoring case
vim.g.netrw_localcopydircmd = 'cp -r'; -- Enable recursive copying by default
-- Telescope.nvim not working correctly with this option
-- vim.g.netrw_keepdir = 0; -- Keep the current directory and the browsing directory synced, helps avoid the move files error
vim.g.netrw_sort_sequence = [[[\/]\s]] -- Show directories first (sorting)
vim.g.netrw_sizestyle = "H"; -- Human-readable files sizes

vim.keymap.set('n', '<Leader>e', '<cmd>Re<cr>'); -- Open last directory with netrw by Spc+e
vim.keymap.set('n', '<Leader>n', '<cmd>noh<cr>'); -- Reset current search pattern with Spc-h
vim.keymap.set('n', '<Leader>o', ':<c-u>call append(line("."), repeat([""], v:count1))<cr>'); -- Insert blank line after
vim.keymap.set('n', '<Leader>O', ':<c-u>call append(line(".")-1, repeat([""], v:count1))<cr>'); -- Insert blank line before
vim.keymap.set('n', '<c-a>', 'a <ESC>r'); -- Insert single character in normal mode with Ctrl+A
vim.keymap.set('n', '<c-u>', '<c-u>zz'); -- Always center cursor after half-page scroll
vim.keymap.set('n', '<c-d>', '<c-d>zz'); -- Always center cursor after half-page scroll
vim.keymap.set('n', '<Leader>vn', function() -- Leader-[v]isual-[n]umber – toggle relative line numbers
    vim.wo.relativenumber = not vim.wo.relativenumber;
end);

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    float = {
        border = 'rounded',
        source = 'always',
    },
});

-- Setup code folding based on Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()";
vim.opt.foldlevel = 99;
vim.api.nvim_create_autocmd({"BufWinLeave"}, {
  pattern = {"*.*"},
  desc = "save view (folds), when closing file",
  command = "mkview",
});
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*.*"},
  desc = "load view (folds), when opening file",
  command = "silent! loadview",
});
