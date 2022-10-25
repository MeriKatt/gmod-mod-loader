DEBUG = false

function DebugPrint(text)
	if DEBUG then
		print(text)
	end
end

BasePath = "mod-loader/addons" -- Sets the base path for the addon search to this addon.

oInclude = include -- Store the old include function.

function include(path) -- overwrite
	oInclude("../"..path);
end

function OldInclude(path) -- Give access to the old one
	oInclude(path)
end

function GetIncludeFiles(directory, filepaths) -- Grab init files in addon.
	dir = directory .. "/";
	filepaths = filepaths or {};
	local files,dirs = file.Find(dir.."*","LUA");
	if string.EndsWith(directory, "autorun") then
		for _,v in ipairs(files) do
			table.insert(filepaths, dir..v);
		end
		return filepaths;
	else
		for _,v in ipairs(dirs) do
			DebugPrint("[MODLOADER DEBUG] Folder: "..v)
			filepaths = GetIncludeFiles(dir..v, filepaths);
		end
	end
	return filepaths;
end

function GetAllAddons() -- Grab addons in mod-loader/addons and call GetIncludeFiles in order to include them.
	local files,dirs = file.Find(BasePath.."/*", "LUA");
	for k,v in ipairs(dirs) do
		ToInclude = GetIncludeFiles(BasePath.."/"..v,{});
		for _,file in ipairs(ToInclude) do
			OldInclude(file);
			print("[MODLOADER] LOADED: "..file);
		end
	end
end

GetAllAddons() -- Actually do the above.

include = oInclude -- Reset the include function back to normal so it doesnt fuck with other addons.