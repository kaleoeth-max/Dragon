-- Minimal Roblox API mock, enough to run the Kirasa builder and animation offline.
local V = {}
local function vec(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, V) end
V.__index = function(t, k)
	if k == "Magnitude" then return math.sqrt(t.X ^ 2 + t.Y ^ 2 + t.Z ^ 2) end
	if k == "Unit" then local m = math.sqrt(t.X ^ 2 + t.Y ^ 2 + t.Z ^ 2); return vec(t.X / m, t.Y / m, t.Z / m) end
	return V[k]
end
V.__add = function(a, b) return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V.__sub = function(a, b) return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V.__unm = function(a) return vec(-a.X, -a.Y, -a.Z) end
V.__mul = function(a, b)
	if type(a) == "number" then return vec(a * b.X, a * b.Y, a * b.Z) end
	if type(b) == "number" then return vec(a.X * b, a.Y * b, a.Z * b) end
	return vec(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V.__div = function(a, b) return vec(a.X / b, a.Y / b, a.Z / b) end
function V.Cross(a, b) return vec(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X) end
function V.Dot(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end
Vector3 = { new = function(x, y, z) return vec(x or 0, y or 0, z or 0) end, zero = vec(0, 0, 0) }

local CF = {}
local function cf(p, m) return setmetatable({ p = p, m = m }, CF) end
local function mmul(a, b)
	local r = {}
	for i = 1, 3 do r[i] = {}; for j = 1, 3 do r[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j] end end
	return r
end
local function mvec(m, v) return vec(m[1][1] * v.X + m[1][2] * v.Y + m[1][3] * v.Z, m[2][1] * v.X + m[2][2] * v.Y + m[2][3] * v.Z, m[3][1] * v.X + m[3][2] * v.Y + m[3][3] * v.Z) end
local I = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } }
CF.__mul = function(a, b)
	if getmetatable(b) == CF then return cf(a.p + mvec(a.m, b.p), mmul(a.m, b.m)) end
	return a.p + mvec(a.m, b)
end
CF.__index = function(t, k)
	if k == "Position" then return t.p end
	if k == "LookVector" then return vec(-t.m[1][3], -t.m[2][3], -t.m[3][3]) end
	return CF[k]
end
function CF.Inverse(a)
	local mt = { {}, {}, {} }
	for i = 1, 3 do for j = 1, 3 do mt[i][j] = a.m[j][i] end end
	return cf(-mvec(mt, a.p), mt)
end
function CF.ToObjectSpace(a, b) return a:Inverse() * b end
local function cols(x, y, z) return { { x.X, y.X, z.X }, { x.Y, y.Y, z.Y }, { x.Z, y.Z, z.Z } } end
function CF.Lerp(a, b, k) return b end
function typeof(v) if type(v) == "table" and getmetatable(v) == CF then return "CFrame" end return type(v) end
CFrame = {
	new = function(x, y, z)
		if type(x) == "table" then return cf(x, I) end
		return cf(vec(x or 0, y or 0, z or 0), I)
	end,
	Angles = function(rx, ry, rz)
		local cx, sx, cy, sy, cz, sz = math.cos(rx), math.sin(rx), math.cos(ry), math.sin(ry), math.cos(rz), math.sin(rz)
		local Rx = { { 1, 0, 0 }, { 0, cx, -sx }, { 0, sx, cx } }
		local Ry = { { cy, 0, sy }, { 0, 1, 0 }, { -sy, 0, cy } }
		local Rz = { { cz, -sz, 0 }, { sz, cz, 0 }, { 0, 0, 1 } }
		return cf(vec(0, 0, 0), mmul(mmul(Rx, Ry), Rz))
	end,
	fromMatrix = function(p, x, y, z) return cf(p, cols(x, y, z or x:Cross(y))) end,
	lookAt = function(at, target)
		local back = (at - target).Unit
		local right = vec(0, 1, 0):Cross(back).Unit
		return cf(at, cols(right, back:Cross(right), back))
	end,
}
Color3 = { fromRGB = function(r, g, b) return { r, g, b } end }
Enum = setmetatable({}, { __index = function(_, k) return setmetatable({}, { __index = function(_, j) return k .. "." .. j end }) end })
RaycastParams = { new = function() return {} end }

ALL = {}
local Inst = {}
Inst.__index = function(t, k)
	if Inst[k] then return Inst[k] end
	if k == "Position" then return rawget(t, "CFrame").p end
	return rawget(t, "_children")[k]
end
function Inst:IsA(c) return self.ClassName == c end
function Inst:GetDescendants()
	local out = {}
	local function walk(n) for _, c in ipairs(n._list) do table.insert(out, c); walk(c) end end
	walk(self)
	return out
end
function Inst:FindFirstChild(n, rec)
	if not rec then return self._children[n] end
	for _, d in ipairs(self:GetDescendants()) do if d.Name == n then return d end end
end
function Inst:WaitForChild(n) return self._children[n] end
function Inst:SetAttribute(k, v)
	self._attr[k] = v
	for _, f in (self._sig[k] or {}) do f() end
end
function Inst:GetAttributeChangedSignal(k)
	local o = self
	return { Connect = function(_, f) o._sig[k] = o._sig[k] or {}; table.insert(o._sig[k], f) end }
end
function Inst:GetAttribute(k) return self._attr[k] end
function Inst:Destroy() end
Inst.__newindex = function(t, k, v)
	if k == "Parent" then
		table.insert(v._list, t); v._children[t.Name] = t
	end
	rawset(t, k, v)
end
local function newInst(class)
	local o = setmetatable({ ClassName = class, Name = class, _children = {}, _list = {}, _attr = {}, _sig = {} }, Inst)
	table.insert(ALL, o)
	return o
end
Instance = { new = newInst }
workspace = newInst("Workspace")
workspace.CurrentCamera = { CFrame = CFrame.lookAt(vec(0, 12, -40), vec(0, 5, 0)) }
function workspace:Raycast() return nil end
HB, RS = {}, {}
SIMT = 0
os = setmetatable({ clock = function() return SIMT end }, { __index = os })
function STEP(dt)
	SIMT += dt
	for _, f in HB do f(dt) end
	for _, f in RS do f(dt) end
end
game = { GetService = function(_, n)
	if n == "RunService" then return { Heartbeat = { Connect = function(_, f) table.insert(HB, f) end }, RenderStepped = { Connect = function(_, f) table.insert(RS, f) end } } end
	return { Set = function() end }
end }
