local __lt = (function()
	local globalEnv = (getgenv and getgenv()) or _G or {}
	local cached = type(globalEnv) == "table" and rawget(globalEnv, "__NAServiceResolver") or nil
	if type(cached) == "table" then
		return cached
	end
	local loader = loadstring or load
	if type(loader) ~= "function" then
		error("Service resolver loader unavailable")
	end
	local resolver = loader(game:HttpGet("https://ltseverydayyou.github.io/ServiceResolver.luau"), "@ServiceResolver.luau")
	if type(resolver) ~= "function" then
		error("Service resolver failed to compile")
	end
	local loaded = resolver()
	if type(loaded) ~= "table" then
		error("Service resolver failed to load")
	end
	return loaded
end)()

local __NAUIProtector = (function()
	local globalEnv = (getgenv and getgenv()) or _G or {}
	local cached = type(globalEnv) == "table" and rawget(globalEnv, "__NAUIProtector") or nil
	if type(cached) == "table" then
		return cached
	end
	local loader = loadstring or load
	if type(loader) ~= "function" then
		return nil
	end
	local protector = loader(game:HttpGet("https://ltseverydayyou.github.io/UIprotector.luau"), "@UIprotector.luau")
	if type(protector) ~= "function" then
		return nil
	end
	local loaded = protector()
	if type(loaded) == "table" then
		return loaded
	end
	return nil
end)()

local __NACloneRef = type(cloneref) == "function" and cloneref or nil

local function NAGetService(name)
	local service = nil
	if __NACloneRef and __lt and type(__lt.cs) == "function" then
		local ok, result = pcall(__lt.cs, name, __NACloneRef)
		if ok and result then
			service = result
		end
	end
	if not service and __lt and type(__lt.gs) == "function" then
		local ok, result = pcall(__lt.gs, name)
		if ok and result then
			service = result
		end
	end
	return service or game:GetService(name)
end

local function NAProtectUI(instance)
	if __NAUIProtector and type(__NAUIProtector.protectName) == "function" then
		pcall(__NAUIProtector.protectName, instance)
	end
	return instance
end

local function NADisconnect(conn)
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
	return nil
end

local function NADestroy(instance)
	if instance then
		pcall(function()
			instance:Destroy()
		end)
	end
end

local Players      = NAGetService("Players")
local RunService   = NAGetService("RunService")
local TweenService = NAGetService("TweenService")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
repeat task.wait() until Char:FindFirstChild("Torso")


local Torso = Char:WaitForChild("Torso")
local rArm  = Char:WaitForChild("Right Arm")
local lArm  = Char:WaitForChild("Left Arm")
local Head  = Char:WaitForChild("Head")
local Humanoid = Char:FindFirstChildOfClass("Humanoid")

if not Humanoid or Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
	return
end

local function resolveR6Shoulders()
	local right = Torso:FindFirstChild("Right Shoulder")
	local left = Torso:FindFirstChild("Left Shoulder")
	if right and left then
		return right, left
	end
	pcall(function()
		Humanoid:UnequipTools()
	end)
	local deadline = os.clock() + 1.5
	repeat
		task.wait()
		right = Torso:FindFirstChild("Right Shoulder")
		left = Torso:FindFirstChild("Left Shoulder")
	until (right and left) or os.clock() >= deadline
	if right and left then
		return right, left
	end
	for _, inst in ipairs(Torso:GetChildren()) do
		if inst:IsA("Weld") and (inst.Name == "lWeld" or inst.Name == "rWeld") then
			NADestroy(inst)
		end
	end
	local function makeShoulder(name, part1, c0, c1)
		local joint = Instance.new("Motor6D")
		joint.Name = name
		joint.Part0 = Torso
		joint.Part1 = part1
		joint.C0 = c0
		joint.C1 = c1
		joint.Parent = Torso
		return joint
	end
	right = right or makeShoulder("Right Shoulder", rArm, CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0), CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0))
	left = left or makeShoulder("Left Shoulder", lArm, CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0), CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0))
	return right, left
