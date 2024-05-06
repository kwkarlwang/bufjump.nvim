local M = {}

local on_success = nil

local jumpbackward = function(num)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(tostring(num) .. "<c-o>", true, true, true), "n", false)
end

local jumpforward = function(num)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(tostring(num) .. "<c-i>", true, true, true), "n", false)
end

---@param stop_cond fun(from_bufnr: integer, to_bufnr: integer):boolean
M.backward_cond = function(stop_cond)
  local jumplist, to_pos = unpack(vim.fn.getjumplist())
  if #jumplist == 0 or to_pos == 0 then
    return
  end

  local from_bufnr = vim.fn.bufnr()
  local from_pos = to_pos + 1
  repeat
    local to_bufnr = jumplist[to_pos].bufnr
    if stop_cond(from_bufnr, to_bufnr) then
      jumpbackward(from_pos - to_pos)
      if on_success then
        on_success()
      end
      return
    end
    to_pos = to_pos - 1
  until to_pos == 0
end

M.backward = function()
  M.backward_cond(function(from_bufnr, to_bufnr)
    return from_bufnr ~= to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
  end)
end

M.backward_same_buf = function()
  M.backward_cond(function(from_bufnr, to_bufnr)
    return from_bufnr == to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
  end)
end

---@param stop_cond fun(from_bufnr: integer, to_bufnr: integer):boolean
M.forward_cond = function(stop_cond)
  local getjumplist = vim.fn.getjumplist()
  local jumplist, from_pos = getjumplist[1], getjumplist[2] + 1
  local max_pos = #jumplist
  if max_pos == 0 or from_pos >= max_pos then
    return
  end

  local from_bufnr = vim.fn.bufnr()
  local to_pos = from_pos + 1
  repeat
    local to_bufnr = jumplist[to_pos].bufnr
    if stop_cond(from_bufnr, to_bufnr) then
      jumpforward(to_pos - from_pos)
      if on_success then
        on_success()
      end
      return
    end
    to_pos = to_pos + 1
  until to_pos == max_pos + 1
end

M.forward = function()
  M.forward_cond(function(from_bufnr, to_bufnr)
    return from_bufnr ~= to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
  end)
end

M.forward_same_buf = function()
  M.forward_cond(function(from_bufnr, to_bufnr)
    return from_bufnr == to_bufnr and vim.api.nvim_buf_is_valid(to_bufnr)
  end)
end

M.setup = function(cfg)
  local bufjump = require("bufjump")
  cfg = cfg or {}
  if cfg.forward_key ~= false then
    local forward_key = cfg.forward_key or "<C-n>"
    vim.keymap.set("n", forward_key, bufjump.forward)
  end
  if cfg.backward_key ~= false then
    local backward_key = cfg.backward_key or "<C-p>"
    vim.keymap.set("n", backward_key, bufjump.backward)
  end
  if cfg.forward_same_buf_key then
    vim.keymap.set("n", cfg.forward_same_buf_key, bufjump.forward_same_buf)
  end
  if cfg.backward_same_buf_key then
    vim.keymap.set("n", cfg.backward_same_buf_key, bufjump.backward_same_buf)
  end
  on_success = cfg.on_success or nil
end

return M
