---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local GetTimePreciseSec = GetTimePreciseSec

local addon = AceAddon:GetAddon("GlobalSearch")
---@class TaskQueueModule : AceModule, ModulePrototype, AceEvent-3.0
local module = addon:NewModule("TaskQueue", "AceEvent-3.0", "AceConsole-3.0")

---@class QueuedTask
---@field task Task
---@field name string
---@field queuedAt number
---@field startedAt number
---@field longestPoll number
---@field pollCount number
---@field totalTimeSpent number

---@type QueuedTask[]
module.taskQueue = {}
module.timeLimitPerFrameInSeconds = 0.005
module.blockers = {}

function module:OnInitialize()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterMessage("GlobalSearch_QueueTask", "OnQueueTask")
	self:RegisterMessage("GlobalSearch_RunTaskToCompletion", "OnRunTaskToCompletion")
end

function module:PLAYER_REGEN_DISABLED()
	self.blockers.combat = true
	self:CheckBlockers()
end

function module:PLAYER_REGEN_ENABLED()
	self.blockers.combat = nil
	self:CheckBlockers()
end

function module:PLAYER_ENTERING_WORLD()
	self.blockers.instance = IsInInstance() and true or nil
	self:CheckBlockers()
end

function module:CheckBlockers()
	if self:IsDebugMode() then
		local blockerNames = {}
		for blocker in pairs(self.blockers) do
			blockerNames[#blockerNames + 1] = blocker
		end
		self:Debugf("Blockers: %s", table.concat(blockerNames, ", "))
	end
	if next(self.blockers) then
		self:Pause()
	else
		self:Resume()
	end
end

function module:Pause()
	self:Debugf("Paused.")
	self.isPaused = true
	if self.ticker then
		self.ticker:Cancel()
		self.ticker = nil
	end
end

function module:Resume()
	self.isPaused = false
	self:StartTickerIfNotRunning()
end

---@param _ any
---@param taskName string
function module:OnRunTaskToCompletion(_, taskName)
	local newTaskQueue = {}
	for _, task in ipairs(self.taskQueue) do
		if task.name == taskName then
			task.task:PollToCompletion()
			self:Debugf("RunTaskToCompletion called for %s", taskName)
		else
			newTaskQueue[#newTaskQueue + 1] = task
		end
	end
	self.taskQueue = newTaskQueue
end

---@param _ any
---@param task Task
---@param name string
function module:OnQueueTask(_, task, name)
	assert(type(task) == "table")
	assert(type(name) == "string")
	self.taskQueue[#self.taskQueue + 1] = { task = task, name = name, queuedAt = GetTimePreciseSec(), longestPoll = 0,
		pollCount = 0, totalTimeSpent = 0 }
	self:StartTickerIfNotRunning()
end

function module:StartTickerIfNotRunning()
	if not self.ticker and not self.isPaused and #self.taskQueue >= 1 then
		self:Debugf("Ticker is not running, starting it.")
		self.ticker = C_Timer.NewTicker(0, function()
			self:Run()
		end)
	end
end

function module:Run()
	local timeLimit = self:GetDB().profile.options.taskQueueTimeAllocationInMilliseconds / 1000
	local startTime = GetTimePreciseSec()
	local timeAfterPoll = startTime
	repeat
		local currentTask = self.taskQueue[1]
		if not currentTask then
			self:Debugf("The queue is empty. Stopping ticker.")
			self.ticker:Cancel()
			self.ticker = nil
			break
		end
		local timeBeforePoll = GetTimePreciseSec()

		if not currentTask.startedAt then
			currentTask.startedAt = timeBeforePoll
			self:Debugf(
				"Starting task %s. It was queued %d seconds ago.",
				currentTask.name,
				currentTask.startedAt - currentTask.queuedAt
			)
		end

		local isUnfinished = currentTask.task:Poll()
		timeAfterPoll = GetTimePreciseSec()

		currentTask.pollCount = currentTask.pollCount + 1
		local pollDuration = timeAfterPoll - timeBeforePoll
		currentTask.totalTimeSpent = currentTask.totalTimeSpent + pollDuration
		if currentTask.longestPoll < pollDuration then
			currentTask.longestPoll = pollDuration
		end

		if not isUnfinished then
			self:Debugf(
				"Finished task %s after %f seconds. It was polled a total of %d times. The average poll duration was %f seconds, and the longest was %f seconds."
				,
				currentTask.name,
				timeAfterPoll - currentTask.startedAt,
				currentTask.pollCount,
				currentTask.totalTimeSpent / currentTask.pollCount,
				currentTask.longestPoll
			)
			table.remove(self.taskQueue, 1)
		end
	until self.ticker == nil or (timeAfterPoll - startTime) > timeLimit -- Time limit per frame
end
