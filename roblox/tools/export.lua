-- Lancé par make.py après mock.lua et build.lua : écrit Kirasa.obj et les données du squelette.
-- Chaque objet du .obj s'appelle "<Os>_<couleur>" (ex. "Head_red") pour que KirasaRig.lua
-- sache à quel os le souder et de quelle couleur le peindre.

local model = workspace._children.Kirasa
local colorKey = {}
for k, c in KIRASA_EXPORT.colors do
	colorKey[c] = k
end
local SPECIAL = { Eye = "eye", LidL = "lidL", LidR = "lidR" }

local bones, motors = {}, {}
for _, o in ALL do
	if o.ClassName == "Motor6D" then
		local pivot = o.Part0.CFrame * o.C0
		table.insert(motors, { o.Name, o.Part0.Name, o.Part1.Name, pivot.Position })
		bones[o.Part1] = true
	end
end

local objects, order = {}, {}
local function add(name, a, b, c, inside)
	if not objects[name] then
		objects[name] = {}
		table.insert(order, name)
	end
	table.insert(objects[name], { a, b, c, inside })
end

for _, t in KIRASA_EXPORT do
	if type(t) == "table" and t.a then
		add(t.bone .. "_" .. colorKey[t.color], t.a, t.b, t.c, t.inside)
	end
end

-- pièces simples (yeux, narines, lames des ailes) converties en triangles
for _, o in model._list do
	if (o.ClassName == "Part" or o.ClassName == "WedgePart") and o.Name ~= "Root" and not bones[o] then
		local weld
		for _, c in o._list do
			if c.ClassName == "WeldConstraint" then
				weld = c
			end
		end
		local name = weld.Part0.Name .. "_" .. (SPECIAL[o.Name] or colorKey[o.Color])
		local cf, h = o.CFrame, o.Size / 2
		local function P(x, y, z)
			return cf * Vector3.new(x * h.X, y * h.Y, z * h.Z)
		end
		if o.ClassName == "Part" then
			local inside = cf.Position
			local faces = {
				{ P(-1, -1, -1), P(1, -1, -1), P(1, 1, -1), P(-1, 1, -1) },
				{ P(-1, -1, 1), P(1, -1, 1), P(1, 1, 1), P(-1, 1, 1) },
				{ P(-1, -1, -1), P(-1, 1, -1), P(-1, 1, 1), P(-1, -1, 1) },
				{ P(1, -1, -1), P(1, 1, -1), P(1, 1, 1), P(1, -1, 1) },
				{ P(-1, -1, -1), P(1, -1, -1), P(1, -1, 1), P(-1, -1, 1) },
				{ P(-1, 1, -1), P(1, 1, -1), P(1, 1, 1), P(-1, 1, 1) },
			}
			for _, f in faces do
				add(name, f[1], f[2], f[3], inside)
				add(name, f[1], f[3], f[4], inside)
			end
		else
			-- WedgePart : pleine hauteur à l'arrière (+Z), pente vers l'avant
			local inside = cf * Vector3.new(0, -h.Y / 3, h.Z / 3)
			local A, B, C, D = P(-1, -1, -1), P(1, -1, -1), P(-1, -1, 1), P(1, -1, 1)
			local E, F = P(-1, 1, 1), P(1, 1, 1)
			for _, t in { { A, B, D }, { A, D, C }, { C, D, F }, { C, F, E }, { A, B, F }, { A, F, E }, { A, C, E }, { B, D, F } } do
				add(name, t[1], t[2], t[3], inside)
			end
		end
	end
end

-- écriture : faces orientées vers l'extérieur ; les pièces plates sont en double face
local out = { "# Kirasa, dragon lame-pétale (low poly). Généré par make.py." }
local vi = 0
local boxes = {}
local function fmt(v)
	return string.format("%.4f %.4f %.4f", v.X, v.Y, v.Z)
end
for _, name in order do
	table.insert(out, "o " .. name)
	local lo, hi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
	local function face(a, b, c)
		local n = (b - a):Cross(c - a)
		if n.Magnitude < 1e-9 then
			return
		end
		n = n.Unit
		table.insert(out, "v " .. fmt(a))
		table.insert(out, "v " .. fmt(b))
		table.insert(out, "v " .. fmt(c))
		table.insert(out, "vn " .. fmt(n))
		vi += 3
		local ni = vi / 3
		table.insert(out, string.format("f %d//%d %d//%d %d//%d", vi - 2, ni, vi - 1, ni, vi, ni))
		for _, v in { a, b, c } do
			lo = Vector3.new(math.min(lo.X, v.X), math.min(lo.Y, v.Y), math.min(lo.Z, v.Z))
			hi = Vector3.new(math.max(hi.X, v.X), math.max(hi.Y, v.Y), math.max(hi.Z, v.Z))
		end
	end
	for _, t in objects[name] do
		local a, b, c, inside = t[1], t[2], t[3], t[4]
		if inside then
			if (b - a):Cross(c - a):Dot(a - inside) < 0 then
				b, c = c, b
			end
			face(a, b, c)
		else
			face(a, b, c)
			face(a, c, b)
		end
	end
	boxes[name] = { (lo + hi) / 2, hi - lo }
end
print("@@OBJ")
print(table.concat(out, "\n"))

local data = { "{", "\tcenters = {" }
for _, name in order do
	local c, s = boxes[name][1], boxes[name][2]
	table.insert(data, string.format('\t\t["%s"] = { %.4f, %.4f, %.4f, %.4f, %.4f, %.4f },', name, c.X, c.Y, c.Z, s.X, s.Y, s.Z))
end
table.insert(data, "\t},")
table.insert(data, "\tmotors = {")
for _, m in motors do
	table.insert(data, string.format('\t\t{ "%s", "%s", "%s", %.4f, %.4f, %.4f },', m[1], m[2], m[3], m[4].X, m[4].Y, m[4].Z))
end
table.insert(data, "\t},")
table.insert(data, "}")
print("@@DATA")
print(table.concat(data, "\n"))
