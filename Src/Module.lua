---@class BomModuleModule
BuffomatModule = {}

local moduleIndex = {}
BuffomatModule._moduleIndex = moduleIndex

---New empty module with private section
function BuffomatModule:NewModule()
  return {
    private = {}
  }
end

---@param name string
function BuffomatModule.New(name)
  if (not moduleIndex[name]) then
    moduleIndex[name] = BuffomatModule:NewModule()
    return moduleIndex[name]
  end

  return moduleIndex[name] -- found
end

BuffomatModule.Import = BuffomatModule.New

---For each known module call function by fnName and optional context will be
---passed as 1st argument, can be ignored (defaults to nil)
---module:EarlyModuleInit (called early on startup)
---module:LateModuleInit (called late on startup, after entered world)
function BuffomatModule:CallInEachModule(fnName, context)
  for _name, module in pairs(moduleIndex) do
    local fn = module[fnName]
    if fn then
      fn(context)
    end
  end
end
