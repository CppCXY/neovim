local M = {}

--- Prompts the user to pick a single item from a collection of entries
---
---@param items table Arbitrary items
---@param opts table Additional options
---     - prompt (string|nil)
---               Text of the prompt. Defaults to `Select one of:`
---     - format_item (function item -> text)
---               Function to format an
---               individual item from `items`. Defaults to `tostring`.
---     - kind (string|nil)
---               Arbitrary hint string indicating the item shape.
---               Plugins reimplementing `vim.ui.select` may wish to
---               use this to infer the structure or semantics of
---               `items`, or the context in which select() was called.
---@param on_choice function ((item|nil, idx|nil) -> ())
---               Called once the user made a choice.
---               `idx` is the 1-based index of `item` within `item`.
---               `nil` if the user aborted the dialog.
---
---
--- Example:
--- <pre>
--- vim.ui.select({ 'tabs', 'spaces' }, {
---     prompt = 'Select tabs or spaces:',
---     format_item = function(item)
---         return "I'd like to choose " .. item
---     end,
--- }, function(choice)
---     if choice == 'spaces' then
---         vim.o.expandtab = true
---     else
---         vim.o.expandtab = false
---     end
--- end)
--- </pre>

function M.select(items, opts, on_choice)
  vim.validate {
    items = { items, 'table', false },
    on_choice = { on_choice, 'function', false },
  }
  opts = opts or {}
  local choices = { opts.prompt or 'Select one of:' }
  local format_item = opts.format_item or tostring
  for i, item in pairs(items) do
    table.insert(choices, string.format('%d: %s', i, format_item(item)))
  end
  local choice = vim.fn.inputlist(choices)
  if choice < 1 or choice > #items then
    on_choice(nil, nil)
  else
    on_choice(items[choice], choice)
  end
end

--- Prompts the user for input
---
---@param opts table Additional options. See |input()|
---     - prompt (string|nil)
---               Text of the prompt. Defaults to `Input: `.
---     - default (string|nil)
---               Default reply to the input
---     - completion (string|nil)
---               Specifies type of completion supported
---               for input. Supported types are the same
---               that can be supplied to a user-defined
---               command using the "-complete=" argument.
---               See |:command-completion|
---     - highlight (function)
---               Function that will be used for highlighting
---               user inputs.
---@param on_confirm function ((input|nil) -> ())
---               Called once the user confirms or abort the input.
---               `input` is what the user typed.
---               `nil` if the user aborted the dialog.
---
--- Example:
--- <pre>
--- vim.ui.input({ prompt = 'Enter value for shiftwidth: ' }, function(input)
---     vim.o.shiftwidth = tonumber(input)
--- end)
--- </pre>
function M.input(opts, on_confirm)
  vim.validate {
    on_confirm = { on_confirm, 'function', false },
  }

  opts = opts or {}
  local input = vim.fn.input(opts)
  if #input > 0 then
    on_confirm(input)
  else
    on_confirm(nil)
  end
end

return M
