-- Macros picker: list recorded named registers (a-z, 0-9) and play them.
-- <leader>m opens the picker; <CR> plays the selected macro.
-- Type a count BEFORE opening (e.g. 3<leader>m) to play the macro 3 times,
-- like 3@q.

local NAMED_REGS = "abcdefghijklmnopqrstuvwxyz0123456789"

local function escape(v)
  return (v:gsub("\r", "\\r"):gsub("\n", "\\n"):gsub("\t", "\\t"))
end

local function macro_items()
  local items = {}
  for i = 1, #NAMED_REGS do
    local reg = NAMED_REGS:sub(i, i)
    local ok, value = pcall(vim.fn.getreg, reg, 1)
    if ok and type(value) == "string" and value ~= "" then
      items[#items + 1] = {
        reg = reg,
        value = escape(value),
        data = value,
        text = reg .. ": " .. escape(value),
        preview = { text = value, ft = "text" },
      }
    end
  end
  return items
end

local function open_macros_picker()
  -- capture the count NOW: by the time the picker's confirm action runs,
  -- v:count has long been reset
  local count = vim.v.count
  Snacks.picker.pick({
    name = "macros",
    title = " 󰁕 Macros",
    finder = macro_items,
    format = "register",
    preview = "preview",
    confirm = { "close", "play" },
    actions = {
      play = {
        desc = "Play Macro",
        action = function(_, item)
          if item and item.reg then
            local prefix = count > 0 and tostring(count) or ""
            -- schedule: the picker's close sequence still runs after this
            -- action returns; injecting before it lands does nothing
            vim.schedule(function()
              vim.api.nvim_input(prefix .. "@" .. item.reg)
            end)
          end
        end,
      },
    },
  })
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>m", open_macros_picker, desc = "Macros (recorded registers)" },
  },
}
