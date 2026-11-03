-- main.lua
local anim = require("libraries.anim8")
local Camera = require("libraries.camera")
local Vector = require("libraries.vector") 
local kaoru = require("kaoru")

local cam
local bedroom = {}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    cam = Camera(kaoru.x, kaoru.y)
    cam.scale = 2.0 -- ปรับซูมสำหรับแนว Pixel Art

    -- bedroom
    bedroom.image = love.graphics.newImage("assets/images/kaoru_bedroom.png")
    bedroom.width = bedroom.image:getWidth()
    bedroom.height = bedroom.image:getHeight()
    bedroom.MAP_WIDTH = bedroom.width
    bedroom.MAP_HEIGHT = bedroom.height

    -- โหลดตัวละครคาโอรุ
    kaoru:load()
end

function love.update(dt)
    -- 1. อัปเดตการเคลื่อนไหวและระบบชนของคาโอรุ
    kaoru:update(dt, bedroom)

    -- 2. กล้องแบบ Snap ตามติดพิกัดตัวละครทันที
    cam:lookAt(kaoru.x, kaoru.y)
end

function love.keypressed(key)
    -- ส่งอีเวนต์ปุ่มกดไปให้คาโอรุ (ซึ่งจะส่งต่อไปยังเมนูสเตตัสอีกที)
    kaoru:keypressed(key)
end

function love.gamepadpressed(joystick, button)
    kaoru:gamepadpressed(joystick, button)
end

function love.draw()
    -- เปิดใช้งานกล้อง (World Layer)
    cam:attach()
    
        -- วาดฉากห้องนอน
        love.graphics.draw(bedroom.image, 0, 0)

        -- วาดตัวละครคาโอรุ
        kaoru:draw(cam)

    -- ปิดการใช้งานกล้อง
    cam:detach()

    -- วาด UI หรือเมนูด้านบนสุด (Screen Layer)
    -- ส่งขนาดหน้าจอจริงเข้าไปเพื่อให้ status_menu จัดเลย์เอาต์แบบ Responsive ได้สมบูรณ์
    if kaoru.status_menu then
        kaoru.status_menu.draw(love.graphics.getWidth(), love.graphics.getHeight())
    end
end