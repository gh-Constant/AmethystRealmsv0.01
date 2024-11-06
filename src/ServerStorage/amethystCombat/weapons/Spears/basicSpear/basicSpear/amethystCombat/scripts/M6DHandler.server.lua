local m6d
local tool = script.Parent.Parent.Parent

tool.Equipped:Connect(function()
	local char = tool.Parent
	local a:Weld = char:FindFirstChild("RightHand"):WaitForChild("RightGrip")
	m6d = Instance.new("Motor6D")
	m6d.Parent = char:FindFirstChild("RightHand")
	m6d.Name = "RightGrip"
	m6d.Part0 = a.Part0
	m6d.Part1 = a.Part1
	m6d.C0 = a.C0
	m6d.C1 = a.C1
	a:Destroy()
end)

tool.Unequipped:Connect(function()
	m6d:Destroy()
end)