end

local rShoulder, lShoulder = resolveR6Shoulders()
if not rShoulder or not lShoulder then
	return
end

local defLS_C0 = lShoulder.C0
local defLS_C1 = lShoulder.C1
local defRS_C0 = rShoulder.C0
local defRS_C1 = rShoulder.C1

local rShoulderStorage = rShoulder:Clone()
local lShoulderStorage = lShoulder:Clone()


local CF   = CFrame.new
local CFAN = CFrame.Angles
local RAD  = math.rad
local VEC3 = Vector3.new
local RS   = RunService.Stepped


local CHERRY_UNLIT = Color3.fromRGB(40,  40,  40)
local CHERRY_IDLE  = Color3.fromRGB(200, 80,  0)
local CHERRY_DRAG  = Color3.fromRGB(255, 140, 20)


local Selected  = false
local pulling   = false
local hasPipe   = false
local drawing   = false
local ready     = false
local isLit     = false

local lWeld, rWeld
local currentPipe, currentWeld, pipeWeld, pipeAnchor
local activatedConn
local deactivatedConn
local activeToken = 0


local function TweenJoint(Joint, NewC0, NewC1, Alpha, Duration)
	if not Joint or not Joint.Parent then return end
	coroutine.resume(coroutine.create(function()
		if not Joint or not Joint.Parent then return end
		local TweenIndicator
		local NewCode = math.random(-1e9, 1e9)
		if not Joint:FindFirstChild("TweenCode") then
			TweenIndicator        = Instance.new("IntValue")
			TweenIndicator.Name   = "TweenCode"
			TweenIndicator.Value  = NewCode
			TweenIndicator.Parent = Joint
		else
			TweenIndicator        = Joint.TweenCode
			TweenIndicator.Value  = NewCode
		end
		local function MatrixCFrame(CFPos, CFTop, CFBack)
			local CFRight = CFTop:Cross(CFBack)
			return CF(
				CFPos.x,   CFPos.y,   CFPos.z,
				CFRight.x, CFTop.x,   CFBack.x,
				CFRight.y, CFTop.y,   CFBack.y,
				CFRight.z, CFTop.z,   CFBack.z
			)
		end
		local function LerpCF(StartCF, EndCF, Al)
			local StartTop  = (StartCF * CFAN(RAD(90),0,0)).lookVector
			local StartBack = -StartCF.lookVector
			local EndTop    = (EndCF   * CFAN(RAD(90),0,0)).lookVector
			local EndBack   = -EndCF.lookVector
			return MatrixCFrame(
				StartCF.p:lerp(EndCF.p, Al),
				StartTop:lerp(EndTop, Al),
				StartBack:lerp(EndBack, Al)
			)
		end
		local StartC0 = Joint.C0
		local StartC1 = Joint.C1
		local X = 0
		while true do
			if not Joint or not Joint.Parent then break end
			local NewX = X + math.min(1.5 / math.max(Duration, 0), 90)
			X = (NewX > 90 and 90 or NewX)
			if TweenIndicator.Value ~= NewCode then break end
			if not Selected then break end
			if NewC0 then Joint.C0 = LerpCF(StartC0, NewC0, Alpha(X)) end
			if NewC1 then Joint.C1 = LerpCF(StartC1, NewC1, Alpha(X)) end
			if X == 90 then break end
			RS:wait()
		end
		if TweenIndicator.Value == NewCode then
			NADestroy(TweenIndicator)
		end
	end))
end

local function Linear(X) return X / 90 end


local LeftValue2  = CF(-1.33,-0.14, 0.3 ) * CFAN(RAD(  7.261), RAD(-54.019), RAD( 14.367))
local LeftValue3  = CF(-0.84, 0.58,-0.71) * CFAN(RAD(-77.331), RAD(-163.091),RAD(-108.349))
local RightValue2 = CF( 1.1,  0.74,-0.81) * CFAN(RAD(-75.651), RAD(-158.195), RAD(115.249))
local RightValue4 = CF( 1.45,-0.04,-0.13) * CFAN(RAD(-10.373), RAD(  -6.056), RAD(  0.231))


