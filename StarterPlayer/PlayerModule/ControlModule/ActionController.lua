local _ = {
	SERVER_AUTHORITY_CHANGED = "SERVER_AUTHORITY_CHANGED",
	ACTIONS_RELOADED = "ACTIONS_RELOADED"
}

local ActionController = {}
ActionController.__index = ActionController

function ActionController.new()
	local self = setmetatable({}, ActionController)

	self.enabled = true
	return self
end

function ActionController.initializeActions(data)
	data.connectionUtil:trackConnection(
		"SERVER_AUTHORITY_CHANGED",
		data.eventBus:subscribe("SERVER_AUTHORITY_CHANGED"):Connect(function()
			data.controlModule.actions = {}
		end)
	)

	if
		data.controlModule.actions.MoveAction and data.controlModule.actions.JumpAction
		or not data.engineInterface.player
	then
		return
	end

	pcall(function()
		local inputContexts = script.Parent.Parent.InputContexts

		if data.isServerAuthority then
			inputContexts = data.engineInterface.player.InputContexts
		end

		local characterContext = inputContexts.CharacterContext

		data.controlModule.actions = {
			MoveAction = characterContext.MoveAction,
			JumpAction = characterContext.JumpAction
		}

		data.eventBus:publish("ACTIONS_RELOADED")
	end)
end

function ActionController.update(p)
	if not (p.controlModule.actions.MoveAction and p.controlModule.actions.JumpAction) then
		return
	end

	local controlModule = p.playerModule.ControlModule

	p.controlModule.actions.MoveAction.Enabled = controlModule.Enabled
	p.controlModule.actions.JumpAction.Enabled = controlModule.Enabled

	p.controlModule.moveVector = p.controlModule.actions.MoveAction:GetState()
	p.controlModule.isJumping = p.controlModule.actions.JumpAction:GetState()
end

function ActionController.Enable(_, _: boolean) end

return ActionController