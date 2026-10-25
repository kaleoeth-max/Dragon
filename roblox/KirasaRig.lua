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
		["Body_back"] = { -0.0267, 2.0789, 0.7009, 6.3420, 7.9872, 10.5899 },
		["Body_belly"] = { -0.0106, 1.3811, 0.2866, 4.7518, 7.7267, 10.7473 },
		["Body_bellyShade"] = { -0.0106, 1.2286, -0.0767, 4.7518, 7.4218, 10.0206 },
		["Body_red"] = { -0.0267, 2.8073, 0.3725, 6.3420, 4.9979, 10.5449 },
		["Body_ink"] = { -0.1123, 3.7570, 2.2138, 0.6736, 4.3214, 6.8623 },
		["Body_petal"] = { 0.0941, 3.3882, -0.4622, 5.6692, 5.0590, 8.4955 },
		["Neck_back"] = { 0.0116, 8.7817, -2.7233, 4.0651, 8.0789, 3.6280 },
		["Neck_belly"] = { 0.0116, 8.0435, -4.1061, 4.0651, 7.1443, 1.9088 },
		["Neck_bellyShade"] = { -0.0247, 8.4617, -4.2252, 3.6386, 6.7824, 2.0290 },
		["Neck_red"] = { -0.0146, 8.1795, -1.5488, 1.1038, 2.2475, 0.2031 },
		["Neck_petal"] = { -0.0898, 9.0113, -1.7392, 0.5389, 7.2711, 3.2309 },
		["Neck_ink"] = { -0.0838, 9.0113, -1.7392, 0.5269, 7.2711, 3.2309 },
		["Head_back"] = { 0.0000, 13.1739, -7.0172, 6.0166, 2.8258, 8.3616 },
		["Head_belly"] = { 0.0064, 12.1161, -7.2622, 3.0333, 1.2354, 7.8714 },
		["Head_ink"] = { 0.0000, 13.2632, -6.4990, 6.0166, 3.7235, 9.3980 },
		["Head_redDark"] = { 0.0075, 11.7315, -7.3486, 1.2816, 0.6699, 7.6988 },
		["Head_bellyShade"] = { 0.0064, 12.1161, -7.1594, 3.0333, 1.2354, 7.0498 },
		["Head_red"] = { 0.0000, 13.8163, -6.9054, 3.0377, 3.8027, 8.5851 },
		["Jaw_redDark"] = { -0.0089, 11.7382, -7.3910, 1.5976, 0.6052, 6.8112 },
		["Jaw_ink"] = { 0.0147, 11.2990, -7.3867, 2.3304, 1.6816, 6.8198 },
		["Jaw_belly"] = { 0.0148, 11.5664, -7.3867, 2.8828, 1.1468, 6.8198 },
		["Jaw_bellyShade"] = { 0.0148, 11.5664, -7.3127, 2.8828, 1.1468, 6.0753 },
		["Jaw_red"] = { 0.0000, 11.7860, -7.0419, 0.9600, 0.6712, 4.5047 },
		["Head_claw"] = { -0.0274, 11.4430, -7.8000, 2.0477, 1.6837, 4.9905 },
		["Jaw_claw"] = { 0.0250, 11.8659, -7.6755, 1.5597, 1.0452, 3.9243 },
		["Head_lilac"] = { 0.0000, 16.2554, -1.8617, 3.5256, 2.2051, 2.5720 },
		["Head_petal"] = { 0.0000, 16.9720, -0.9081, 3.5591, 2.3241, 2.9769 },
		["EarL_back"] = { -1.3933, 13.1980, -3.3099, 2.1404, 1.2044, 1.8625 },
		["EarL_ink"] = { -4.9771, 15.5106, -0.7916, 7.3303, 11.6061, 4.7479 },
		["EarL_petal"] = { -4.4271, 14.9426, -1.2198, 5.7469, 9.4694, 3.6482 },
		["EarL_lilac"] = { -4.3911, 14.7011, -1.2047, 4.6462, 8.2161, 2.8850 },
		["EarL_red"] = { -4.5299, 14.7628, -1.1589, 3.3785, 6.8188, 2.1804 },
		["EarR_back"] = { 1.3898, 13.1980, -3.3021, 2.1558, 1.2044, 1.8284 },
		["EarR_ink"] = { 4.9771, 15.5106, -0.7916, 7.3303, 11.6061, 4.7479 },
		["EarR_petal"] = { 4.4271, 14.9426, -1.2198, 5.7469, 9.4694, 3.6482 },
		["EarR_lilac"] = { 4.3911, 14.7011, -1.2047, 4.6462, 8.2161, 2.8850 },
		["EarR_red"] = { 4.5299, 14.7628, -1.1589, 3.3785, 6.8188, 2.1804 },
		["UpperWingL_ink"] = { -6.2139, 1.2004, -1.6633, 8.3722, 8.9992, 3.1265 },
		["UpperWingL_red"] = { -5.7902, 3.5500, -1.8592, 7.5248, 4.3000, 1.1183 },
		["UpperWingL_belly"] = { -5.3720, 3.4109, -2.0070, 6.5172, 1.2776, 2.4390 },
		["UpperWingL_bellyShade"] = { -6.3305, 3.5022, -1.9850, 6.3198, 1.0952, 2.2092 },
		["UpperWingL_lilac"] = { -6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingL_claw"] = { -9.7683, 3.2500, -1.3500, 1.2635, 2.9000, 2.5000 },
		["ForewingL_ink"] = { -25.2494, -2.5693, -1.8684, 33.7648, 15.9387, 1.8168 },
		["ForewingL_red"] = { -14.5180, 3.3603, -1.6000, 12.5804, 7.6389, 1.3600 },
		["ForewingL_belly"] = { -13.9035, 3.7357, -2.0044, 9.1837, 0.9416, 1.5447 },
		["ForewingL_bellyShade"] = { -13.9497, 3.8169, -1.9907, 7.0871, 0.7792, 1.3775 },
		["ForewingL_petal"] = { -25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingL_lilac"] = { -22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingL_claw"] = { -17.2442, 3.2112, -2.4000, 1.9115, 2.0224, 1.4000 },
		["UpperWingR_ink"] = { 6.2139, 1.2004, -1.6563, 8.3722, 8.9992, 3.1125 },
		["UpperWingR_red"] = { 5.7902, 3.5500, -1.8482, 7.5248, 4.3000, 1.0964 },
		["UpperWingR_belly"] = { 5.3720, 3.4109, -1.9930, 6.5172, 1.2776, 2.4390 },
		["UpperWingR_bellyShade"] = { 6.3305, 3.5022, -2.0150, 6.3198, 1.0952, 2.2092 },
		["UpperWingR_lilac"] = { 6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingR_claw"] = { 9.7111, 3.2500, -1.3500, 1.3778, 2.9000, 2.5000 },
		["ForewingR_ink"] = { 25.2494, -2.5693, -1.8640, 33.7648, 15.9387, 1.8079 },
		["ForewingR_red"] = { 14.5180, 3.3603, -1.6000, 12.5804, 7.6389, 1.3600 },
		["ForewingR_belly"] = { 13.9035, 3.7357, -1.9956, 9.1837, 0.9416, 1.5447 },
		["ForewingR_bellyShade"] = { 13.9497, 3.8169, -2.0093, 7.0871, 0.7792, 1.3775 },
		["ForewingR_petal"] = { 25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingR_lilac"] = { 22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingR_claw"] = { 17.2739, 3.2112, -2.3926, 1.8522, 2.0224, 1.4148 },
		["ThighL_belly"] = { -2.5407, -1.3799, 0.5242, 3.5677, 5.0202, 1.9287 },
		["ThighL_back"] = { -2.5558, -2.0819, 2.4614, 3.9172, 6.3016, 3.6390 },
		["ThighL_bellyShade"] = { -2.6218, -2.0901, 0.4238, 3.4056, 5.0274, 1.7528 },
		["ThighL_red"] = { -3.0092, -3.1722, 1.6092, 4.1816, 3.9443, 3.1028 },
		["ShinL_back"] = { -2.7939, -5.7279, 1.2000, 2.1138, 3.2147, 3.0076 },
		["ShinL_red"] = { -2.7896, -8.1438, 1.7930, 1.6018, 2.1867, 1.8216 },
		["ShinL_redDeep"] = { -2.7599, -9.3532, 0.4273, 1.8722, 1.0469, 3.0546 },
		["ShinL_claw"] = { -2.7971, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["ShinL_ink"] = { -2.7600, -5.9830, 1.0000, 0.4800, 3.1659, 5.0000 },
		["ThighL_ink"] = { -4.6231, -1.5918, 2.6080, 0.9537, 0.7836, 0.7840 },
		["ThighR_belly"] = { 2.5550, -1.3647, 0.5242, 3.4763, 5.0482, 1.9287 },
		["ThighR_back"] = { 2.5587, -2.0724, 2.4614, 3.8844, 6.3206, 3.6390 },
		["ThighR_bellyShade"] = { 2.5912, -2.0860, 0.4238, 3.4038, 5.0371, 1.7528 },
		["ThighR_red"] = { 3.0026, -3.1846, 1.6092, 4.1948, 3.9693, 3.1028 },
		["ShinR_back"] = { 2.8061, -5.7279, 1.2000, 2.1138, 3.2147, 3.0076 },
		["ShinR_red"] = { 2.8104, -8.1438, 1.7930, 1.6018, 2.1867, 1.8216 },
		["ShinR_redDeep"] = { 2.8401, -9.3532, 0.4273, 1.8722, 1.0469, 3.0546 },
		["ShinR_claw"] = { 2.8029, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["ShinR_ink"] = { 2.8400, -5.9830, 1.0000, 0.4800, 3.1659, 5.0000 },
		["ThighR_ink"] = { 4.7080, -1.5918, 2.5231, 0.7840, 0.7836, 0.9537 },
		["TailBone1_back"] = { -0.0111, -0.3215, 7.2275, 3.8618, 3.0280, 5.3988 },
		["TailBone1_belly"] = { -0.0111, -1.9013, 6.8674, 3.8618, 2.4101, 5.3530 },
		["TailBone1_bellyShade"] = { 0.0238, -1.8490, 6.8787, 3.5087, 1.6528, 2.3603 },
		["TailBone1_red"] = { -0.0596, 1.1000, 6.2065, 0.3578, 0.8064, 0.7968 },
		["TailBone1_ink"] = { 0.0000, 0.0443, 7.6615, 4.6580, 2.9177, 3.7067 },
		["TailBone1_petal"] = { -0.0545, 0.2130, 9.1504, 0.3273, 0.7377, 0.7289 },
		["TailBone2_back"] = { -0.0093, -1.6207, 11.5964, 3.2521, 2.7236, 5.3139 },
		["TailBone2_red"] = { -0.0146, -0.9171, 11.7792, 1.0863, 1.7634, 4.9483 },
		["TailBone2_belly"] = { -0.0093, -2.9085, 11.3060, 3.2521, 2.1180, 5.3011 },
		["TailBone2_bellyShade"] = { 0.0196, -2.8822, 11.3187, 2.8849, 1.4141, 2.3041 },
		["TailBone2_ink"] = { 0.0000, -1.3250, 11.9682, 4.0856, 2.5791, 3.6018 },
		["TailBone2_petal"] = { -0.0473, -1.2984, 13.4528, 0.2841, 0.6403, 0.6326 },
		["TailBone3_back"] = { -0.0072, -2.7410, 15.9477, 2.5203, 1.9929, 5.1590 },
		["TailBone3_belly"] = { -0.0072, -3.7380, 15.7987, 2.5203, 1.4832, 5.1589 },
		["TailBone3_bellyShade"] = { 0.0150, -3.7241, 15.8062, 2.2092, 1.0327, 2.1759 },
		["TailBone3_red"] = { -0.0439, -1.7863, 14.7152, 0.2633, 0.6200, 0.5554 },
		["TailBone3_ink"] = { 0.0000, -2.4954, 16.1839, 3.4592, 2.0382, 3.4928 },
		["TailBone3_petal"] = { -0.0401, -2.4414, 17.6763, 0.2408, 0.5672, 0.5080 },
		["TailBone4_back"] = { -0.0054, -3.5544, 20.3245, 1.8699, 1.4835, 5.0845 },
		["TailBone4_red"] = { -0.0084, -3.1199, 20.3782, 0.6246, 1.1049, 4.9772 },
		["TailBone4_belly"] = { -0.0054, -4.2809, 20.2437, 1.8699, 1.0688, 5.0897 },
		["TailBone4_bellyShade"] = { 0.0109, -4.2778, 20.2485, 1.6114, 0.7495, 2.1137 },
		["TailBone4_ink"] = { 0.0000, -3.3660, 20.4846, 2.9048, 1.5970, 3.3959 },
		["TailBone4_petal"] = { -0.0329, -3.3405, 21.9805, 0.1976, 0.4745, 0.4040 },
		["TailBone5_back"] = { -0.0037, -4.1522, 24.7084, 1.3008, 1.0042, 5.0334 },
		["TailBone5_belly"] = { -0.0037, -4.6249, 24.6765, 1.3008, 0.6452, 5.0471 },
		["TailBone5_bellyShade"] = { 0.0072, -4.6372, 24.6774, 1.0656, 0.4710, 2.0713 },
		["TailBone5_red"] = { -0.0281, -4.3711, 26.4796, 0.1687, 1.8579, 6.6407 },
		["TailBone5_ink"] = { 0.0000, -4.0283, 24.8096, 2.4008, 1.1724, 3.3007 },
		["TailBone5_petal"] = { -0.0257, -4.4000, 29.6775, 0.1544, 3.2000, 7.0451 },
		["Head_eye"] = { 0.0000, 13.6096, -5.9000, 3.2089, 0.6054, 1.0753 },
		["Head_lidL"] = { -1.5395, 13.6096, -5.9000, 0.2663, 0.7483, 1.1890 },
		["Head_lidR"] = { 1.5395, 13.6096, -5.9000, 0.2663, 0.7483, 1.1890 },
	},
	motors = {
		{ "BodyJoint", "Root", "Body", 0.0000, 0.0000, 0.0000 },
		{ "NeckJoint", "Body", "Neck", 0.0000, 5.2000, -3.0000 },
		{ "HeadJoint", "Neck", "Head", 0.0000, 12.0000, -4.4000 },
		{ "JawJoint", "Head", "Jaw", 0.0000, 11.9000, -4.0000 },
		{ "EarJointL", "Head", "EarL", -1.4000, 13.1000, -3.4000 },
		{ "EarJointR", "Head", "EarR", 1.4000, 13.1000, -3.4000 },
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
