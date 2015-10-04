
fir = {}

fir.input = {}
fir.size = 10

fir.current = 1

function fir:addValue(val)
  fir.input[current] = val
  current = current + 1
  current = (current % 10) + 1
end

function fir:getValue()
  local ret, val  = 0
  for _, val in ipairs(self.input) do
    ret = ret + val
  end

  ret = ret / #self.input
  return ret
end

return fir
