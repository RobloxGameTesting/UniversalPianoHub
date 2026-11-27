local RunService = game:GetService("RunService")

local CommonUtils = require(script.Parent:WaitForChild("CommonUtils"))
require(script.Parent.Types)

local characterUtil = CommonUtils.get("CharacterUtil")
local connectionUtil = CommonUtils.get("ConnectionUtil")
local eventBus = CommonUtils.get("EventBus")
local userFlag = CommonUtils.get("FlagUtil").getUserFlag("UserPlayerModuleEngineAPI")

local parentModule = require(script.Parent)
local CameraModule = require(script.Parent:WaitForChild("CameraModule"))
local ControlModule = require(script.Parent:WaitForChild("ControlModule"))
local EngineInterface = require(script.Parent:WaitForChild("EngineInterface"))
local InputSampler = require(script.Parent:WaitForChild("InputSampler"))
local ServerAuthority = require(script.Parent:WaitForChild("ServerAuthority"))

local _ = {
	BIND_TO_SIMULATION = "BIND_TO_SIMULATION",
	RENDERSTEPPED_INPUT = "PLAYERMODULE_RENDERSTEPPED_INPUT",
	RENDERSTEPPED_CAMERA = "PLAYERMODULE_RENDERSTEPPED_CAMERA",
	ONLOCALPLAYER = "ONLOCALPLAYER"
}

local PlayerModuleInternal = {}
PlayerModuleInternal.__index = PlayerModuleInternal

function PlayerModuleInternal.new()
	return (setmetatable({
		data = {
			playerModule = parentModule,
			controlModule = {
				isJumping = false,
				moveVector = Vector2.new(),
				worldMoveVector = Vector3.new(),
				actions = {},
				enabled = true
			},
			engineInterface = {
				player = nil,
				character = nil,
				humanoid = nil,
				characterChanged = false
			},
			connectionUtil = connectionUtil.new(),
			eventBus = eventBus.new(),
			isServerAuthority = false
		},
		inputSampler = InputSampler.new()
	}, PlayerModuleInternal))
end

function PlayerModuleInternal.start(p)
	p.data.connectionUtil:trackConnection("ONLOCALPLAYER", characterUtil.onLocalPlayer(function(player)
		if userFlag then
			EngineInterface.update(p.data)
			ServerAuthority.initialize(p.data)
			ControlModule:initialize(p.data)

			RunService:BindToRenderStep(
				"PLAYERMODULE_RENDERSTEPPED_INPUT",
				Enum.RenderPriority.Input.Value,
				function(p2)
					EngineInterface.update(p.data)
					ControlModule:Update(p.data, p2)
				end
			)

			RunService:BindToRenderStep(
				"PLAYERMODULE_RENDERSTEPPED_CAMERA",
				Enum.RenderPriority.Camera.Value,
				function(p2)
					CameraModule:Update(p.data, p2)
					p.inputSampler:Update(p.data)
					EngineInterface.cleanDirty(p.data)
				end
			)
		else
			p.data.engineInterface.player = player

			ServerAuthority.initialize(p.data)
			ControlModule:initialize(p.data)

			RunService:BindToRenderStep(
				"PLAYERMODULE_RENDERSTEPPED_INPUT",
				Enum.RenderPriority.Input.Value,
				function(p2)
					p.data.engineInterface.character = characterUtil.getCharacter()

					if not p.data.engineInterface.character then
						return
					end

					ControlModule:Update(p.data, p2)
				end
			)

			p.data.connectionUtil:trackBoundFunction("PLAYERMODULE_RENDERSTEPPED_INPUT", function()
				RunService:UnbindFromRenderStep("PLAYERMODULE_RENDERSTEPPED_INPUT")
			end)

			RunService:BindToRenderStep(
				"PLAYERMODULE_RENDERSTEPPED_CAMERA",
				Enum.RenderPriority.Camera.Value,
				function(p2)
					CameraModule:Update(p.data, p2)
					p.inputSampler:Update(p.data)
				end
			)

			p.data.connectionUtil:trackBoundFunction("PLAYERMODULE_RENDERSTEPPED_CAMERA", function()
				RunService:UnbindFromRenderStep("PLAYERMODULE_RENDERSTEPPED_CAMERA")
			end)
		end
	end))
end

if not userFlag then
	function PlayerModuleInternal.stop(p)
		p.data.connectionUtil:disconnectAll()
	end
end

return PlayerModuleInternal