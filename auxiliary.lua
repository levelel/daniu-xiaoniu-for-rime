local auxiliary = {}

function auxiliary.init(env)
  env.aux_table = {}
  -- 修改为使用正确的文件路径
  local aux_path = env.schema_path .. "/../小牛形码.txt"
  local f = io.open(aux_path, "r")
  if f then
    -- 跳过可能的UTF-8 BOM
    local first_char = f:read(1)
    if first_char ~= '\239' then
      f:seek("set", 0)
    else
      f:read(2)  -- 跳过BOM的剩余字节
    end
    
    for line in f:lines() do
      -- 解析每行数据：假设格式为 "汉字+辅码"
      local han, code = line:match("^(.)(.+)$")
      if han and code then
        env.aux_table[code] = han
      end
    end
    f:close()
  else
    -- 可在日志中记录未找到辅码文件的错误
    io.stderr:write("未能打开辅码文件：" .. aux_path .. "\n")
  end
end

function auxiliary.translate(input, seg, env)
  -- 检查辅码开关状态
  if env.engine.context:get_option("auxiliary") then
    local cand = {}
    local han = env.aux_table[input]
    if han then
      yield(Candidate("aux", seg.start, seg._end, han, "辅码"))
    end
  end
end

return auxiliary