-- Kirasa, dragon lame-pétale en low poly pour Roblox.
-- Utilisation : dans Roblox Studio, ouvre Affichage > Barre de commande (View > Command Bar),
-- colle tout ce fichier, puis appuie sur Entrée. Le dragon apparaît devant la caméra.
-- Change SCALE pour un dragon plus petit ou plus grand.

local SCALE = 1

local S = SCALE
local COLORS = {
	petal = Color3.fromRGB(236, 231, 251),
	lilac = Color3.fromRGB(185, 175, 226),
	red = Color3.fromRGB(211, 18, 46),
	ink = Color3.fromRGB(24, 18, 36),
	claw = Color3.fromRGB(246, 243, 255),
	eye = Color3.fromRGB(255, 123, 28),
}

local old = workspace:FindFirstChild("Kirasa")
if old then
	old:Destroy()
end

local model = Instance.new("Model")
model.Name = "Kirasa"

-- Placement : au sol, devant la caméra, tourné vers elle
local cam = workspace.CurrentCamera
local spot = cam.CFrame.Position + cam.CFrame.LookVector * 35 * S
local hit = workspace:Raycast(spot + Vector3.new(0, 100, 0), Vector3.new(0, -1000, 0))
local groundY = hit and hit.Position.Y or 0
local base = Vector3.new(spot.X, groundY + 5 * S, spot.Z)
local ROOT = CFrame.lookAt(base, Vector3.new(cam.CFrame.Position.X, base.Y, cam.CFrame.Position.Z))

local function at(x, y, z, rx, ry, rz)
	return ROOT * CFrame.new(x * S, y * S, z * S) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
end

local function part(name, kind, sx, sy, sz, cf, color, attachTo)
	local p = Instance.new(kind)
	p.Name = name
	p.Size = Vector3.new(sx, sy, sz) * S
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.Massless = true
	p.Parent = model
	if attachTo then
		local w = Instance.new("WeldConstraint")
		w.Part0 = attachTo
		w.Part1 = p
		w.Parent = p
	end
	return p
end

local function motor(name, p0, p1, pivot)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = p0.CFrame:ToObjectSpace(pivot)
	m.C1 = p1.CFrame:ToObjectSpace(pivot)
	m.Parent = p0
	return m
end

-- Racine invisible : c'est elle que le script déplace
local root = part("Root", "Part", 2, 2, 2, at(0, 0, 0), COLORS.ink)
root.Transparency = 1
root.Anchored = true
root.Massless = false
model.PrimaryPart = root

---------------------------------------------------------------- corps
local body = part("Body", "Part", 3.2, 3.4, 4.4, at(0, 0, 0), COLORS.petal)
motor("BodyJoint", root, body, at(0, 0, 0))
part("FlankL", "Part", 0.2, 2.6, 3.4, at(-1.62, -0.2, 0.2), COLORS.lilac, body)
part("FlankR", "Part", 0.2, 2.6, 3.4, at(1.62, -0.2, 0.2), COLORS.lilac, body)
for _, sx in { -1, 1 } do
	part("FlankStripe", "Part", 0.06, 0.25, 1.4, at(sx * 1.74, 0.3, -0.4, 0.5, 0, 0), COLORS.ink, body)
	part("FlankStripe", "Part", 0.06, 0.25, 1.4, at(sx * 1.74, -0.6, 0.7, 0.5, 0, 0), COLORS.ink, body)
end
for _, z in { -0.4, 0.8, 2.0 } do
	part("BackSpike", "WedgePart", 0.25, 0.6, 0.8, at(0, 2.0, z), COLORS.red, body)
end

local chest = part("Chest", "Part", 2.6, 2.6, 0.6, at(0, 0.1, -2.3), COLORS.petal, body)
for _, s in { { -0.55, -0.5 }, { 0.6, -0.95 } } do
	part("Skull", "Part", 0.8, 0.7, 0.12, at(s[1], s[2], -2.65), COLORS.red, chest)
	part("SkullEye", "Part", 0.16, 0.2, 0.06, at(s[1] - 0.17, s[2] + 0.06, -2.73), COLORS.ink, chest)
	part("SkullEye", "Part", 0.16, 0.2, 0.06, at(s[1] + 0.17, s[2] + 0.06, -2.73), COLORS.ink, chest)
