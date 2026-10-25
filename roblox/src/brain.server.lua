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
