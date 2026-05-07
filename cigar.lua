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
local hasCigar  = false
local drawing   = false
local ready     = false
local isLit     = false

local heat    = 0
local size    = 5000
local minSize = 1050

local lWeld, rWeld
local currentCigar, currentWeld, cigarWeld, cigarAnchor
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


local LeftValue2 = CF(-1.33,-0.14, 0.3 ) * CFAN(RAD(  7.261), RAD(-54.019), RAD( 14.367))
local LeftValue3 = CF(-0.84, 0.58,-1) * CFAN(RAD(-77.331), RAD(-163.091),RAD(-123.349))
local RightValue2 = CF( 1.1, 0.74,-0.81) * CFAN(RAD(-75.651), RAD(-158.195), RAD(115.249))
local RightValue4 = CF( 1.45,-0.04,-0.13)* CFAN(RAD(-10.373), RAD(  -6.056), RAD(  0.231))




local function tweenCherry(cherry, light, targetColour, targetTransp, targetBright, duration)
	if not cherry or not cherry.Parent then return end
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	TweenService:Create(cherry, info, {
		Color        = targetColour,
		Transparency = targetTransp,
	}):Play()
	if light then
		TweenService:Create(light, info, {
			Brightness = targetBright,
			Color      = targetColour,
		}):Play()
	end
end







local function buildCigar()
	local cig = Instance.new("Model")
	cig.Name  = "Cigar"

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
		p.Parent       = cig
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



	local Body     = makePart("Paper", VEC3(0.22, 1.0, 0.22), "Burnt Sienna", "SmoothPlastic")
	local BodyMesh = Instance.new("CylinderMesh", Body)
	BodyMesh.Name  = "Mesh"


	local Crackle         = Instance.new("Sound")
	Crackle.Name          = "Crackle"
	Crackle.SoundId       = "rbxassetid://150367028"
	Crackle.Volume        = 0.18
	Crackle.Looped        = true
	Crackle.PlaybackSpeed = 1.0
	Crackle.Parent        = Body
	local eq      = Instance.new("EqualizerSoundEffect")
	eq.HighGain   = -22
	eq.LowGain    = -35
	eq.MidGain    = -70
	eq.Priority   = 0
	eq.Parent     = Crackle


	local ExtSound      = Instance.new("Sound")
	ExtSound.Name       = "Sound"
	ExtSound.SoundId    = "rbxassetid://229579267"
	ExtSound.Volume     = 0.6
	ExtSound.Parent     = Body


	local Cap     = makePart("Filter", VEC3(0.22, 0.22, 0.22), "Burnt Sienna", "SmoothPlastic")
	local CapMesh = Instance.new("SpecialMesh", Cap)
	CapMesh.MeshType = Enum.MeshType.Sphere
	CapMesh.Name  = "Mesh"
	attachWeld(Cap, Body, CF(0, -0.5, 0))


	local Band     = makePart("Band", VEC3(0.225, 0.055, 0.225), "Bright red", "SmoothPlastic")
	local BandMesh = Instance.new("CylinderMesh", Band)
	BandMesh.Name  = "Mesh"
	attachWeld(Band, Body, CF(0, -0.35, 0))


	local Tobaccy     = makePart("Tobaccy", VEC3(0.215, 0.012, 0.215), "Reddish brown", "SmoothPlastic")
	local TobaccyMesh = Instance.new("CylinderMesh", Tobaccy)
	TobaccyMesh.Name  = "Mesh"
	local tobaccyWeld       = Instance.new("Weld")
	tobaccyWeld.Name        = "TobaccyWeld"
	tobaccyWeld.Part0       = Tobaccy
	tobaccyWeld.Part1       = Body
	tobaccyWeld.C0          = CF(0, 0.506, 0)
	tobaccyWeld.Parent      = Tobaccy


	local Cherry     = makePart("Cherry", VEC3(0.22, 0.035, 0.22), "Fossil", "Neon", 1)
	Cherry.Color     = CHERRY_UNLIT
	local CherryMesh = Instance.new("CylinderMesh", Cherry)
	CherryMesh.Name  = "Mesh"
	local cherryWeld       = Instance.new("Weld")
	cherryWeld.Name        = "CherryWeld"
	cherryWeld.Part0       = Cherry
	cherryWeld.Part1       = Body
	cherryWeld.C0          = CF(0, 0.518, 0)
	cherryWeld.Parent      = Cherry
	cig:SetAttribute("CherryWeldName", "CherryWeld")


	local CherryLight           = Instance.new("PointLight")
	CherryLight.Name            = "CherryLight"
	CherryLight.Brightness      = 0
	CherryLight.Range           = 10
	CherryLight.Color           = Color3.fromRGB(255, 100, 0)
	CherryLight.Parent          = Cherry


	local SmkEmit                 = Instance.new("ParticleEmitter")
	SmkEmit.Texture               = "rbxasset://textures/particles/smoke_main.dds"
	SmkEmit.Color                 = ColorSequence.new(
		Color3.fromRGB(175,175,175), Color3.fromRGB(130,130,130))
	SmkEmit.LightEmission         = 0
	SmkEmit.LightInfluence        = 1
	SmkEmit.EmissionDirection     = Enum.NormalId.Back
	SmkEmit.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.14),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1,   0.65),
	}
	SmkEmit.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0,   0.25),
		NumberSequenceKeypoint.new(0.7, 0.72),
		NumberSequenceKeypoint.new(1,   1),
	}
	SmkEmit.Lifetime      = NumberRange.new(1.5, 3.0)
	SmkEmit.Rate          = 7
	SmkEmit.Speed         = NumberRange.new(0.8, 2.2)
	SmkEmit.SpreadAngle   = Vector2.new(12, 12)
	SmkEmit.RotSpeed      = NumberRange.new(-35, 35)
	SmkEmit.Enabled       = false
	SmkEmit.Parent        = Tobaccy


	local Fizzled       = Instance.new("BoolValue")
	Fizzled.Name        = "Fizzled"
	Fizzled.Value       = false
	Fizzled.Parent      = cig

	return cig
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


