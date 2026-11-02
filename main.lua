local Gamestate = require "lib.gamestate"
local anim8 = require "lib.anim8"

-- [Define Game States]
state_bedroom = {}
state_train   = {}
state_shrine  = {}
state_tekken  = {}

-- Scene 1: Bedroom Setup
function state_bedroom:enter()
    image.love.graphics.newImage("assets/sprites/kaoru_sheet.png")
end

function state_bedroom:update(dt)
end

function state_bedroom:draw()
    love.graphics.print("Scene: Kaoru's Bedroom (Press Space to Next Scene)", 50, 50)
end

function state_bedroom:keypressed(key)
    if key == "space" then
        Gamestate.switch(state_tekken)
    end
end

-- Scene 2: Tekken Minigame Setup
function state_tekken:enter()
    -- Code สำหรับมินิเกมตู้กดจังหวะ 0.03s Dead Space
end

function state_tekken:draw()
    love.graphics.print("Scene: Tekken Minigame (Press Space to Return)", 50, 50)
end

function state_tekken:keypressed(key)
    if key == "space" then
        Gamestate.switch(state_bedroom)
    end
end

-- Main Engine Callbacks
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest") -- ล็อก Pixel Art ไม่ให้แตกเบลอ
    Gamestate.registerEvents()
    Gamestate.switch(state_bedroom)
end
