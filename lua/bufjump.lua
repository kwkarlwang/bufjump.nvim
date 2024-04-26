local on_success = nil
local jumpbackward = function(num)
  vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-o>"]])
end

local jumpforward = function(num)
  vim.cmd([[execute "normal! ]] .. tostring(num) .. [[\<c-i>"]])
end

local backward = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  -- plus one because of one index
  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  while j > 1 and (curBufNum == targetBufNum or not vim.api.nvim_buf_is_valid(targetBufNum)) do
    j = j - 1
    targetBufNum = jumplist[j].bufnr
  end
  if targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpbackward(i - j)
    if on_success then
      on_success()
    end
  end
end

local backwardSameBuf = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  -- plus one because of one index
  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  while j > 1 and (curBufNum ~= targetBufNum or not vim.api.nvim_buf_is_valid(targetBufNum)) do
    j = j - 1
    targetBufNum = jumplist[j].bufnr
  end
  if targetBufNum == curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpbackward(i - j)
    if on_success then
      on_success()
    end
  end
end

local forward = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  -- find the next different buffer
  while j < #jumplist and (curBufNum == targetBufNum or vim.api.nvim_buf_is_valid(targetBufNum) == false) do
    j = j + 1
    targetBufNum = jumplist[j].bufnr
  end
  while j + 1 <= #jumplist and jumplist[j + 1].bufnr == targetBufNum and vim.api.nvim_buf_is_valid(targetBufNum) do
    j = j + 1
  end
  if j <= #jumplist and targetBufNum ~= curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpforward(j - i)

    if on_success then
      on_success()
    end
  end
end

local forwardSameBuf = function()
  local getjumplist = vim.fn.getjumplist()
  local jumplist = getjumplist[1]
  if #jumplist == 0 then
    return
  end

  local i = getjumplist[2] + 1
  local j = i
  local curBufNum = vim.fn.bufnr()
  local targetBufNum = curBufNum

  -- find the next jump in same buffer
  j = j + 1
  while j < #jumplist and (curBufNum ~= targetBufNum or vim.api.nvim_buf_is_valid(targetBufNum) == false) do
    j = j + 1
    targetBufNum = jumplist[j].bufnr
  end
  if j <= #jumplist and targetBufNum == curBufNum and vim.api.nvim_buf_is_valid(targetBufNum) then
    jumpforward(j - i)

    if on_success then
      on_success()
    end
  end
end

local setup = function(cfg)
  local opts = { silent = true, noremap = true }
  cfg = cfg or {}
  if cfg.forwardkey ~= false then
    local forwardkey = cfg.forward or "<C-n>"
    vim.api.nvim_set_keymap("n", forwardkey, ":lua require('bufjump').forward()<cr>", opts)
  end
  if cfg.backwardkey ~= false then
    local backwardkey = cfg.backward or "<C-n>"
    vim.api.nvim_set_keymap("n", backwardkey, ":lua require('bufjump').forward()<cr>", opts)
  end
  if cfg.forwardSameBufKey then
    vim.api.nvim_set_keymap("n", cfg.forwardSameBufKey, ":lua require('bufjump').forwardSameBuf()<cr>", opts)
  end
  if cfg.backwardSameBufKey then
    vim.api.nvim_set_keymap("n", cfg.backwardSameBufKey, ":lua require('bufjump').backwardSameBuf()<cr>", opts)
  end
end

return {
  backward = backward,
  forward = forward,
  backwardSameBuf = backwardSameBuf,
  forwardSameBuf = forwardSameBuf,
  setup = setup,
}
