--[[
	majorTom.lua
		this is a long way to go for a bowie reference
--]]

local controller = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
controller:SetAllPoints(UIParent)

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
	local f = self:GetFrameRef('addFrame')

	if not myFrames then
		myFrames = table.new()
	end
	myFrames[f:GetAttribute('id')] = f

	f:SetParent(self)
	f:SetAttribute('state-main', self:GetAttribute('state-main'))
	f:SetAttribute('state-lock', self:GetAttribute('state-lock'))
]])

--removes the frame from control by majorTom
controller:SetAttribute('remFrame', [[
	local f = ...
	if myFrames then
		myFrames[f:GetAttribute('id')] = nil
	end
]])

local TCFB = select(2, ...)
TCFB.MajorTom = {
	--add frame to state control
	addFrame = function(self, frame)
		controller:SetFrameRef('addFrame', frame)
		controller:Execute([[
			self:RunAttribute('addFrame', self:GetFrameRef('addFrame'))
		]])
	end,

	--remove frame from state control
	removeFrame = function(self, frame)
		controller:SetFrameRef('remFrame', frame)
		controller:Execute([[
			self:RunAttribute('remFrame', self:GetFrameRef('remFrame'))
		]])
	end,

	--updates the state driver for groundControl
	setStateDriver = function(self, values)
		self.stateDriver = stateDriver
		RegisterStateDriver(controller, 'groundControl', values)
		--controller:SetAttribute('state-groundControl', SecureCmdOptionParse(values))
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
}