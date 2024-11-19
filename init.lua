---@meta

---@class CacheEnvironment
---@field [string] table

CacheEnvironment = {}

--- Registers a cache module with a given name.
---@param name string The name of the cache module to register.
---@param module table The cache module to register.
function RegisterCache(name, module)
    if not name or not module then
        error("Invalid name or module for cache registration")
        return
    end

    if CacheEnvironment[name] then
        print(("[CacheEnvironment] Warning: Module '%s' is already registered!"):format(name))
        return
    end

    CacheEnvironment[name] = module --[[@as CacheEnvironment]]
end

--- Retrieves a cache module from the CacheEnvironment by its name.
---@param name string The name of the cache module to retrieve.
---@return table|nil The cache module if found, or nil if not found.
function getCache(name)
    return CacheEnvironment[name]
end

exports('cacheManager', function()
    return CacheEnvironment
end)

