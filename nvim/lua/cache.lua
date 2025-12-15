local M = {}
M.__index = M

function M.new(default_ttl)
  local self = setmetatable({}, M)
  self.data = {}
  self.default_ttl = default_ttl or 300 -- 5 minutes default
  return self
end

function M:set(key, value, ttl)
  local expiration = os.time() + (ttl or self.default_ttl)
  self.data[key] = { value = value, expiration = expiration }
end

function M:get(key)
  local entry = self.data[key]
  if entry and os.time() < entry.expiration then
    return entry.value
  end
  if entry then
    -- Clean up expired entry
    self.data[key] = nil
  end
  return nil
end

function M:invalidate(key)
  if key then
    self.data[key] = nil
  else
    self.data = {}
  end
end

--- Wraps a function with caching logic.
--- The wrapped function will first check the cache for a result.
--- If found, it returns the cached result.
--- If not found, it executes the original function, caches its result, and then returns it.
--- @param self The Cache object.
--- @param key The cache key to use.
--- @param fn function The function to wrap.
--- @return function The wrapped function.
function M:wrap(key, fn, ttl)
  local self = self
  return function(...)
    local cached_value = self:get(key)
    if cached_value then
      return cached_value
    end

    local result = fn(...)
    self:set(key, result, ttl)
    return result
  end
end

--- Wraps an async function with caching and state management.
--- @param self The Cache object.
--- @param key The cache key to use.
--- @param fn function An async function that takes a callback `done(result)`.
--- @return function A function that returns the cached value or a loading state.
function M:async_wrap(key, fn, loading_value, ttl, done)
  local self = self
  local is_running = false

  return function(...)
    local cached_value = self:get(key)
    if cached_value then
      return cached_value
    end

    if is_running then
      return loading_value
    end

    is_running = true
    fn(function(result)
      self:set(key, result, ttl)
      is_running = false
      done()
    end, ...)

    return loading_value
  end
end

return M
