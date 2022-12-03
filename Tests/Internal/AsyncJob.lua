---@type ns
local ns = select(2, ...)
local luaunit = require("luaunit")

TestAsyncJob = {}

function TestAsyncJob:TestPollToCompletion()
	local job = ns.AsyncJob.Create(coroutine.create(function()
		for i = 1, 4 do
			coroutine.yield()
		end
		return 5
	end))

	luaunit.assertEquals(job:PollToCompletion(), 5)
end

function TestAsyncJob:TestChaining()
	local job = ns.AsyncJob.Create(coroutine.create(function()
		coroutine.yield()
		return 1
	end)):Then(ns.AsyncJob.Create(coroutine.create(function(num)
		return num + 1
	end)))

	job:PollToCompletion()

	luaunit.assertEquals(job:Results(), 2)
end

function TestAsyncJob:TestPollToCompletionAsync()
	local job = ns.AsyncJob.Create(coroutine.create(function()
		coroutine.yield()
		local job = ns.AsyncJob.Create(coroutine.create(function()
			return 1
		end))
		return job:PollToCompletionAsync()
	end)):Then(ns.AsyncJob.Create(coroutine.create(function(num)
		return num + 2
	end))):Then(ns.AsyncJob.Create(coroutine.create(function(num)
		return num * 3
	end)))

	luaunit.assertEquals(job:PollToCompletion(), 9)
end

function TestAsyncJob:TestNumberOfPolls()
	local job = ns.AsyncJob.Create(coroutine.create(function()
		for i = 1, 4 do
			coroutine.yield()
		end
		return 1
	end)):Then(ns.AsyncJob.Create(coroutine.create(function(num)
		ns.AsyncJob.Create(coroutine.create(function()
			for i = 5, 6 do
				coroutine.yield()
			end
		end)):PollToCompletionAsync()
	end))):Then(ns.AsyncJob.Create(coroutine.create(function(num)
		coroutine.yield() -- 7
	end)))

	local i = 0
	while job:Poll() do
		i = i + 1
	end

	luaunit.assertEquals(i, 7)
end