local PIPE_REST  = CF(0.18, 0.3, 0.2) * CFAN(RAD(-30.954), RAD(130.889), RAD(18.939))
local PIPE_MOUTH = CF(0.18, 0.3, 0.2) * CFAN(RAD(-30.954), RAD(130.889), RAD(18.939))


local function tweenEmber(cherry, targetColour, targetTransp, duration)
	if not cherry or not cherry.Parent then return end
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	TweenService:Create(cherry, info, {
		Color        = targetColour,
		Transparency = targetTransp,
	}):Play()
end













local function buildPipe()
	local pipe = Instance.new("Model")
	pipe.Name  = "Pipe"

	local function makePart(name, sz, col, mat, transp)
		local p = Instance.new("Part")
		p.Name         = name
		p.Size         = sz
		p.BrickColor   = BrickColor.new(col)
		p.Material     = Enum.Material[mat] or Enum.Material.SmoothPlastic
		p.Transparency = transp or 0
		p.CanCollide   = false
		p.CastShadow   = false
		p.Anchored     = false
		p.Parent       = pipe
		return p
	end

	local function attachWeld(child, root, c0)
		local w = Instance.new("Weld")
		w.Name   = "Weld"
		w.Part0  = child
		w.Part1  = root
		w.C0     = c0
		w.Parent = child
	end




	local Bowl = makePart("Bowl", VEC3(0.05, 0.05, 0.05), "Really black", "SmoothPlastic", 1)



	local wallCount = 16
	local wallRadius    = 0.125
	local wallHeight    = 0.20
	local wallThickness = 0.05

	local wallWidth = 2 * wallRadius * math.sin(math.pi / wallCount) + 0.01

	for i = 1, wallCount do
		local angle = (i / wallCount) * math.pi * 2
		local x = math.cos(angle) * wallRadius
		local z = math.sin(angle) * wallRadius
		local seg = makePart("BowlWall", VEC3(wallWidth, wallHeight, wallThickness), "Burnt Sienna", "SmoothPlastic")

		attachWeld(seg, Bowl, CFAN(0, -angle, 0) * CF(z, 0.06, x))

	end


	local BowlCap     = makePart("BowlCap", VEC3(0.28, 0.03, 0.28), "Burnt Sienna", "SmoothPlastic")
	local BowlCapMesh = Instance.new("CylinderMesh", BowlCap)
	BowlCapMesh.Name  = "Mesh"
	attachWeld(BowlCap, Bowl, CF(0, -0.04, 0))


	local Crackle         = Instance.new("Sound")
	Crackle.Name          = "Crackle"
	Crackle.SoundId       = "rbxassetid://150367028"
	Crackle.Volume        = 0.22
	Crackle.Looped        = true
	Crackle.PlaybackSpeed = 0.85
	Crackle.Parent        = Bowl
	local eq      = Instance.new("EqualizerSoundEffect")
	eq.HighGain   = -22
	eq.LowGain    = -35
	eq.MidGain    = -70
	eq.Priority   = 0
	eq.Parent     = Crackle

	local ExtSound      = Instance.new("Sound")
	ExtSound.Name       = "Sound"
	ExtSound.SoundId    = "rbxassetid://229579267"
	ExtSound.Volume     = 0.5
	ExtSound.Parent     = Bowl


	local Stem     = makePart("Stem", VEC3(0.10, 0.68, 0.10), "Burnt Sienna", "SmoothPlastic")
	local StemMesh = Instance.new("CylinderMesh", Stem)
	StemMesh.Name  = "Mesh"
	attachWeld(Stem, Bowl, CF(0, -0.45, 0) * CFAN(RAD(90), 0, 0))


	local Tobaccy     = makePart("Tobaccy", VEC3(0.20, 0.015, 0.20), "Reddish brown", "SmoothPlastic")
	local TobaccyMesh = Instance.new("CylinderMesh", Tobaccy)
	TobaccyMesh.Name  = "Mesh"
	attachWeld(Tobaccy, Bowl, CF(0, 0.10, 0))


	local Cherry     = makePart("Cherry", VEC3(0.20, 0.008, 0.20), "Fossil", "Neon", 1)
	Cherry.Color     = CHERRY_UNLIT
	local CherryMesh = Instance.new("CylinderMesh", Cherry)
	CherryMesh.Name  = "Mesh"
	attachWeld(Cherry, Bowl, CF(0, 0.115, 0))


	local SmkEmit                 = Instance.new("ParticleEmitter")
	SmkEmit.Texture               = "rbxasset://textures/particles/smoke_main.dds"
	SmkEmit.Color                 = ColorSequence.new(
		Color3.fromRGB(175,175,175), Color3.fromRGB(115,115,115))
	SmkEmit.LightEmission         = 0
	SmkEmit.LightInfluence        = 1
	SmkEmit.EmissionDirection     = Enum.NormalId.Top
	SmkEmit.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.09),
		NumberSequenceKeypoint.new(0.5, 0.26),
		NumberSequenceKeypoint.new(1,   0.52),
	}
	SmkEmit.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.20),
		NumberSequenceKeypoint.new(0.7, 0.70),
		NumberSequenceKeypoint.new(1,   1),
	}
	SmkEmit.Lifetime      = NumberRange.new(1.5, 3.0)
	SmkEmit.Rate          = 6
	SmkEmit.Speed         = NumberRange.new(0.5, 1.6)
	SmkEmit.SpreadAngle   = Vector2.new(12, 12)
	SmkEmit.RotSpeed      = NumberRange.new(-25, 25)
	SmkEmit.Enabled       = false
	SmkEmit.Parent        = Tobaccy

	local Fizzled       = Instance.new("BoolValue")
	Fizzled.Name        = "Fizzled"
	Fizzled.Value       = false
	Fizzled.Parent      = pipe

	return pipe
