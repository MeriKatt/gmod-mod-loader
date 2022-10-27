ModLoader.DEBUG = false

ModLoader.BasePath = "mod-loader/addons" -- Sets the base path for the addon search to this addon.

function ModLoader:DebugPrint(text)
	if self.DEBUG then
		print("[MODLOADER] "..text)
	end
end

ModLoader.WORKSHOP_ADDONS = {};