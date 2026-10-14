--==================================================
-- MIASMA ENTITY + ATMOSPHERE EFFECTS + ACHIEVEMENT
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--==================================================
-- ENTITY CREATOR
--==================================================

local Creator = loadstring(
    game:HttpGet(
        "https://pastebin.com/raw/0fSnvfGt"
    )
)()

--==================================================
-- CUSTOM ACHIEVEMENTS
--==================================================

local CustomAchievements = loadstring(
    game:HttpGet(
        "https://raw.githubusercontent.com/RegularVynixu/DOORS-Custom-Achievements/main/init.luau"
    )
)()

local ACHIEVEMENT_ID = "YouWontFoolMe"

local function grantMiasmaAchievement()
    local success, err = pcall(function()
        if CustomAchievements:CheckOwned(ACHIEVEMENT_ID) then
            print("Miasma achievement already owned")
            return
        end

        CustomAchievements:Grant({
            Identifier = ACHIEVEMENT_ID,
            Title = "You Wont Fool Me",
            Desc = "Not Halt this time",
            Reason = "Survive And Encounter Miasma",
            Image = "rbxassetid://11712891957"
        }, {
            CheckOwned = true,
            Remember = true
        })

        print("Miasma achievement granted!")
    end)

    if not success then
        warn("Failed to grant Miasma achievement:", err)
    end
end

--==================================================
-- MIASMA EFFECT SETTINGS
--==================================================

local active = false
local originalColors = {}
local sound
local captionGui
local colorEffect
local roomConnection

local BLUE = Color3.fromRGB(35, 75, 255)

--==================================================
-- COLOR ROOM PARTS BLUE
--==================================================

local function colorPart(part)
    if not active or not part:IsA("BasePart") then
        return
    end

    if originalColors[part] == nil then
        originalColors[part] = part.Color
    end

    part.Color = BLUE
end

local function colorRoom(room)
    for _, obj in ipairs(room:GetDescendants()) do
        colorPart(obj)
    end
end

--==================================================
-- RESTORE ORIGINAL ROOM COLORS
--==================================================

local function restoreColors()
    if roomConnection then
        roomConnection:Disconnect()
        roomConnection = nil
    end

    for part, originalColor in pairs(originalColors) do
        if part and part.Parent then
            part.Color = originalColor
        end
    end

    table.clear(originalColors)
end

--==================================================
-- MIASMA SPAWN EFFECTS
--==================================================

local function startMiasma()
    if active then
        return
    end

    active = true

    -- Color existing rooms
    local rooms = Workspace:FindFirstChild("CurrentRooms")

    if rooms then
        for _, room in ipairs(rooms:GetChildren()) do
            colorRoom(room)
        end

        -- Color newly added room parts
        roomConnection = rooms.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if active and obj.Parent then
                    colorPart(obj)
                end
            end)
        end)
    else
        warn("Miasma: CurrentRooms folder not found!")
    end

    -- Blue atmosphere
    colorEffect = Instance.new("ColorCorrectionEffect")
    colorEffect.Name = "MiasmaBlueAtmosphere"
    colorEffect.TintColor = Color3.fromRGB(100, 130, 255)
    colorEffect.Brightness = -0.05
    colorEffect.Contrast = 0.15
    colorEffect.Parent = Lighting

    -- RUN... caption
    captionGui = Instance.new("ScreenGui")
    captionGui.Name = "MiasmaCaption"
    captionGui.ResetOnSpawn = false
    captionGui.IgnoreGuiInset = true
    captionGui.Parent = player:WaitForChild("PlayerGui")

    local caption = Instance.new("TextLabel")
    caption.Name = "WarningText"
    caption.Size = UDim2.new(1, 0, 0, 100)
    caption.Position = UDim2.new(0, 0, 0.38, 0)
    caption.BackgroundTransparency = 1
    caption.Text = "RUN..."
    caption.TextColor3 = Color3.fromRGB(100, 170, 255)
    caption.TextStrokeColor3 = Color3.fromRGB(0, 0, 40)
    caption.TextStrokeTransparency = 0.1
    caption.Font = Enum.Font.GothamBlack
    caption.TextScaled = true
    caption.TextTransparency = 1
    caption.Parent = captionGui

    TweenService:Create(
        caption,
        TweenInfo.new(0.4),
        {TextTransparency = 0}
    ):Play()

    -- Looping Miasma ambient sound
    sound = Instance.new("Sound")
    sound.Name = "MiasmaAmbientSound"
    sound.SoundId = "rbxassetid://9106419038"
    sound.Volume = 1
    sound.Looped = true
    sound.Parent = Workspace.CurrentCamera or Workspace
    sound:Play()

    print("Miasma effects started")
