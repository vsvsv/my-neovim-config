--
-- colorscheme.lua -- defines custom 16-color colorscheme which resembles GitHub scheme
--

-- Set background to transparent for all groups listed below
local function remove_background()
    local groups = {
        "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
        "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
        "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
        "SignColumn", "CursorLine", "CursorLineNr", "EndOfBuffer", "FloatBorder",
    };
    for _, v in ipairs(groups) do
        ---@diagnostic disable-next-line: deprecated
        local ok, prev_attrs = pcall(vim.api.nvim_get_hl_by_name, v, true)
        if ok and (prev_attrs.background or prev_attrs.bg or prev_attrs.ctermbg) then
            local attrs = vim.tbl_extend("force", prev_attrs, { bg = "NONE", ctermbg = "NONE" })
            attrs[true] = nil
            vim.api.nvim_set_hl(0, v, attrs)
        end
    end
end
remove_background();

-- Sets additional attributes (like bg/fg color) to specified highlight group
local function set_highlight_group_attrs(hl_group, attrs)
    ---@diagnostic disable-next-line: deprecated
    local ok, prev_attrs = pcall(vim.api.nvim_get_hl_by_name, hl_group, true);
    if ok then
        local new_attrs = vim.tbl_extend("force", prev_attrs, attrs);
        new_attrs[true] = nil;
        vim.api.nvim_set_hl(0, hl_group, new_attrs);
    end
end

-- Colors for True Color mode
local c_gui = {
    white = "#ffffff",
    black = "NvimDarkGrey1",
    lightYellow = "NvimLightYellow",
    lightRed = "NvimLightRed",
    lightBlue = "NvimLightBlue",
    lightGreen = "NvimLightGreen",
    darkBlue = "NvimDarkBlue",
    lightGrey1 = "NvimLightGrey1",
    lightGrey2 = "NvimLightGrey2",
    lightGrey3 = "NvimLightGrey3",
    lightGrey4 = "NvimLightGrey4",
    darkGrey2 = "NvimDarkGrey2",
    darkGrey3 = "NvimDarkGrey3",
    darkGrey4 = "NvimDarkGrey4",
    nonText = "#333034",
};

-- Colors for 16-color terminal mode
local c_term = {
    white = "White",
    black = "Black",
    lightYellow = "LightYellow",
    lightRed = "Red",
    lightBlue = "LightBlue",
    lightGreen = "LightGreen",
    darkBlue = "DarkBlue",
    lightGrey1 = "White",
    lightGrey2 = "Grey",
    lightGrey3 = "Grey",
    lightGrey4 = "DarkGrey",
    darkGrey2 = "DarkGrey",
    darkGrey3 = "DarkGrey",
    darkGrey4 = "DarkGrey",
};

local function deemphasize_dots_at_beginning()
    set_highlight_group_attrs("NonText", { ctermfg = c_term.darkGrey3, fg = c_gui.darkGrey3 });
    set_highlight_group_attrs("Whitespace", { ctermfg = c_term.darkGrey3, fg = c_gui.nonText });
end

local function set_default_theme()
    -- General highlighting groups modufications
    set_highlight_group_attrs("normal", { ctermbg = "none", bg = "none", fg = c_gui.white });
    set_highlight_group_attrs("Function", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue });
    set_highlight_group_attrs("Special", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue });
    set_highlight_group_attrs("Statement", { ctermfg = c_term.lightGrey1, fg = c_gui.lightGrey2 });
    set_highlight_group_attrs("Operator", { ctermfg = c_term.white, fg = c_gui.white });
    set_highlight_group_attrs("Constant", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue });

    deemphasize_dots_at_beginning();
    set_highlight_group_attrs("Directory", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue, bold = false, });
    set_highlight_group_attrs("CursorLine", { bg = c_gui.darkGrey4, });
    set_highlight_group_attrs("DiagnosticUnderlineError", { fg = c_gui.lightRed, undercurl = true });
    set_highlight_group_attrs("DiagnosticUnderlineWarn", { fg = c_gui.lightYellow, undercurl = true });
    set_highlight_group_attrs("FloatBorder", { bg = c_gui.black, ctermbg = c_term.black });
    set_highlight_group_attrs("NormalFloat", { bg = c_gui.black, ctermbg = c_term.black });

    -- Custom highlight groups for Scrollbar.nvim git colors
    vim.api.nvim_set_hl(0, "MySbGitSignsAdd", { fg = c_gui.lightGreen, ctermfg = c_term.lightGreen });
    vim.api.nvim_set_hl(0, "MySbGitSignsChange", { fg = c_gui.lightBlue, ctermfg = c_term.lightBlue });
    vim.api.nvim_set_hl(0, "MySbGitSignsDelete", { fg = c_gui.lightRed, ctermfg = c_term.lightRed });

    -- Nvim-Cmp floating windows style
    vim.api.nvim_set_hl(0, "MyCmpFloatingWindow", { bg = c_gui.black, ctermbg = c_term.black });

    -- JS/TS
    -- set_highlight_group_attrs("@tag.javascript", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue, bold = true });
    -- set_highlight_group_attrs("@tag.delimiter.javascript",
    --     { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue, bold = false });
    -- set_highlight_group_attrs("@punctuation.bracket.javascript", { ctermfg = c_term.lightGrey3, fg = c_gui.lightGrey3 });
    -- set_highlight_group_attrs("@tag.attribute.javascript", { ctermfg = c_term.lightGrey2, fg = c_gui.lightGrey2 });
    set_highlight_group_attrs("@comment.documentation.javascript", { ctermfg = c_term.lightGrey4, fg = c_gui.lightGrey4 });
    set_highlight_group_attrs("@keyword.jsdoc", { ctermfg = c_term.lightGrey4, fg = c_gui.lightGrey4, bold = true });
    vim.api.nvim_set_hl(0, "@keyword.export.javascript", { link = "Keyword" });
    vim.api.nvim_set_hl(0, "@lsp.type.parameter.javascriptreact", { link = "@variable" });
    vim.api.nvim_set_hl(0, "@variable.parameter.javascript", { link = "@variable" });

    -- Markdown
    set_highlight_group_attrs("@markup.raw.markdown_inline", { ctermbg = c_term.darkGrey3, bg = c_gui.darkGrey3 });

    -- Zig
    set_highlight_group_attrs("@type.qualifier.zig", { ctermfg = c_term.lightGrey1, fg = c_gui.lightGrey2, bold = true, });
    set_highlight_group_attrs("@attribute.zig", { ctermfg = c_term.lightGrey1, fg = c_gui.lightGrey2, bold = true });
    set_highlight_group_attrs("@lsp.type.type.zig", { ctermfg = c_term.lightBlue, fg = c_gui.lightBlue });
end

set_default_theme();

return {
    c_gui = c_gui,
    c_term = c_term,
    remove_background = remove_background,
    set_default_theme = set_default_theme,
    deemphasize_dots_at_beginning = deemphasize_dots_at_beginning,
};
