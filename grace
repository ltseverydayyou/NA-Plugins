cmdPluginAdd = {
  Aliases = {"gracegod","ggod"}, 
  ArgsHint = "", 
  Info = "h",
  Function = function(arg)
      local Players = game:GetService("Players")
      local ReplicatedStorage = game:GetService("ReplicatedStorage")

      local localPlayer = Players.LocalPlayer
      local playerGui = localPlayer:WaitForChild("PlayerGui")

      local blockedGuiNames = {
        "smilegui",
        "static",
        "eyegui",
        "goatport",
        "memorygui",
        "litanygui",
        "epikduk",
        "mimejumpscare",
        "pulseui",
      }

      local blockedGuiSet = {}
      for _, name in ipairs(blockedGuiNames) do
        blockedGuiSet[name] = true
      end

      playerGui.ChildAdded:Connect(function(child)
          local name = child.Name:lower()
          if blockedGuiSet[name] then
            child:Destroy()
          end
      end)

--[[local killClient = ReplicatedStorage:FindFirstChild("KillClient")
if killClient then
    killClient:Destroy()
end]]
      cmdRun("blockremote killclient")

      return blockedGuiNames
    end,
    RequiresArguments = false
}
