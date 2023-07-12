---@class SearchItem
---@field id? any
---@field providerID? string
---@field name string
---@field category string
---@field texture number|string|fun(texture: Texture)
---@field extraSearchText? string
---@field action? function
---@field macroText? string
---@field pickup? function
---@field tooltip? fun(limitedTooltip: GameTooltip) | string
---@field hyperlink? string|fun(): string
