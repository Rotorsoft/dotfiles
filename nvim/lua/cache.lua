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

--- Wraps a function with caching logic
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

--- Wraps an async function with caching logic
function M:async_wrap(key, fn, ttl, loading_value, done)
  local self = self
  local is_running = false

  return function(...)
    local cached_value = self:get(key)
    if cached_value then
      return cached_value
    end

    if is_running then
      self:set(key, loading_value, ttl)
      return
    end

    is_running = true
    fn(function(result)
      self:set(key, result, ttl)
      is_running = false
      done()
    end, ...)
  end
end

return M