end

-- collerette de pétales autour du cou
for i = 0, 7 do
	local a = -1.9 + i * (3.8 / 7)
	local ox, oy = math.sin(a), -math.cos(a)
	part("Petal", "Part", 0.95, 1.4, 0.22, at(ox * 1.25, 1.75 + oy * 1.25, -2.75, 0, 0, a), COLORS.petal, body)
	part("PetalSpot", "Part", 0.5, 0.7, 0.26, at(ox * 1.4, 1.75 + oy * 1.4, -2.75, 0, 0, a), COLORS.red, body)
end
for i = 0, 3 do
	local a = -1.0 + i * (2.0 / 3)
	local ox, oy = math.sin(a), -math.cos(a)
	part("Petal", "Part", 0.8, 1.1, 0.22, at(ox * 0.6, 1.75 + oy * 0.6, -2.95, 0, 0, a), COLORS.petal, body)
	part("PetalSpot", "Part", 0.4, 0.55, 0.26, at(ox * 0.7, 1.75 + oy * 0.7, -2.95, 0, 0, a), COLORS.red, body)
end

---------------------------------------------------------------- cou et tête
local HEAD_DROP = -0.7
local function atHead(x, y, z, rx, ry, rz)
	return at(x, y + HEAD_DROP, z, rx, ry, rz)
end

local neck = part("Neck", "Part", 1.5, 1.7, 1.5, at(0, 2.3, -1.9), COLORS.petal)
motor("NeckJoint", body, neck, at(0, 1.6, -1.9))

local head = part("Head", "Part", 2.3, 1.9, 2.2, atHead(0, 4.0, -2.5), COLORS.petal)
motor("HeadJoint", neck, head, atHead(0, 3.5, -2.2))
part("Snout", "Part", 1.4, 1.1, 1.8, atHead(0, 3.6, -4.3), COLORS.petal, head)
part("Blaze", "Part", 0.55, 0.1, 2.0, atHead(0, 4.97, -2.6), COLORS.red, head)
part("Blaze", "Part", 0.5, 0.1, 1.6, atHead(0, 4.17, -4.35), COLORS.red, head)
part("Blaze", "Part", 0.5, 0.8, 0.1, atHead(0, 4.55, -3.62), COLORS.red, head)
part("Nose", "Part", 0.7, 0.45, 0.1, atHead(0, 3.75, -5.22), COLORS.red, head)
part("Nostril", "Part", 0.14, 0.1, 0.05, atHead(-0.2, 3.75, -5.28), COLORS.ink, head)
part("Nostril", "Part", 0.14, 0.1, 0.05, atHead(0.2, 3.75, -5.28), COLORS.ink, head)
part("Crest", "WedgePart", 0.3, 1.4, 1.4, atHead(0, 5.6, -2.2), COLORS.red, head)
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local eye = part("Eye", "Part", 0.5, 0.38, 0.1, atHead(sx * 0.75, 4.45, -3.63), COLORS.eye, head)
	eye.Material = Enum.Material.Neon
	part("Pupil", "Part", 0.12, 0.34, 0.05, atHead(sx * 0.75, 4.45, -3.69), COLORS.ink, head)
	local lid = part("Lid" .. side, "Part", 0.56, 0.44, 0.12, atHead(sx * 0.75, 4.45, -3.72), COLORS.petal, head)
	lid.Transparency = 1
	part("Cheek", "Part", 0.06, 0.45, 0.45, atHead(sx * 1.16, 3.8, -3.1, math.pi / 4, 0, 0), COLORS.ink, head)

	-- collerettes en forme d'ailes de papillon
	local ear = part("Ear" .. side, "Part", 0.3, 0.3, 0.3, atHead(sx * 1.1, 4.7, -2.4), COLORS.petal)
	ear.Transparency = 1
	motor("EarJoint" .. side, head, ear, atHead(sx * 1.1, 4.7, -2.4))
	part("Lobe", "Part", 2.0, 2.6, 0.25, atHead(sx * 2.0, 6.0, -2.4, 0, 0, -sx * 0.6), COLORS.petal, ear)
	part("LobeSpot", "Part", 1.1, 1.5, 0.29, atHead(sx * 2.15, 6.2, -2.4, 0, 0, -sx * 0.6), COLORS.red, ear)
	part("LobeTip", "Part", 0.35, 0.35, 0.3, atHead(sx * 2.75, 7.15, -2.4, 0, 0, math.pi / 4), COLORS.ink, ear)
	part("Lobe", "Part", 1.6, 2.0, 0.25, atHead(sx * 2.5, 4.6, -2.3, 0, 0, -sx * 1.35), COLORS.petal, ear)
	part("LobeSpot", "Part", 0.85, 1.1, 0.29, atHead(sx * 2.6, 4.62, -2.3, 0, 0, -sx * 1.35), COLORS.red, ear)