end



local function buildLighter()
	local function makePart(name, sz, col, mat, transp)
		local p = Instance.new("Part")
		p.Name         = name
		p.Size         = sz
		p.BrickColor   = BrickColor.new(col)
		p.Material     = Enum.Material[mat] or Enum.Material.SmoothPlastic
		p.Transparency = transp or 0
		p.CanCollide   = false
		p.CastShadow   = false
		p.Anchored     = false
		return p
	end

	local function attachWeld(child, root, c0)
		local w = Instance.new("Weld")
		w.Name   = "Weld"
		w.Part0  = child
		w.Part1  = root
		w.C0     = c0
		w.Parent = child
	end

	local lighter   = Instance.new("Model")
	lighter.Name    = "Lighter"
	local body      = Instance.new("Part")
	body.Name       = "Union"
	body.Size       = VEC3(0.167, 0.361, 0.381)
	body.BrickColor = BrickColor.new("Medium stone grey")
	body.Material = Enum.Material.Metal
	body.CanCollide = false
	body.Parent = lighter

	local lid = makePart("lid", VEC3(0.167, 0.214, 0.381), "Medium stone grey", "Metal", 0)
	lid.Parent = lighter
	attachWeld(lid, body, CF(0, 0.11, -0.45)*CFAN(RAD(45),0,0))

	local cage = makePart("cage", VEC3(0.184, 0.098, 0.084), "Really black", "Plastic", 1)
	local t = Instance.new("Decal")
	t.Texture  = "rbxassetid://95858094726954"
	t.Face = Enum.NormalId.Front
	t.Color3 = Color3.fromRGB(34, 34, 34)
	t.Parent = cage
	local t2 = t:Clone()
	t2.Face = Enum.NormalId.Back
	t2.Parent = cage
	t2 = t:Clone()
	t2.Face = Enum.NormalId.Right
	t2.Parent = cage
	t2 = t:Clone()
	t2.Face = Enum.NormalId.Left
	t2.Parent = cage
	cage.Parent = lighter
	attachWeld(cage, body, CF(0, -0.22, 0)*CFAN(0,RAD(90),0))

	local rock = makePart("rock", VEC3(0.084, 0.084, 0.084), "Black", "Basalt", 0)
	local rockMesh = Instance.new("CylinderMesh",rock)
	rockMesh.Name = "Mesh"
	rock.Parent = lighter
	attachWeld(rock, body, CF(0.25, 0, 0.14)*CFAN(0,0,RAD(90)))

	local rope = makePart("rope", VEC3(0.084, 0.084, 0.021), "Medium brown", "Sand", 0)
	local ropeMesh = Instance.new("CylinderMesh",rope)
	ropeMesh.Name = "Mesh"
	local Bill = Instance.new("BillboardGui")
	Bill.Enabled = false
	Bill.Parent = rope
	Bill.Size = UDim2.new(0.209, 0, 0.293, 0)
	Bill.StudsOffset = Vector3.new(0, 0.146, 0)
	local im = Instance.new("ImageLabel")
	im.Image = "rbxassetid://91181651318006"
	im.BackgroundTransparency = 1
	im.Size = UDim2.new(1, 0, 1, 0)
	im.Parent = Bill
	rope.Parent = lighter
	attachWeld(rope, body, CF(0, -0.22, 0))
	return lighter
