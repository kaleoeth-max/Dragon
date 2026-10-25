-- Kirasa : animations (repos, marche, vol) et promenade automatique.
-- Attributs du modèle :
--   AutoWander (bool)  : le dragon se promène tout seul autour de son point de départ
--   Mode (string)      : "Idle", "Walk" ou "Fly", utilisé quand AutoWander est désactivé
--   WalkSpeed, FlySpeed, WanderRadius, FlyHeight : réglages de la promenade

local RunService = game:GetService("RunService")

local model = script.Parent
local root = model:WaitForChild("Root")
local S = model:GetAttribute("Scale") or 1
local LEG = 5 * S -- hauteur du centre du corps au-dessus du sol

local joints = {}
for _, d in model:GetDescendants() do
	if d:IsA("Motor6D") then
		joints[d.Name] = { motor = d, base = d.C0 }
	end
end

local lids = {}
for _, d in model:GetDescendants() do
	if d.Name == "LidL" or d.Name == "LidR" then
		table.insert(lids, d)
	end
end

local function setJoint(name, cf)
	local j = joints[name]
	if j then
		j.motor.C0 = j.base * cf
	end
end

-- Pose cible de chaque animation, en fonction du temps
local function targets(mode, t)
	local cycle = t % 4.3
	local flick = cycle < 0.3 and math.sin(cycle / 0.3 * math.pi) * 0.35 or 0

	if mode == "Walk" then
		local ph = t * 6
		local s, c = math.sin(ph), math.cos(ph)
		return {
			bob = (math.abs(s) - 0.5) * 0.3 * S, pitch = -0.06, roll = s * 0.06, flyH = 0,
			neck = -0.08 + math.sin(ph * 2) * 0.04, head = 0.08, headYaw = 0, flick = flick * 0.5,
			wingRaise = 0.1 + math.sin(ph * 2) * 0.04, wingFold = 1.1, elbow = 0.5, elbowFlap = 0, wingTwist = -0.3,
			hipL = s * 0.55, hipR = -s * 0.55,
			kneeL = -math.max(0, c) * 0.9, kneeR = -math.max(0, -c) * 0.9,
			tail = math.sin(ph - 0.6) * 0.22, tail2 = math.sin(ph - 1.2) * 0.3, tail3 = math.sin(ph - 1.8) * 0.4,
			tailLift = 0,
		}
	elseif mode == "Fly" then
		local ph = t * 4.5
		local f = math.sin(ph)
		return {
			bob = -f * 0.1 * S, pitch = -0.12, roll = math.sin(t * 0.7) * 0.05,
			flyH = (model:GetAttribute("FlyHeight") or 8) * S + math.sin(ph - 1.2) * 0.6 * S,
			neck = 0.12, head = 0.05, headYaw = 0, flick = 0.15 + f * 0.1,
			wingRaise = 0.15 + f * 0.8, wingFold = 0.1, elbow = 0.1, elbowFlap = math.sin(ph - 0.9) * 0.35, wingTwist = -1.4,
			hipL = -0.9, hipR = -0.9, kneeL = 0.7, kneeR = 0.7,
			tail = math.sin(ph * 0.5) * 0.12, tail2 = math.sin(ph * 0.5 - 0.6) * 0.18, tail3 = math.sin(ph * 0.5 - 1.2) * 0.25,
			tailLift = 0.1 + f * 0.05,
		}
	end

	local br = math.sin(t * 1.8)
	return {
		bob = br * 0.08 * S, pitch = 0, roll = 0, flyH = 0,
		neck = math.sin(t * 0.6) * 0.08, head = br * 0.03, headYaw = math.sin(t * 0.45) * 0.25, flick = flick,
		wingRaise = 0.25 + math.sin(t * 1.1) * 0.06, wingFold = 0.2, elbow = 0.25, elbowFlap = 0, wingTwist = 0,
		hipL = 0, hipR = 0, kneeL = 0, kneeR = 0,
		tail = math.sin(t * 0.9) * 0.15, tail2 = math.sin(t * 0.9 - 0.7) * 0.22, tail3 = math.sin(t * 0.9 - 1.4) * 0.3,
		tailLift = 0,
	}
