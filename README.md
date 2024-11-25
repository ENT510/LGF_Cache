# Cache System Documentation

This Lua-based cache system allows for efficient data storage and retrieval with built-in change tracking. You can add, update, remove, and listen to changes on specific cache keys.

## Features

- **Add/Update Cache Entries**: Store values associated with specific keys.
- **Retrieve Cache Values**: Retrieve the value associated with a key.
- **Remove Cache Entries**: Remove specific cache entries.
- **Clear All Cache**: Clear all cache entries at once.
- **Change Listeners**: Listen for changes to specific cache keys, including set, update, or remove actions.

## Using the Cache System in Your Project

To use the cache system, import the cache manager via the exports mechanism. This allows you to load specific modules for managing cache or handling events.

```lua
exports.LGF_Cache:cacheManager(module)
```

## Example Module Imports

### Default Cache Module:

This module provides the basic cache management API.

```lua
---@param moduleName any
local Cache = exports.LGF_Cache:cacheManager("Cache")
print(json.encode(Cache,{indent = true}))
```

# Cache Handler

Use this for tracking in-game events like weapons, mounts, and vehicles.

```lua
---@param moduleName any
local CacheHandler = exports.LGF_Cache:cacheManager("CacheHandler")
print(json.encode(CacheHandler,{indent = true}))
```

#### Example Cache Handler

- Weapon

```lua
CacheHandler:onCacheChange("Weapon", function(currentWeaponHash, isArmed, ped)
    print(("Ped ID: %s | Weapon Hash: %s | Is Armed: %s"):format( ped, currentWeaponHash ,tostring(isArmed)))
end)
```

- Mount (only RedM)

```lua
CacheHandler:onCacheChange("Mount", function(currentMountId, isOnMount, ped)
    print(("Ped ID: %s | Mount ID: %s | Is On Mount: %s"):format( ped, currentMountId, tostring(isOnMount)))
end)
```

- Vehicle

```lua
CacheHandler:onCacheChange("Vehicle", function(vehicleId, seat, ped)
    print(("Ped ID: %s | Vehicle ID: %s | Seat: %s"):format(ped,vehicleId, seat))
end)
```

#### Cache Handler Supported Types

The CacheHandler module provides tracking for specific in-game states. Pass the type to CacheHandler:onCacheChange to track updates.

Supported Types:

- `Weapon`: Tracks changes to the player's equipped weapon and whether the player is armed.
- `Mount` (For RedM): Tracks the player's mount and whether the player is on a mount.
- `Vehicle`: Tracks the player's vehicle and seat position.

# Cache Class

The `Cache` class provides methods for managing in-memory cache entries. It uses a key-value storage mechanism where keys are strings, and the values can be any Lua datatype.

### Cache Methods:

- **`Cache:set`**
  Adds or updates a cache entry. If the cache entry already exists, its value is updated. It triggers the change event for the key if applicable.

```lua
---@param key string
---@param value any
Cache:set(key, value)
```

- **`Cache:get`**  
  Retrieves the value of a cache entry by its key. Returns `nil` if the key doesn't exist in the cache.

```lua
---@param key string
---@return any
Cache:get(key)
```

- **`Cache:remove`**  
  Removes a cache entry. If a listener is registered for this key, it triggers a removal event.

```lua
---@param key string
Cache:remove(key)

```

- **`Cache:clear`**  
  Clears all cache entries and triggers removal events for each one.

```lua
Cache:clear()
```

- **`Cache:onChangeValue`**  
  Adds a listener that is called whenever the value associated with the specified key is changed (added, updated, or removed). The listener receives the action type (`"set"`, `"remove"`) and the old and new values.

```lua
---@param key string
---@param func fun(action: string, oldValue: any, newValue: any)
Cache:onChangeValue(key, function(action, oldValue, newValue))
```

## Usage

### Creating and Using Cache Entries

Before interacting with cache entries, you need to call `Cache:set()` to add or update a key-value pair in the cache.

#### Example:

```lua
-- Setting a cache entry
Cache:set("username", "ENT510")

-- Getting a cache entry
local username = Cache:get("username")
print(username)  -- Output: ENT510
```

### Creating and Using Cache Entries

You can create and use cache entries by calling `Cache:set()` to store data and `Cache:get()` to retrieve it.

#### Example:

```lua
-- Creating a new cache entry with key "playerHealt" and value 100
Cache:set("playerHealt", 100)

-- Retrieving the cache entry
local PlayerHealt = Cache:get("playerHealt")
print(PlayerHealt)  -- Output: 100

--You can also update existing cache entries by calling Cache:set() again with a new value.

-- Updating an existing cache entry
Cache:set("playerHealt", 200)

-- Retrieving the updated cache entry
local updatedHealt = Cache:get("playerHealt")
print(updatedHealt)  -- Output: 200
```

### Listening for Changes on Cache Keys

You can register a listener to monitor changes to specific cache keys. The listener will be triggered whenever the value of the cache entry is set, updated, or removed.

#### Example:

```lua
-- Register a listener for changes on the "playerHealt" cache entry
Cache:onChangeValue("playerHealt", function(action, oldValue, newValue)
    print("Action: " .. action)  -- Output: "set", "remove", or "update"
    print("Old Value: " .. tostring(oldValue))  -- Output the old value
    print("New Value: " .. tostring(newValue))  -- Output the new value
end)

-- Setting a new value for "playerHealt", which will trigger the listener
Cache:set("playerHealt", 150)

-- Output:
-- Action: set
-- Old Value: nil
-- New Value: 150

-- Updating the value of "playerHealt", which will also trigger the listener
Cache:set("playerHealt", 200)

-- Output:
-- Action: set
-- Old Value: 150
-- New Value: 200
```

### Removing Cache Entries

You can remove cache entries using the Cache:remove() method. This will delete the specified entry and trigger a removal event if there is a listener registered for that key.

#### Example:

```lua
-- Remove a cache entry
Cache:remove("playerHealt")

-- Trying to get the removed entry will return nil
local removedScore = Cache:get("playerHealt")
print(removedScore)  -- Output: nil
```

### Clearing All Cache Entries

To clear all the cache entries, use the Cache:clear() method. This will remove all cache entries and trigger removal events for each entry.

#### Example:

```lua
CreateThread(function()
    Wait(2000)
    Cache:set("playerHealt", 100)
    Cache:set("username", "ENT510")


    local scoreBeforeClear = Cache:get("playerHealt")
    local usernameBeforeClear = Cache:get("username")

    print(scoreBeforeClear)    -- Output: 100
    print(usernameBeforeClear) -- Output: ENT510

    Wait(1000)

    Cache:clear()


    local scoreAfterClear = Cache:get("playerHealt")
    local usernameAfterClear = Cache:get("username")

    print(scoreAfterClear)    -- Output: nil
    print(usernameAfterClear) -- Output: nil
end)

```
