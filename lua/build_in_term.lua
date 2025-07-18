--- @module "build_in_term"
--[[
  This module provides utility functions and key mappings for executing
  compiler/linter commands in the built-in terminal and importing the
  command output into a quickfix list.

  This facilitates compiler-assisted refactoring and aids in error fixing
  by making compiler/linter diagnostics easily navigable.
]]

local M = {}

local term_buf = nil
local command_history = {}

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

    vim.cmd("terminal " .. cmd)
    local new_buf = vim.api.nvim_get_current_buf()
    term_buf = new_buf
    vim.bo[new_buf].bufhidden = "delete"
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

function M.parse_and_close()
    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
        print("No active build terminal found")
        return
    end
    local lines = vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)

    -- Clean up terminal artifacts and trim empty lines
    local cleaned_lines = {}
    for i, line in ipairs(lines) do
        line = line:gsub("\27%[[0-9;]*[mK]", "") -- Remove ANSI escape codes
        line = line:gsub("^%s*(.-)%s*$", "%1")   -- Trim whitespace
        if not line:match("^||") then
            if #line > 0 or i < #lines then
                table.insert(cleaned_lines, line)
            end
        end
    end
    while #cleaned_lines > 0 and cleaned_lines[#cleaned_lines] == "" do
        table.remove(cleaned_lines)
    end

    vim.fn.setqflist({}, " ", {
        lines = cleaned_lines,
        efm = vim.o.errorformat
    })

    vim.api.nvim_buf_delete(term_buf, { force = true })
    term_buf = nil

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

-- Parse the output to a quickfix list
vim.keymap.set(
    "n",
    "<Leader>ci",
    function() M.parse_and_close() end,
    { noremap = true, silent = true }
)

return M