end

local function applyPose(p, t)
	setJoint("BodyJoint", CFrame.new(0, p.bob, 0) * CFrame.Angles(p.pitch, 0, p.roll))
	setJoint("NeckJoint", CFrame.Angles(p.neck, 0, 0))
	setJoint("HeadJoint", CFrame.Angles(p.head, p.headYaw, 0))
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
	setJoint("Tail1", CFrame.Angles(p.tailLift, p.tail, 0))
	setJoint("Tail2", CFrame.Angles(p.tailLift, p.tail2, 0))
	setJoint("Tail3", CFrame.Angles(p.tailLift, p.tail3, 0))

	local blinking = (t % 3.7) < 0.14
	for _, lid in lids do
		lid.Transparency = blinking and 0 or 1
	end
end

-- Déplacement
local home = root.Position
local pos = root.Position
local look = root.CFrame.LookVector
local yaw = math.atan2(-look.X, -look.Z)
local height = pos.Y

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { model }

local function groundAt(p)
	local hit = workspace:Raycast(Vector3.new(p.X, p.Y + 50, p.Z), Vector3.new(0, -500, 0), rayParams)
	return hit and hit.Position.Y or (home.Y - LEG)
end

local function pickTarget(radius)
	local a = math.random() * math.pi * 2
	local r = radius * (0.3 + 0.7 * math.random())
	return home + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
end

local state = { mode = "Idle", timer = 3, target = nil }
local t = 0
local pose = targets("Idle", 0)

RunService.Heartbeat:Connect(function(dt)
	t += dt
	local mode

	if model:GetAttribute("AutoWander") then
		state.timer -= dt
		if state.mode == "Idle" then
			if state.timer <= 0 then
				local fly = math.random() < 0.3
				state.mode = fly and "Fly" or "Walk"
				state.target = pickTarget(model:GetAttribute("WanderRadius") or 40)
			end
		else
			local flat = Vector3.new(state.target.X - pos.X, 0, state.target.Z - pos.Z)
			if flat.Magnitude < 1.5 then
				state.mode = "Idle"
				state.timer = 3 + math.random() * 4
				state.target = nil
			else
				-- tourner vers la cible
				local want = math.atan2(-flat.X, -flat.Z)
				local diff = (want - yaw + math.pi) % (math.pi * 2) - math.pi
				local turn = 2.5 * dt
				yaw += math.clamp(diff, -turn, turn)

				-- avancer quand il regarde à peu près dans la bonne direction
				local forward = Vector3.new(-math.sin(yaw), 0, -math.cos(yaw))
				local facing = math.max(0, forward:Dot(flat.Unit))
				local speed
				if state.mode == "Fly" then
					local takeoff = math.clamp(pose.flyH / ((model:GetAttribute("FlyHeight") or 8) * S), 0, 1)
					speed = (model:GetAttribute("FlySpeed") or 18) * takeoff
				else
					speed = model:GetAttribute("WalkSpeed") or 8
				end
				pos += forward * math.min(speed * facing * dt, flat.Magnitude)
			end
		end
		mode = state.mode
	else
		mode = model:GetAttribute("Mode") or "Idle"
	end

	-- transition douce vers la pose cible
	local target = targets(mode, t)
	local k = 1 - 0.0015 ^ dt
	for key, value in target do
		pose[key] += (value - pose[key]) * k
	end
	applyPose(pose, t)

	local wantY = groundAt(pos) + LEG + pose.flyH
	height += (wantY - height) * math.min(1, dt * 8)
	root.CFrame = CFrame.new(pos.X, height, pos.Z) * CFrame.Angles(0, yaw, 0)
end)
