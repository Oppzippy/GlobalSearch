---@class ns
local ns = select(2, ...)

---@class AsyncJob
local AsyncJobPrototype = {}
local metatable = { __index = AsyncJobPrototype }

---@param co thread
---@return AsyncJob
local function Create(co)
	---@class AsyncJob
	---@field results unknown[]?
	local job = setmetatable({
		coroutine = co,
		isStarted = false,
		args = {},
	}, metatable)
	return job
end

---@param job AsyncJob
function AsyncJobPrototype:Then(job)
	return Create(coroutine.create(function()
		while self:Poll() do coroutine.yield() end
		job:SetArgs(self.results)
		while job:Poll() do coroutine.yield() end
		return job:Results()
	end))
end

function AsyncJobPrototype:Poll()
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

function AsyncJobPrototype:PollToCompletion()
	while self:Poll() do end
	return self:Results()
end

function AsyncJobPrototype:PollToCompletionAsync()
	while self:Poll() do coroutine.yield() end
	return self:Results()
end

---@return any[]?
function AsyncJobPrototype:Results()
	if self.results then
		return unpack(self.results)
	end
	error("can't get results before job completion")
end

---@param args any[]
function AsyncJobPrototype:SetArgs(args)
	if self.isStarted then
		error("can't set args after an AsyncJob is already started")
	end
	self.args = args
end

ns.AsyncJob = { Create = Create }
