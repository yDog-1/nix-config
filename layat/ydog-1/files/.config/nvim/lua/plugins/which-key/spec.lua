local spec = {}
spec.body = {}

spec.add = function(sp)
	table.insert(spec.body, { sp })
end

return spec
