local anim8 = require("libraries.anim8") 

local kaoru = {
    -- ให้ x, y เป็นตำแหน่งของ "ฮิตบ็อกซ์ (Collider)" โดยตรงเลย จะได้ไม่สับสน
    x = 30,
    y = 80,
    width = 32,
    height = 32,
    speed = 0.5, 
    
    collider = {
        x_offset = 8,   -- ระยะห่างจากซ้ายของภาพ ถึงฮิตบ็อกซ์
        y_offset = 16,  -- ระยะห่างจากบนของภาพ ถึงฮิตบ็อกซ์ (ช่วงเท้า)
        width = 16,  
        height = 12  
    },

    direction = "down",     
    is_moving = false,      
    
    sheet = nil,
    grid = nil,
    animations = {},

    status_menu = nil
}

function kaoru:load()
    self.sheet = love.graphics.newImage("assets/character_playable/kaoru_sheet.png")
    self.grid = anim8.newGrid(32, 32, self.sheet:getWidth(), self.sheet:getHeight())

    self.animations = {
        ["idle_down"]  = anim8.newAnimation(self.grid(1, 1), 1),
        ["idle_up"]    = anim8.newAnimation(self.grid(3, 1), 1),
        ["idle_left"]  = anim8.newAnimation(self.grid(4, 1), 1),
        ["idle_right"] = anim8.newAnimation(self.grid(2, 1), 1),

        ["walk_down"]  = anim8.newAnimation(self.grid(1, '1-4'), 0.2),
        ["walk_up"]    = anim8.newAnimation(self.grid(3, '1-4'), 0.2),
        ["walk_left"]  = anim8.newAnimation(self.grid(4, '1-4'), 0.2),
        ["walk_right"] = anim8.newAnimation(self.grid(2, '1-4'), 0.2)
    }

    self.status_menu = require("status_menu")
    if self.status_menu and self.status_menu.init then
        self.status_menu.init()
    end
end

function kaoru:update(dt, world_map)
    if self.status_menu then
        self.status_menu.update(dt)
    end

    if self.status_menu and self.status_menu.isOpen then
        self.is_moving = false
        local anim_key = "idle_" .. self.direction
        if self.animations[anim_key] then
            self.animations[anim_key]:update(dt)
        end
        return
    end

    self:handleInput(dt, world_map)

    local anim_key = (self.is_moving and "walk_" or "idle_") .. self.direction
    if self.animations[anim_key] then
        self.animations[anim_key]:update(dt)
    else
        local fallback_key = "idle_" .. self.direction
        if self.animations[fallback_key] then
            self.animations[fallback_key]:gotoFrame(1)
        end
    end
end

function kaoru:handleInput(dt, world_map)
    self.is_moving = false
    
    local dx, dy = 0, 0
    local current_speed = self.speed * 120

    if love.keyboard.isDown("left")  then dx = -1 end
    if love.keyboard.isDown("right") then dx = 1  end
    if love.keyboard.isDown("up")    then dy = -1 end
    if love.keyboard.isDown("down")  then dy = 1  end

    if dx ~= 0 or dy ~= 0 then
        self.is_moving = true

        if dx ~= 0 and dy ~= 0 then
            dx = dx * 0.7071
            dy = dy * 0.7071
        end

        if math.abs(dx) > math.abs(dy) then
            if dx < 0 then self.direction = "left" else self.direction = "right" end
        else
            if dy < 0 then self.direction = "up" else self.direction = "down" end
        end

        -- คำนวณเป้าหมายของฮิตบ็อกซ์
        local goal_x = self.x + dx * current_speed * dt
        local goal_y = self.y + dy * current_speed * dt

        if world_map and world_map:hasItem(self) then
            -- ให้ Bump จัดการเรื่องการชนและคืนพิกัดใหม่ของฮิตบ็อกซ์มาตรงๆ
            local actual_x, actual_y = world_map:move(self, goal_x, goal_y, function(item, other)
                return 'slide'
            end)
            
            self.x = actual_x
            self.y = actual_y
        else
            self.x = goal_x
            self.y = goal_y
        end
    end
end

function kaoru:keypressed(key)
    if self.status_menu then
        self.status_menu.keypressed(key)
    end
end

function kaoru:gamepadpressed(joystick, button)
    if self.status_menu then
        self.status_menu.gamepadpressed(joystick, button)
    end
end

function kaoru:draw()
    local anim_key = (self.is_moving and "walk_" or "idle_") .. self.direction
    if self.animations[anim_key] then
        -- ตอนวาดภาพ: ให้ถอยหลัง (ลบ) ด้วยค่า offset เพื่อให้ภาพตัวละครครอบทับอยู่บนฮิตบ็อกซ์พอดี
        local draw_x = self.x - self.collider.x_offset
        local draw_y = self.y - self.collider.y_offset
        self.animations[anim_key]:draw(self.sheet, math.floor(draw_x), math.floor(draw_y))
    end
end

return kaoru