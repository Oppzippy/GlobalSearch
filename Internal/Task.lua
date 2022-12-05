---@class ns
local ns = select(2, ...)

---@class Task
local TaskPrototype = {}
local metatable = { __index = TaskPrototype }

---@param co thread
---@return Task
local function Create(co)
	---@class Task
	---@field results unknown[]?
	local task = setmetatable({
		coroutine = co,
		isStarted = false,
		args = {},
	}, metatable)
	return task
end

---@param task Task
function TaskPrototype:Then(task)
	return Create(coroutine.create(function()
		while self:Poll() do coroutine.yield() end
		task:SetArgs(self.results)
		while task:Poll() do coroutine.yield() end
		return task:Results()
	end))
end

function TaskPrototype:Poll()
	if coroutine.status(self.coroutine) == "dead" then return false end

	local returns
	if self.isStarted then
		returns = { coroutine.resume(self.coroutine) }
	else
		returns = { coroutine.resume(self.coroutine, unpack(self.args)) }
	end
	self.isStarted = true
	if not returns[1] then
		error(returns[2])
	end

	if coroutine.status(self.coroutine) == "dead" then
		local theRest = {}
		for i = 2, #returns do
			theRest[#theRest + 1] = returns[i]
		end
		self.results = theRest
		return false
	end
	return true
end

function TaskPrototype:PollToCompletion()
	while self:Poll() do end
	return self:Results()
end

function TaskPrototype:PollToCompletionAsync()
	while self:Poll() do coroutine.yield() end
	return self:Results()
end

---@return ...
function TaskPrototype:Results()
	if self.results then
		return unpack(self.results)
	end
	error("can't get results before task completion")
end

---@param args any[]
function TaskPrototype:SetArgs(args)
	if self.isStarted then
		error("can't set args after a task is already started")
	end
	self.args = args
end

ns.Task = { Create = Create }
