-- source/maps/bedroom_map.lua
local bedroom_map = {}
local kaoru = require("source.kaoru")
local sti = require("libs.sti") -- เรียกใช้งาน library sti 

local bedroomBGM  = nil
local is_loaded   = false
local map         = nil  -- ตัวแปรเก็บข้อมูลแผนที่จาก STI

-- [🎯 STEP 1]: ตารางสำหรับเก็บกล่องชนสิ่งกีดขวางภายในห้อง (ดึงอัตโนมัติจาก STI)
bedroom_map.colliders = {}

function bedroom_map.load()
    if is_loaded then return end

    -- 1. โหลด BGM
    bedroomBGM = love.audio.newSource("soundtracks/ost/Kaoru_Home.mp3", "stream")
    bedroomBGM:setLooping(true)
    bedroomBGM:setVolume(0.5)
    bedroomBGM:play()

    -- 2. โหลดแผนที่ผ่าน STI (สมมติว่าไฟล์ TMX อยู่ใน assets/maps/bedroom.lua หรือ .tmx)
    -- *มึงอย่าลืมไปสร้างไฟล์แผนที่ใน Tiled แล้ว export เป็น .lua หรือ .tmx มาไว้ที่ path นี้ด้วยนะ
    map = sti("assets/maps/bedroom.lua")

    -- 3. ดึง Object/Collider จาก Object Layer ใน Tiled (ตั้งชื่อ Layer ใน Tiled ว่า "colliders" หรือ "collision")
    bedroom_map.colliders = {}
    if map.layers["colliders"] then
        for _, obj in ipairs(map.layers["colliders"].objects) do
            table.insert(bedroom_map.colliders, {
                id = obj.name or "block",
                x = obj.x,
                y = obj.y,
                width = obj.width,
                height = obj.height
            })
        end
    end

    is_loaded = true
end

function bedroom_map.init()
    myCamera:setZoom(1.5)
    bedroom_map.load()
    if kaoru then
        -- จุดเกิดของคาโอรุ (ปรับให้ตรงกับจุด Spawn ใน Map หรือเซ็ตพิกัดเริ่มต้น)
        kaoru.x = 45
        kaoru.y = 50
    end
end

function bedroom_map.destroy()
    if bedroomBGM then
        bedroomBGM:stop()
        bedroomBGM = nil
    end
    
    if map then
        map = nil
    end

    bedroom_map.colliders = {} -- ล้างค่ากล่องชนเมื่อย้ายฉาก
    is_loaded = false
end

function bedroom_map.update(dt)
    -- อัปเดตแอนิเมชันหรือ Tile ที่เคลื่อนไหวในแมพ (ถ้ามี)
    if map then
        map:update(dt)
    end
end

function bedroom_map.draw()
    if not is_loaded then bedroom_map.load() end

    love.graphics.clear(0.15, 0.12, 0.10)
    love.graphics.setColor(1, 1, 1, 1)

    -- เรนเดอร์แผนที่ด้วย STI โดยผสานเข้ากับระบบกล้อง (myCamera) ของมึง
    if map then
        -- ดึงค่าตำแหน่งและซูมจากกล้องมาเซ็ตให้ STI วาดตาม
        -- ปรับแต่งการย้ายมุมมองตามฟังก์ชันกล้องที่มึงใช้
        local zoom = myCamera.zoom or 1.5
        
        -- ถ้ากล้องของมึงรองรับการส่งค่า translate ให้ STI โดยตรง:
        love.graphics.push()
        love.graphics.scale(zoom, zoom)
        love.graphics.translate(-myCamera.x + (love.graphics.getWidth() / 2 / zoom), -myCamera.y + (love.graphics.getHeight() / 2 / zoom))
        
        map:draw()
        
        love.graphics.pop()
    end

    -- =======================================================
    -- [🎯 STEP 3/DEV ONLY]: วาดตัวละครคาโอรุ (ต้องอยู่ในพิกัดที่แปลงตามกล้องแล้ว)
    -- =======================================================
    if kaoru and kaoru.draw then
        kaoru:draw(myCamera)
    end

    -- DEBUG TEXT
    --[[love.graphics.setColor(1, 1, 0, 1)
    -- love.graphics.print("SCENE: KAORU'S BEDROOM (STI)", 4, 4)]]
    love.graphics.setColor(1, 1, 1, 1)
end

return bedroom_map