end

--==================================================
-- MIASMA DESPAWN EFFECTS
--==================================================

local function stopMiasma()
    if not active then
        return
    end

    active = false

    -- Restore rooms
    restoreColors()

    -- Remove atmosphere
    if colorEffect then
        colorEffect:Destroy()
        colorEffect = nil
    end

    -- Remove caption
    if captionGui then
        captionGui:Destroy()
        captionGui = nil
    end

    -- Stop ambient sound
    if sound then
        sound:Stop()
        sound:Destroy()
        sound = nil
    end

    print("Miasma effects stopped")
end

--==================================================
-- CREATE MIASMA ENTITY
--==================================================

local entity = Creator.createEntity({

    CustomName = "Miasma",

    Model = "https://raw.githubusercontent.com/Ilikerobloxdoors/Miasmaa/main/miasma%20remake.rbxm",

    Speed = 35,
    DelayTime = 0.5,
    HeightOffset = 0,

    CanKill = true,
    KillRange = 15,

    BreakLights = true,
    BackwardsMovement = true,

    FlickerLights = {
        false,
        1,
    },

    Cycles = {
        Min = 1,
        Max = 1,
        WaitTime = 1,
    },

    CamShake = {
        true,
        {6, 6, 0.1, 1.5},
        100,
    },

    Jumpscare = {
        true,
        {
            Image1 = "rbxassetid://11712893558",
            Image2 = "rbxassetid://11712893558",

            Shake = true,

            Sound1 = {
                10483790459,
                {
                    Volume = 0.5,
                },
            },

            Sound2 = {
                107562158799759,
                {
                    Volume = 0.5,
                },
            },

            Flashing = {
                true,
                Color3.fromRGB(255, 47, 0),
            },

            Tease = {
                true,
                Min = 1,
                Max = 2,
            },
        },
    },

    CustomDialog = {
        "You died to Miasma...",
    },
})

--==================================================
-- ENTITY DEBUG CALLBACKS + EFFECT INTEGRATION
--==================================================

entity.Debug.OnEntitySpawned = function(entityTable)
    print("Miasma spawned:", entityTable.Model)
    startMiasma()
end

entity.Debug.OnEntityDespawned = function(entityTable)
    print("Miasma despawned:", entityTable.Model)

    -- Stop effects first
    stopMiasma()

    -- Grant achievement when Miasma disappears
    grantMiasmaAchievement()
end

entity.Debug.OnEntityStartMoving = function(entityTable)
    print("Miasma started moving:", entityTable.Model)
end

entity.Debug.OnEntityFinishedRebound = function(entityTable)
    print("Miasma finished rebound:", entityTable.Model)
end

entity.Debug.OnEntityEnteredRoom = function(entityTable, room)
    print("Miasma entered room:", room)
end

entity.Debug.OnLookAtEntity = function(entityTable)
    print("Player looked at Miasma")
end

entity.Debug.OnDeath = function(entityTable)
    warn("Player died to Miasma")
end

--==================================================
-- RUN ENTITY
--==================================================

Creator.runEntity(entity)
