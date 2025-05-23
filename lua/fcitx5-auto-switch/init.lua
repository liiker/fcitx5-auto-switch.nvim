local M = {}

local function is_supported()
	return vim.fn.executable('fcitx5-remote') == 1
end

local function get_im_status()
	return tonumber(vim.fn.system('fcitx5-remote')) or 0
end

local function set_im_status(status)
	if status == 1 then
		os.execute('fcitx5-remote -o')
	else
		os.execute('fcitx5-remote -c')
	end
end

local function is_cjk_char(char)
	if not char or #char == 0 then return false end

	local first_byte = string.byte(char, 1)

	if first_byte >= 0x80 then
		if #char >= 3 then
			local byte2 = string.byte(char, 2)
			local byte3 = string.byte(char, 3)
			local code = (first_byte % 0x10) * 0x1000 + (byte2 % 0x40) * 0x40 + (byte3 % 0x40)

			if (code >= 0x4E00 and code <= 0x9FFF) or
				(code >= 0x3400 and code <= 0x4DBF) or
				(code >= 0x20000 and code <= 0x2A6DF) then
				return true
			end
		end
	end
	return false
end

local function get_full_char_around_cursor(pos)
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	if pos == 'before' then
		if col <= 1 then return "" end
		local start = col - 1
		while start > 1 and string.byte(line, start) >= 0x80 and string.byte(line, start) < 0xC0 do
			start = start - 1
		end
		return line:sub(start, col - 1)
	elseif pos == 'after' then
		if col >= #line then return "" end
		local finish = col + 1
		while finish < #line and string.byte(line, finish) >= 0x80 and string.byte(line, finish) < 0xC0 do
			finish = finish + 1
		end
		return line:sub(col + 1, finish)
	else
		if col > #line then return "" end
		local finish = col
		while finish < #line and string.byte(line, finish + 1) >= 0x80 and string.byte(line, finish + 1) < 0xC0 do
			finish = finish + 1
		end
		return line:sub(col, finish)
	end
end

local function need_switch_chinese()
	local before = get_full_char_around_cursor('before')
	local after = get_full_char_around_cursor('after')
	local curr = get_full_char_around_cursor('')
	local b_before = is_cjk_char(before)
	local b_after = is_cjk_char(after)
	local b_curr = is_cjk_char(curr)

	return b_before or b_after or b_curr
end

function M.setup()
	if not is_supported() then
		vim.notify("fcitx5-auto-switch: fcitx5-remote not found!", vim.log.levels.WARN)
		return
	end

	local last_im_status = 0

	vim.api.nvim_create_autocmd('InsertEnter', {
		callback = function()
			if need_switch_chinese() then
				vim.notifyx("Chinese") -- 测试一下
				set_im_status(1)
			end
		end
	})

	vim.api.nvim_create_autocmd('InsertLeave', {
		callback = function()
			last_im_status = get_im_status()
			set_im_status(0)
		end
	})

	set_im_status(0)
end

return M
