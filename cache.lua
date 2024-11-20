--- The `Cache` system manages key-value pairs in memory.
--- It allows for the addition, retrieval, modification, deletion, and clearing of cache entries.
---@class Cache
---@field set fun(self: Cache, key: string, value: any): void Adds or updates a cache entry.
---@field get fun(self: Cache, key: string): any Retrieves a value by its key.
---@field remove fun(self: Cache, key: string): void Removes a cache entry by its key.
---@field clear fun(self: Cache): void Clears all entries in the cache.
---@field onChange fun(self: Cache, key: string, callback: fun(oldValue: any, newValue: any)): void Adds a listener for changes to a specific key.


local Cache = {}
Cache.listeners = {}

--- Creates a new cache entry with the associated key and value.
--- This method is used internally to create CacheEntry objects.
--- @param key string The key for the cache entry.
--- @param value any The value to store in the cache.
--- @return CacheEntry A new CacheEntry object with associated methods.
function Cache.new(key, value)
    local self = {}

    self.key = key
    self.value = value

    function self:get()
        return self.value
    end

    function self:update(newValue)
        if newValue ~= self.value then
            self.value = newValue
        end
    end

    function self:delete()
        Cache[self.key] = nil
    end

    return self
end

--- Adds or updates a cache entry.
--- If the cache entry already exists, its value is updated with the new one.
--- If the entry doesn't exist, a new cache entry is created.
--- @param key string The key of the cache entry.
--- @param value any The value to store in the cache.
function Cache:set(key, value)
    if not key then
        error("Invalid key provided")
        return
    end

    local oldValue = Cache[key] and Cache[key]:get() or nil

    if Cache[key] then
        Cache[key]:update(value)
    else
        Cache[key] = Cache.new(key, value)
    end

    self:_triggerListeners(key, oldValue, value)
end

--- Returns the value associated with the provided key if it exists,
--- or `nil` if the key is not found in the cache.
--- @param key string The key of the cache entry.
--- @return any | nil The value associated with the key, or `nil` if not found.
function Cache:get(key)
    if not key then
        error("Invalid key provided")
        return
    end
    if Cache[key] then
        return Cache[key]:get()
    else
        return nil
    end
end

--- Deletes the cache entry associated with the provided key.
--- If the key does not exist, no action is taken.
--- @param key string The key of the cache entry to remove.
function Cache:remove(key)
    if not key then
        error("Invalid key provided")
        return
    end

    local oldValue = Cache[key] and Cache[key]:get() or nil

    if Cache[key] then
        Cache[key]:delete()
        Cache[key] = nil
    end

    self:_triggerListeners(key, oldValue, nil)
end

--- Clears all entries in the cache.
--- Removes all cache entries, effectively emptying the cache.
function Cache:clear()
    for key, cacheEntry in pairs(Cache) do
        if key ~= "listeners" and type(cacheEntry) == "table" and cacheEntry.delete then
            local oldValue = cacheEntry:get() or nil
            cacheEntry:delete()
            Cache[key] = nil
            self:_triggerListeners(key, oldValue, nil)
        end
    end
end

--- Adds a listener that will be called whenever a key changes.
--- @param key string The cache key to monitor.
--- @param callback fun(oldValue: any, newValue: any) The callback to call when the value changes.
function Cache:onChange(key, callback)
    if not key or type(callback) ~= "function" then
        error("You must provide a valid key and a function as the callback")
        return
    end

    if not self.listeners[key] then
        self.listeners[key] = {}
    end

    local index = #self.listeners[key] + 1
    self.listeners[key][index] = callback
end

--- Executes all the registered listeners for a key when that key changes.
--- @param key string The cache key that changed.
--- @param oldValue any The previous value of the key.
--- @param newValue any The new value of the key.
function Cache:_triggerListeners(key, oldValue, newValue)
    if self.listeners[key] then
        for i = 1, #self.listeners[key] do
            self.listeners[key][i](oldValue, newValue)
        end
    end
end

RegisterCache("Cache", Cache)


CreateThread(function()
    Cache:onChange("PlayerData", function(oldValue, newValue)
        local oldValueStr = oldValue and json.encode(oldValue, { indent = true }) or "nil"
        local newValueStr = newValue and json.encode(newValue, { indent = true }) or "nil"

        print(("OldValue: %s, NewValue: %s"):format(oldValueStr, newValueStr))
    end)


    Cache:set("PlayerData", {
        Name = "John Doe",
        Age = 30,
        Friends = { "Alice", "Bob", "Charlie" }
    })
    Wait(2000)

    Cache:set("PlayerData", {
        Name = "Jane Smith",
        Age = 30,
        Friends = { "Alice", "Bob", "Charlie" }
    })
    Wait(2000)

    Cache:set("PlayerData", {
        Name = "Jane Smith",
        Age = 35,
        Friends = { "Alice", "Bob", "Charlie" }
    })
    Wait(2000)

    Cache:set("PlayerData", {
        Name = "Jane Smith",
        Age = 35,
        Friends = { "Alice", "Bob", "Charlie", "David" }
    })
    Wait(2000)
end)
