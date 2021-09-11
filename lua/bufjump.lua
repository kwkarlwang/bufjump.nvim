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
local setup = function(cfg)
	local opts = { silent = true, noremap = true }
	cfg = cfg or {}
	local forwardkey = cfg.forward or "<C-n>"
	local backwardkey = cfg.backward or "<C-p>"
	on_success = cfg.on_success or nil
	vim.api.nvim_set_keymap("n", backwardkey, ":lua require('bufjump').backward()<cr>", opts)
	vim.api.nvim_set_keymap("n", forwardkey, ":lua require('bufjump').forward()<cr>", opts)
end

return {
	backward = backward,
	forward = forward,
	setup = setup,
}
