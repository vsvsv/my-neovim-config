--- @module "build_in_term"
--[[
  This module provides utility functions and key mappings for executing
  compiler/linter commands in the built-in terminal and importing the
  command output into a quickfix list.

  This facilitates compiler-assisted refactoring and aids in error fixing
  by making compiler/linter diagnostics easily navigable.
]]

local M = {}

local term_ref = { buf = nil, cmd = nil }
local command_history = {}

-- Language-specific error formats
local error_formats = {
    python =
        '%A%\\s%#File \\"%f\\"\\, line %l\\, in%.%#' ..
        ',%+CFailed example:%.%#' ..
        ',%-G*%\\{70%\\}' ..
        ',%-G%*\\d items had failures:' ..
        ',%-G%*\\s%*\\d of%*\\s%*\\d in%.%#' ..
        ',%E  File \\"%f\\"\\, line %l' ..
        ', File \\"%f\\"\\, line %l' ..
        ',%-C%p^' ..
        ',%+C  %m' ..
        ',%Z  %m',
    zig = '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c: %tnote: %m',
    gcc = '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l: %trror: %m,%f:%l: %tarning: %m',
    go = '%f:%l:%c: %m',
    rust = '%Eerror[E%n]: %m,%C %*--> %f:%l:%c,%Z = help: %m,%Wwarning: %m',
    eslint = "%f:\\ line\\ %l\\,\\ col\\ %c\\,\\ %m",
}

function M.run_build(split_type)
    local default_cmd = #command_history > 0 and command_history[#command_history] or ""
    local cmd = vim.fn.input(
        "Execute command: ",
        default_cmd,
        "customlist,v:lua.require'build_terminal'.command_history_complete"
    )
    if cmd == "" then
        print("Shell command canceled")
        return
    end

    if #command_history == 0 or cmd ~= command_history[#command_history] then
        table.insert(command_history, cmd)
    end

    if split_type == "split" then
        vim.cmd("botright split")
    else
        vim.cmd("tabnew")
    end


    vim.cmd("cclose") -- close existing quickfix list, if exist
    vim.cmd("terminal " .. cmd)
    local new_buf = vim.api.nvim_get_current_buf()
    term_ref = { buf = new_buf, cmd = cmd }
    vim.cmd("setlocal nonumber norelativenumber")
    vim.cmd("setlocal nospell")

    vim.keymap.set("n", "q", function()
        if vim.bo.modified then
            vim.cmd("confirm q")
        else
            vim.cmd("q!")
        end
    end, { buffer = true, silent = true, nowait = true })
end

function M.get_error_format(cmd)
    -- First try to match the command exactly
    for lang, efm in pairs(error_formats) do
        if cmd:match(lang) then
            return efm
        end
    end

    -- Then try more generic matching
    if cmd:match("gcc") or cmd:match("clang") or cmd:match("make") then
        return error_formats.gcc
    elseif cmd:match("cargo") or cmd:match("rustc") then
        return error_formats.rust
    elseif cmd:match("yarn lint") or cmd:match("npm run lint") then
        return error_formats.eslint
    end

    -- Fallback to global errorformat
    return vim.o.errorformat
end

function M.parse_and_close()
    if not term_ref or not term_ref.buf or not vim.api.nvim_buf_is_valid(term_ref.buf) then
        print("No active build terminal found")
        return
    end
    local lines = vim.api.nvim_buf_get_lines(term_ref.buf, 0, -1, false)

    -- Clean up terminal artifacts and trim empty lines
    local cleaned_lines = {}
    for i, line in ipairs(lines) do
        line = line:gsub("\27%[[0-9;]*[mK]", "") -- Remove ANSI escape codes
        line = line:gsub("^%s*(.-)%s*$", "%1")   -- Trim whitespace
        if #line > 0 or i < #lines then
            table.insert(cleaned_lines, line)
        end
    end
    while #cleaned_lines > 0 and cleaned_lines[#cleaned_lines] == "" do
        table.remove(cleaned_lines)
    end

    local efm = M.get_error_format(term_ref.cmd)
    vim.fn.setqflist({}, " ", {
        lines = cleaned_lines,
        efm = efm
    })
    print(efm)

    vim.api.nvim_buf_delete(term_ref.buf, { force = true })
    term_ref = { buf = nil, cmd = nil }

    vim.cmd("copen")
end

-- Execute shell command in new tab
vim.keymap.set(
    "n",
    "<Leader>ce",
    function() M.run_build('tab') end,
    { noremap = true, silent = true }
)

-- Execute shell command in new split
vim.keymap.set(
    "n",
    "<Leader>cm",
    function() M.run_build('split') end,
    { noremap = true, silent = true }
)

-- Parse the output of previously executed shell command to a quickfix list
vim.keymap.set(
    "n",
    "<Leader>ci",
    function() M.parse_and_close() end,
    { noremap = true, silent = true }
)

return M