local function fizzleCigar(oldCig, delaySecs)
	task.delay(delaySecs, function()
		if not oldCig or not oldCig.Parent then return end
		if oldCig.Fizzled.Value then return end
		oldCig.Fizzled.Value = true
		local cherry = oldCig:FindFirstChild("Cherry")
		if cherry then
			tweenCherry(cherry, cherry:FindFirstChild("CherryLight"),
				CHERRY_UNLIT, 0.65, 0, 1.0)
		end
		local pe = oldCig.Tobaccy:FindFirstChildOfClass("ParticleEmitter")
		if pe then pe.Enabled = false end
	end)
end


local function setupTouchStub(oldCig)
	local paper = oldCig:FindFirstChild("Paper")
	if not paper then return end
	local touchConn
	touchConn = paper.Touched:Connect(function(hit)
		if (hit.Name == "Left Leg" or hit.Name == "Right Leg")
			and not oldCig.Fizzled.Value then
			touchConn = NADisconnect(touchConn)
			paper.Anchored = true
			oldCig.Fizzled.Value = true
			local s = paper:FindFirstChild("Sound")
			if s then s:Play() end
			local cherry = oldCig:FindFirstChild("Cherry")
			if cherry then
				tweenCherry(cherry, cherry:FindFirstChild("CherryLight"),
					CHERRY_UNLIT, 0.65, 0, 0.35)
			end
			local pe = oldCig.Tobaccy:FindFirstChildOfClass("ParticleEmitter")
			if pe then pe.Enabled = false end
		end
	end)
end