end

---------------------------------------------------------------- ailes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local sh = Vector3.new(sx * 1.6, 1.0, -0.8)
	local function w(dx, dy, dz)
		return sh.X + sx * dx, sh.Y + dy, sh.Z + dz
	end

	local arm = part("UpperWing" .. side, "Part", 3.0, 0.6, 0.6, at(w(1.5, 0, 0)), COLORS.red)
	motor("Shoulder" .. side, body, arm, at(w(0, 0, 0)))
	part("ArmBand", "Part", 0.2, 0.64, 0.64, at(w(1.0, 0, 0)), COLORS.ink, arm)
	part("ArmBand", "Part", 0.2, 0.64, 0.64, at(w(2.0, 0, 0)), COLORS.ink, arm)
	part("Membrane", "Part", 3.2, 2.6, 0.12, at(w(1.7, -1.45, 0.05)), COLORS.lilac, arm)

	local fore = part("Forewing" .. side, "Part", 3.6, 0.45, 0.45, at(w(4.8, 0, 0)), COLORS.red)
	motor("Elbow" .. side, arm, fore, at(w(3.0, 0, 0)))
	part("ArmBand", "Part", 0.2, 0.49, 0.49, at(w(4.2, 0, 0)), COLORS.ink, fore)
	part("Membrane", "Part", 2.8, 2.0, 0.12, at(w(4.4, -1.2, 0.05)), COLORS.lilac, fore)
	part("WristClaw", "Part", 0.25, 0.9, 0.25, at(w(6.6, 0.5, 0)), COLORS.claw, fore)

	-- longues plumes en lames, qui pendent vers l'extérieur (le script les met à plat en vol)
	for i = 0, 3 do
		local a = math.rad(15 + i * 18)
		local L, W = 8.6 - i * 1.3, 1.3
		local o = Vector3.new(w(6.4 - i * 1.1, -0.15, 0.06 * i))
		local d = Vector3.new(sx * math.cos(a), -math.sin(a), 0)
		local vX = Vector3.new(0, 0, sx)
		local vZ = -d
		local vY = vZ:Cross(vX)
		local function blade(name, kind, sxz, sy, sz, center, color)
			local cf = ROOT * CFrame.fromMatrix(center * S, vX, vY, vZ)
			return part(name, kind, sxz, sy, sz, cf, color, fore)
		end
		blade("Blade", "WedgePart", 0.2, W, L, o + d * (L / 2) + vY * (W / 2), COLORS.petal)
		blade("BladeEdge", "WedgePart", 0.24, 0.3, L * 0.9, o + d * (L * 0.55) + vY * 0.15, COLORS.ink)
		blade("BladeBase", "Part", 0.26, W * 0.8, 1.6, o + d * 0.9 + vY * (W * 0.4), COLORS.red)
	end
end

