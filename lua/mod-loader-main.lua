ModLoader = ModLoader or {};

include("loader-config.lua");

ModLoader.Mods = {}; -- ["Mod name"] = {"mod_includes"}

ModLoader.Includes = {
	["gma"] = function(path)
		ModLoader:DebugPrint("Attempting to mount GMA file.");
		game.MountGMA("addons/gmod-mod-loader/lua/"..path);
	end,
	["lua"] = function(path)
		OldInclude(path);
	end
};


function ModLoader:GetMods()
	return ModLoader.Mods;
end

function ModLoader:GetModPaths(mod)
	return self.Mods[mod];
end

function ModLoader:AddMod(paths, name)
	ModLoader.Mods[name] = paths;
end

function ModLoader:RemoveMod(name)
	table.remove(ModLoader.Mods, name);
end

function ModLoader:FetchModIncludes(PathStart, filepaths)
	self:DebugPrint("IN FetchModIncludes()");
	dir = PathStart .. "/";
	filepaths = filepaths or {};
	local files,dirs = file.Find(dir.."*","LUA");
	for _,v in pairs(files) do
		if string.EndsWith(v, ".gma") then
			table.insert(filepaths, dir..v);
		end
	end
	if string.EndsWith(PathStart, "autorun") then
		for _,v in ipairs(files) do
			table.insert(filepaths, dir..v);
		end
		return filepaths;
	elseif table.Count(dirs) < 1 then
		self:DebugPrint("Returning filepaths table for "..dir);
		return filepaths;
	else
		for _,v in ipairs(dirs) do
			self:DebugPrint("Folder: "..v)
			filepaths = self:FetchModIncludes(dir..v, filepaths);
		end
	end
	return filepaths;
end

function ModLoader:FetchAddonsFolder()
	local files,dirs = file.Find(self.BasePath.."/*", "LUA");
	return dirs;
end

function ModLoader:FetchAddons(folders)
	for _,v in ipairs(folders) do
		local paths = self:FetchModIncludes(self.BasePath.."/"..v, {});
		self:DebugPrint("paths for " .. v);
		self:AddMod(paths, v);
	end
	return self:GetMods();
end

ModLoader:DebugPrint("Setting include functions");
oInclude = include -- Store the old include function.

function include(path) -- overwrite
	oInclude("../"..path);
end

function OldInclude(path) -- Give access to the old one
	oInclude(path)
end

function ModLoader:InitMods()


	self:FetchAddons(self:FetchAddonsFolder())

	self:DebugPrint("Starting mod loop")
	for k,v in ipairs(self:FetchAddonsFolder()) do
		self:DebugPrint("Loading mod: "..v);
		for _,path in pairs(self:GetModPaths(v)) do
			self:DebugPrint("file extension is: "..string.GetExtensionFromFilename(path))
			ModLoader.Includes[string.GetExtensionFromFilename(path)](path);
		end
	end

end

ModLoader:InitMods();

ModLoader:DebugPrint("Reverting Include function.")
include = oInclude -- Reset the include function back to normal so it doesnt fuck with other addons.
