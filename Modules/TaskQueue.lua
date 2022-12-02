---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local GetTimePreciseSec = GetTimePreciseSec

local addon = AceAddon:GetAddon("GlobalSearch")
---@class TaskQueueModule : AceModule, ModulePrototype, AceEvent-3.0
local module = addon:NewModule("TaskQueue", "AceEvent-3.0")
---@type thread[]
module.taskQueue = {}
module.timeLimitPerFrame = 0.01

function module:OnInitialize()
	self:RegisterMessage("GlobalSearch_QueueTask", "OnQueueTask")
end

---@param _ any
---@param task thread
function module:OnQueueTask(_, task)
	self.taskQueue[#self.taskQueue + 1] = task
	self:Trigger()
end

function module:Trigger()
	if not self.ticker then
		self.ticker = C_Timer.NewTicker(0, function()
			self:Run()
		end)
	end
end

function module:Run()
	local time = GetTimePreciseSec()
	repeat
		self:RunIteration()
	until self.ticker == nil or (GetTimePreciseSec() - time) > self.timeLimitPerFrame -- Time limit per frame
end

function module:RunIteration()
	local unfinished = coroutine.resume(self.taskQueue[1])
	if not unfinished then
		table.remove(self.taskQueue, 1)
		if #self.taskQueue == 0 then
			self.ticker:Cancel()
			self.ticker = nil
		end
	end
end