local Tool          = Instance.new("Tool")
Tool.Name           = "Cigar"
Tool.ToolTip        = "Cigar"
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
	isLit    = false
	size     = 5000


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


	cigarAnchor              = Instance.new("Part")
	cigarAnchor.Name         = "Paper"
	cigarAnchor.Size         = VEC3(0.1, 0.1, 0.1)
	cigarAnchor.Transparency = 1
	cigarAnchor.CanCollide   = false
	cigarAnchor.Parent       = rArm

	local anchorWeld      = Instance.new("Weld")
	anchorWeld.Name       = "anchorWeld"
	anchorWeld.Part0      = cigarAnchor
	anchorWeld.Part1      = rArm
	anchorWeld.C0         = CF(0.1, 1.1, 0.05) * CFAN(RAD(0), RAD(-30), RAD(25))
	anchorWeld.C1         = CF(-0.5, 0, 0.5)   * CFAN(RAD(13), RAD(170), 0)
	anchorWeld.Parent     = cigarAnchor


	local cigClone = buildCigar()

	cigarWeld        = Instance.new("Weld")
	cigarWeld.Name   = "cigarWeld"
	cigarWeld.Part0  = cigClone.Paper
	cigarWeld.Part1  = cigarAnchor
	cigarWeld.C0     = CF(-0.3, -0.05, -0.4) * CFAN(RAD(-27), 0, RAD(34))
	cigarWeld.C1     = CF(0, 0, 0)
	cigarWeld.Parent = cigClone
	cigClone.Parent  = rArm

	currentCigar = cigClone
	currentWeld  = cigarWeld
	hasCigar     = true
	heat         = 0


	TweenJoint(rWeld, RightValue4, CF(0,0,0), Linear, 0.5)
	task.wait(0.55)
	if not isCurrentRun(equipToken) then return end
	ready = true


	activatedConn = NADisconnect(activatedConn)
	activatedConn = Tool.Activated:Connect(function()
		if not isCurrentRun(equipToken) then return end




		if hasCigar and ready and not pulling and not isLit then
			pulling = true

			local cigRef      = currentCigar
			local cherryRef   = cigRef:FindFirstChild("Cherry")
			local cherryLight = cherryRef and cherryRef:FindFirstChild("CherryLight")
			local cherryWeld  = cherryRef and cherryRef:FindFirstChild("CherryWeld")
			local tobaccyWeld = cigRef.Tobaccy:FindFirstChild("TobaccyWeld")


			TweenJoint(lWeld,     LeftValue2,  CF(0,0,0), Linear, 0.5)
			TweenJoint(rWeld,     RightValue2, CF(0,0,0), Linear, 0.5)
			TweenJoint(cigarWeld,
				CF(-0.3,-0.05,-0.4)*CFAN(RAD(-27),0,RAD(34)),
				CF(0,0,0), Linear, 0.5)
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


			tweenCherry(cherryRef, cherryLight, CHERRY_IDLE, 0.05, 0.9, 1.4)

			task.wait(0.9)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end


			cigRef.Tobaccy:FindFirstChildOfClass("ParticleEmitter").Enabled = true
			cigRef.Paper.Crackle:Play()

			task.wait(0.5)
			if lGUI then lGUI.Enabled = false end
			task.wait(0.2)
			if not isCurrentRun(equipToken) then NADestroy(lighterClone); pulling = false; return end


			TweenJoint(lWeld, LeftValue2, CF(0,0,0), Linear, 0.5)
			task.wait(0.5)
			NADestroy(lighterClone)


			lShoulderStorage:Clone().Parent = Torso
			if lWeld then NADestroy(lWeld); lWeld = nil end


			TweenJoint(rWeld, RightValue4, CF(0,0,0), Linear, 0.5)
			TweenJoint(cigarWeld,
				CF(-0.3,-0.26,-0.4)*CFAN(RAD(-27),0,RAD(34)),
				CF(0,0,0)*CFAN(0,0,RAD(20)), Linear, 0.5)

			pulling = false
			isLit   = true
			heat    = 0.5


			local PaperMesh   = cigRef.Paper.Mesh
			local PaperOrigSc = PaperMesh.Scale.y

			task.spawn(function()
				while isCurrentRun(equipToken) and hasCigar and size > minSize do
					task.wait(0.1)
					if not isCurrentRun(equipToken) or not cigRef or not cigRef.Parent then break end
					size = size - heat


					local currentSc = math.max(0.01, PaperOrigSc * (size / 5000))
					PaperMesh.Scale = VEC3(
						PaperMesh.Scale.x,
						currentSc,
						PaperMesh.Scale.z
					)



					PaperMesh.Offset = VEC3(
						PaperMesh.Offset.x,
						(PaperOrigSc - currentSc) * (cigRef.Paper.Size.y / 2),
						PaperMesh.Offset.z
					)


					local burnPct = size / 5000
					if cherryWeld then
						cherryWeld.C0  = CF(0, (2*burnPct - 1) * 0.518, 0)
					end
					if tobaccyWeld then
						tobaccyWeld.C0 = CF(0, (2*burnPct - 1) * 0.506, 0)
					end



					if size <= minSize then
						ready = false; isLit = false

						TweenJoint(rWeld,
							CF(1.3, 0.6, -0.7) * CFAN(RAD(75), RAD(10), RAD(-15)),
							CF(0, 0, 0), Linear, 0.15)

						task.wait(0.15)

						hasCigar = false

						NADestroy(cigarWeld)
						cigRef.Parent = workspace
						cigRef.Paper.CanCollide = true

						local root = Char:FindFirstChild("HumanoidRootPart") or Torso
						local throwDir = (
							root.CFrame.LookVector +
								root.CFrame.RightVector * 0.45 +
								Vector3.new(0, 0.25, 0)
						).Unit
						cigRef.Paper.AssemblyLinearVelocity  = throwDir * 30
						cigRef.Paper.AssemblyAngularVelocity = Vector3.new(
							math.random(-22, 22),
							math.random(-22, 22),
							math.random(-22, 22)
						)

						cigRef.Paper.Crackle:Stop()
						NADestroy(cigarAnchor)

						task.wait(0.22)
						TweenJoint(rWeld, RightValue4, CF(0,0,0), Linear, 0.5)
						fizzleCigar(cigRef, 5)


						task.delay(25, function()
							if cigRef and cigRef.Parent then NADestroy(cigRef) end
						end)
						setupTouchStub(cigRef)


						task.wait(0.6)
						Selected = false
						restoreShoulders()
						activatedConn = NADisconnect(activatedConn)
						deactivatedConn = NADisconnect(deactivatedConn)
						NADestroy(Tool)
						return
					end
				end
			end)




		elseif hasCigar and ready and isLit and not pulling and not drawing then
			drawing = true

			local cigRef      = currentCigar
			local cherryRef   = cigRef:FindFirstChild("Cherry")
			local cherryLight = cherryRef and cherryRef:FindFirstChild("CherryLight")


			TweenJoint(rWeld, RightValue2, CF(0,0,0), Linear, 0.5)
			TweenJoint(cigarWeld,
				CF(-0.3,-0.05,-0.4)*CFAN(RAD(-27),0,RAD(34)),
				CF(0,0,0), Linear, 0.5)
			task.wait(0.5)
			if not isCurrentRun(equipToken) then drawing = false; return end

			if drawing then
				heat = 6
				cigRef.Paper.Crackle.PlaybackSpeed = 2.2
				cigRef.Paper.Crackle.Volume        = 0.38


				tweenCherry(cherryRef, cherryLight, CHERRY_DRAG, 0, 1.3, 0.4)
			end


			deactivatedConn = NADisconnect(deactivatedConn)
			deactivatedConn = Tool.Deactivated:Connect(function()
				deactivatedConn = NADisconnect(deactivatedConn)
				if not (hasCigar and ready and not pulling) then return end


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
				heat    = 0.5


				local cr = currentCigar
				if cr then
					local cCherry = cr:FindFirstChild("Cherry")
					local cLight  = cCherry and cCherry:FindFirstChild("CherryLight")
					tweenCherry(cCherry, cLight, CHERRY_IDLE, 0.05, 0.9, 0.9)
				end


				TweenJoint(rWeld, RightValue4, CF(0,0,0), Linear, 0.5)
				TweenJoint(cigarWeld,
					CF(0,0.5,-0.22)*CFAN(RAD(75),0,RAD(20)),
					CF(0,0,0)*CFAN(0,0,RAD(20)), Linear, 0.5)
				cigRef.Paper.Crackle.PlaybackSpeed = 1.0
				cigRef.Paper.Crackle.Volume        = 0.18
			end)
		end
	end)
