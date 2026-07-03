local ok, cmp = pcall(require, "cmp")
if ok then
	cmp.register_source("bash_history", require("cmp_bash_history").new())
end
