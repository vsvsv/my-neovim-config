--
-- A Neovim config by vsvsv (vsevolodplatunov@gmail.com)
--

require("core_config");
local colorscheme = require("colorscheme");
require("packages");

-- Use Catppuccin theme (only truecolor terminals)
vim.cmd("colorscheme catppuccin");
colorscheme.deemphasize_dots_at_beginning(); -- default color for leading dots (spaces) is annoying, decrease it

-- In case of non-truecolor terminal register a command to set default theme back
vim.api.nvim_create_user_command("DefaultTheme", function ()
    vim.cmd("set termguicolors&");
    vim.cmd("colorscheme default");
    colorscheme.set_default_theme();
end, {});
