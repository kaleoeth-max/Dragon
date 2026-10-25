-- Kirasa, dragon lame-pétale en low poly pour Roblox.
-- Utilisation : dans Roblox Studio, ouvre Affichage > Barre de commande (View > Command Bar),
-- colle tout ce fichier, puis appuie sur Entrée. Le dragon apparaît devant la caméra.
-- Change SCALE pour un dragon plus petit ou plus grand, et COLORS pour changer ses couleurs.

local SCALE = 2
local THICK = 0.05 -- épaisseur des facettes

local S = SCALE
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

local function V(x, y, z)
	return Vector3.new(x, y, z)
end

local function at(x, y, z, rx, ry, rz)
	return ROOT * CFrame.new(x * S, y * S, z * S) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
end

local function newPart(name, kind, size, cf, color, attachTo)
	local p = Instance.new(kind)
	p.Name = name
	p.Size = size
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

local function part(name, kind, sx, sy, sz, cf, color, attachTo)
	return newPart(name, kind, Vector3.new(sx, sy, sz) * S, cf, color, attachTo)
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

-- Os invisible : chaque partie mobile du corps est soudée à un os
local function bone(name, x, y, z)
	local b = part(name, "Part", 0.4, 0.4, 0.4, at(x, y, z), COLORS.ink)
	b.Transparency = 1
	return b
end

---------------------------------------------------------------- facettes
-- Un triangle quelconque fait de deux WedgeParts (méthode classique de Roblox)
local function tri(a, b, c, color, attachTo)
	a, b, c = a * S, b * S, c * S
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end
	ab, ac, bc = b - a, c - a, c - b
	local n = ac:Cross(ab)
	if n.Magnitude < 1e-6 then
		return
	end
	local right = n.Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	local height = math.abs(ab:Dot(up))
	local t = THICK * S
	newPart("Facet", "WedgePart", Vector3.new(t, height, math.abs(ab:Dot(back))),
		ROOT * CFrame.fromMatrix((a + b) / 2, right, up, back), color, attachTo)
	newPart("Facet", "WedgePart", Vector3.new(t, height, math.abs(ac:Dot(back))),
		ROOT * CFrame.fromMatrix((a + c) / 2, -right, up, -back), color, attachTo)
end

local function ring(x, y, z, w, h)
	return { p = V(x, y, z), w = w, h = h }
end

