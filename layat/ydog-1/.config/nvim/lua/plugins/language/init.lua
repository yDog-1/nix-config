require("plugins.which-key.spec").add({
	mode = "n",
	{ "<Leader>l", group = "Language", icon = { icon = "󱌯 ", color = "green" } },
})

return {
	require("plugins.language.markdown"),
}
