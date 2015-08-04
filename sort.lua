local function insertionsort( a, compare )
  for i=2,#a do
    local v = a[i]
    local j = i
    while j > 1 and compare(v, a[j-1]) do
      a[j] = a[j-1]
      j = j - 1
    end
    a[j] = v
  end
end

return { insertion = insertionsort }
