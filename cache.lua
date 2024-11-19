--- The `Cache` system manages key-value pairs in memory.
--- It allows for the addition, retrieval, modification, deletion, and clearing of cache entries.
---@class Cache
---@field set fun(self: Cache, key: string, value: any): void Adds or updates a cache entry.
---@field get fun(self: Cache, key: string): any Retrieves a value by its key.
---@field remove fun(self: Cache, key: string): void Removes a cache entry by its key.
---@field clear fun(self: Cache): void Clears all entries in the cache.

local Cache = {}

RegisterCache("Cache", Cache)

--- Creates a new cache entry with the associated key and value.
--- This method is used internally to create CacheEntry objects.
--- @param key string The key for the cache entry.
--- @param value any The value to store in the cache.
--- @return value CacheEntry A new CacheEntry object with associated methods.
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

    TriggerEvent('LGF_Cache:cache', oldValue, value, key)

    if Cache[key] then
        Cache[key]:update(value)
    else
        Cache[key] = Cache.new(key, value)
    end
end

--- Returns the value associated with the provided key if it exists,
--- or `nil` if the key is not found in the cache.
--- @param key string The key of the cache entry.
--- @return value | nil any The value associated with the key, or `nil` if not found.
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
    if Cache[key] then
        Cache[key]:delete()
        Cache[key] = nil
    end
end

--- Clears all entries in the cache.
--- Removes all cache entries, effectively emptying the cache.
function Cache:clear()
    for key in pairs(Cache) do
        Cache[key] = nil
    end
end

