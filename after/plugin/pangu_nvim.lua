local pangu = require("pangu")

local ut = require("jb_utils")

-- TokenType Enum
TokenType = { hans = 1, punc = 2, space = 3, non_word = 4, eng = 5 }

local function get_token_type(token)
	if not token or string.match(token, "%s+") then
		return TokenType.space
	end
	if ut.is_punctuation(token) then
		return TokenType.punc
	end
	if ut.is_chinese(token) then
		return TokenType.hans
	end
	if string.match(token, "[a-zA-Z0-9]") then
		return TokenType.eng
	end
	return TokenType.non_word
end

local parse_tokens = function(tokens)
	local cum_l = 0
	local parsed = {}
	for _, tok in ipairs(tokens) do
		local t = get_token_type(tok)
		cum_l = cum_l + #tok
		table.insert(parsed, t)
	end
	return parsed
end

local function find_han_eng(tab)
	local res = {}
	for i = 1, #tab - 1 do
		local token = tab[i]
		local next_token = tab[i + 1]
		if token == 1 and next_token == 5 then
			res[#res + 1] = i + 1
		else
			if token == 5 and next_token == 1 then
				res[#res + 1] = i + 1
			end
		end
	end
	return res
end

local spacing = function(sentence)
	local tab = {}
	for i in string.gmatch(sentence, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(tab, i)
	end
	local res = find_han_eng(parse_tokens(tab))
	for i = #res, 1, -1 do
		table.insert(tab, res[i], " ")
	end
	return table.concat(tab)
end

vim.api.nvim_create_autocmd({ "BufWritePost" },
  { pattern = "*.md",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    local tab = {}
    for _,j in pairs(lines) do
      tab[#tab+1] = spacing(j)
    end
    vim.api.nvim_buf_set_text(0, 0, 0, -1, -1, tab)
  end
})

print('pangu')
