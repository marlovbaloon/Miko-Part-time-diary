-- main.lua
local sti = require("libraries.sti")
local bedroom

function love.load()
    bedroom = sti("assets/maps/kaoru_home.lua")
end

function love.update(dt)
    bedroom:update(dt)
end

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

   
    local mapWidth = bedroom.width * bedroom.tilewidth
    local mapHeight = bedroom.height * bedroom.tileheight

   
    local tx = math.floor((screenWidth - mapWidth) / 2)
    local ty = math.floor((screenHeight - mapHeight) / 2)

 
    bedroom:draw(tx, ty)
end
