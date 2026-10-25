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
--@@ANIMATE@@
]==]
animate.Parent = model

model.Parent = workspace
game:GetService("Selection"):Set({ model })
print("Kirasa est prête ! Lance le jeu (Play) pour voir ses animations.")
