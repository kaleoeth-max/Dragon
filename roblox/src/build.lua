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
	bellyShade = Color3.fromRGB(214, 208, 240), -- une écaille du ventre sur deux
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

-- Export du maillage (Kirasa.obj) : seulement quand make.py lance ce fichier hors de Roblox
local EXPORT = KIRASA_EXPORT
if EXPORT then
	ROOT = CFrame.new()
	EXPORT.colors = COLORS
end
-- Le maillage 3D est en haute définition (plus d'anneaux, de faces, de relief et d'épines).
-- La version en pièces reste simple pour ne pas dépasser quelques milliers de pièces.
local HIGH = EXPORT ~= nil

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
	if EXPORT then
		table.insert(EXPORT, { bone = attachTo.Name, color = color, a = a, b = b, c = c, inside = inside and inside * S })
		return
	end
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
local function hash(a, b)
	local x = math.sin(a * 12.9898 + b * 78.233) * 43758.5453
	return x - math.floor(x)
end

-- Haute définition : anneaux intermédiaires le long d'une courbe douce (Catmull-Rom)
local function refine(rings, steps)
	local out, src = {}, {}
	local n = #rings
	for i = 1, n - 1 do
		local p0 = rings[math.max(1, i - 1)].p
		local p1, p2 = rings[i].p, rings[i + 1].p
		local p3 = rings[math.min(n, i + 2)].p
		local a, b = rings[i], rings[i + 1]
		for s = 0, steps - 1 do
			local t = s / steps
			local p = (p1 * 2 + (p2 - p0) * t + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * (t * t)
				+ (p1 * 3 - p0 - p2 * 3 + p3) * (t * t * t)) * 0.5
			table.insert(out, { p = p, w = a.w + (b.w - a.w) * t, h = a.h + (b.h - a.h) * t })
			table.insert(src, { i, s })
		end
	end
	table.insert(out, rings[n])
	table.insert(src, { n, 0 })
	return out, src
end

