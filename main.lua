local sti = require("libraries.sti")
local cameraModule = require("libraries.camera")
local kaoruModule = require("kaoru")
local bump = require("libraries.bump")

local bedroom
local kaoru
local cam
local spriteLayer
local world

function love.load()
    world = bump.newWorld(16)
    bedroom = sti("assets/maps/kaoru_home.lua", {"bump"})
    bedroom:bump_init(world)

    cam = cameraModule()

    kaoru = kaoruModule
    kaoru:load()
    kaoru.x = 30
    kaoru.y = 80

    -- แอดเข้า World โดยใช้ขนาดของ collider และพิกัด x, y ตรงๆ ได้เลย
    world:add(kaoru, kaoru.x, kaoru.y, kaoru.collider.width, kaoru.collider.height)

    spriteLayer = bedroom:addCustomLayer("Sprite Layer", 13)
    spriteLayer.draw = function(self)
        kaoru:draw()
    end
end

function love.update(dt)
    bedroom:update(dt)
    
    if kaoru.update then
        kaoru:update(dt, world)
    end

    -- กล้องตามตัวละคร (ใช้ตำแหน่งฮิตบ็อกซ์ + ครึ่งหนึ่งของขนาดภาพ)
    cam:lockPosition(math.floor(kaoru.x + kaoru.collider.width / 2), math.floor(kaoru.y + kaoru.collider.height / 2), cameraModule.smooth.linear(10))
end

function love.draw()
    cam:draw(function()
        bedroom:draw()
        
        -- [แก้ไข] วาดกรอบสีแดงเฉพาะของ Kaoru ตัวเดียวพอ ไม่ต้องไปลูป items ทั้งหมดของแมพ
        love.graphics.setColor(1, 0, 0, 1)
        if world:hasItem(kaoru) then
            local bx, by, bw, bh = world:getRect(kaoru)
            love.graphics.rectangle("line", bx, by, bw, bh)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end)
end