---------------------------------------------------------------- pattes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local x = sx * 1.15
	local thigh = part("Thigh" .. side, "Part", 1.2, 2.1, 1.4, at(x, -2.25, 0.5), COLORS.red)
	motor("Hip" .. side, body, thigh, at(x, -1.3, 0.5))
	part("ThighStripe", "Part", 1.25, 0.25, 1.45, at(x, -2.6, 0.5), COLORS.ink, thigh)

	local shin = part("Shin" .. side, "Part", 0.7, 1.4, 0.7, at(x, -3.95, 0.6), COLORS.ink)
	motor("Knee" .. side, thigh, shin, at(x, -3.3, 0.55))
	part("Foot", "Part", 1.3, 0.4, 1.7, at(x, -4.8, 0.25), COLORS.ink, shin)
	for _, dx in { -0.45, 0, 0.45 } do
		part("Claw", "WedgePart", 0.25, 0.35, 0.6, at(x + dx, -4.83, -0.85), COLORS.claw, shin)
	end
end

---------------------------------------------------------------- queue
local seg1 = part("Tail1", "Part", 1.3, 1.1, 2.6, at(0, -0.7, 3.4), COLORS.lilac)
motor("Tail1", body, seg1, at(0, -0.5, 2.1))
part("TailBand", "Part", 1.35, 1.15, 0.25, at(0, -0.7, 3.0), COLORS.ink, seg1)

local seg2 = part("Tail2", "Part", 1.0, 0.85, 2.6, at(0, -0.95, 5.8), COLORS.lilac)
motor("Tail2", seg1, seg2, at(0, -0.9, 4.6))
part("TailBand", "Part", 1.05, 0.9, 0.25, at(0, -0.95, 5.6), COLORS.red, seg2)

local seg3 = part("Tail3", "Part", 0.7, 0.6, 2.4, at(0, -1.1, 8.1), COLORS.lilac)
motor("Tail3", seg2, seg3, at(0, -1.05, 7.0))
part("TailBlade", "WedgePart", 0.2, 1.6, 2.4, at(0, -0.6, 10.2, 0, math.pi, 0), COLORS.petal, seg3)
part("TailBladeSpot", "WedgePart", 0.24, 0.8, 1.2, at(0, -1.0, 9.9, 0, math.pi, 0), COLORS.red, seg3)

---------------------------------------------------------------- finitions
local outline = Instance.new("Highlight")
outline.FillTransparency = 1
outline.OutlineColor = COLORS.ink
outline.OutlineTransparency = 0
outline.DepthMode = Enum.HighlightDepthMode.Occluded
outline.Parent = model

model:SetAttribute("Scale", S)
model:SetAttribute("AutoWander", true)
model:SetAttribute("Mode", "Idle")
model:SetAttribute("WalkSpeed", 8 * S)
model:SetAttribute("FlySpeed", 18 * S)
model:SetAttribute("WanderRadius", 40 * S)
model:SetAttribute("FlyHeight", 8)

