-- Kirasa, version maillage 3D (sans jointures entre les triangles).
-- 1. Dans Roblox Studio : onglet Avatar ou Accueil > Importer 3D (Import 3D), choisis Kirasa.obj.
--    Dans les réglages d'import, laisse « Fusionner les maillages » (Merge Meshes) décoché.
-- 2. Ouvre Affichage > Barre de commande, colle tout ce fichier, puis appuie sur Entrée.
-- Le script retrouve les morceaux importés, leur donne leurs couleurs, construit le squelette
-- et ajoute les animations. Change COLORS pour changer ses couleurs.

local COLORS = {
	back = Color3.fromRGB(150, 138, 208), -- dos
	belly = Color3.fromRGB(238, 234, 252), -- ventre, gorge, dessous des ailes
	bellyShade = Color3.fromRGB(214, 208, 240), -- une écaille du ventre sur deux
	backShade = Color3.fromRGB(122, 110, 182), -- écailles en relief sur le dos
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
local DATA = --@@DATA@@

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
--@@BRAIN@@
]==]
brain.Parent = model

local pose = Instance.new("Script")
pose.Name = "KirasaPose"
pose.RunContext = Enum.RunContext.Client
pose.Source = [==[
--@@POSE@@
]==]
pose.Parent = model

model.Parent = workspace
game:GetService("Selection"):Set({ model })
print("Kirasa est prête ! Lance le jeu avec Play (pas Run) pour voir ses animations.")
