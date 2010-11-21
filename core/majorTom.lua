--[[
	majorTom.lua
		this is a long way to go for a bowie reference
--]]

local controller = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
controller:SetAllPoints(controller:GetParent())

--main controller state
controller:SetAttribute('_onstate-groundControl', [[
	local prevstate = self:GetAttribute('state-main')
	local newstate = self:GetAttribute('state-majorTom') or newstate

	if prevstate ~= newstate then
		self:SetAttribute('state-main', newstate)
	end
]])

--override state
controller:SetAttribute('_onstate-majorTom', [[
	local prevstate = self:GetAttribute('state-main')
	local newstate = newstate or self:GetAttribute('state-groundControl')

	if prevstate ~= newstate then
		self:SetAttribute('state-main', newstate)
	end
]])

--current state (majorTom or groundControl)
controller:SetAttribute('_onstate-main', [[
	self:ChildUpdate('state-main', newstate)
]])

--lock state
controller:SetAttribute('_onstate-lock', [[
	self:ChildUpdate('state-lock', newstate)
]])

--adds the given frame to control by majorTom
controller:SetAttribute('addFrame', [[
	local frameId = ...
	local f = self:GetFrameRef('frame-' .. frameId)

	f:SetParent(self)
	f:SetAttribute('state-main', self:GetAttribute('state-main'))
	f:SetAttribute('state-lock', self:GetAttribute('state-lock'))
	f:SetAttribute('state-destroy', nil)
]])

controller:SetAttribute('delFrame', [[
	local f = self:GetFrameRef('delFrame')

	f:SetAttribute('state-destroy', true)
	f:SetParent(nil)
	f:Hide()
]])

controller:SetAttribute('getFrame', [[
	local frameId = ...
	if frameId then
		local f = self:GetFrameRef('frame-' .. frameId)
		if not f:GetAttribute('destroy') then
			return f
		end
	end
]])

controller:SetAttribute('placeFrame', [[
	local frameId, point, relFrameId, relPoint, xOff, yOff = ...
	local frame = self:GetFrameRef('frame-' .. frameId)
	local relFrame = self:GetFrameRef('frame-' .. relFrameId)

	if frame and relFrame then
		frame:SetPoint(point, relFrame, relPoint, xOff, yOff)
		return true
	end
	return false
]])

local TCFB = select(2, ...)
TCFB.MajorTom = {
	--add frame to state control
	addFrame = function(self, frame)
		local frameId = frame:GetAttribute('id')
		controller:SetFrameRef('frame-' .. frameId, frame)
		controller:Execute(string.format([[ self:RunAttribute('addFrame', '%s') ]], frameId))
	end,

	--remove frame from state control
	removeFrame = function(self, frame)
		controller:SetFrameRef('delFrame', frame)
		controller:Execute([[ self:RunAttribute('delFrame') ]])
	end,

	--updates the state driver for groundControl
	setStateDriver = function(self, values)
		self.stateDriver = stateDriver
		RegisterStateDriver(controller, 'groundControl', values)
	end,

	getStateDriver = function(self, values)
		return self.stateDriver
	end,

	--updates the override state for groundControl (majorTom)
	setOverrideState = function(self, state)
		controller:SetAttribute('state-majorTom', state)
	end,

	getState = function(self)
		return controller:GetAttribute('state-main')
	end,

	--enables|disables the lock state
	setLock = function(self, enable)
		controller:SetAttribute('state-lock', enable and true or false)
	end,

	getLock = function(self)
		return controller:GetAttribute('state-lock')
	end,
}