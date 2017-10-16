--[[
	A Lemur Habitat is an instance of an emulated Roblox environment.

	It is the root instance of the emulated hierarchy.
]]

local Game = require("lemur.Game")
local environment = require("lemur.environment")
local fs = require("lemur.fs")

local Habitat = {}
Habitat.__index = Habitat

function Habitat.new(path)
	local habitat = {}

	habitat._path = path

	habitat.game = Game.new(habitat)

	setmetatable(habitat, Habitat)

	return habitat
end

function Habitat:isFile(path)
	local fullPath = self._path .. "/" .. path

	return fs.isFile(fullPath)
end

function Habitat:isDirectory(path)
	local fullPath = self._path .. "/" .. path

	return fs.isDirectory(fullPath)
end

function Habitat:_load(path)
	local fullPath = self._path .. "/" .. path

	return loadfile(fullPath)
end

function Habitat:require(instance)
	local internalInstance = instance._internal
	if internalInstance._loaded then
		return internalInstance._result
	end

	local chunk, err = self:_load(internalInstance._path)

	if not chunk then
		error(err)
	end

	local env = environment.create(self, instance)
	setfenv(chunk, env)

	local result = chunk()

	internalInstance._loaded = true
	internalInstance._result = result

	return result
end

return Habitat