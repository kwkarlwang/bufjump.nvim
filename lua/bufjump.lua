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

local backward_same_buf = function()
  local jumplistAndPos = vim.fn.getjumplist()

  local jumplist = jumplistAndPos[1]
  if #jumplist == 0 then
    return
  end
  local lastUsedJumpPos = jumplistAndPos[2] + 1
  local curBufNum = vim.fn.bufnr()

  local j = lastUsedJumpPos
  local foundJump = false
  repeat
    j = j - 1
    if j > 0 and (curBufNum == jumplist[j].bufnr and vim.api.nvim_buf_is_valid(jumplist[j].bufnr)) then
      foundJump = true
    end
  until j == 0 or foundJump

  if foundJump then
    jumpbackward(lastUsedJumpPos - j)
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

local forward_same_buf = function()
  local jumplistAndPos = vim.fn.getjumplist()
  local jumplist = jumplistAndPos[1]
  if #jumplist == 0 then
    return
  end
  local lastUsedJumpPos = jumplistAndPos[2] + 1
  local curBufNum = vim.fn.bufnr()

  local j = lastUsedJumpPos
  local foundJump = false
  repeat
    j = j + 1
    if j <= #jumplist and curBufNum == jumplist[j].bufnr and vim.api.nvim_buf_is_valid(jumplist[j].bufnr) then
      foundJump = true
    end
  until j > #jumplist or foundJump

  if foundJump then
    jumpforward(j - lastUsedJumpPos)
    if on_success then
      on_success()
    end
  end
end

local setup = function(cfg)
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

return {
  backward = backward,
  forward = forward,
  backward_same_buf = backward_same_buf,
  forward_same_buf = forward_same_buf,
  setup = setup,
}
