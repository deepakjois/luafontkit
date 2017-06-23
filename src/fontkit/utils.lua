-- NOTE This function is ported from Javascript, but is adapted
-- for Lua array indices.
local function binarySearch(arr, cmp)
  local min = 1
  local max = #arr
  while min <= max do
    local mid = math.floor((min + max) / 2)
    local res = cmp(arr[mid])

    if res < 0 then
      max = mid - 1
    elseif res > 0 then
      min = mid + 1
    else
      return mid
    end
  end

  return -1
end

-- NOTE This function is ported from Javascript, but is adapted
-- for Lua array indices.
local function range(index, end_)
  local r = {}
  while index <= end_ do
    table.insert(r, index)
    index = index + 1
  end
  return r
end

return {
  binarySearch = binarySearch,
  range = range
}