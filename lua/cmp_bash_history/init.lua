local source = {}

local defaults = {
	-- history file path; nil resolves to $HISTFILE or ~/.bash_history
	histfile = nil,
	-- maximum number of items returned, most recent first
	max_items = 5000,
}

source.new = function()
	local self = setmetatable({}, { __index = source })
	self.cache = {}
	return self
end

function source:is_available()
	return true
end

function source:get_debug_name()
	return "bash_history"
end

---Span the whole typed command (first non-blank char up to the cursor), so
---accepting an item replaces the entire partial command instead of only the
---word under the cursor.
function source:get_keyword_pattern()
	return [[\S\+\%(\s\+\S*\)*]]
end

local function get_option(params)
	local opts = vim.tbl_deep_extend("keep", params.option or {}, defaults)
	if not opts.histfile or opts.histfile == "" then
		opts.histfile = vim.env.HISTFILE or "~/.bash_history"
	end
	opts.histfile = vim.fn.expand(opts.histfile)
	return opts
end

local function read_history(path, max_items)
	local file = io.open(path, "r")
	if not file then
		return {}
	end
	local lines = {}
	for line in file:lines() do
		lines[#lines + 1] = line
	end
	file:close()

	local cmp = require("cmp")
	local items = {}
	local seen = {}
	-- iterate backwards so the most recent occurrence of a command wins
	for i = #lines, 1, -1 do
		local line = vim.trim(lines[i])
		-- skip blanks and HISTTIMEFORMAT timestamp lines like "#1719999999"
		if line ~= "" and not line:match("^#%d+$") and not seen[line] then
			seen[line] = true
			items[#items + 1] = {
				label = line,
				kind = cmp.lsp.CompletionItemKind.Text,
				sortText = string.format("%08d", #items + 1),
				dup = 0,
			}
			if #items >= max_items then
				break
			end
		end
	end
	return items
end

function source:complete(params, callback)
	local opts = get_option(params)
	local uv = vim.uv or vim.loop
	local stat = uv.fs_stat(opts.histfile)
	if not stat then
		return callback({ items = {}, isIncomplete = false })
	end

	local cache = self.cache[opts.histfile]
	if not cache or cache.mtime ~= stat.mtime.sec or cache.size ~= stat.size or cache.max_items ~= opts.max_items then
		cache = {
			mtime = stat.mtime.sec,
			size = stat.size,
			max_items = opts.max_items,
			items = read_history(opts.histfile, opts.max_items),
		}
		self.cache[opts.histfile] = cache
	end

	callback({ items = cache.items, isIncomplete = false })
end

return source
