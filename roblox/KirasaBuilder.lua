-- Kirasa, dragon lame-pétale en low poly pour Roblox.
-- Utilisation : dans Roblox Studio, ouvre Affichage > Barre de commande (View > Command Bar),
-- colle tout ce fichier, puis appuie sur Entrée. Le dragon apparaît devant la caméra.
-- Change SCALE pour un dragon plus petit ou plus grand, et COLORS pour changer ses couleurs.

local SCALE = 2
local THICK = 0.05 -- épaisseur des facettes plates (pétales, membranes)

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
-- Un triangle quelconque fait de deux WedgeParts (méthode classique de Roblox).
-- Avec un point « inside », la facette est épaissie vers l'intérieur du volume :
-- sa face extérieure reste sur le triangle et les facettes voisines se recouvrent sans fente.
local function tri(a, b, c, color, attachTo, inside, depth)
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
	local shift = Vector3.zero
	if inside then
		t = depth * S
		local inward = (inside * S - a):Dot(right) > 0 and right or -right
		shift = inward * (t / 2)
	end
	newPart("Facet", "WedgePart", Vector3.new(t, height, math.abs(ab:Dot(back))),
		ROOT * CFrame.fromMatrix((a + b) / 2 + shift, right, up, back), color, attachTo)
	newPart("Facet", "WedgePart", Vector3.new(t, height, math.abs(ac:Dot(back))),
		ROOT * CFrame.fromMatrix((a + c) / 2 + shift, -right, up, -back), color, attachTo)
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
		local inside = (rings[i].p + rings[i + 1].p) / 2
		local depth = math.min(0.25, 0.6 * math.min(rings[i].w, rings[i].h, rings[i + 1].w, rings[i + 1].h))
		for k = 0, sides - 1 do
			local k2 = (k + 1) % sides
			local col = paint(i, face(k))
			tri(verts[i][k], verts[i][k2], verts[i + 1][k2], col, attachTo, inside, depth)
			tri(verts[i][k], verts[i + 1][k2], verts[i + 1][k], col, attachTo, inside, depth)
		end
	end
	if tip == false then
		return frames -- bout caché dans la pièce suivante
	end
	local last = frames[#rings]
	local apex = last.p + last.t * (tip or 0)
	for k = 0, sides - 1 do
		tri(verts[#rings][k], verts[#rings][(k + 1) % sides], apex, paint(#rings, face(k)), attachTo,
			last.p - last.t * 0.05, math.min(0.2, 0.5 * math.min(last.w, last.h)))
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
		tri(pts[k], pts[(k + 1) % 3], to, k == 1 and tipColor or color, attachTo, from + (to - from) * 0.2, w * 0.6)
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
