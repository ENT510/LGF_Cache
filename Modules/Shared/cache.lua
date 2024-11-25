---@class Cache
---@field set fun(self: Cache, key: string, value: any): void Adds or updates a cache entry.
---@field get fun(self: Cache, key: string): any Retrieves a value by its key.
---@field remove fun(self: Cache, key: string): void Removes a cache entry by its key.
---@field clear fun(self: Cache): void Clears all entries in the cache.
---@field onChangeValue fun(self: Cache, key: string, callback: fun(action: string, oldValue: any, newValue: any)): void Adds a listener for a specific key.

local Cache = {}
local cacheStore = {}
local listeners = {}

---@class CacheEntry
---@field key string The key for the cache entry.
---@field value any The value stored in the cache entry.
local CacheEntry = {}

--- Creates a new cache entry with the associated key and value.
--- @param key string The key for the cache entry.
--- @param value any The value to store in the cache.
--- @return CacheEntry A new CacheEntry object with associated methods.
function Cache.new(key, value)
    if type(key) ~= "string" or key == "" then
        error("Invalid key provided: key must be a non-empty string.")
    end

    local self = {}
    self.key = key
    self.value = value

    --- Gets the value of the cache entry.
    --- @return any The value of the cache entry.
    function self:get()
        return self.value
    end

    --- Updates the value of the cache entry.
    --- @param newValue any The new value to store in the cache.
    function self:update(newValue)
        if newValue ~= self.value then
            self.value = newValue
        end
    end

    --- Deletes the cache entry.
    function self:delete()
        cacheStore[self.key] = nil
    end

    return self
end

--- Adds or updates a cache entry.
--- Triggers change events if applicable.
--- @param key string The key of the cache entry.
--- @param value any The value to store in the cache.
function Cache:set(key, value)
    if type(key) ~= "string" or key == "" then
        error("Invalid key provided: key must be a non-empty string.")
    end

    local oldValue = cacheStore[key] and cacheStore[key]:get() or nil

    if cacheStore[key] then
        cacheStore[key]:update(value)
    else
        cacheStore[key] = Cache.new(key, value)
    end

    -- Trigger the listener if it exists.
    if listeners[key] then
        listeners[key]("set", oldValue, value)
    end
end

--- Gets the value for a key from the cache.
--- @param key string The key to retrieve.
--- @return any The value associated with the key, or `nil` if not found.
function Cache:get(key)
    if type(key) ~= "string" or key == "" then
        error("Invalid key provided: key must be a non-empty string.")
    end

    return cacheStore[key] and cacheStore[key]:get() or nil
end

--- Removes a cache entry and triggers events.
--- @param key string The key to remove.
function Cache:remove(key)
    if type(key) ~= "string" or key == "" then
        error("Invalid key provided: key must be a non-empty string.")
    end

    local oldValue = cacheStore[key] and cacheStore[key]:get() or nil

    if cacheStore[key] then
        cacheStore[key]:delete()
    end


    if listeners[key] then
        listeners[key]("remove", oldValue, nil)
    end
end

--- Clears all cache entries.
--- Triggers removal events for each entry.
function Cache:clear()
    for key in pairs(cacheStore) do
        self:remove(key)
    end
end

--- Adds a listener for changes to a specific key.
--- @param key string The key to listen for changes on.
--- @param callback fun(action: string, oldValue: any, newValue: any) The function to call when the key changes.
function Cache:onChangeValue(key, callback)
    if type(key) ~= "string" or key == "" then
        error("Invalid key provided: key must be a non-empty string.")
    end

    listeners[key] = callback
end

RegisterCache("Cache", Cache)