end


local function buildPuff()
	local puff             = Instance.new("ParticleEmitter")
	puff.Texture           = "rbxasset://textures/particles/smoke_main.dds"
	puff.Color             = ColorSequence.new(
		Color3.fromRGB(215,215,215), Color3.fromRGB(175,175,175))
	puff.LightEmission     = 0
	puff.LightInfluence    = 1
	puff.EmissionDirection = Enum.NormalId.Front
	puff.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.40),
		NumberSequenceKeypoint.new(0.5, 0.90),
		NumberSequenceKeypoint.new(1,   1.60),
	}
	puff.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.20),
		NumberSequenceKeypoint.new(0.6, 0.65),
		NumberSequenceKeypoint.new(1,   1),
	}
	puff.Lifetime    = NumberRange.new(3, 5)
	puff.Rate        = 20
	puff.Speed       = NumberRange.new(1, 3)
	puff.SpreadAngle = Vector2.new(35, 35)
	puff.RotSpeed    = NumberRange.new(-30, 30)
	puff.Enabled     = false
	return puff
end


local function removeShoulderMotors()
	for _, m in ipairs(Torso:GetChildren()) do
		if m:IsA("Motor6D") and
			(m.Name == "Left Shoulder" or m.Name == "Right Shoulder") then
			NADestroy(m)
		end
	end
end

local function restoreShoulders()
	if lWeld then NADestroy(lWeld); lWeld = nil end
	if rWeld then NADestroy(rWeld); rWeld = nil end
	removeShoulderMotors()
	lShoulderStorage:Clone().Parent = Torso
	rShoulderStorage:Clone().Parent = Torso
end




local Tool          = Instance.new("Tool")
Tool.Name           = "Pipe"
Tool.ToolTip        = "Pipe"
Tool.RequiresHandle = true
Tool.CanBeDropped   = false

local Handle        = Instance.new("Part")
Handle.Name         = "Handle"
Handle.Size         = VEC3(0.1, 0.1, 0.1)
Handle.Transparency = 1
Handle.CanCollide   = false
Handle.Parent       = Tool

local reloadVal     = Instance.new("BoolValue")
reloadVal.Name      = "reload"
reloadVal.Value     = false
reloadVal.Parent    = Tool

Tool.Parent = LP.Backpack

local function isCurrentRun(token)
	return token == activeToken and Selected and Tool and Tool.Parent ~= nil
end




