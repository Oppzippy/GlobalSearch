---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestTask = {}

function TestTask:TestPollToCompletion()
	local task = ns.Task.Create(coroutine.create(function()
		for i = 1, 4 do
			coroutine.yield()
		end
		return 5
	end))

	luaunit.assertEquals(task:PollToCompletion(), 5)
end

function TestTask:TestChaining()
	local task = ns.Task.Create(coroutine.create(function()
		coroutine.yield()
		return 1
	end)):Then(ns.Task.Create(coroutine.create(function(num)
		return num + 1
	end)))

	task:PollToCompletion()

	luaunit.assertEquals(task:Results(), 2)
end

function TestTask:TestPollToCompletionAsync()
	local task = ns.Task.Create(coroutine.create(function()
		coroutine.yield()
		local task = ns.Task.Create(coroutine.create(function()
			return 1
		end))
		return task:PollToCompletionAsync()
	end)):Then(ns.Task.Create(coroutine.create(function(num)
		return num + 2
	end))):Then(ns.Task.Create(coroutine.create(function(num)
		return num * 3
	end)))

	luaunit.assertEquals(task:PollToCompletion(), 9)
end

function TestTask:TestNumberOfPolls()
	local task = ns.Task.Create(coroutine.create(function()
		for i = 1, 4 do
			coroutine.yield()
		end
		return 1
	end)):Then(ns.Task.Create(coroutine.create(function(num)
		ns.Task.Create(coroutine.create(function()
			for i = 5, 6 do
				coroutine.yield()
			end
		end)):PollToCompletionAsync()
	end))):Then(ns.Task.Create(coroutine.create(function(num)
		coroutine.yield() -- 7
	end)))

	local i = 0
	while task:Poll() do
		i = i + 1
	end

	luaunit.assertEquals(i, 7)
end
