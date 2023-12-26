if game.PlaceId == 537413528 then

-- // Custom Settings
getgenv().TreasureAutoFarm = {
    Enabled = true, -- // Toggle the auto farm on and off
    Teleport = 2, -- // How fast between each teleport between the stages and stuff
    TimeBetweenRuns = 5 -- // How long to wait until it goes to the next run
}

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- // Goes through all of the stages
local autoFarm = function(currentRun)
    -- // Variables
    local Character = LocalPlayer.Character
    local NormalStages = Workspace.BoatStages.NormalStages

    -- // Go to each stage thing
    for i = 1, 10 do
        local Stage = NormalStages["CaveStage" .. i]
        local DarknessPart = Stage:FindFirstChild("DarknessPart")

        if (DarknessPart) then
            -- // Teleport to next stage
            print("Teleporting to next stage: Stage " .. i)
            Character.HumanoidRootPart.CFrame = DarknessPart.CFrame

            -- // Create a temp part under you
            local Part = Instance.new("Part", LocalPlayer.Character)
            Part.Anchored = true
            Part.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)

            -- // Wait and remove temp part
            wait(getgenv().TreasureAutoFarm.Teleport)
            Part:Destroy()
        end
    end

    -- // Go to end
    print("Teleporting to the end")
    repeat wait()
        Character.HumanoidRootPart.CFrame = NormalStages.TheEnd.GoldenChest.Trigger.CFrame
    until Lighting.ClockTime ~= 14

    -- // Wait until you have respawned
    local Respawned = false
    local Connection
    Connection = LocalPlayer.CharacterAdded:Connect(function()
        Respawned = true
        Connection:Disconnect()
    end)

    repeat wait() until Respawned
    wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
    print("Auto Farm: Run " .. currentRun .. " finished")
end

-- // Whilst the autofarm is enable, constantly do it
local autoFarmRun = 1
while wait() do
    if (getgenv().TreasureAutoFarm.Enabled) then
        print("Initialising Auto Farm: Run " .. autoFarmRun)
        autoFarm(autoFarmRun)
        autoFarmRun = autoFarmRun + 1
    end
end

elseif game.PlaceId == 13772394625 then

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")

local ballFolder = workspace.Balls
local indicatorPart = Instance.new("Part")
indicatorPart.Size = Vector3.new(5, 5, 5)
indicatorPart.Anchored = true
indicatorPart.CanCollide = false
indicatorPart.Transparency = 1
indicatorPart.BrickColor = BrickColor.new("Bright red")
indicatorPart.Parent = workspace

local lastBallPressed = nil
local isKeyPressed = false

local function calculatePredictionTime(ball, player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local relativePosition = ball.Position - rootPart.Position
        local velocity = ball.Velocity + rootPart.Velocity 
        local a = (ball.Size.magnitude / 2) 
        local b = relativePosition.magnitude
        local c = math.sqrt(a * a + b * b)
        local timeToCollision = (c - a) / velocity.magnitude
        return timeToCollision
    end
    return math.huge
end

local function updateIndicatorPosition(ball)
    indicatorPart.Position = ball.Position
end

local function checkProximityToPlayer(ball, player)
    local predictionTime = calculatePredictionTime(ball, player)
    local realBallAttribute = ball:GetAttribute("realBall")
    local target = ball:GetAttribute("target")
    
    local ballSpeedThreshold = math.max(0.4, 0.6 - ball.Velocity.magnitude * 0.01)

    if predictionTime <= ballSpeedThreshold and realBallAttribute == true and target == player.Name and not isKeyPressed then
        vim:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
        wait(0.005)
        vim:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
        lastBallPressed = ball
        isKeyPressed = true
    elseif lastBallPressed == ball and (predictionTime > ballSpeedThreshold or realBallAttribute ~= true or target ~= player.Name) then
        isKeyPressed = false
    end
end

local function checkBallsProximity()
    local player = players.LocalPlayer
    if player then
        for _, ball in pairs(ballFolder:GetChildren()) do
            checkProximityToPlayer(ball, player)
            updateIndicatorPosition(ball)
        end
    end
end

runService.Heartbeat:Connect(checkBallsProximity)

print("Script ran without errors")