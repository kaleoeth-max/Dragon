-- Kirasa, dragon lame-pétale en low poly pour Roblox.
-- Utilisation : dans Roblox Studio, ouvre Affichage > Barre de commande (View > Command Bar),
-- colle tout ce fichier, puis appuie sur Entrée. Le dragon apparaît devant la caméra.
-- Change SCALE pour un dragon plus petit ou plus grand.

local SCALE = 2

local S = SCALE
local COLORS = {
	petal = Color3.fromRGB(236, 231, 251),
	lilac = Color3.fromRGB(185, 175, 226),
	red = Color3.fromRGB(211, 18, 46),
	ink = Color3.fromRGB(24, 18, 36),
	claw = Color3.fromRGB(246, 243, 255),
	eye = Color3.fromRGB(255, 123, 28),
	redDark = Color3.fromRGB(90, 8, 24),
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

-- Pièce plate orientée par un angle dans le plan de face (pétales, lobes)
local function dirXY(sx, angle, dist)
	return sx * math.sin(angle) * dist, math.cos(angle) * dist
end

local function skull(x, y, z, attachTo)
	part("Skull", "Part", 0.9, 0.75, 0.12, at(x, y, z), COLORS.red, attachTo)
	part("SkullJaw", "Part", 0.55, 0.3, 0.12, at(x, y - 0.5, z), COLORS.red, attachTo)
	part("SkullEye", "Part", 0.2, 0.22, 0.06, at(x - 0.2, y + 0.05, z - 0.08), COLORS.ink, attachTo)
	part("SkullEye", "Part", 0.2, 0.22, 0.06, at(x + 0.2, y + 0.05, z - 0.08), COLORS.ink, attachTo)
	part("SkullNose", "Part", 0.1, 0.12, 0.06, at(x, y - 0.22, z - 0.08), COLORS.ink, attachTo)
end

---------------------------------------------------------------- corps
local body = part("Body", "Part", 4.0, 4.2, 5.0, at(0, 0.1, 0), COLORS.petal)
motor("BodyJoint", root, body, at(0, 0, 0))
part("Belly", "Part", 3.2, 1.0, 4.2, at(0, -2.3, 0.1), COLORS.lilac, body)
part("BackPlate", "Part", 3.0, 0.5, 4.6, at(0, 2.4, 0.1), COLORS.petal, body)
for _, sx in { -1, 1 } do
	part("Flank", "Part", 0.25, 3.4, 4.2, at(sx * 2.05, -0.1, 0.2), COLORS.lilac, body)
	part("FlankStripe", "Part", 0.08, 0.3, 2.0, at(sx * 2.2, 0.9, -0.4, 0.45, 0, 0), COLORS.ink, body)
	part("FlankStripe", "Part", 0.08, 0.3, 1.6, at(sx * 2.2, -0.2, 0.6, 0.45, 0, 0), COLORS.ink, body)
	part("FlankStripe", "Part", 0.08, 0.25, 1.2, at(sx * 2.2, -1.2, 1.4, 0.45, 0, 0), COLORS.ink, body)
	part("FlankSpot", "Part", 0.1, 0.9, 0.9, at(sx * 2.2, 0.4, 1.6, math.pi / 4, 0, 0), COLORS.red, body)
	part("ShoulderPad", "Part", 1.5, 1.7, 2.0, at(sx * 2.0, 1.5, -1.0, 0, 0, -sx * 0.3), COLORS.red, body)
	part("ShoulderStripe", "Part", 1.55, 0.3, 2.05, at(sx * 2.05, 1.2, -1.0, 0, 0, -sx * 0.3), COLORS.ink, body)
	part("ShoulderSpike", "WedgePart", 0.3, 0.9, 0.9, at(sx * 2.3, 2.6, -0.6), COLORS.claw, body)
end
for i, z in { -1.2, 0.0, 1.2, 2.3 } do
	part("BackSpike", "WedgePart", 0.35, 1.0 - i * 0.1, 1.1, at(0, 3.1 - i * 0.05, z), COLORS.red, body)
	part("BackSpikeEdge", "WedgePart", 0.4, 0.35, 1.1, at(0, 2.8, z + 0.05), COLORS.ink, body)
end

local chest = part("Chest", "Part", 3.4, 3.2, 0.7, at(0, 0.2, -2.75), COLORS.petal, body)
part("ChestLow", "Part", 2.6, 1.3, 0.5, at(0, -1.45, -2.9), COLORS.lilac, body)
skull(-0.75, -0.3, -3.16, chest)
skull(0.8, -0.85, -3.16, chest)
skull(0, -1.55, -3.2, chest)

-- collerette de pétales en trois couches autour du cou
local function petal(cx, cy, z, angle, dist, w, h, attachTo)
	local dx, dy = dirXY(1, angle, dist)
	part("Petal", "Part", w, h, 0.25, at(cx + dx, cy - dy, z, 0, 0, angle), COLORS.petal, attachTo)
	local sx2, sy2 = dirXY(1, angle, dist + h * 0.12)
	part("PetalSpot", "Part", w * 0.5, h * 0.5, 0.29, at(cx + sx2, cy - sy2, z, 0, 0, angle), COLORS.red, attachTo)
	local tx, ty = dirXY(1, angle, dist + h * 0.45)
	part("PetalTip", "Part", w * 0.28, w * 0.28, 0.27, at(cx + tx, cy - ty, z + 0.02, 0, 0, math.pi / 4), COLORS.ink, attachTo)
end
for i = 0, 8 do
	petal(0, 2.0, -3.25, -2.1 + i * (4.2 / 8), 1.75, 1.25, 1.8, body)
end
for i = 0, 5 do
	petal(0, 2.0, -3.45, -1.5 + i * (3.0 / 5), 1.0, 1.05, 1.45, body)
end
for i = 0, 2 do
	petal(0, 2.0, -3.62, -0.6 + i * 0.6, 0.35, 0.8, 1.1, body)
end

---------------------------------------------------------------- cou et tête
local neck = part("Neck", "Part", 2.0, 2.0, 2.0, at(0, 2.8, -2.4), COLORS.petal)
motor("NeckJoint", body, neck, at(0, 2.0, -2.4))

local head = part("Head", "Part", 2.8, 2.2, 2.6, at(0, 4.6, -3.0), COLORS.petal)
motor("HeadJoint", neck, head, at(0, 3.6, -2.7))
part("HeadTop", "Part", 2.2, 0.4, 2.2, at(0, 5.85, -3.0), COLORS.petal, head)
part("Snout", "Part", 1.8, 1.0, 2.2, at(0, 4.3, -5.2), COLORS.petal, head)
part("SnoutTip", "Part", 1.4, 0.7, 0.5, at(0, 4.25, -6.5), COLORS.petal, head)
part("MouthRoof", "Part", 1.4, 0.1, 2.0, at(0, 3.82, -5.1), COLORS.redDark, head)
local jaw = part("Jaw", "Part", 1.6, 0.6, 2.2, at(0, 3.5, -5.0), COLORS.lilac)
motor("JawJoint", head, jaw, at(0, 3.7, -3.9))
part("Chin", "Part", 1.2, 0.4, 0.6, at(0, 3.35, -6.2), COLORS.lilac, jaw)
part("Tongue", "Part", 0.8, 0.12, 1.5, at(0, 3.8, -5.1), COLORS.red, jaw)
for _, sx in { -1, 1 } do
	for _, z in { -5.55, -4.85 } do
		part("LowerTooth", "WedgePart", 0.16, 0.3, 0.2, at(sx * 0.62, 3.92, z, 0, math.pi, 0), COLORS.claw, jaw)
	end
end
for _, sx in { -1, 1 } do
	for _, z in { -5.9, -5.2, -4.5 } do
		part("Tooth", "WedgePart", 0.18, 0.35, 0.22, at(sx * 0.65, 3.88, z, 0, math.pi, math.pi), COLORS.claw, head)
	end
end
part("Blaze", "Part", 0.6, 0.08, 2.2, at(0, 6.08, -3.0), COLORS.red, head)
part("Blaze", "Part", 0.6, 0.1, 2.2, at(0, 4.83, -5.2), COLORS.red, head)
part("Blaze", "Part", 0.6, 0.9, 0.1, at(0, 5.25, -4.33), COLORS.red, head)
part("BlazeTip", "Part", 0.5, 0.5, 0.1, at(0, 5.62, -4.34, 0, 0, math.pi / 4), COLORS.red, head)
part("Nose", "Part", 0.9, 0.5, 0.1, at(0, 4.3, -6.78), COLORS.red, head)
part("Nostril", "Part", 0.16, 0.12, 0.05, at(-0.25, 4.32, -6.84), COLORS.ink, head)
part("Nostril", "Part", 0.16, 0.12, 0.05, at(0.25, 4.32, -6.84), COLORS.ink, head)
part("Crest", "WedgePart", 0.35, 1.8, 1.6, at(0, 6.95, -2.7), COLORS.red, head)
part("CrestEdge", "WedgePart", 0.4, 0.5, 1.6, at(0, 6.3, -2.65), COLORS.ink, head)

for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	part("Brow", "Part", 1.2, 0.35, 0.6, at(sx * 0.8, 5.3, -4.35, 0, 0, sx * 0.25), COLORS.ink, head)
	part("EyeSocket", "Part", 0.85, 0.65, 0.06, at(sx * 0.85, 4.7, -4.31), COLORS.ink, head)
	local eye = part("Eye", "Part", 0.6, 0.45, 0.1, at(sx * 0.85, 4.7, -4.36), COLORS.eye, head)
	eye.Material = Enum.Material.Neon
	part("Pupil", "Part", 0.14, 0.4, 0.05, at(sx * 0.85, 4.7, -4.42), COLORS.ink, head)
	local lid = part("Lid" .. side, "Part", 0.66, 0.5, 0.12, at(sx * 0.85, 4.7, -4.45), COLORS.petal, head)
	lid.Transparency = 1
	part("CheekTuft", "Part", 0.25, 1.1, 1.3, at(sx * 1.5, 4.0, -3.6, 0.5, 0, 0), COLORS.petal, head)
	part("CheekTuft", "Part", 0.25, 0.8, 1.0, at(sx * 1.55, 3.7, -3.0, 0.9, 0, 0), COLORS.petal, head)
	part("CheekMark", "Part", 0.06, 0.5, 0.5, at(sx * 1.43, 4.6, -3.8, math.pi / 4, 0, 0), COLORS.ink, head)
	part("CheekMark", "Part", 0.06, 0.35, 0.35, at(sx * 1.43, 4.1, -2.4, math.pi / 4, 0, 0), COLORS.red, head)
	part("SideHorn", "WedgePart", 0.25, 0.9, 0.9, at(sx * 0.9, 6.3, -2.2), COLORS.ink, head)

	-- collerettes en forme d'ailes de papillon : trois lobes cerclés de noir
	local ex, ey, ez = sx * 1.4, 5.4, -2.9
	local ear = part("Ear" .. side, "Part", 0.3, 0.3, 0.3, at(ex, ey, ez), COLORS.petal)
	ear.Transparency = 1
	motor("EarJoint" .. side, head, ear, at(ex, ey, ez))
	local function lobe(angle, dist, w, h, z, color)
		local dx, dy = dirXY(sx, angle, dist)
		local rz = -sx * angle
		part("LobeRim", "Part", w + 0.3, h + 0.3, 0.2, at(ex + dx, ey + dy, z + 0.08, 0, 0, rz), COLORS.ink, ear)
		part("Lobe", "Part", w, h, 0.28, at(ex + dx, ey + dy, z, 0, 0, rz), color, ear)
		local sx2, sy2 = dirXY(sx, angle, dist + h * 0.08)
		part("LobeSpot", "Part", w * 0.55, h * 0.55, 0.32, at(ex + sx2, ey + sy2, z, 0, 0, rz), COLORS.red, ear)
		local tx, ty = dirXY(sx, angle, dist + h * 0.38)
		part("LobeDot", "Part", w * 0.16, w * 0.16, 0.32, at(ex + tx, ey + ty, z, 0, 0, math.pi / 4), COLORS.red, ear)
		local nx, ny = dirXY(sx, angle + 0.35, dist + h * 0.3)
		part("LobeDot", "Part", w * 0.1, w * 0.1, 0.32, at(ex + nx, ey + ny, z, 0, 0, math.pi / 4), COLORS.red, ear)
		local kx, ky = dirXY(sx, angle, dist + h * 0.5)
		part("LobeNotch", "Part", w * 0.22, w * 0.22, 0.34, at(ex + kx, ey + ky, z, 0, 0, math.pi / 4), COLORS.ink, ear)
	end
	lobe(1.15, 2.0, 1.8, 2.4, ez + 0.35, COLORS.lilac)
	lobe(0.6, 2.2, 3.2, 4.0, ez, COLORS.petal)
	lobe(1.75, 1.9, 2.4, 3.0, ez + 0.1, COLORS.petal)
end

---------------------------------------------------------------- ailes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local sh = Vector3.new(sx * 2.0, 1.6, -1.0)
	local function w(dx, dy, dz)
		return sh.X + sx * dx, sh.Y + dy, sh.Z + dz
	end

	local arm = part("UpperWing" .. side, "Part", 3.4, 1.0, 1.0, at(w(1.7, 0, 0)), COLORS.red)
	motor("Shoulder" .. side, body, arm, at(w(0, 0, 0)))
	part("ArmBand", "Part", 0.3, 1.05, 1.05, at(w(1.0, 0, 0)), COLORS.ink, arm)
	part("ArmBand", "Part", 0.3, 1.05, 1.05, at(w(2.3, 0, 0)), COLORS.ink, arm)
	part("ArmSpur", "WedgePart", 0.3, 0.8, 0.8, at(w(1.6, 0.85, 0.1)), COLORS.ink, arm)
	part("Membrane", "Part", 3.8, 4.6, 0.18, at(w(1.9, -2.5, 0.05)), COLORS.lilac, arm)
	part("MembranePatch", "Part", 1.8, 0.9, 0.22, at(w(1.3, -0.9, 0.05)), COLORS.red, arm)
	part("MembraneStripe", "Part", 3.0, 0.35, 0.22, at(w(2.0, -3.4, 0.05)), COLORS.ink, arm)
	part("MembraneStripe", "Part", 2.0, 0.3, 0.22, at(w(2.3, -2.2, 0.05, 0, 0, sx * 0.4)), COLORS.ink, arm)
	part("MembraneEdge", "Part", 3.8, 0.2, 0.22, at(w(1.9, -4.8, 0.05)), COLORS.ink, arm)

	local fore = part("Forewing" .. side, "Part", 4.0, 0.8, 0.8, at(w(5.4, 0, 0)), COLORS.red)
	motor("Elbow" .. side, arm, fore, at(w(3.4, 0, 0)))
	part("ArmBand", "Part", 0.3, 0.85, 0.85, at(w(4.6, 0, 0)), COLORS.ink, fore)
	part("ArmBand", "Part", 0.3, 0.85, 0.85, at(w(6.1, 0, 0)), COLORS.ink, fore)
	part("Membrane", "Part", 3.6, 4.0, 0.18, at(w(5.0, -2.2, 0.05)), COLORS.lilac, fore)
	part("MembraneStripe", "Part", 2.6, 0.35, 0.22, at(w(5.1, -3.1, 0.05)), COLORS.ink, fore)
	part("MembranePatch", "Part", 1.4, 0.7, 0.22, at(w(5.6, -0.8, 0.05)), COLORS.red, fore)
	part("WristClaw", "Part", 0.3, 1.2, 0.3, at(w(7.4, 0.7, 0, 0, 0, -sx * 0.3)), COLORS.claw, fore)
	part("WristClaw", "Part", 0.25, 0.9, 0.25, at(w(7.1, 0.6, -0.35, 0, 0, sx * 0.2)), COLORS.claw, fore)

	-- longues plumes en lames, qui pendent vers l'extérieur (le script les met à plat en vol)
	for i = 0, 5 do
		local a = math.rad(12 + i * 14)
		local L, W = 14 - i * 1.5, 2.2
		local o = Vector3.new(w(7.2 - i * 0.9, -0.2, 0.08 * i))
		local d = Vector3.new(sx * math.cos(a), -math.sin(a), 0)
		local vX = Vector3.new(0, 0, sx)
		local vZ = -d
		local vY = vZ:Cross(vX)
		local function blade(name, kind, bx, by, bz, center, color, flip)
			local fx = flip and -vX or vX
			local fy = flip and -vY or vY
			local cf = ROOT * CFrame.fromMatrix(center * S, fx, fy, vZ)
			return part(name, kind, bx, by, bz, cf, color, fore)
		end
		blade("Blade", "WedgePart", 0.2, W, L, o + d * (L / 2) + vY * (W / 2), COLORS.petal)
		blade("BladeUnder", "WedgePart", 0.2, W * 0.45, L * 0.85, o + d * (L * 0.425) - vY * (W * 0.225), COLORS.lilac, true)
		blade("BladeEdge", "WedgePart", 0.24, 0.3, L * 0.9, o + d * (L * 0.55) + vY * 0.15, COLORS.ink)
		blade("BladeStreak", "Part", 0.26, 0.25, L * 0.3, o + d * (L * 0.35) + vY * (W * 0.6), COLORS.ink)
		blade("BladeBase", "Part", 0.28, W * 0.9, 2.0, o + d * 1.1 + vY * (W * 0.35), COLORS.red)
	end
end

---------------------------------------------------------------- pattes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local x = sx * 1.5
	local thigh = part("Thigh" .. side, "Part", 1.8, 2.6, 2.2, at(x, -2.5, 0.8), COLORS.red)
	motor("Hip" .. side, body, thigh, at(sx * 1.4, -1.6, 0.8))
	part("ThighStripe", "Part", 0.15, 0.3, 1.9, at(x + sx * 0.92, -2.1, 0.8, 0.4, 0, 0), COLORS.ink, thigh)
	part("ThighStripe", "Part", 0.15, 0.3, 1.6, at(x + sx * 0.92, -2.9, 0.9, -0.4, 0, 0), COLORS.ink, thigh)
	part("ThighPatch", "Part", 0.15, 0.7, 0.7, at(x + sx * 0.92, -1.6, 0.3, math.pi / 4, 0, 0), COLORS.petal, thigh)
	part("ThighFront", "Part", 1.4, 1.6, 0.15, at(x, -2.5, -0.35), COLORS.ink, thigh)
	skull(x, -2.2, -0.45, thigh)

	local shin = part("Shin" .. side, "Part", 1.0, 0.9, 1.0, at(x, -4.1, 1.0), COLORS.ink)
	motor("Knee" .. side, thigh, shin, at(x, -3.7, 0.9))
	part("AnkleFluff", "Part", 1.4, 0.45, 1.4, at(x, -3.8, 0.95, 0, math.pi / 4, 0), COLORS.petal, shin)
	part("Foot", "Part", 1.7, 0.5, 2.2, at(x, -4.75, 0.6), COLORS.ink, shin)
	part("HeelSpur", "WedgePart", 0.3, 0.7, 0.8, at(x, -4.3, 2.05, 0, math.pi, 0), COLORS.ink, shin)
	for _, dx in { -0.55, 0, 0.55 } do
		part("Toe", "Part", 0.4, 0.35, 0.5, at(x + dx, -4.85, -0.6), COLORS.ink, shin)
		part("Claw", "WedgePart", 0.3, 0.45, 0.8, at(x + dx, -4.78, -1.1), COLORS.claw, shin)
	end
end

---------------------------------------------------------------- queue
local tailSizes = { { 1.8, 1.5 }, { 1.5, 1.25 }, { 1.2, 1.0 }, { 0.9, 0.8 }, { 0.65, 0.6 } }
local prev = body
for k, sz in tailSizes do
	local z, y = 3.6 + (k - 1) * 2.3, -0.9 - (k - 1) * 0.22
	local seg = part("Tail" .. k, "Part", sz[1], sz[2], 2.4, at(0, y, z), COLORS.lilac)
	motor("Tail" .. k, prev, seg, at(0, y + 0.05, z - 1.15))
	part("TailBand", "Part", sz[1] + 0.05, sz[2] + 0.05, 0.3, at(0, y, z - 0.4), k % 2 == 1 and COLORS.ink or COLORS.red, seg)
	part("TailSpike", "WedgePart", 0.25, 0.6, 0.9, at(0, y + sz[2] / 2 + 0.3, z + 0.3), COLORS.red, seg)
	part("TailSide", "Part", sz[1] + 0.04, sz[2] * 0.3, 1.0, at(0, y - sz[2] * 0.2, z + 0.6), COLORS.petal, seg)
	prev = seg
end
part("TailBlade", "WedgePart", 0.25, 2.2, 3.2, at(0, -1.4, 15.6, 0, math.pi, 0), COLORS.petal, prev)
part("TailBladeSpot", "WedgePart", 0.29, 1.1, 1.6, at(0, -1.9, 15.1, 0, math.pi, 0), COLORS.red, prev)
part("TailBladeEdge", "WedgePart", 0.3, 0.3, 3.0, at(0, -2.35, 15.6, 0, math.pi, 0), COLORS.ink, prev)

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

model:SetAttribute("PlayAction", "")
model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

-- le serveur décide où elle va, chaque joueur calcule l'animation chez lui
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
	-- le cou penche vers l'avant au repos, la tête compense
	setJoint("BodyJoint", CFrame.new(0, p.bob, 0) * CFrame.Angles(p.pitch, 0, p.roll))
	setJoint("NeckJoint", CFrame.Angles(p.neck - 0.22, 0, 0))
	setJoint("HeadJoint", CFrame.Angles(p.head + 0.18, p.headYaw, 0))
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