Tool.Equipped:Connect(function()
	activeToken = activeToken + 1
	local equipToken = activeToken
	Selected = true
	deactivatedConn = NADisconnect(deactivatedConn)

	lWeld        = Instance.new("Weld")
	lWeld.Name   = "lWeld"
	lWeld.C0     = defLS_C0
	lWeld.C1     = defLS_C1
	lWeld.Part0  = Torso
	lWeld.Part1  = lArm

	rWeld        = Instance.new("Weld")
	rWeld.Name   = "rWeld"
	rWeld.C0     = defRS_C0
	rWeld.C1     = defRS_C1
	rWeld.Part0  = Torso
	rWeld.Part1  = rArm

	removeShoulderMotors()
	lWeld.Parent = Torso
	rWeld.Parent = Torso


	pipeAnchor              = Instance.new("Part")
	pipeAnchor.Name         = "PipeAnchor"
	pipeAnchor.Size         = VEC3(0.1, 0.1, 0.1)
	pipeAnchor.Transparency = 1
	pipeAnchor.CanCollide   = false
	pipeAnchor.Parent       = rArm

	local anchorWeld      = Instance.new("Weld")
	anchorWeld.Name       = "anchorWeld"
	anchorWeld.Part0      = pipeAnchor
	anchorWeld.Part1      = rArm
	anchorWeld.C0         = CF(0.2, 0.9, 0.5) * CFAN(RAD(20), RAD(0), RAD(30))
	anchorWeld.C1         = CF(-0.5, 0, 0.5)   * CFAN(RAD(13), RAD(170), 0)
	anchorWeld.Parent     = pipeAnchor

	local pipeClone = buildPipe()

	pipeWeld        = Instance.new("Weld")
	pipeWeld.Name   = "pipeWeld"
	pipeWeld.Part0  = pipeClone.Bowl
	pipeWeld.Part1  = pipeAnchor
	pipeWeld.C1     = CF(0, 0, 0) * CFAN(RAD(90),0,0)
	pipeWeld.C0     = PIPE_REST
	pipeWeld.Parent = pipeClone
	pipeClone.Parent = rArm

	currentPipe = pipeClone
	currentWeld = pipeWeld
	hasPipe     = true

	if isLit then
		local cherry = pipeClone:FindFirstChild("Cherry")
		if cherry then
			cherry.Color        = CHERRY_IDLE
			cherry.Transparency = 0.05
		end
		pipeClone.Bowl.Crackle:Play()
		local pe = pipeClone.Tobaccy:FindFirstChildOfClass("ParticleEmitter")
		if pe then pe.Enabled = true end
	end

	TweenJoint(rWeld, RightValue4, CF(0,0,0), Linear, 0.5)
	task.wait(0.55)
	if not isCurrentRun(equipToken) then return end
	ready = true


	activatedConn = NADisconnect(activatedConn)
	activatedConn = Tool.Activated:Connect(function()
		if not isCurrentRun(equipToken) then return end




		if hasPipe and ready and not pulling and not isLit then
			pulling = true

			local pipeRef   = currentPipe
			local cherryRef = pipeRef:FindFirstChild("Cherry")

			TweenJoint(lWeld,    LeftValue2,  CF(0,0,0), Linear, 0.5)
			TweenJoint(rWeld,    RightValue2, CF(0,0,0), Linear, 0.5)
			TweenJoint(pipeWeld, PIPE_MOUTH,  CF(0,0,0), Linear, 0.5)
			task.wait(0.5)
			if not isCurrentRun(equipToken) then pulling = false; return end

			local lighterClone = buildLighter()
			local lighterBody  = lighterClone:FindFirstChildWhichIsA("Part")
			local lw           = Instance.new("Weld")
			lw.Name            = "lighterWeld"
			lw.Part0           = lighterBody
			lw.Part1           = lArm
			lw.C0              = CF(-0.34,-0.15,-1.11)*CFAN(RAD(95),RAD(0),RAD(-170))
			lw.C1              = CF(0,0,0)
			lw.Parent          = lighterClone
			lighterClone.Parent = lArm

			TweenJoint(lWeld, LeftValue3, CF(0,0,0), Linear, 0.5)
			task.wait(0.6)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end
			local lSnd = lighterBody:FindFirstChild("Sound")
			if lSnd then lSnd:Play() end
			task.wait(0.1)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end

			local lGUI = lighterClone.rope:FindFirstChildOfClass("BillboardGui")
			if lGUI then
				NAProtectUI(lGUI)
				lGUI.Enabled = true
			end

			tweenEmber(cherryRef, CHERRY_IDLE, 0.05, 1.4)
			task.wait(0.9)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end

			pipeRef.Tobaccy:FindFirstChildOfClass("ParticleEmitter").Enabled = true
			pipeRef.Bowl.Crackle:Play()

			task.wait(0.5)
			if lGUI then lGUI.Enabled = false end
			task.wait(0.2)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end

			TweenJoint(lWeld, LeftValue2, CF(0,0,0), Linear, 0.5)
			task.wait(0.5)
			NADestroy(lighterClone)

			lShoulderStorage:Clone().Parent = Torso
			if lWeld then NADestroy(lWeld); lWeld = nil end

			TweenJoint(rWeld,    RightValue4, CF(0,0,0), Linear, 0.5)
			TweenJoint(pipeWeld, PIPE_REST,   CF(0,0,0), Linear, 0.5)

			pulling = false
			isLit   = true




		elseif hasPipe and ready and isLit and not pulling and not drawing then
			drawing = true

			local pipeRef   = currentPipe
			local cherryRef = pipeRef:FindFirstChild("Cherry")

			TweenJoint(rWeld,    RightValue2, CF(0,0,0), Linear, 0.5)
			TweenJoint(pipeWeld, PIPE_MOUTH,  CF(0,0,0), Linear, 0.5)
			task.wait(0.5)
			if not isCurrentRun(equipToken) then drawing = false; return end

			if drawing then
				pipeRef.Bowl.Crackle.PlaybackSpeed = 1.9
				pipeRef.Bowl.Crackle.Volume        = 0.42
				tweenEmber(cherryRef, CHERRY_DRAG, 0, 0.4)
			end

			deactivatedConn = NADisconnect(deactivatedConn)
			deactivatedConn = Tool.Deactivated:Connect(function()
				deactivatedConn = NADisconnect(deactivatedConn)
				if not (hasPipe and ready and not pulling) then return end

				if not reloadVal.Value then
					reloadVal.Value = true
					local puff = buildPuff()
					local at   = Instance.new("Attachment")
					at.CFrame  = CF(0, -0.25, 0)
					at.Parent  = Head
					puff.Enabled = true
					puff.Parent  = at
					task.spawn(function()
						task.wait(2.5)
						if puff then puff.Enabled = false end
						task.wait(1)
						NADestroy(at)
						reloadVal.Value = false
					end)
				end

				drawing = false

				local cr = currentPipe
				if cr then
					local cCherry = cr:FindFirstChild("Cherry")
					tweenEmber(cCherry, CHERRY_IDLE, 0.05, 0.9)
				end

				TweenJoint(rWeld,    RightValue4, CF(0,0,0), Linear, 0.5)
				TweenJoint(pipeWeld, PIPE_REST,   CF(0,0,0), Linear, 0.5)
				pipeRef.Bowl.Crackle.PlaybackSpeed = 0.85
				pipeRef.Bowl.Crackle.Volume        = 0.22
			end)
		end
	end)
end)




Tool.Unequipped:Connect(function()
	activeToken = activeToken + 1
	Selected = false
	activatedConn = NADisconnect(activatedConn)
	deactivatedConn = NADisconnect(deactivatedConn)
	isLit = false
	if hasPipe then
		hasPipe  = false
		ready    = false
		pulling  = false
		drawing  = false
		if currentPipe and currentPipe.Parent then
			currentPipe.Bowl.Crackle:Stop()
			local pe = currentPipe.Tobaccy:FindFirstChildOfClass("ParticleEmitter")
			if pe then pe.Enabled = false end
			NADestroy(currentPipe)
			currentPipe = nil
		end
	end

	if pipeAnchor then
		NADestroy(pipeAnchor)
		pipeAnchor = nil
	end

	restoreShoulders()


end)
