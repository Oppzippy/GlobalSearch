---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local GetTimePreciseSec = GetTimePreciseSec

local addon = AceAddon:GetAddon("GlobalSearch")
---@class TaskQueueModule : AceModule, ModulePrototype, AceEvent-3.0
local module = addon:NewModule("TaskQueue", "AceEvent-3.0")
---@type Task[]
module.taskQueue = {}
module.timeLimitPerFrameInSeconds = 0.005

function module:OnInitialize()
	self:RegisterMessage("GlobalSearch_QueueTask", "OnQueueTask")
end

---@param _ any
---@param task Task
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
	local timeLimit = self:GetDB().profile.options.taskQueueTimeAllocationInMilliseconds / 1000
	local time = GetTimePreciseSec()
	repeat
		local unfinished = self.taskQueue[1]:Poll()
		if not unfinished then
			table.remove(self.taskQueue, 1)
			if #self.taskQueue == 0 then
				self.ticker:Cancel()
				self.ticker = nil
			end
		end
	until self.ticker == nil or (GetTimePreciseSec() - time) > timeLimit -- Time limit per frame
end