local animate = Instance.new("Script")
animate.Name = "KirasaAnimate"
animate.Source = [==[
-- Kirasa : animations (repos, marche, vol) et promenade automatique.
-- Attributs du modèle :
--   AutoWander (bool)  : le dragon se promène tout seul autour de son point de départ
--   Mode (string)      : "Idle", "Walk" ou "Fly", utilisé quand AutoWander est désactivé
--   WalkSpeed, FlySpeed, WanderRadius, FlyHeight : réglages de la promenade

local RunService = game:GetService("RunService")

local model = script.Parent
local root = model:WaitForChild("Root")
local S = model:GetAttribute("Scale") or 1
local LEG = 5 * S -- hauteur du centre du corps au-dessus du sol

local joints = {}
for _, d in model:GetDescendants() do
	if d:IsA("Motor6D") then
		joints[d.Name] = { motor = d, base = d.C0 }
	end
end

local lids = {}
for _, d in model:GetDescendants() do
	if d.Name == "LidL" or d.Name == "LidR" then
		table.insert(lids, d)
	end
end

local function setJoint(name, cf)
	local j = joints[name]
	if j then
		j.motor.C0 = j.base * cf
	end
end

-- Pose cible de chaque animation, en fonction du temps
local function targets(mode, t)
	local cycle = t % 4.3
	local flick = cycle < 0.3 and math.sin(cycle / 0.3 * math.pi) * 0.35 or 0

	if mode == "Walk" then
		local ph = t * 6
		local s, c = math.sin(ph), math.cos(ph)
		return {
			bob = (math.abs(s) - 0.5) * 0.3 * S, pitch = -0.06, roll = s * 0.06, flyH = 0,
			neck = -0.08 + math.sin(ph * 2) * 0.04, head = 0.08, headYaw = 0, flick = flick * 0.5,
			wingRaise = 0.1 + math.sin(ph * 2) * 0.04, wingFold = 1.1, elbow = 0.5, elbowFlap = 0, wingTwist = -0.3,
			hipL = s * 0.55, hipR = -s * 0.55,
			kneeL = -math.max(0, c) * 0.9, kneeR = -math.max(0, -c) * 0.9,
			tail = math.sin(ph - 0.6) * 0.22, tail2 = math.sin(ph - 1.2) * 0.3, tail3 = math.sin(ph - 1.8) * 0.4,
			tailLift = 0,
		}
	elseif mode == "Fly" then
		local ph = t * 4.5
		local f = math.sin(ph)
		return {
			bob = -f * 0.1 * S, pitch = -0.12, roll = math.sin(t * 0.7) * 0.05,
			flyH = (model:GetAttribute("FlyHeight") or 8) * S + math.sin(ph - 1.2) * 0.6 * S,
			neck = 0.12, head = 0.05, headYaw = 0, flick = 0.15 + f * 0.1,
			wingRaise = 0.15 + f * 0.8, wingFold = 0.1, elbow = 0.1, elbowFlap = math.sin(ph - 0.9) * 0.35, wingTwist = -1.4,
			hipL = -0.9, hipR = -0.9, kneeL = 0.7, kneeR = 0.7,
			tail = math.sin(ph * 0.5) * 0.12, tail2 = math.sin(ph * 0.5 - 0.6) * 0.18, tail3 = math.sin(ph * 0.5 - 1.2) * 0.25,
			tailLift = 0.1 + f * 0.05,
		}
	end

	local br = math.sin(t * 1.8)
	return {
		bob = br * 0.08 * S, pitch = 0, roll = 0, flyH = 0,
		neck = math.sin(t * 0.6) * 0.08, head = br * 0.03, headYaw = math.sin(t * 0.45) * 0.25, flick = flick,
		wingRaise = 0.25 + math.sin(t * 1.1) * 0.06, wingFold = 0.2, elbow = 0.25, elbowFlap = 0, wingTwist = 0,
		hipL = 0, hipR = 0, kneeL = 0, kneeR = 0,
		tail = math.sin(t * 0.9) * 0.15, tail2 = math.sin(t * 0.9 - 0.7) * 0.22, tail3 = math.sin(t * 0.9 - 1.4) * 0.3,
		tailLift = 0,
	}
end

local function applyPose(p, t)
	setJoint("BodyJoint", CFrame.new(0, p.bob, 0) * CFrame.Angles(p.pitch, 0, p.roll))
	setJoint("NeckJoint", CFrame.Angles(p.neck, 0, 0))
	setJoint("HeadJoint", CFrame.Angles(p.head, p.headYaw, 0))
	setJoint("EarJointL", CFrame.Angles(0, 0, p.flick))
	setJoint("EarJointR", CFrame.Angles(0, 0, -p.flick * 0.7))
	for side, sgn in { L = -1, R = 1 } do
		setJoint("Shoulder" .. side, CFrame.Angles(0, 0, sgn * p.wingRaise) * CFrame.Angles(0, -sgn * p.wingFold, 0) * CFrame.Angles(p.wingTwist, 0, 0))
		setJoint("Elbow" .. side, CFrame.Angles(0, 0, sgn * p.elbowFlap) * CFrame.Angles(0, -sgn * p.elbow, 0))
	end
	setJoint("HipL", CFrame.Angles(p.hipL, 0, 0))
	setJoint("HipR", CFrame.Angles(p.hipR, 0, 0))
	setJoint("KneeL", CFrame.Angles(p.kneeL, 0, 0))
	setJoint("KneeR", CFrame.Angles(p.kneeR, 0, 0))
	setJoint("Tail1", CFrame.Angles(p.tailLift, p.tail, 0))
	setJoint("Tail2", CFrame.Angles(p.tailLift, p.tail2, 0))
	setJoint("Tail3", CFrame.Angles(p.tailLift, p.tail3, 0))

	local blinking = (t % 3.7) < 0.14
	for _, lid in lids do
		lid.Transparency = blinking and 0 or 1
	end
end

-- Déplacement
local home = root.Position
local pos = root.Position
local look = root.CFrame.LookVector
local yaw = math.atan2(-look.X, -look.Z)
local height = pos.Y

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { model }

local function groundAt(p)
	local hit = workspace:Raycast(Vector3.new(p.X, p.Y + 50, p.Z), Vector3.new(0, -500, 0), rayParams)
	return hit and hit.Position.Y or (home.Y - LEG)
end

local function pickTarget(radius)
	local a = math.random() * math.pi * 2
	local r = radius * (0.3 + 0.7 * math.random())
	return home + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
end

local state = { mode = "Idle", timer = 3, target = nil }
local t = 0
local pose = targets("Idle", 0)

RunService.Heartbeat:Connect(function(dt)
	t += dt
	local mode

	if model:GetAttribute("AutoWander") then
		state.timer -= dt
		if state.mode == "Idle" then
			if state.timer <= 0 then
				local fly = math.random() < 0.3
				state.mode = fly and "Fly" or "Walk"
				state.target = pickTarget(model:GetAttribute("WanderRadius") or 40)
			end
		else
			local flat = Vector3.new(state.target.X - pos.X, 0, state.target.Z - pos.Z)
			if flat.Magnitude < 1.5 then
				state.mode = "Idle"
				state.timer = 3 + math.random() * 4
				state.target = nil
			else
				-- tourner vers la cible
				local want = math.atan2(-flat.X, -flat.Z)
				local diff = (want - yaw + math.pi) % (math.pi * 2) - math.pi
				local turn = 2.5 * dt
				yaw += math.clamp(diff, -turn, turn)

				-- avancer quand il regarde à peu près dans la bonne direction
				local forward = Vector3.new(-math.sin(yaw), 0, -math.cos(yaw))
				local facing = math.max(0, forward:Dot(flat.Unit))
				local speed
				if state.mode == "Fly" then
					local takeoff = math.clamp(pose.flyH / ((model:GetAttribute("FlyHeight") or 8) * S), 0, 1)
					speed = (model:GetAttribute("FlySpeed") or 18) * takeoff
				else
					speed = model:GetAttribute("WalkSpeed") or 8
				end
				pos += forward * math.min(speed * facing * dt, flat.Magnitude)
			end
		end
		mode = state.mode
	else
		mode = model:GetAttribute("Mode") or "Idle"
	end

	-- transition douce vers la pose cible
	local target = targets(mode, t)
	local k = 1 - 0.0015 ^ dt
	for key, value in target do
		pose[key] += (value - pose[key]) * k
	end
	applyPose(pose, t)

	local wantY = groundAt(pos) + LEG + pose.flyH
	height += (wantY - height) * math.min(1, dt * 8)
	root.CFrame = CFrame.new(pos.X, height, pos.Z) * CFrame.Angles(0, yaw, 0)
end)
]==]
animate.Parent = model

model.Parent = workspace
game:GetService("Selection"):Set({ model })
print("Kirasa est prête ! Lance le jeu (Play) pour voir ses animations.")