end)




Tool.Unequipped:Connect(function()
	activeToken = activeToken + 1
	activatedConn = NADisconnect(activatedConn)
	deactivatedConn = NADisconnect(deactivatedConn)

	if hasCigar then
		hasCigar = false; ready = false; pulling = false; drawing = false; isLit = false
		currentCigar.Paper.Crackle:Stop()
		local oldCig = currentCigar

		TweenJoint(rWeld,
			CF(1.3, 0.6, -0.7) * CFAN(RAD(75), RAD(10), RAD(-35)),
			CF(0, 0, 0), Linear, 0.15)

		task.wait(0.15)

		if currentWeld then NADestroy(currentWeld); currentWeld = nil end
		oldCig.Parent = workspace
		oldCig.Paper.CanCollide = true

		local root = Char:FindFirstChild("HumanoidRootPart") or Torso
		local throwDir = (
			root.CFrame.LookVector +
				root.CFrame.RightVector * 0.45 +
				Vector3.new(0, 0.25, 0)
		).Unit
		oldCig.Paper.AssemblyLinearVelocity  = throwDir * 30
		oldCig.Paper.AssemblyAngularVelocity = Vector3.new(
			math.random(-22, 22),
			math.random(-22, 22),
			math.random(-22, 22)
		)

		Selected = false

		local pa = rArm:FindFirstChild("Paper")
		if pa then NADestroy(pa) end

		fizzleCigar(oldCig, 5)
		setupTouchStub(oldCig)
		activatedConn = NADisconnect(activatedConn)
		deactivatedConn = NADisconnect(deactivatedConn)
		NADestroy(Tool)
		task.delay(10, function()
			if oldCig and oldCig.Parent then NADestroy(oldCig) end
		end)

		task.wait(0.22)
		restoreShoulders()
	else
		Selected = false
		restoreShoulders()
	end
end)
