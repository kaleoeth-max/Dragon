-- Kirasa, version maillage 3D (sans jointures entre les triangles).
-- 1. Dans Roblox Studio : onglet Avatar ou Accueil > Importer 3D (Import 3D), choisis Kirasa.obj.
--    Dans les réglages d'import, laisse « Fusionner les maillages » (Merge Meshes) décoché.
-- 2. Ouvre Affichage > Barre de commande, colle tout ce fichier, puis appuie sur Entrée.
-- Le script retrouve les morceaux importés, leur donne leurs couleurs, construit le squelette
-- et ajoute les animations. Change COLORS pour changer ses couleurs.

local COLORS = {
	back = Color3.fromRGB(150, 138, 208), -- dos
	belly = Color3.fromRGB(238, 234, 252), -- ventre, gorge, dessous des ailes
	petal = Color3.fromRGB(236, 231, 251),
	lilac = Color3.fromRGB(185, 175, 226),
	red = Color3.fromRGB(211, 18, 46),
	redDeep = Color3.fromRGB(110, 6, 28),
	ink = Color3.fromRGB(24, 18, 36),
	claw = Color3.fromRGB(246, 243, 255),
	eye = Color3.fromRGB(255, 123, 28),
	redDark = Color3.fromRGB(90, 8, 24),
}

