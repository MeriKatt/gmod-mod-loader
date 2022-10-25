DEBUG = false

function DebugPrint(text)
	if DEBUG then
		print(text)
	end
end

WORKSHOP_ADDONS = {};

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
	for _,v in pairs(files) do
		if string.EndsWith(v, ".gma") then
			DebugPrint("ATTEMPTING TO MOUNT")
			DebugPrint(v)
			game.MountGMA("addons/gmod-mod-loader/lua/"..dir..v);
		end
	end
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

-- Uncomment the below if you have the gmsv_workshop module and want to pull directly from the workshop.

/*
if require("gmsv_workshop") then
	if table.Count(WORKSHOP_ADDONS) > 0 then
		for _,v in pairs(WORKSHOP_ADDONS) do
			steamworks.DownloadUGC( v, function( path )
				game.MountGMA( path )
			end)
		end
	end
end*/