local function loft(attachTo, rings, sides, ref, paint, tip)
	local nOrig, src = #rings, nil
	local relief = HIGH and math.min(rings[1].w, rings[1].h) > 0.25
	if HIGH then
		rings, src = refine(rings, 3)
		sides += math.floor(sides / 2)
	end
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
			local bump = 1
			if relief then
				-- petites irrégularités sculptées, et écailles du ventre un anneau sur deux
				bump = 1 + (hash(i, k) - 0.5) * 0.08
				if math.sin(th) < -0.5 and i % 2 == 0 then
					bump += 0.05
				end
			end
			verts[i][k] = r.p + right * (math.cos(th) * r.w * bump) + up * (math.sin(th) * r.h * bump)
		end
	end
	local function face(k)
		return math.sin((k + phase + 0.5) / sides * math.pi * 2)
	end
	local function colorAt(i, k)
		local col = paint(src and src[i][1] or i, face(k))
		if HIGH and col == COLORS.belly and i % 2 == 0 then
			col = COLORS.bellyShade
		end
		return col
	end
	-- les appelants utilisent les anneaux d'origine (pour placer épines et détails)
	local origFrames = frames
	if src then
		origFrames = {}
		for j, sj in src do
			if sj[2] == 0 then
				origFrames[sj[1]] = frames[j]
			end
		end
	end
	for i = 1, #rings - 1 do
		local inside = (rings[i].p + rings[i + 1].p) / 2
		local depth = math.min(0.25, 0.6 * math.min(rings[i].w, rings[i].h, rings[i + 1].w, rings[i + 1].h))
		for k = 0, sides - 1 do
			local k2 = (k + 1) % sides
			local col = colorAt(i, k)
			tri(verts[i][k], verts[i][k2], verts[i + 1][k2], col, attachTo, inside, depth)
			tri(verts[i][k], verts[i + 1][k2], verts[i + 1][k], col, attachTo, inside, depth)
		end
	end
	if tip == false then
		return origFrames -- bout caché dans la pièce suivante
	end
	local last = frames[#rings]
	local apex = last.p + last.t * (tip or 0)
	for k = 0, sides - 1 do
		tri(verts[#rings][k], verts[#rings][(k + 1) % sides], apex, paint(nOrig, face(k)), attachTo,
			last.p - last.t * 0.05, math.min(0.2, 0.5 * math.min(last.w, last.h)))
	end
	return origFrames
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

-- Rangée d'épines le long d'un tube, entre les anneaux « from » et « to » (numéros d'origine).
-- lean = -1 : penchées vers le début du tube, 1 : vers la fin.
local function spikeRow(attachTo, frames, from, to, count, size, lean, colors)
	for j = 0, count - 1 do
		local u = from + (to - from) * (j + 0.5) / count
		local i = math.min(math.floor(u), #frames - 1)
		local t = u - i
		local a, b = frames[i], frames[i + 1]
		local p = a.p + (b.p - a.p) * t
		local up = (a.up + (b.up - a.up) * t).Unit
		local dir = (a.t + (b.t - a.t) * t).Unit
		local h = a.h + (b.h - a.h) * t
		local len = size * (0.75 + 0.25 * math.sin(j * 1.7))
		local base = p + up * (h * 0.92)
		spike(attachTo, base, base + up * len + dir * (lean * len * 0.6), len * 0.3, colors[j % #colors + 1], COLORS.ink)
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
if HIGH then
	spikeRow(body, torso, 1.3, 5.6, 9, 0.75, -1, { COLORS.red, COLORS.ink, COLORS.petal })
else
	for i = 2, 5 do
		local fr = torso[i]
		local top = fr.p + fr.up * fr.h
		spike(body, top, top + fr.up * (0.9 - i * 0.08) + fr.t * -0.5, 0.22, i % 2 == 0 and COLORS.red or COLORS.ink, COLORS.ink)
	end
end

-- collerette de pétales sous la gorge
for i = 0, 4 do
	local a = -1.2 + i * 0.6
	local x, y = math.sin(a) * 0.95, 1.75 - math.cos(a) * 0.75
	plate(body, x, y, -2.25, 0.42, 0.6, a, 5, COLORS.petal)
	plate(body, x * 1.05, y - 0.08, -2.4, 0.2, 0.28, a, 4, COLORS.red)
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
if HIGH then
	spikeRow(neck, neckFrames, 1.2, 4.9, 11, 0.6, -1, { COLORS.petal, COLORS.petal, COLORS.ink })
else
	for i = 2, 4 do
		local fr = neckFrames[i]
		local top = fr.p + fr.up * fr.h
		spike(neck, top, top + fr.up * 0.7 + V(0, -0.25, 0), 0.17, COLORS.petal, COLORS.ink)
	end
end

local head = bone("Head", 0, 6.0, -2.2)
motor("HeadJoint", neck, head, at(0, 6.0, -2.2))
-- tête anguleuse : crâne large derrière les yeux, long museau pointu
local headFrames = loft(head, {
	ring(0, 6.3, -1.75, 0.6, 0.6),
	ring(0, 6.5, -2.35, 0.78, 0.72),
	ring(0, 6.35, -3.05, 0.62, 0.55),
	ring(0, 6.12, -3.8, 0.42, 0.42),
	ring(0, 5.98, -4.6, 0.3, 0.32),
	ring(0, 5.9, -5.2, 0.18, 0.22),
}, 4, UP, function(i, f)
	if f > 0.99 and i >= 2 then
		return COLORS.red
	elseif f < -0.4 then
		return COLORS.belly
	end
	return COLORS.back
end, 0.4)
if HIGH then
	spikeRow(head, headFrames, 1.0, 2.8, 4, 0.45, -1, { COLORS.ink, COLORS.red })
end
-- cornes du nez
spike(head, V(0, 6.38, -4.3), V(0, 6.9, -4.0), 0.12, COLORS.red, COLORS.ink)
spike(head, V(0, 6.55, -3.6), V(0, 6.85, -3.4), 0.08, COLORS.ink)

local jaw = bone("Jaw", 0, 5.85, -2.3)
motor("JawJoint", head, jaw, at(0, 5.85, -2.3))
loft(jaw, {
	ring(0, 5.75, -2.3, 0.55, 0.28),
	ring(0, 5.62, -3.4, 0.42, 0.22),
	ring(0, 5.55, -4.5, 0.26, 0.17),
}, 4, UP, function(_, f)
	return f > 0.99 and COLORS.redDark or COLORS.belly
end, 0.5)

for _, sx in { -1, 1 } do
	local side = sx < 0 and "L" or "R"
	-- dents
	local teeth = HIGH and { -2.8, -3.15, -3.5, -3.85, -4.2, -4.55, -4.9 } or { -3.0, -3.6, -4.2, -4.8 }
	for j, z in teeth do
		local x = sx * (0.47 - j * 0.042)
		spike(head, V(x, 5.85, z), V(x, (j % 2 == 0) and 5.42 or 5.55, z - 0.05), 0.06, COLORS.claw)
	end
	if HIGH then
		for j, z in { -3.0, -3.5, -4.0, -4.5 } do
			local x = sx * (0.4 - j * 0.04)
			spike(jaw, V(x, 5.75, z), V(x, 6.05, z + 0.03), 0.05, COLORS.claw)
		end
		-- arcade sourcilière, joues et menton à épines
		for j = 0, 2 do
			local z = -2.6 - j * 0.35
			spike(head, V(sx * 0.5, 6.8 - j * 0.03, z), V(sx * (0.62 + j * 0.03), 7.05 - j * 0.06, z + 0.25), 0.07, COLORS.ink)
		end
		spike(head, V(sx * 0.6, 6.15, -2.4), V(sx * 1.4, 6.05, -1.35), 0.17, COLORS.back, COLORS.petal)
		spike(head, V(sx * 0.55, 5.95, -2.75), V(sx * 1.25, 5.65, -1.85), 0.13, COLORS.back, COLORS.petal)
		spike(head, V(sx * 0.45, 5.9, -3.3), V(sx * 0.9, 5.6, -2.7), 0.08, COLORS.ink)
		spike(jaw, V(sx * 0.25, 5.5, -2.9), V(sx * 0.36, 5.12, -2.55), 0.07, COLORS.ink)
		spike(head, V(sx * 0.14, 6.12, -4.8), V(sx * 0.2, 6.3, -4.6), 0.06, COLORS.back)
	end
	-- yeux étroits, inclinés vers le museau, sous une grosse arcade noire
	local function eyeAt(dx, dy, dz)
		return at(sx * (0.5 + dx), 6.62 + dy, -3.0 + dz, 0, 0, sx * 0.57) * CFrame.Angles(-0.3, 0, 0)
	end
	part("EyeSocket", "Part", 0.05, 0.28, 0.72, eyeAt(0, 0, 0), COLORS.ink, head)
	local eye = part("Eye", "Part", 0.07, 0.15, 0.52, eyeAt(0.02, 0, 0), COLORS.eye, head)
	eye.Material = Enum.Material.Neon
	part("Pupil", "Part", 0.08, 0.14, 0.07, eyeAt(0.03, 0, -0.04), COLORS.ink, head)
	local lid = part("Lid" .. side, "Part", 0.09, 0.2, 0.56, eyeAt(0.04, 0, 0), COLORS.back, head)
	lid.Transparency = 1
	spike(head, V(sx * 0.36, 7.02, -2.35), V(sx * 0.62, 6.7, -3.55), 0.16, COLORS.ink)
	part("Nostril", "Part", 0.1, 0.07, 0.12, at(sx * 0.11, 6.1, -5.05), COLORS.ink, head)
	-- cornes balayées vers l'arrière, rouges à la base et blanches au bout
	local hornRings = {}
	local hb, hc, he = V(sx * 0.36, 6.8, -2.3), V(sx * 0.58, 7.75, -1.55), V(sx * 0.78, 8.6, -0.35)
	local hornSteps = HIGH and 7 or 3
	for j = 0, hornSteps - 1 do
		local u = j / (hornSteps - 1)
		local p = hb * ((1 - u) ^ 2) + hc * (2 * u * (1 - u)) + he * (u * u)
		local r = 0.24 * (1 - u * 0.55) * ((HIGH and j % 2 == 1) and 1.15 or 1)
		table.insert(hornRings, { p = p, w = r, h = r })
	end
	loft(head, hornRings, 5, UP, function(i)
		if i <= math.ceil(hornSteps / 3) then
			return COLORS.red
		end
		return (HIGH and i % 2 == 0) and COLORS.lilac or COLORS.petal
	end, 0.8)
	spike(head, V(sx * 0.3, 6.6, -1.7), V(sx * 0.55, 6.9, -0.9), 0.1, COLORS.ink)

	-- grandes collerettes en éventail, balayées vers l'arrière, bordées d'épines
	local ex, ey, ez = sx * 0.7, 6.55, -1.7
	local ear = bone("Ear" .. side, ex, ey, ez)
	motor("EarJoint" .. side, head, ear, at(ex, ey, ez))
	local origin = V(ex, ey, ez)
	local u = V(sx * math.cos(0.55), 0, math.sin(0.55)) -- vers l'extérieur et l'arrière
	local v = V(0, math.cos(0.2), math.sin(0.2)) -- vers le haut
	local nrm = v:Cross(u) * sx -- face avant de la collerette
	local function flat(x, y, lift)
		return origin + u * x + v * y + nrm * lift
	end
	local function layer(cx, cy, rx, ry, rot, n, lift, color)
		local center = flat(cx, cy, lift)
		local pts = {}
		for k = 0, n - 1 do
			local th = k / n * math.pi * 2
			local x, y = math.cos(th) * rx, math.sin(th) * ry
			pts[k] = flat(cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot), lift)
		end
		for k = 0, n - 1 do
			tri(pts[k], pts[(k + 1) % n], center, color, ear)
		end
	end
	local function lobe(cx, cy, rx, ry, rot)
		local n = HIGH and 9 or 6
		layer(cx, cy, rx + 0.16, ry + 0.16, rot, n, 0, COLORS.ink)
		for _, side2 in { 1, -1 } do
			layer(cx, cy, rx, ry, rot, n, 0.03 * side2, COLORS.petal)
			layer(cx, cy, rx * 0.72, ry * 0.72, rot, n, 0.06 * side2, COLORS.lilac)
			layer(cx + 0.1, cy + 0.15, rx * 0.42, ry * 0.42, rot, 6, 0.09 * side2, COLORS.red)
		end
		-- épines sur le bord extérieur
		for _, th in { 1.15, 1.57, 1.99 } do
			local x, y = math.cos(th) * rx, math.sin(th) * ry
			local px, py = x * math.cos(rot) - y * math.sin(rot), x * math.sin(rot) + y * math.cos(rot)
			local len = (th == 1.57) and 0.9 or 0.55
			local d = V(px, py, 0).Unit
			spike(ear, flat(cx + px * 0.9, cy + py * 0.9, 0), flat(cx + px + d.X * len, cy + py + d.Y * len, 0), 0.09, COLORS.ink)
		end
	end
	-- attache qui relie les collerettes à la tête
	loft(ear, { ring(sx * 0.3, 6.6, -1.8, 0.34, 0.34), { p = flat(0.5, 0.05, 0), w = 0.26, h = 0.26 } }, 4, UP, function()
		return COLORS.back
	end, 0)
	lobe(1.25, 1.75, 1.05, 1.75, -0.4)
	lobe(2.15, 0.55, 0.85, 1.35, -1.2)
	lobe(1.75, -0.75, 0.65, 1.0, -2.0)
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
	if HIGH then
		for j = 0, 2 do
			local x = 0.7 + j * 0.9
			spike(arm, w(x, 0.4, 0.05), w(x - 0.25, 0.85, 0.35), 0.1, j % 2 == 0 and COLORS.red or COLORS.ink)
		end
		spike(arm, w(3.3, 0.15, 0.2), w(3.85, 0.35, 0.95), 0.16, COLORS.ink, COLORS.claw)
		-- doigt de l'aile en relief dans la membrane
		loft(arm, { { p = w(3.3, -0.1, 0.12), w = 0.1, h = 0.1 }, { p = w(3.0, -3.55, 0.22), w = 0.05, h = 0.05 } }, 4,
			FRONT, function()
				return COLORS.ink
			end, 0.1)
		tri(w(0.7, -0.5, 0.0), w(1.0, -0.5, 0.0), w(0.9, -2.4, 0.1), COLORS.ink, arm)
	end

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
	if HIGH then
		spike(fore, w(7.3, 0.05, 0.05), w(7.75, -0.5, 0.15), 0.11, COLORS.claw)
		for j = 0, 2 do
			local x = 4.0 + j * 1.0
			spike(fore, w(x, 0.3, 0.05), w(x - 0.2, 0.7, 0.3), 0.08, j % 2 == 0 and COLORS.ink or COLORS.red)
		end
		for _, tip in { w(6.2, -3.2, 0.17), w(4.8, -3.5, 0.2) } do
			loft(fore, { { p = w(7.0, -0.1, 0.12), w = 0.09, h = 0.09 }, { p = tip, w = 0.04, h = 0.04 } }, 4,
				FRONT, function()
					return COLORS.ink
				end, 0.1)
		end
	end

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
	if HIGH then
		spike(shin, V(kx, -2.45, -0.15), V(kx, -2.2, -0.75), 0.14, COLORS.ink)
		spike(shin, V(kx, -3.7, 1.25), V(kx, -3.55, 1.75), 0.1, COLORS.ink)
		spike(thigh, V(kx + sx * 0.75, -0.9, 1.1), V(kx + sx * 1.15, -0.6, 1.5), 0.12, COLORS.red, COLORS.ink)
		for _, dx in { -0.32, 0, 0.32 } do
			-- jointure des doigts
			local knuckle = V(kx + dx * 1.2, -4.72, -0.05)
			spike(shin, knuckle + V(0, 0.1, 0.05), knuckle + V(0, 0.22, -0.2), 0.08, COLORS.redDeep)
		end
	end
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
	if HIGH then
		spikeRow(seg, fr, 1.05, 1.95, 3, 0.6 - k * 0.07, 1, { COLORS.red, COLORS.ink, COLORS.petal })
		for _, side in { -1, 1 } do
			for j = 0, 1 do
				local u = 0.3 + j * 0.45
				local p = fr[1].p + (fr[2].p - fr[1].p) * u
				local wd = fr[1].w + (fr[2].w - fr[1].w) * u
				local base = p + fr[1].right * (side * wd * 0.9)
				spike(seg, base, base + fr[1].right * (side * 0.35) + V(0, 0.15, 0.25), 0.07, COLORS.ink)
			end
		end
	else
		local mid = (fr[1].p + fr[2].p) / 2
		local top = mid + fr[1].up * (fr[1].h + fr[2].h) / 2
		spike(seg, top, top + V(0, 0.7 - k * 0.08, 0.35), 0.16, k % 2 == 1 and COLORS.red or COLORS.ink, COLORS.ink)
	end
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