-- Position de chaque morceau et de chaque articulation dans le fichier, écrite par make.py
local DATA = {
	centers = {
		["Body_back"] = { -0.0000, 2.5561, 1.0745, 5.9128, 7.1981, 9.9286 },
		["Body_belly"] = { -0.0000, 1.5253, 0.4179, 5.9128, 7.6896, 10.5664 },
		["Body_red"] = { -0.0000, 2.6735, 0.2632, 5.9128, 5.3660, 9.9263 },
		["Body_ink"] = { -0.1100, 4.0112, 2.1283, 0.6600, 3.5773, 6.1961 },
		["Body_petal"] = { 0.0941, 2.3521, -4.6050, 5.6692, 2.9867, 0.2100 },
		["Neck_back"] = { 0.0000, 8.7476, -2.7419, 4.0000, 7.8952, 3.3162 },
		["Neck_belly"] = { 0.0000, 8.2830, -3.9862, 4.0000, 7.4340, 2.3725 },
		["Neck_red"] = { 0.0000, 8.1955, -1.6942, 1.6000, 2.2572, 0.1298 },
		["Neck_petal"] = { -0.0850, 9.2576, -1.1850, 0.5100, 5.2336, 2.3635 },
		["Neck_ink"] = { 0.0850, 9.2576, -1.1850, 0.1700, 5.2336, 2.3635 },
		["Head_back"] = { 0.0000, 12.8429, -6.6051, 3.2000, 2.1373, 6.3632 },
		["Head_belly"] = { 0.0000, 12.0290, -6.6933, 3.2000, 1.3420, 6.1867 },
		["Head_red"] = { 0.0000, 13.3033, -6.4052, 3.1341, 3.0579, 6.7629 },
		["Jaw_belly"] = { 0.0000, 11.3348, -6.7596, 2.4000, 1.3582, 4.4734 },
		["Jaw_redDark"] = { 0.0000, 11.4738, -6.8367, 1.2000, 1.0801, 4.3193 },
		["Head_claw"] = { -0.0300, 11.3573, -7.4500, 1.8200, 0.7147, 3.1058 },
		["Head_ink"] = { 0.0000, 12.9852, -5.5800, 2.7579, 1.8103, 7.5600 },
		["Head_petal"] = { 0.0000, 15.2587, -1.6923, 3.7635, 1.8914, 3.4020 },
		["EarL_back"] = { -1.4398, 13.3470, -3.6586, 2.0784, 1.2892, 0.9615 },
		["EarL_ink"] = { -3.0296, 14.2259, -3.5000, 3.7556, 5.1931, 0.5200 },
		["EarL_petal"] = { -3.0239, 14.2249, -3.6250, 3.2519, 4.6352, 0.4500 },
		["EarL_red"] = { -3.2640, 14.1946, -3.6575, 1.7710, 3.1785, 0.2750 },
		["EarR_back"] = { 1.4398, 13.3470, -3.6586, 2.0784, 1.2892, 0.9615 },
		["EarR_ink"] = { 3.0296, 14.2259, -3.5000, 3.7556, 5.1931, 0.5200 },
		["EarR_petal"] = { 3.0239, 14.2249, -3.6250, 3.2519, 4.6352, 0.4500 },
		["EarR_red"] = { 3.2283, 14.1104, -3.6575, 1.9167, 3.0935, 0.2750 },
		["UpperWingL_ink"] = { -5.7924, 4.5190, -2.0000, 7.4885, 1.0379, 2.4000 },
		["UpperWingL_red"] = { -5.7924, 3.2190, -2.0000, 7.4885, 3.6379, 1.2000 },
		["UpperWingL_belly"] = { -5.8000, 3.5810, -2.0000, 7.4000, 1.2379, 2.4000 },
		["UpperWingL_lilac"] = { -6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingL_claw"] = { -9.3658, 2.6203, -2.2823, 0.4240, 1.6406, 0.6354 },
		["ForewingL_ink"] = { -25.2494, -2.8769, -1.8600, 33.7648, 15.3237, 1.8000 },
		["ForewingL_red"] = { -14.5180, 3.3603, -1.6500, 12.5804, 7.6389, 1.4600 },
		["ForewingL_belly"] = { -13.8986, 3.8390, -2.0000, 9.1972, 0.9220, 1.5200 },
		["ForewingL_petal"] = { -25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingL_lilac"] = { -22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingL_claw"] = { -16.9942, 3.0494, -2.5353, 1.4115, 1.6988, 1.1294 },
		["UpperWingR_ink"] = { 5.7924, 4.5190, -2.0000, 7.4885, 1.0379, 2.4000 },
		["UpperWingR_red"] = { 5.7924, 3.2190, -2.0000, 7.4885, 3.6379, 1.2000 },
		["UpperWingR_belly"] = { 5.8000, 3.5810, -2.0000, 7.4000, 1.2379, 2.4000 },
		["UpperWingR_lilac"] = { 6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingR_claw"] = { 9.2611, 2.6376, -2.2823, 0.4778, 1.6753, 0.6354 },
		["ForewingR_ink"] = { 25.2494, -2.8769, -1.8600, 33.7648, 15.3237, 1.8000 },
		["ForewingR_red"] = { 14.5180, 3.3603, -1.6500, 12.5804, 7.6389, 1.4600 },
		["ForewingR_belly"] = { 13.8986, 3.8390, -2.0000, 9.1972, 0.9220, 1.5200 },
		["ForewingR_petal"] = { 25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingR_lilac"] = { 22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingR_claw"] = { 17.0239, 3.0494, -2.5501, 1.3522, 1.6988, 1.0997 },
		["ThighL_back"] = { -2.6045, -2.0151, 1.9697, 3.9748, 6.3572, 4.0272 },
		["ThighL_belly"] = { -2.4954, -1.6425, 0.2233, 2.2004, 5.6121, 1.1867 },
		["ThighL_red"] = { -2.7000, -3.3814, 1.4369, 3.7838, 3.6246, 3.6139 },
		["ShinL_back"] = { -2.8000, -5.7904, 1.1509, 2.0800, 3.0599, 2.7923 },
		["ShinL_red"] = { -2.8000, -8.1093, 1.7232, 1.6000, 2.0595, 1.6477 },
		["ShinL_redDeep"] = { -2.7619, -9.3400, 0.4236, 1.8762, 0.9562, 3.0473 },
		["ShinL_claw"] = { -2.7971, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["ThighR_back"] = { 2.6045, -2.0151, 1.9697, 3.9748, 6.3572, 4.0272 },
		["ThighR_belly"] = { 2.4954, -1.6425, 0.2233, 2.2004, 5.6121, 1.1867 },
		["ThighR_red"] = { 2.7000, -3.3814, 1.4369, 3.7838, 3.6246, 3.6139 },
		["ShinR_back"] = { 2.8000, -5.7904, 1.1509, 2.0800, 3.0599, 2.7923 },
		["ShinR_red"] = { 2.8000, -8.1093, 1.7232, 1.6000, 2.0595, 1.6477 },
		["ShinR_redDeep"] = { 2.8381, -9.3400, 0.4236, 1.8762, 0.9562, 3.0473 },
		["ShinR_claw"] = { 2.8029, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["TailBone1_back"] = { 0.0000, -0.2800, 7.2455, 3.8000, 2.6400, 5.2910 },
		["TailBone1_belly"] = { 0.0000, -1.6063, 6.9272, 3.8000, 2.4126, 5.3456 },
		["TailBone1_red"] = { -0.0800, 1.0834, 7.6969, 0.4800, 1.3762, 0.9413 },
		["TailBone1_ink"] = { 0.0800, 1.0834, 7.6969, 0.1600, 1.3762, 0.9413 },
		["TailBone2_back"] = { 0.0000, -1.5937, 11.6128, 3.2000, 2.4126, 5.2256 },
		["TailBone2_red"] = { -0.0000, -1.1238, 11.7583, 1.6000, 1.4728, 4.9345 },
		["TailBone2_belly"] = { 0.0000, -2.6699, 11.3545, 3.2000, 2.1398, 5.2910 },
		["TailBone2_ink"] = { -0.0800, -0.4927, 12.0320, 0.4800, 1.2307, 0.9326 },
		["TailBone3_back"] = { 0.0000, -2.7228, 15.9566, 2.4800, 1.7543, 5.1133 },
		["TailBone3_belly"] = { 0.0000, -3.5540, 15.8237, 2.4800, 1.5081, 5.1527 },
		["TailBone3_red"] = { -0.0800, -1.8641, 16.2933, 0.4800, 1.0878, 0.9205 },
		["TailBone3_ink"] = { 0.0800, -1.8641, 16.2933, 0.1600, 1.0878, 0.9205 },
		["TailBone4_back"] = { 0.0000, -3.5440, 20.3297, 1.8400, 1.3120, 5.0594 },
		["TailBone4_red"] = { -0.0000, -3.2964, 20.3724, 0.9200, 0.8167, 4.9740 },
		["TailBone4_belly"] = { 0.0000, -4.1476, 20.2573, 1.8400, 1.0953, 5.0854 },
		["TailBone4_ink"] = { -0.0800, -2.9169, 20.6317, 0.4800, 0.9477, 0.9038 },
		["TailBone5_back"] = { 0.0000, -4.1514, 24.7112, 1.2800, 0.8972, 5.0224 },
		["TailBone5_belly"] = { 0.0000, -4.5398, 24.6801, 1.2800, 0.6797, 5.0398 },
		["TailBone5_red"] = { -0.0800, -4.3257, 27.1778, 0.4800, 1.9486, 5.2445 },
		["TailBone5_ink"] = { 0.0800, -3.7566, 24.9957, 0.1600, 0.8104, 0.8804 },
		["TailBone5_petal"] = { 0.0000, -4.4000, 30.2000, 0.0000, 3.2000, 6.0000 },
		["Head_eye"] = { 0.0000, 13.1200, -6.0000, 2.7240, 0.4422, 0.9000 },
		["Head_lidL"] = { -1.2200, 13.1200, -6.0000, 0.4422, 0.5308, 1.0000 },
		["Head_lidR"] = { 1.2200, 13.1200, -6.0000, 0.4422, 0.5308, 1.0000 },
	},
	motors = {
		{ "BodyJoint", "Root", "Body", 0.0000, 0.0000, 0.0000 },
		{ "NeckJoint", "Body", "Neck", 0.0000, 5.2000, -3.0000 },
		{ "HeadJoint", "Neck", "Head", 0.0000, 12.0000, -4.4000 },
		{ "JawJoint", "Head", "Jaw", 0.0000, 11.7000, -4.6000 },
		{ "EarJointL", "Head", "EarL", -1.4000, 13.0000, -3.8000 },
		{ "EarJointR", "Head", "EarR", 1.4000, 13.0000, -3.8000 },
		{ "ShoulderL", "Body", "UpperWingL", -2.7000, 4.0000, -2.0000 },
		{ "ElbowL", "UpperWingL", "ForewingL", -9.5000, 4.0000, -2.0000 },
		{ "ShoulderR", "Body", "UpperWingR", 2.7000, 4.0000, -2.0000 },
		{ "ElbowR", "UpperWingR", "ForewingR", 9.5000, 4.0000, -2.0000 },
		{ "HipL", "Body", "ThighL", -2.3000, -0.6000, 2.2000 },
		{ "KneeL", "ThighL", "ShinL", -2.8000, -4.8000, 0.6000 },
		{ "HipR", "Body", "ThighR", 2.3000, -0.6000, 2.2000 },
		{ "KneeR", "ThighR", "ShinR", 2.8000, -4.8000, 0.6000 },
		{ "Tail1", "Body", "TailBone1", 0.0000, -0.4000, 5.2000 },
		{ "Tail2", "TailBone1", "TailBone2", 0.0000, -1.6000, 9.6000 },
		{ "Tail3", "TailBone2", "TailBone3", 0.0000, -2.8000, 14.0000 },
		{ "Tail4", "TailBone3", "TailBone4", 0.0000, -3.6000, 18.4000 },
		{ "Tail5", "TailBone4", "TailBone5", 0.0000, -4.2000, 22.8000 },
	},
}

---------------------------------------------------------------- retrouver les morceaux importés
local function findParts(container)
	local found = {}
	for _, d in container:GetDescendants() do
		if d:IsA("MeshPart") and DATA.centers[d.Name] then
			found[d.Name] = found[d.Name] or d
		end
	end
	return found
end

local parts = {}
for _, sel in game:GetService("Selection"):Get() do
	for name, p in findParts(sel) do
		parts[name] = p
	end
end
if not parts.Body_back then
	parts = findParts(workspace)
end
for _, needed in { "Body_back", "Head_back", "TailBone5_back", "ThighL_back" } do
	if not parts[needed] then
		error("Kirasa : je ne trouve pas le morceau « " .. needed .. " ». Importe d'abord Kirasa.obj avec Importer 3D, sans fusionner les maillages.")
	end
end

---------------------------------------------------------------- correspondance fichier -> monde
-- On compare trois morceaux repères pour retrouver où l'import a placé, tourné et agrandi le dragon.
local function center(name)
	local c = DATA.centers[name]
	return Vector3.new(c[1], c[2], c[3])
end
local function frame(u, v)
	local x = u.Unit
	local z = x:Cross(v).Unit
	return CFrame.fromMatrix(Vector3.zero, x, z:Cross(x), z)
end
local bodyE, bodyA = center("Body_back"), parts.Body_back.Position
local uE, vE = center("Head_back") - bodyE, center("TailBone5_back") - bodyE
local uA, vA = parts.Head_back.Position - bodyA, parts.TailBone5_back.Position - bodyA
local k = uA.Magnitude / uE.Magnitude
local R = frame(uA, vA) * frame(uE, vE):Inverse()
local function toWorld(p)
	return bodyA + R * ((p - bodyE) * k)
end
local sideE = center("ThighL_back") - bodyE
local sideA = parts.ThighL_back.Position - bodyA
if (R * sideE):Dot(sideA) < 0 then
	warn("Kirasa : l'import semble avoir inversé la gauche et la droite. Les animations des ailes et des pattes seront échangées.")
end

---------------------------------------------------------------- modèle et squelette
local containers = {}
for _, p in parts do
	local c = p.Parent
	while c and c ~= workspace do
		containers[c] = true
		c = c.Parent
	end
end
local old = workspace:FindFirstChild("Kirasa")
if old and not containers[old] then
	old:Destroy()
end

local model = Instance.new("Model")
model.Name = "Kirasa"

local function invisible(name, cf)
	local b = Instance.new("Part")
	b.Name = name
	b.Size = Vector3.new(0.4, 0.4, 0.4) * k
	b.CFrame = cf
	b.Transparency = 1
	b.CanCollide = false
	b.CanTouch = false
	b.Massless = true
	b.Parent = model
	return b
end

local rot = R.Rotation
local root = invisible("Root", CFrame.new(toWorld(Vector3.zero)) * rot)
root.Size = Vector3.new(2, 2, 2) * k
root.Anchored = true
root.Massless = false
model.PrimaryPart = root

local bones = { Root = root }
for _, m in DATA.motors do
	local name, p0, p1 = m[1], m[2], m[3]
	local pivot = CFrame.new(toWorld(Vector3.new(m[4], m[5], m[6]))) * rot
	if not bones[p1] then
		bones[p1] = invisible(p1, pivot)
	end
	local j = Instance.new("Motor6D")
	j.Name = name
	j.Part0 = bones[p0]
	j.Part1 = bones[p1]
	j.C0 = bones[p0].CFrame:ToObjectSpace(pivot)
	j.C1 = bones[p1].CFrame:ToObjectSpace(pivot)
	j.Parent = bones[p0]
end

for name, p in parts do
	local boneName, key = name:match("^(.-)_(%w+)$")
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.Massless = true
	p.Material = Enum.Material.SmoothPlastic
	p.TextureID = ""
	if key == "lidL" or key == "lidR" then
		p.Name = key == "lidL" and "LidL" or "LidR"
		p.Color = COLORS.back
		p.Transparency = 1
	elseif key == "eye" then
		p.Color = COLORS.eye
		p.Material = Enum.Material.Neon
	else
		p.Color = COLORS[key] or COLORS.back
	end
	p.Parent = model
	local w = Instance.new("WeldConstraint")
	w.Part0 = bones[boneName]
	w.Part1 = p
	w.Parent = p
end

for c in containers do
	if c.Parent and #c:GetDescendants() == 0 then
		c:Destroy()
	end
end

---------------------------------------------------------------- comportement et animations
local S = 2 * k
model:SetAttribute("Scale", S)
model:SetAttribute("AutoWander", true)
model:SetAttribute("Mode", "Idle")
model:SetAttribute("WalkSpeed", 8 * S)
model:SetAttribute("FlySpeed", 18 * S)
model:SetAttribute("WanderRadius", 40 * S)
model:SetAttribute("FlyHeight", 8)
model:SetAttribute("PlayAction", "")
model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

local brain = Instance.new("Script")
brain.Name = "KirasaBrain"
brain.Source = [==[
-- Kirasa : cerveau (déplacements, décollage, atterrissage, choix des actions), côté serveur.
-- Attributs du modèle que tu peux changer :
--   AutoWander (bool)   : elle se promène toute seule autour de son point de départ
--   Mode (string)       : "Idle", "Walk" ou "Fly", utilisé quand AutoWander est décoché
--   PlayAction (string) : écris "Roar", "Stretch", "Look" ou "Shake" pour lancer une action
--   WalkSpeed, FlySpeed, WanderRadius, FlyHeight : réglages de la promenade
-- Attributs écrits par ce script pour l'animation : State, Goal, Action, ActionId

local RunService = game:GetService("RunService")

local model = script.Parent
local root = model:WaitForChild("Root")
local S = model:GetAttribute("Scale") or 1
local LEG = 5 * S -- hauteur du centre du corps au-dessus du sol
local TAKEOFF_TIME = 0.7
local ACTIONS = { "Roar", "Stretch", "Look", "Look", "Shake" }

local home = root.Position
local pos = root.Position
local look = root.CFrame.LookVector
local yaw = math.atan2(-look.X, -look.Z)
local ground = pos.Y - LEG
local alt = 0

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { model }

local function groundAt(p)
	local hit = workspace:Raycast(Vector3.new(p.X, p.Y + 50 * S, p.Z), Vector3.new(0, -500 * S, 0), rayParams)
	return hit and hit.Position.Y or (home.Y - LEG)
end

local function pickTarget(radius)
	local a = math.random() * math.pi * 2
	local r = radius * (0.3 + 0.7 * math.random())
	return home + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
end

local state, stateTime = "Idle", 0
local target = nil
local idleTimer, actionTimer = 3, 5
local actionId = 0

local function setState(s)
	if s ~= state then
		state, stateTime = s, 0
	end
end

local function playAction(name)
	actionId += 1
	model:SetAttribute("Action", name)
	model:SetAttribute("ActionId", actionId)
	actionTimer = 7 + math.random() * 6
end

model:GetAttributeChangedSignal("PlayAction"):Connect(function()
	local name = model:GetAttribute("PlayAction")
	if name and name ~= "" then
		playAction(name)
		model:SetAttribute("PlayAction", "")
	end
end)

-- Avance vers la cible en tournant d'abord la tête dans sa direction
local function moveTowards(dt, speed)
	local flat = Vector3.new(target.X - pos.X, 0, target.Z - pos.Z)
	if flat.Magnitude < 1.5 * S then
		return true
	end
	local want = math.atan2(-flat.X, -flat.Z)
	local diff = (want - yaw + math.pi) % (math.pi * 2) - math.pi
	local turn = 2.2 * dt
	yaw += math.clamp(diff, -turn, turn)
	local forward = Vector3.new(-math.sin(yaw), 0, -math.cos(yaw))
	local facing = math.max(0, forward:Dot(flat.Unit))
	pos += forward * math.min(speed * facing * dt, flat.Magnitude)
	return false
end

RunService.Heartbeat:Connect(function(dt)
	stateTime += dt
	local flyHeight = (model:GetAttribute("FlyHeight") or 8) * S
	local walkSpeed = model:GetAttribute("WalkSpeed") or 8 * S
	local flySpeed = model:GetAttribute("FlySpeed") or 18 * S

	if model:GetAttribute("AutoWander") then
		if state == "Idle" then
			idleTimer -= dt
			actionTimer -= dt
			if actionTimer <= 0 then
				playAction(ACTIONS[math.random(#ACTIONS)])
			end
			if idleTimer <= 0 then
				target = pickTarget(model:GetAttribute("WanderRadius") or 40 * S)
				setState(math.random() < 0.3 and "TakeOff" or "Walk")
			end
		elseif state == "Walk" then
			if moveTowards(dt, walkSpeed) then
				setState("Idle")
				idleTimer = 4 + math.random() * 5
			end
		elseif state == "TakeOff" then
			if stateTime > TAKEOFF_TIME then
				setState("Fly")
			end
		elseif state == "Fly" then
			local lifted = math.clamp(alt / flyHeight, 0, 1)
			if moveTowards(dt, flySpeed * lifted) then
				setState("Land")
			end
		elseif state == "Land" then
			if alt < 0.05 * S then
				setState("Idle")
				idleTimer = 4 + math.random() * 5
			end
		end
	else
		local mode = model:GetAttribute("Mode") or "Idle"
		if mode == "Fly" then
			if state == "Idle" or state == "Walk" or state == "Land" then
				setState("TakeOff")
			elseif state == "TakeOff" and stateTime > TAKEOFF_TIME then
				setState("Fly")
			end
		elseif state == "Fly" or state == "TakeOff" then
			setState("Land")
		elseif state == "Land" then
			if alt < 0.05 * S then
				setState(mode)
			end
		else
			setState(mode)
		end
	end

	-- altitude : monte en vol, redescend à l'atterrissage
	local wantAlt = state == "Fly" and flyHeight or 0
	local rate = (state == "Fly" and 7 or 5) * S
	alt += math.clamp(wantAlt - alt, -rate * dt, rate * dt)

	ground += (groundAt(pos) - ground) * math.min(1, dt * 8)
	local cf = CFrame.new(pos.X, ground + LEG + alt, pos.Z) * CFrame.Angles(0, yaw, 0)
	root.CFrame = cf
	model:SetAttribute("Goal", cf)
	model:SetAttribute("State", state)
end)
]==]
brain.Parent = model

local pose = Instance.new("Script")
pose.Name = "KirasaPose"
pose.RunContext = Enum.RunContext.Client
pose.Source = [==[
-- Kirasa : animations, côté client (chaque joueur calcule les mouvements chez lui,
-- donc c'est fluide même avec de la latence réseau).

local RunService = game:GetService("RunService")

local model = script.Parent
local root = model:WaitForChild("Root")
local S = model:GetAttribute("Scale") or 1

local joints, lids = {}, {}
for _, d in model:GetDescendants() do
	if d:IsA("Motor6D") then
		joints[d.Name] = { motor = d, base = d.C0 }
	elseif d.Name == "LidL" or d.Name == "LidR" then
		table.insert(lids, d)
	end
end

local function setJoint(name, cf)
	local j = joints[name]
	if j then
		j.motor.C0 = j.base * cf
	end
end

local function smooth(a, b, x)
	local t = math.clamp((x - a) / (b - a), 0, 1)
	return t * t * (3 - 2 * t)
end

---------------------------------------------------------------- poses de base
local function statePose(state, t, st, turn)
	local cycle = t % 4.3
	local flick = cycle < 0.3 and math.sin(cycle / 0.3 * math.pi) * 0.35 or 0
	local p = {
		bob = 0, pitch = 0, roll = 0,
		neck = 0, head = 0, headYaw = 0, jaw = 0, flick = flick,
		wingRaise = 0.25, wingFold = 0.2, wingTwist = 0, elbow = 0.25, elbowFlap = 0,
		hipL = 0, hipR = 0, kneeL = 0, kneeR = 0,
		tail = 0, tail2 = 0, tail3 = 0, tailLift = 0,
	}

	if state == "Walk" then
		local ph = t * 6
		local s, c = math.sin(ph), math.cos(ph)
		p.bob = (math.abs(s) - 0.5) * 0.3 * S
		p.pitch, p.roll = -0.06, s * 0.06
		p.neck = -0.08 - math.abs(s) * 0.06
		p.head = 0.08 + math.abs(s) * 0.06
		p.headYaw = s * 0.06
		p.flick = math.abs(c) * 0.15
		p.wingRaise, p.wingFold, p.wingTwist, p.elbow = 0.1 + math.sin(ph * 2) * 0.04, 1.1, -0.3, 0.5
		p.hipL, p.hipR = s * 0.55, -s * 0.55
		p.kneeL, p.kneeR = -math.max(0, c) * 0.9, -math.max(0, -c) * 0.9
		p.tail, p.tail2, p.tail3 = math.sin(ph - 0.6) * 0.22, math.sin(ph - 1.2) * 0.3, math.sin(ph - 1.8) * 0.4
	elseif state == "TakeOff" then
		-- s'accroupit, lève les ailes, puis bondit
		local crouch = math.sin(math.min(st / 0.7, 1) * math.pi)
		local up = smooth(0, 0.5, st)
		p.bob = -0.7 * S * crouch
		p.pitch = 0.15 * crouch
		p.neck = 0.1
		p.hipL, p.hipR = 0.5 * crouch, 0.5 * crouch
		p.kneeL, p.kneeR = -1.0 * crouch, -1.0 * crouch
		p.wingRaise = 0.25 + 0.8 * up
		p.wingTwist = -1.3 * up
		p.wingFold, p.elbow = 0, 0
		p.flick = 0.3 * up
		p.tailLift = 0.2 * crouch
	elseif state == "Fly" then
		-- battements, puis vol plané quelques secondes
		local ph = t * 4.5
		local f = math.sin(ph)
		local cyc = t % 7
		local glide = smooth(4, 4.6, cyc) * (1 - smooth(6.4, 7, cyc))
		local amp = 0.8 * (1 - glide) + 0.05 * glide
		p.bob = -f * 0.1 * S * (1 - glide)
		p.pitch = -0.12 - glide * 0.05
		p.roll = math.clamp(-turn * 0.5, -0.5, 0.5)
		p.neck, p.head = 0.12, 0.05
		p.headYaw = math.clamp(turn * 0.3, -0.3, 0.3)
		p.flick = 0.15 + f * 0.1 * (1 - glide)
		p.wingRaise = 0.15 + glide * 0.1 + f * amp
		p.wingFold, p.wingTwist, p.elbow = 0.1, -1.4, 0.1
		p.elbowFlap = math.sin(ph - 0.9) * 0.35 * (1 - glide)
		p.hipL, p.hipR, p.kneeL, p.kneeR = -0.9, -0.9, 0.7, 0.7
		p.tail, p.tail2, p.tail3 = math.sin(ph * 0.5) * 0.12, math.sin(ph * 0.5 - 0.6) * 0.18, math.sin(ph * 0.5 - 1.2) * 0.25
		p.tailLift = 0.1 + f * 0.05
	elseif state == "Land" then
		-- freine avec de petits battements rapides, pattes tendues vers le sol
		local ph = t * 7
		local f = math.sin(ph)
		p.pitch = 0.2
		p.neck, p.head = 0.15, -0.05
		p.wingRaise = 0.35 + f * 0.4
		p.wingTwist, p.wingFold, p.elbow = -1.0, 0, 0
		p.elbowFlap = math.sin(ph - 0.9) * 0.25
		p.hipL, p.hipR, p.kneeL, p.kneeR = 0.25, 0.25, -0.1, -0.1
		p.flick = 0.3
		p.tail, p.tail2, p.tail3 = 0, 0.05, 0.1
		p.tailLift = 0.15
	else
		local br = math.sin(t * 1.8)
		p.bob = br * 0.08 * S
		p.neck = math.sin(t * 0.6) * 0.06
		p.head = br * 0.03
		p.headYaw = math.sin(t * 0.45) * 0.2
		p.wingRaise = 0.25 + math.sin(t * 1.1) * 0.06
		p.elbowFlap = math.sin(t * 1.1 - 0.5) * 0.04
		p.tail, p.tail2, p.tail3 = math.sin(t * 0.9) * 0.15, math.sin(t * 0.9 - 0.7) * 0.22, math.sin(t * 0.9 - 1.4) * 0.3
	end
	return p
end

---------------------------------------------------------------- actions au repos
-- u : temps depuis le début de l'action, e : force de l'action (monte puis redescend)
local ACTIONS = {
	Roar = { dur = 2.6, apply = function(p, u, e)
		local shake = math.sin(u * 30) * 0.03 * e
		p.neck += 0.35 * e
		p.head += 0.3 * e + shake
		p.headYaw *= 1 - e
		p.jaw += 0.65 * e
		p.wingRaise += 0.5 * e
		p.wingFold -= 0.2 * e
		p.flick += 0.5 * e
		p.pitch += 0.12 * e
		p.tailLift += 0.15 * e
	end },
	Stretch = { dur = 3.2, apply = function(p, u, e)
		p.wingRaise += (0.7 + math.sin(u * 4) * 0.25) * e
		p.wingTwist -= 0.5 * e
		p.wingFold -= 0.25 * e
		p.elbow -= 0.25 * e
		p.neck -= 0.15 * e
		p.pitch -= 0.08 * e
		p.jaw += 0.3 * e * smooth(1, 1.5, u) * (1 - smooth(2, 2.6, u)) -- bâillement
	end },
	Look = { dur = 4, apply = function(p, u, e)
		p.headYaw = p.headYaw * (1 - e) + math.sin(u / 4 * math.pi * 2) * 0.8 * e
		p.neck += 0.1 * e
	end },
	Shake = { dur = 1.4, apply = function(p, u, e)
		local decay = 1 - u / 1.4
		local s = math.sin(u * 28)
		p.headYaw += s * 0.3 * decay * e
		p.flick += math.abs(s) * 0.5 * e
		p.roll += s * 0.04 * e
		p.wingRaise += s * 0.05 * e
	end },
}

local action, actionStart = nil, 0
model:GetAttributeChangedSignal("ActionId"):Connect(function()
	action = ACTIONS[model:GetAttribute("Action") or ""]
	actionStart = os.clock()
end)

---------------------------------------------------------------- application
local function applyPose(p, t)
	setJoint("BodyJoint", CFrame.new(0, p.bob, 0) * CFrame.Angles(p.pitch, 0, p.roll))
	setJoint("NeckJoint", CFrame.Angles(p.neck, 0, 0))
	setJoint("HeadJoint", CFrame.Angles(p.head, p.headYaw, 0))
	setJoint("JawJoint", CFrame.Angles(-p.jaw, 0, 0))
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
	setJoint("Tail1", CFrame.Angles(-p.tailLift, p.tail, 0))
	setJoint("Tail2", CFrame.Angles(-p.tailLift, p.tail2, 0))
	setJoint("Tail3", CFrame.Angles(-p.tailLift, p.tail3, 0))
	setJoint("Tail4", CFrame.Angles(-p.tailLift * 0.5, p.tail3 * 1.15, 0))
	setJoint("Tail5", CFrame.Angles(-p.tailLift * 0.5, p.tail3 * 1.3, 0))

	local blinking = (t % 3.7) < 0.14
	for _, lid in lids do
		lid.Transparency = blinking and 0 or 1
	end
end

local t = 0
local pose = statePose("Idle", 0, 0, 0)
local lastState, stateTime = "Idle", 0
local shown = root.CFrame
local lastYaw, turn = nil, 0

RunService.RenderStepped:Connect(function(dt)
	t += dt

	-- position : suit celle du serveur en douceur
	local goal = model:GetAttribute("Goal")
	if typeof(goal) == "CFrame" then
		shown = shown:Lerp(goal, 1 - 0.0005 ^ dt)
		root.CFrame = shown
	end
	local look = shown.LookVector
	local yaw = math.atan2(-look.X, -look.Z)
	if lastYaw and dt > 0 then
		local rate = ((yaw - lastYaw + math.pi) % (math.pi * 2) - math.pi) / dt
		turn += (rate - turn) * math.min(1, dt * 3)
	end
	lastYaw = yaw

	local state = model:GetAttribute("State") or "Idle"
	if state ~= lastState then
		lastState, stateTime = state, 0
	end
	stateTime += dt

	local target = statePose(state, t, stateTime, turn)
	if action then
		local u = os.clock() - actionStart
		if state ~= "Idle" or u > action.dur then
			action = nil
		else
			local e = smooth(0, 0.35, u) * (1 - smooth(action.dur - 0.5, action.dur, u))
			action.apply(target, u, e)
		end
	end

	local k = 1 - 0.0015 ^ dt
	for key, value in target do
		pose[key] += (value - pose[key]) * k
	end
	applyPose(pose, t)
end)
]==]
pose.Parent = model

model.Parent = workspace
game:GetService("Selection"):Set({ model })
print("Kirasa est prête ! Lance le jeu avec Play (pas Run) pour voir ses animations.")
