--[[
	module:MeshExplode()
	module:MeshSpin()
	module:GenerateParticles()
]]



local effect = {}
effect.__index = effect

function effect.new(Target,Object,Time,Rate)

	assert(type(Time) == "number", "Time must be a number")
	assert(type(Rate) == "number", "Rate must be a number")

	local self = setmetatable({
		_target = Target;
		_object = Object;
		_time = Time;
		_rate = Rate;
	}, effect)

	return self
end

function effect:MeshSpin()
	local rs = game:GetService("RunService")

	local Object = self._object
	local Target = self._target
	local T_ime = self._time
	local Rate = self._rate

	Object.Parent = Target
	Object.CFrame = Target.CFrame

	local connection
	connection = rs.Heartbeat:Connect(function()
		Object.CFrame = Object.CFrame * CFrame.Angles(0,math.rad(Rate),0)
	end)

	delay(T_ime, function()
		if connection then
			connection:Disconnect()
		end
	end)
end

function effect:MeshExplode()
	local tweenservice = game:GetService("TweenService")
	local Object = self._object
	local Target = self._target
	local T_ime = self._time
	local Rate = self._rate

	for i=1, Rate do
		local ClonedObject = Object:Clone()
		ClonedObject.Parent = Target
		ClonedObject.CFrame = Target.CFrame * CFrame.new(math.random(-1,1),math.random(-1,1),math.random(-1,1))
		ClonedObject.CFrame = CFrame.new(ClonedObject.Position, Target.Position)
		game.Debris:AddItem(ClonedObject,1)

		tweenservice:Create(
			ClonedObject,
			TweenInfo.new(
				T_ime,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.InOut
			),
			{
				CFrame = ClonedObject.CFrame + ClonedObject.CFrame.lookVector * -7, 
				Transparency = 1,
			}
		):Play()
	end
end

function effect:GenerateParticles()
	local Object = self._object
	local Target = self._target
	local T_ime = self._time
	local Rate = self._rate

	if not Rate then
		Rate = 1
	end

	Object = Object:Clone()
	Object.Parent = Target
	Object:Emit(Rate)
	game.Debris:AddItem(Object,T_ime)
end


return effect