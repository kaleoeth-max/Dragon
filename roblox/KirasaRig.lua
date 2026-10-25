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
local DATA = {
	centers = {
		["Body_back"] = { 0.1173, 2.0633, 0.7034, 6.4309, 8.0457, 10.5823 },
		["Body_belly"] = { 0.0026, 1.1075, 0.2679, 4.7811, 7.0990, 10.7938 },
		["Body_bellyShade"] = { 0.0026, 1.4030, -0.3621, 4.7811, 7.6900, 9.5338 },
		["Body_red"] = { 0.1175, 2.7964, 0.3707, 6.4306, 5.0674, 10.5414 },
		["Body_ink"] = { -0.1123, 3.7547, 2.2125, 0.6736, 4.3153, 6.8578 },
		["Body_petal"] = { 0.0941, 3.3855, -0.4642, 5.6692, 5.0536, 8.4915 },
		["Body_backShade"] = { 0.0149, 3.0917, 1.6563, 6.2052, 5.6405, 8.2313 },
		["Neck_back"] = { 0.0233, 8.7884, -2.6508, 4.1909, 8.0965, 3.7814 },
		["Neck_belly"] = { 0.0233, 7.9711, -4.0714, 4.1909, 7.0155, 1.8214 },
		["Neck_bellyShade"] = { -0.0476, 8.6880, -4.2182, 3.4720, 6.3388, 1.9721 },
		["Neck_red"] = { 0.0007, 8.1787, -1.5510, 1.0852, 2.2504, 0.1825 },
		["Neck_petal"] = { -0.0898, 9.0112, -1.7399, 0.5389, 7.2731, 3.2315 },
		["Neck_ink"] = { -0.0838, 9.0112, -1.7399, 0.5269, 7.2731, 3.2315 },
		["Neck_backShade"] = { 0.0284, 8.9312, -2.2994, 3.4456, 7.5976, 3.0786 },
		["Head_back"] = { 0.0000, 13.1801, -7.0156, 6.0166, 2.8347, 8.3646 },
		["Head_belly"] = { -0.0356, 12.1160, -7.2626, 3.0264, 1.2355, 7.8707 },
		["Head_ink"] = { 0.0000, 13.2559, -6.4990, 6.0166, 3.7351, 9.3980 },
		["Head_redDark"] = { 0.0073, 11.7342, -7.3474, 1.2739, 0.6971, 7.7011 },
		["Head_bellyShade"] = { -0.0356, 12.1160, -7.2579, 3.0264, 1.2355, 6.8536 },
		["Head_red"] = { 0.0000, 13.8163, -6.9054, 3.0377, 3.8027, 8.5851 },
		["Jaw_redDark"] = { -0.0065, 11.7384, -7.3909, 1.6030, 0.6048, 6.8113 },
		["Jaw_ink"] = { -0.0167, 11.2988, -7.3866, 2.3295, 1.6812, 6.8199 },
		["Jaw_belly"] = { 0.0171, 11.5670, -7.3866, 2.9346, 1.1449, 6.8199 },
		["Jaw_bellyShade"] = { 0.0171, 11.5670, -7.5117, 2.9346, 1.1449, 6.0507 },
		["Jaw_red"] = { 0.0000, 11.7860, -7.0419, 0.9600, 0.6712, 4.5047 },
		["Head_claw"] = { -0.0274, 11.4430, -7.8000, 2.0477, 1.6837, 4.9905 },
		["Jaw_claw"] = { 0.0250, 11.8659, -7.6755, 1.5597, 1.0452, 3.9243 },
		["Head_lilac"] = { 0.0000, 16.2554, -1.8617, 3.5256, 2.2051, 2.5720 },
		["Head_petal"] = { 0.0000, 16.9720, -0.9081, 3.5591, 2.3241, 2.9769 },
		["EarL_back"] = { -1.3963, 13.1960, -3.3073, 2.1428, 1.2311, 1.9096 },
		["EarL_ink"] = { -4.9771, 15.5106, -0.7916, 7.3303, 11.6061, 4.7479 },
		["EarL_petal"] = { -4.4271, 14.9426, -1.2198, 5.7469, 9.4694, 3.6482 },
		["EarL_lilac"] = { -4.3911, 14.7011, -1.2047, 4.6462, 8.2161, 2.8850 },
		["EarL_red"] = { -4.5299, 14.7628, -1.1589, 3.3785, 6.8188, 2.1804 },
		["EarR_back"] = { 1.3909, 13.1960, -3.2955, 2.1769, 1.2311, 1.8336 },
		["EarR_ink"] = { 4.9771, 15.5106, -0.7916, 7.3303, 11.6061, 4.7479 },
		["EarR_petal"] = { 4.4271, 14.9426, -1.2198, 5.7469, 9.4694, 3.6482 },
		["EarR_lilac"] = { 4.3911, 14.7011, -1.2047, 4.6462, 8.2161, 2.8850 },
		["EarR_red"] = { 4.5299, 14.7628, -1.1589, 3.3785, 6.8188, 2.1804 },
		["UpperWingL_ink"] = { -6.2132, 1.2004, -1.6856, 8.3736, 8.9992, 3.1712 },
		["UpperWingL_red"] = { -5.7907, 3.5500, -1.8631, 7.5286, 4.3000, 1.1262 },
		["UpperWingL_belly"] = { -5.0781, 3.3986, -2.0140, 5.9286, 1.3135, 2.5145 },
		["UpperWingL_bellyShade"] = { -6.6936, 3.5723, -1.9709, 5.5948, 0.9661, 2.1218 },
		["UpperWingL_backShade"] = { -5.9635, 4.8464, -1.9996, 5.5627, 0.9170, 1.7285 },
		["UpperWingL_back"] = { -5.9635, 4.8464, -2.0213, 5.5627, 0.9170, 1.6850 },
		["UpperWingL_lilac"] = { -6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingL_claw"] = { -9.7683, 3.2500, -1.3500, 1.2635, 2.9000, 2.5000 },
		["ForewingL_ink"] = { -25.2494, -2.5693, -1.8826, 33.7648, 15.9387, 1.8451 },
		["ForewingL_red"] = { -14.5180, 3.3603, -1.6000, 12.5804, 7.6389, 1.3600 },
		["ForewingL_belly"] = { -13.9036, 3.7284, -2.0089, 9.1834, 0.9633, 1.5925 },
		["ForewingL_bellyShade"] = { -14.3256, 3.8779, -1.9820, 6.3362, 0.6641, 1.3117 },
		["ForewingL_backShade"] = { -12.9185, 4.6598, -1.9807, 5.9455, 0.6452, 0.8956 },
		["ForewingL_back"] = { -12.9185, 4.6598, -2.0048, 5.9455, 0.6452, 0.8474 },
		["ForewingL_petal"] = { -25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingL_lilac"] = { -22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingL_claw"] = { -17.2442, 3.2112, -2.4000, 1.9115, 2.0224, 1.4000 },
		["UpperWingR_ink"] = { 6.2132, 1.2004, -1.6716, 8.3736, 8.9992, 3.1433 },
		["UpperWingR_red"] = { 5.7907, 3.5500, -1.8412, 7.5286, 4.3000, 1.0824 },
		["UpperWingR_belly"] = { 5.0781, 3.3986, -1.9860, 5.9286, 1.3135, 2.5145 },
		["UpperWingR_bellyShade"] = { 6.6936, 3.5723, -2.0291, 5.5948, 0.9661, 2.1218 },
		["UpperWingR_backShade"] = { 5.9635, 4.8464, -2.0004, 5.5627, 0.9170, 1.7285 },
		["UpperWingR_back"] = { 5.9635, 4.8464, -1.9787, 5.5627, 0.9170, 1.6850 },
		["UpperWingR_lilac"] = { 6.1000, 0.4000, -1.7500, 6.8000, 7.2000, 0.3000 },
		["UpperWingR_claw"] = { 9.7111, 3.2500, -1.3500, 1.3778, 2.9000, 2.5000 },
		["ForewingR_ink"] = { 25.2494, -2.5693, -1.8737, 33.7648, 15.9387, 1.8274 },
		["ForewingR_red"] = { 14.5180, 3.3603, -1.6000, 12.5804, 7.6389, 1.3600 },
		["ForewingR_belly"] = { 13.9036, 3.7284, -1.9911, 9.1834, 0.9633, 1.5925 },
		["ForewingR_bellyShade"] = { 14.3256, 3.8779, -2.0180, 6.3362, 0.6641, 1.3117 },
		["ForewingR_backShade"] = { 12.9185, 4.6598, -2.0193, 5.9455, 0.6452, 0.8956 },
		["ForewingR_back"] = { 12.9185, 4.6598, -1.9952, 5.9455, 0.6452, 0.8474 },
		["ForewingR_petal"] = { 25.1659, -1.4631, -1.6000, 33.9318, 18.1513, 1.2000 },
		["ForewingR_lilac"] = { 22.3673, -2.2014, -1.6000, 31.8995, 12.4029, 1.2000 },
		["ForewingR_claw"] = { 17.2739, 3.2112, -2.3926, 1.8522, 2.0224, 1.4148 },
		["ThighL_belly"] = { -2.5599, -1.1657, 0.5210, 3.7067, 4.5544, 1.9469 },
		["ThighL_back"] = { -2.6817, -2.0750, 1.9870, 4.2933, 6.2818, 4.6806 },
		["ThighL_bellyShade"] = { -2.7151, -2.3346, 0.3448, 3.3963, 4.5306, 1.6920 },
		["ThighL_red"] = { -3.0132, -3.1750, 1.5665, 4.1737, 3.9500, 3.1196 },
		["ThighL_backShade"] = { -4.0817, -2.1516, 1.4950, 1.4931, 4.8975, 3.6965 },
		["ShinL_back"] = { -2.7879, -5.7180, 1.1346, 2.1793, 3.2234, 2.9110 },
		["ShinL_red"] = { -2.8126, -8.1498, 1.7242, 1.4919, 2.1563, 1.7318 },
		["ShinL_redDeep"] = { -2.7599, -9.3532, 0.4273, 1.8722, 1.0469, 3.0546 },
		["ShinL_claw"] = { -2.7971, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["ShinL_ink"] = { -2.7600, -5.9830, 1.0000, 0.4800, 3.1659, 5.0000 },
		["ThighL_ink"] = { -4.6231, -1.5918, 2.6080, 0.9537, 0.7836, 0.7840 },
		["ThighR_belly"] = { 2.5754, -1.1319, 0.5210, 3.4980, 4.6036, 1.9469 },
		["ThighR_back"] = { 2.6936, -2.0561, 2.0266, 4.2396, 6.3197, 4.6013 },
		["ThighR_bellyShade"] = { 2.6247, -2.3180, 0.3448, 3.3995, 4.5346, 1.6920 },
		["ThighR_red"] = { 3.0125, -3.1696, 1.5665, 4.1751, 3.9391, 3.1196 },
		["ThighR_backShade"] = { 4.1246, -2.2185, 1.6934, 1.3777, 4.9034, 3.9347 },
		["ShinR_back"] = { 2.8121, -5.7180, 1.1346, 2.1793, 3.2234, 2.9110 },
		["ShinR_red"] = { 2.7874, -8.1498, 1.7242, 1.4919, 2.1563, 1.7318 },
		["ShinR_redDeep"] = { 2.8401, -9.3532, 0.4273, 1.8722, 1.0469, 3.0546 },
		["ShinR_claw"] = { 2.8029, -9.4056, 0.4000, 2.1819, 1.0687, 5.2000 },
		["ShinR_ink"] = { 2.8400, -5.9830, 1.0000, 0.4800, 3.1659, 5.0000 },
		["ThighR_ink"] = { 4.7080, -1.5918, 2.5231, 0.7840, 0.7836, 0.9537 },
		["TailBone1_back"] = { -0.0221, -0.3051, 7.2195, 3.9814, 3.0553, 5.3880 },
		["TailBone1_belly"] = { -0.0221, -1.5991, 5.6100, 3.9814, 1.7906, 2.8584 },
		["TailBone1_bellyShade"] = { 0.0463, -2.0733, 8.1437, 3.3756, 1.6400, 2.8046 },
		["TailBone1_red"] = { -0.0596, 1.1000, 6.2065, 0.3578, 0.8064, 0.7968 },
		["TailBone1_ink"] = { 0.0000, 0.0443, 7.6615, 4.6580, 2.9177, 3.7067 },
		["TailBone1_petal"] = { -0.0545, 0.2130, 9.1504, 0.3273, 0.7377, 0.7289 },
		["TailBone1_backShade"] = { -0.0055, 0.0890, 7.5529, 3.5594, 2.2164, 4.5457 },
		["TailBone2_back"] = { -0.0186, -1.6070, 11.5901, 3.3527, 2.7467, 5.3057 },
		["TailBone2_red"] = { -0.0292, -0.9213, 11.7686, 1.0782, 1.7717, 4.9487 },
		["TailBone2_belly"] = { -0.0186, -2.6342, 10.0488, 3.3527, 1.5567, 2.8037 },
		["TailBone2_bellyShade"] = { 0.0376, -3.1039, 12.5836, 2.7391, 1.3968, 2.7492 },
		["TailBone2_ink"] = { 0.0000, -1.3250, 11.9682, 4.0856, 2.5791, 3.6018 },
		["TailBone2_petal"] = { -0.0473, -1.2984, 13.4528, 0.2841, 0.6403, 0.6326 },
		["TailBone2_backShade"] = { -0.0134, -1.3183, 11.8761, 2.9555, 2.0400, 4.4291 },
		["TailBone3_back"] = { -0.0144, -2.7303, 15.9446, 2.5984, 2.0112, 5.1550 },
		["TailBone3_belly"] = { -0.0144, -3.5689, 14.5447, 2.5984, 1.1352, 2.6598 },
		["TailBone3_bellyShade"] = { 0.0286, -3.8570, 17.0646, 2.0832, 0.9964, 2.6288 },
		["TailBone3_red"] = { -0.0439, -1.7863, 14.7152, 0.2633, 0.6200, 0.5554 },
		["TailBone3_ink"] = { 0.0000, -2.4954, 16.1839, 3.4592, 2.0382, 3.4928 },
		["TailBone3_petal"] = { -0.0401, -2.4414, 17.6763, 0.2408, 0.5672, 0.5080 },
		["TailBone3_backShade"] = { -0.0129, -2.5260, 16.1514, 2.2954, 1.5260, 4.2997 },
		["TailBone4_back"] = { -0.0107, -3.5464, 20.3228, 1.9278, 1.4973, 5.0824 },
		["TailBone4_red"] = { -0.0168, -3.1221, 20.3752, 0.6200, 1.1093, 4.9776 },
		["TailBone4_belly"] = { -0.0107, -4.1651, 18.9913, 1.9278, 0.8299, 2.5898 },
		["TailBone4_bellyShade"] = { 0.0206, -4.3718, 21.5037, 1.5046, 0.7129, 2.5706 },
		["TailBone4_ink"] = { 0.0000, -3.3660, 20.4846, 2.9048, 1.5970, 3.3959 },
		["TailBone4_petal"] = { -0.0329, -3.3405, 21.9805, 0.1976, 0.4745, 0.4040 },
		["TailBone4_backShade"] = { -0.0125, -3.4103, 20.4757, 1.7055, 1.1885, 4.1931 },
		["TailBone5_back"] = { -0.0075, -4.1467, 24.7078, 1.3411, 1.0139, 5.0327 },
		["TailBone5_belly"] = { -0.0075, -4.6016, 24.6759, 1.3411, 0.5934, 5.0483 },
		["TailBone5_bellyShade"] = { 0.0132, -4.6862, 25.9304, 0.9645, 0.4241, 2.5309 },
		["TailBone5_red"] = { -0.0281, -4.3711, 26.4796, 0.1687, 1.8579, 6.6407 },
		["TailBone5_ink"] = { 0.0000, -4.0283, 24.8096, 2.4008, 1.1724, 3.3007 },
		["TailBone5_petal"] = { -0.0257, -4.4000, 29.6775, 0.1544, 3.2000, 7.0451 },
		["TailBone5_backShade"] = { -0.0164, -4.0827, 24.8148, 1.1683, 0.8737, 4.0918 },
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