-- Tube à facettes : des anneaux reliés par des triangles, avec une pointe au bout.
-- paint(i, face) donne la couleur d'une face : i = numéro du tronçon,
-- face = 1 sur le dessus (dos), -1 dessous (ventre), 0 sur les côtés.
local function loft(attachTo, rings, sides, ref, paint, tip)
	local phase = (sides / 4 - 0.5) % 1 -- une face pile sur le dessus
	local verts, frames = {}, {}
	for i, r in rings do
		local t = (rings[math.min(#rings, i + 1)].p - rings[math.max(1, i - 1)].p).Unit
		local right = t:Cross(ref).Unit
		local up = right:Cross(t).Unit
		frames[i] = { p = r.p, t = t, right = right, up = up, w = r.w, h = r.h }
		verts[i] = {}
		for k = 0, sides - 1 do
			local th = (k + phase) / sides * math.pi * 2
			verts[i][k] = r.p + right * (math.cos(th) * r.w) + up * (math.sin(th) * r.h)
		end
	end
	local function face(k)
		return math.sin((k + phase + 0.5) / sides * math.pi * 2)
	end
	for i = 1, #rings - 1 do
		for k = 0, sides - 1 do
			local k2 = (k + 1) % sides
			local col = paint(i, face(k))
			tri(verts[i][k], verts[i][k2], verts[i + 1][k2], col, attachTo)
			tri(verts[i][k], verts[i + 1][k2], verts[i + 1][k], col, attachTo)
		end
	end
	if tip == false then
		return frames -- bout caché dans la pièce suivante
	end
	local last = frames[#rings]
	local apex = last.p + last.t * (tip or 0)
	for k = 0, sides - 1 do
		tri(verts[#rings][k], verts[#rings][(k + 1) % sides], apex, paint(#rings, face(k)), attachTo)
	end
	return frames
end

local function refFor(dir)
	return math.abs(dir.Unit.Y) > 0.9 and V(0, 0, 1) or V(0, 1, 0)
end

-- Pointe à facettes (griffes, dents, épines) : une pyramide à trois faces
local function spike(attachTo, from, to, w, color, tipColor)
	local d = (to - from).Unit
	local right = d:Cross(refFor(d)).Unit
	local up = right:Cross(d)
	local pts = {}
	for k = 0, 2 do
		local th = k / 3 * math.pi * 2
		pts[k] = from + right * (math.cos(th) * w) + up * (math.sin(th) * w)
	end
	for k = 0, 2 do
		tri(pts[k], pts[(k + 1) % 3], to, k == 1 and tipColor or color, attachTo)
	end
end

-- Plaque plate à facettes dans le plan de face (pétales, lobes), légèrement bombée
local function plate(attachTo, cx, cy, cz, rx, ry, rot, n, color)
	local center = V(cx, cy, cz - math.min(rx, ry) * 0.25)
	local pts = {}
	for k = 0, n - 1 do
		local th = k / n * math.pi * 2
		local x, y = math.cos(th) * rx, math.sin(th) * ry
		pts[k] = V(cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot), cz)
	end
	for k = 0, n - 1 do
		tri(pts[k], pts[(k + 1) % n], center, color, attachTo)
	end
end

-- Racine invisible : c'est elle que le script déplace
local root = part("Root", "Part", 2, 2, 2, at(0, 0, 0), COLORS.ink)
root.Transparency = 1
root.Anchored = true
root.Massless = false
model.PrimaryPart = root

local UP, BACK, FRONT = V(0, 1, 0), V(0, 0, 1), V(0, 0, -1)

---------------------------------------------------------------- corps
local body = bone("Body", 0, 0, 0)
motor("BodyJoint", root, body, at(0, 0, 0))
local torso = loft(body, {
	ring(0, -0.2, 2.9, 0.95, 0.85),
	ring(0, 0.0, 1.6, 1.45, 1.3),
	ring(0, 0.5, 0.3, 1.6, 1.5),
	ring(0, 1.3, -0.8, 1.5, 1.5),
	ring(0, 2.2, -1.4, 1.15, 1.1),
	ring(0, 2.8, -1.6, 0.95, 0.95),
}, 8, UP, function(i, f)
	if f < -0.6 then
		return COLORS.belly
	elseif f > 0.9 and (i == 2 or i == 4) then
		return COLORS.red
	elseif math.abs(f) < 0.1 and i == 3 then
		return COLORS.red
	end
	return COLORS.back
end, false)
for i = 2, 5 do
	local fr = torso[i]
	local top = fr.p + fr.up * fr.h
	spike(body, top, top + fr.up * (0.9 - i * 0.08) + fr.t * -0.5, 0.22, i % 2 == 0 and COLORS.red or COLORS.ink, COLORS.ink)
end

-- collerette de pétales sous la gorge
for i = 0, 4 do
	local a = -1.2 + i * 0.6
	local x, y = math.sin(a) * 0.95, 1.75 - math.cos(a) * 0.75
	plate(body, x, y, -2.45, 0.42, 0.6, a, 5, COLORS.petal)
	plate(body, x * 1.05, y - 0.08, -2.5, 0.2, 0.28, a, 4, COLORS.red)
end

---------------------------------------------------------------- cou et tête
local neck = bone("Neck", 0, 2.6, -1.5)
motor("NeckJoint", body, neck, at(0, 2.6, -1.5))
local neckFrames = loft(neck, {
	ring(0, 2.4, -1.4, 1.0, 1.0),
	ring(0, 3.5, -1.55, 0.8, 0.85),
	ring(0, 4.6, -1.5, 0.68, 0.72),
	ring(0, 5.5, -1.75, 0.6, 0.65),
	ring(0, 6.0, -2.2, 0.55, 0.6),
}, 6, BACK, function(i, f)
	if f < -0.5 then
		return COLORS.belly
	elseif f > 0.9 and i == 2 then
		return COLORS.red
	end
	return COLORS.back
end, false)
for i = 2, 4 do
	local fr = neckFrames[i]
	local top = fr.p + fr.up * fr.h
	spike(neck, top, top + fr.up * 0.7 + V(0, -0.25, 0), 0.17, COLORS.petal, COLORS.ink)
end

local head = bone("Head", 0, 6.0, -2.2)
motor("HeadJoint", neck, head, at(0, 6.0, -2.2))
loft(head, {
	ring(0, 6.25, -1.8, 0.62, 0.62),
	ring(0, 6.35, -2.4, 0.8, 0.7),
	ring(0, 6.3, -3.1, 0.72, 0.6),
	ring(0, 6.1, -3.9, 0.5, 0.45),
	ring(0, 5.95, -4.6, 0.36, 0.32),
}, 6, UP, function(i, f)
	if f > 0.99 and i >= 2 then
		return COLORS.red
	elseif f < -0.5 then
		return COLORS.belly
	end
	return COLORS.back
end, 0.3)

local jaw = bone("Jaw", 0, 5.85, -2.3)
motor("JawJoint", head, jaw, at(0, 5.85, -2.3))
loft(jaw, {
	ring(0, 5.75, -2.3, 0.6, 0.3),
	ring(0, 5.6, -3.3, 0.5, 0.25),
	ring(0, 5.5, -4.2, 0.36, 0.2),
}, 6, UP, function(_, f)
	return f > 0.99 and COLORS.redDark or COLORS.belly
end, 0.3)

for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	-- dents
	for j, z in { -3.0, -3.5, -4.0, -4.45 } do
		local x = sx * (0.45 - j * 0.04)
		spike(head, V(x, 5.85, z), V(x, 5.5, z - 0.05), 0.06, COLORS.claw)
	end
	-- yeux sur les côtés de la tête
	local rz = sx * 0.6
	part("EyeSocket", "Part", 0.05, 0.34, 0.62, at(sx * 0.57, 6.55, -3.0, 0, 0, rz), COLORS.ink, head)
	local eye = part("Eye", "Part", 0.07, 0.22, 0.45, at(sx * 0.59, 6.56, -3.0, 0, 0, rz), COLORS.eye, head)
	eye.Material = Enum.Material.Neon
	part("Pupil", "Part", 0.08, 0.2, 0.08, at(sx * 0.6, 6.56, -3.05, 0, 0, rz), COLORS.ink, head)
	local lid = part("Lid" .. side, "Part", 0.09, 0.26, 0.5, at(sx * 0.61, 6.56, -3.0, 0, 0, rz), COLORS.back, head)
	lid.Transparency = 1
	spike(head, V(sx * 0.42, 6.85, -2.5), V(sx * 0.62, 6.8, -3.55), 0.11, COLORS.ink)
	part("Nostril", "Part", 0.12, 0.08, 0.12, at(sx * 0.16, 6.08, -4.62), COLORS.ink, head)
	-- cornes balayées vers l'arrière, rouges à la base et blanches au bout
	loft(head, {
		ring(sx * 0.38, 6.7, -2.3, 0.22, 0.22),
		ring(sx * 0.62, 7.3, -1.6, 0.17, 0.17),
		ring(sx * 0.8, 7.75, -0.7, 0.11, 0.11),
	}, 5, UP, function(i)
		return i == 1 and COLORS.red or COLORS.petal
	end, 0.8)
	spike(head, V(sx * 0.3, 6.6, -1.7), V(sx * 0.55, 6.9, -0.9), 0.1, COLORS.ink)

	-- collerettes en forme d'ailes de papillon, derrière les cornes
	local ex, ey, ez = sx * 0.7, 6.5, -1.9
	local ear = bone("Ear" .. side, ex, ey, ez)
	motor("EarJoint" .. side, head, ear, at(ex, ey, ez))
	local function lobe(cx, cy, rx, ry, rot, z)
		plate(ear, cx, cy, z + 0.08, rx + 0.14, ry + 0.14, rot, 6, COLORS.ink)
		plate(ear, cx, cy, z, rx, ry, rot, 6, COLORS.petal)
		plate(ear, cx + sx * 0.08, cy + 0.08, z - 0.06, rx * 0.5, ry * 0.5, rot, 5, COLORS.red)
	end
	lobe(sx * 1.6, 7.25, 0.75, 1.05, -sx * 0.55, -1.7)
	lobe(sx * 1.9, 6.35, 0.55, 0.8, -sx * 1.45, -1.6)
end

---------------------------------------------------------------- ailes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local sh = V(sx * 1.35, 2.0, -1.0)
	local function w(dx, dy, dz)
		return sh + V(sx * dx, dy, dz)
	end
	local function armPaint(_, f)
		if f > 0.99 then
			return COLORS.red
		elseif f < -0.5 then
			return COLORS.belly
		end
		return COLORS.ink
	end

	local arm = bone("UpperWing" .. side, sh.X, sh.Y, sh.Z)
	motor("Shoulder" .. side, body, arm, at(sh.X, sh.Y, sh.Z))
	loft(arm, {
		{ p = w(-0.3, 0, 0), w = 0.6, h = 0.6 },
		{ p = w(1.7, 0.1, 0), w = 0.5, h = 0.45 },
		{ p = w(3.4, 0, 0), w = 0.38, h = 0.36 },
	}, 6, UP, armPaint, false)
	tri(w(0, 0, 0.05), w(3.4, 0, 0.05), w(3.0, -3.6, 0.2), COLORS.lilac, arm)
	tri(w(0, 0, 0.05), w(3.0, -3.6, 0.2), w(0.6, -2.6, 0.2), COLORS.lilac, arm)
	tri(w(0.4, -0.2, 0.0), w(2.4, -0.2, 0.0), w(1.2, -1.3, 0.05), COLORS.red, arm)
	spike(arm, w(3.3, -0.3, -0.1), w(3.4, -1.1, -0.3), 0.14, COLORS.claw)

	local ex, ey, ez = w(3.4, 0, 0).X, w(3.4, 0, 0).Y, w(3.4, 0, 0).Z
	local fore = bone("Forewing" .. side, ex, ey, ez)
	motor("Elbow" .. side, arm, fore, at(ex, ey, ez))
	loft(fore, {
		{ p = w(3.3, 0, 0), w = 0.38, h = 0.36 },
		{ p = w(5.4, 0.15, 0), w = 0.3, h = 0.28 },
		{ p = w(7.4, 0, 0), w = 0.2, h = 0.2 },
	}, 6, UP, armPaint, 0.5)
	tri(w(3.4, 0, 0.05), w(7.3, 0, 0.05), w(6.2, -3.2, 0.15), COLORS.petal, fore)
	tri(w(3.4, 0, 0.05), w(6.2, -3.2, 0.15), w(3.0, -3.6, 0.2), COLORS.lilac, fore)
	tri(w(4.6, -0.3, 0.0), w(6.4, -0.3, 0.0), w(5.6, -1.4, 0.05), COLORS.red, fore)
	spike(fore, w(7.2, -0.1, -0.1), w(7.5, -0.9, -0.35), 0.13, COLORS.claw)
	spike(fore, w(6.9, -0.1, -0.2), w(7.0, -0.8, -0.55), 0.11, COLORS.claw)

	-- longues plumes en lames, qui pendent vers l'extérieur (le script les met à plat en vol)
	for i = 0, 5 do
		local a = math.rad(12 + i * 14)
		local L, W = 13 - i * 1.4, 2.0
		local o = w(7.0 - i * 0.85, -0.15, 0.08 * i)
		local d = V(sx * math.cos(a), -math.sin(a), 0)
		local vX = V(0, 0, sx)
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
		blade("BladeBase", "WedgePart", 0.28, W * 0.9, 2.0, o + d * 1.1 + vY * (W * 0.45), COLORS.red)
	end
end

---------------------------------------------------------------- pattes
for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	local x = sx * 1.35
	local thigh = bone("Thigh" .. side, sx * 1.15, -0.3, 1.1)
	motor("Hip" .. side, body, thigh, at(sx * 1.15, -0.3, 1.1))
	loft(thigh, {
		ring(sx * 1.15, 0.3, 1.2, 0.85, 0.95),
		ring(x, -1.1, 0.8, 0.95, 1.0),
		ring(sx * 1.4, -2.4, 0.3, 0.55, 0.6),
	}, 6, FRONT, function(i, f)
		if f > 0.5 then
			return COLORS.belly
		elseif i == 2 and math.abs(f) < 0.9 then
			return COLORS.red
		end
		return COLORS.back
	end, false)

	local kx = sx * 1.4
	local shin = bone("Shin" .. side, kx, -2.4, 0.3)
	motor("Knee" .. side, thigh, shin, at(kx, -2.4, 0.3))
	local gradient = { COLORS.back, COLORS.red, COLORS.redDeep }
	loft(shin, {
		ring(kx, -2.35, 0.3, 0.52, 0.55),
		ring(kx, -3.6, 0.95, 0.36, 0.38),
		ring(kx, -4.5, 0.7, 0.4, 0.3),
	}, 6, FRONT, function(i)
		return gradient[i]
	end, false)
	loft(shin, { ring(kx, -4.62, 0.95, 0.4, 0.22), ring(kx, -4.72, 0.15, 0.45, 0.22) }, 6, UP, function()
		return COLORS.redDeep
	end, 0)
	for _, dx in { -0.32, 0, 0.32 } do
		local toe = V(kx + dx * 1.4, -4.85, -0.55)
		spike(shin, V(kx + dx, -4.7, 0.3), toe, 0.17, COLORS.redDeep)
		spike(shin, toe + V(0, 0.08, 0.1), toe + V(dx * 0.3, -0.12, -0.55), 0.1, COLORS.claw)
	end
	spike(shin, V(kx, -4.5, 1.0), V(kx, -4.95, 1.5), 0.1, COLORS.claw)
end

---------------------------------------------------------------- queue
local tailPts = {
	{ V(0, -0.2, 2.6), 0.95 }, { V(0, -0.8, 4.8), 0.8 }, { V(0, -1.4, 7.0), 0.62 },
	{ V(0, -1.8, 9.2), 0.46 }, { V(0, -2.1, 11.4), 0.32 }, { V(0, -2.3, 13.6), 0.18 },
}
local prev = body
for k = 1, 5 do
	local a, b = tailPts[k], tailPts[k + 1]
	local seg = bone("TailBone" .. k, a[1].X, a[1].Y, a[1].Z)
	motor("Tail" .. k, prev, seg, at(a[1].X, a[1].Y, a[1].Z))
	local fr = loft(seg, {
		{ p = a[1] - V(0, 0, 0.3), w = a[2], h = a[2] * 0.9 },
		{ p = b[1], w = b[2], h = b[2] * 0.9 },
	}, 6, UP, function(_, f)
		if f < -0.5 then
			return COLORS.belly
		elseif f > 0.99 and k % 2 == 0 then
			return COLORS.red
		end
		return COLORS.back
	end, k == 5 and 0 or false)
	local mid = (fr[1].p + fr[2].p) / 2
	local top = mid + fr[1].up * (fr[1].h + fr[2].h) / 2
	spike(seg, top, top + V(0, 0.7 - k * 0.08, 0.35), 0.16, k % 2 == 1 and COLORS.red or COLORS.ink, COLORS.ink)
	prev = seg
end
local tipP = tailPts[6][1]
tri(tipP, tipP + V(0, 0.9, 1.4), tipP + V(0, 0, 3.0), COLORS.petal, prev)
tri(tipP, tipP + V(0, 0, 3.0), tipP + V(0, -0.7, 1.2), COLORS.petal, prev)
tri(tipP + V(0, 0, 0.4), tipP + V(0, 0.5, 1.3), tipP + V(0, -0.35, 1.2), COLORS.red, prev)

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
