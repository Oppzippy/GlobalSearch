---@class ns
local ns = select(2, ...)

---@class WaitGroup
---@field count number
---@field subscribers table<number, fun()>
---@field lastID number
local WaitGroupPrototype = {}

function CreateWaitGroup()
	return setmetatable({
		count = 0,
		subscribers = {},
		lastID = 0,
	}, { __index = WaitGroupPrototype })
end

function WaitGroupPrototype:Add()
	self.count = self.count + 1
end

function WaitGroupPrototype:Done()
	self.count = self.count - 1
	if self.count == 0 then
		for _, subscriber in next, self.subscribers do
			subscriber()
		end
		self.subscribers = {}
	elseif self.count < 0 then
		error("wait group count is less than 0")
	end
end

---@param func fun()
function WaitGroupPrototype:Subscribe(func)
	if self.count == 0 then
		func()
	else
		self.subscribers[#self.subscribers + 1] = func
	end
end

local export = {
	Create = CreateWaitGroup,
}
if ns then
	ns.WaitGroup = export
end
return export
