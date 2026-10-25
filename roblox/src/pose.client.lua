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
