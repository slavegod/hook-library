local hooks = getgenv().hooks or {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventMappings = {
    characteradded = function(player)
        return player.CharacterAdded
    end,
    characterremoving = function(player)
        return player.CharacterRemoving
    end,
    chatted = function(player)
        return player, player.Chatted
    end,
    died = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Died
    end,
    joined = function()
        return Players.PlayerAdded
    end,
    left = function()
        return Players.PlayerRemoving
    end,
    stepped = function()
        return RunService.Stepped
    end,
    heartbeat = function()
        return RunService.Heartbeat
    end,
    renderstepped = function()
        return RunService.RenderStepped
    end,
    statechanged = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").StateChanged
    end,
    healthchanged = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").HealthChanged
    end,
    jumping = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Jumping
    end,
    seated = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Seated
    end,
    animationplayed = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").AnimationPlayed
    end,
    animationended = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").AnimationEnded
    end,
    inputbegan = function()
        return UserInputService.InputBegan
    end,
    inputended = function()
        return UserInputService.InputEnded
    end,
    inputchanged = function()
        return UserInputService.InputChanged
    end,
    touch = function()
        return UserInputService.TouchTap
    end,
    partadded = function()
        return workspace.DescendantAdded
    end,
    partremoved = function()
        return workspace.DescendantRemoving
    end,
    touched = function(player)
        return player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Touched
    end,
    collision = function()
        return PhysicsService.CollisionGroupsChanged
    end,
    camerasubject = function()
        return workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject")
    end,
    camerazoom = function()
        return workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView")
    end,
    swimming = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Swimming
    end,
    climbing = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Climbing
    end,
    falling = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").FreeFalling
    end,
    running = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").Running
    end,
    toolequipped = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").ToolEquipped
    end,
    toolunequipped = function(player)
        return player.Character and player.Character:WaitForChild("Humanoid").ToolUnequipped
    end,
    focuslost = function()
        return UserInputService.WindowFocusReleased
    end,
    focusgained = function()
        return UserInputService.WindowFocused
    end,
    gyroscope = function()
        return UserInputService.DeviceGravityChanged
    end,
    acceleration = function()
        return UserInputService.DeviceAccelerationChanged
    end,
    graphicsquality = function()
        return UserInputService.GetPropertyChangedSignal(workspace, "GraphicsQuality")
    end,
    lighting = function()
        return game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime")
    end
}

local hooking = {}

hooking.Add = function(identifier: string, form: string | RBXScriptSignal, func: (...any) -> (), persistent: boolean)
    if typeof(identifier) ~= "string" then return warn("Identifier isn't a string.") end
    if hooks[identifier] then return warn(tostring(identifier) .. " already exists, remove it first.") end
    
    local event
    if typeof(form) == "string" then
        local eventName = string.lower(form)
        if not eventMappings[eventName] then
            return warn("Invalid event string: " .. eventName)
        end
        
        local playerEvents = {
            "characteradded", "characterremoving", "chatted", "died", "statechanged",
            "healthchanged", "jumping", "seated", "animationplayed", "animationended",
            "touched", "swimming", "climbing", "falling", "running", "toolequipped",
            "toolunequipped"
        }
        
        local isPlayerEvent = false
        for _, playerEvent in ipairs(playerEvents) do
            if eventName == playerEvent then
                isPlayerEvent = true
                break
            end
        end
        
        if isPlayerEvent then
            event = eventMappings[eventName](LocalPlayer)
        else
            event = eventMappings[eventName]()
        end
    else
        event = form
    end
    
    if typeof(event) ~= "RBXScriptSignal" then return warn("Event isn't a RBXScriptSignal.") end
    if typeof(func) ~= "function" then return warn("The function needs to be a function.") end

    hooks[identifier] = {
        connection = event:Connect(func),
        event = event,
        func = func,
        persistent = persistent,
        status = "active"
    }
end

hooking.Remove = function(identifier: string)
    if typeof(identifier) ~= "string" then return warn("Identifier isn't a string.") end
    if not hooks[identifier] then return warn("Hook not found.") end

    hooks[identifier].connection:Disconnect()
    hooks[identifier] = nil
    print("Hook removed.")
end

hooking.Pause = function(identifier: string, reason: string?)
    if not hooks[identifier] then return warn("Hook not found.") end
    if hooks[identifier].status == "paused" then return warn("Hook is already paused.") end

    hooks[identifier].connection:Disconnect()
    hooks[identifier].status = "paused"
    print("Hook " .. identifier .. " paused: " .. (reason or "No reason provided."))
end

hooking.Return = function(identifier: string, reason: string?)
    if not hooks[identifier] then return warn("Hook not found.") end
    if hooks[identifier].status ~= "paused" then return warn("Hook is not paused.") end

    hooks[identifier].connection = hooks[identifier].event:Connect(hooks[identifier].func)
    hooks[identifier].status = "active"

    print("Hook " .. identifier .. " returned: " .. (reason or "No reason provided."))
end

hooking.Status = function(identifier: string)
    if not hooks[identifier] then return warn("Hook not found.") end
    return hooks[identifier].status
end

return hooking
