-- kaoru.lua
local anim8 = require("libraries.anim8") 
local Vector = require("libraries.vector")

local kaoru = {
    x = 64,
    y = 160,
    width = 32,
    height = 32,
    speed = 1, 
    
    pos = Vector.new2D(64, 160),
    
    collider = {
        x_offset = 8, 
        y_offset = 8, 
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

        ["walk_down"]  = anim8.newAnimation(self.grid(1, '1-4'), 0.10),
        ["walk_up"]    = anim8.newAnimation(self.grid(3, '1-4'), 0.10),
        ["walk_left"]  = anim8.newAnimation(self.grid(4, '1-4'), 0.10),
        ["walk_right"] = anim8.newAnimation(self.grid(2, '1-4'), 0.10)
    }

    self.status_menu = require("status_menu")
    if self.status_menu.init then
        self.status_menu.init()
    end
end

function kaoru:update(dt, map_data)
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

    self.pos.x = self.x
    self.pos.y = self.y

    self:handleInput(dt)
    
    if map_data then
        self:resolveCollisions(map_data)
    end

    self.x = self.pos.x
    self.y = self.pos.y

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

function kaoru:handleInput(dt)
    self.is_moving = false
    
    local pool = Vector.getPool()
    local move_vec = pool.temp2_A
    move_vec.x = 0
    move_vec.y = 0
    
    if love.keyboard.isDown("left")  then move_vec.x = -1 end
    if love.keyboard.isDown("right") then move_vec.x = 1  end
    if love.keyboard.isDown("up")    then move_vec.y = -1 end
    if love.keyboard.isDown("down")  then move_vec.y = 1  end
    
    if type(controller) == "table" and controller.getAxis then
        local joy_x, joy_y = controller.getAxis()
        if math.abs(joy_x) > 0.1 or math.abs(joy_y) > 0.1 then
            move_vec.x = joy_x
            move_vec.y = joy_y
        end
    end
    
    local move_len = Vector.length2D(move_vec)
    if move_len > 0.1 then
        self.is_moving = true
        
        if math.abs(move_vec.x) > math.abs(move_vec.y) then
            if move_vec.x < 0 then self.direction = "left" else self.direction = "right" end
        else
            if move_vec.y < 0 then self.direction = "up" else self.direction = "down" end
        end
        
        Vector.normalize2D(move_vec, move_vec)
        
        local speed_vec = pool.temp2_B
        local current_speed = self.speed * 80 
        speed_vec.x = move_vec.x * current_speed * dt
        speed_vec.y = move_vec.y * current_speed * dt
        
        Vector.add2D(self.pos, speed_vec, self.pos)
    end
end

function kaoru:resolveCollisions(map)
    local col = self.collider
    local pos = self.pos

    local map_w = (map.MAP_WIDTH or 160) + 500  
    local map_h = (map.MAP_HEIGHT or 160) + 500

    local min_x = -500 
    local max_x = map_w - col.x_offset - col.width
    local min_y = -500
    local max_y = map_h - col.y_offset - col.height

    if pos.x < min_x then pos.x = min_x end
    if pos.x > max_x then pos.x = max_x end
    if pos.y < min_y then pos.y = min_y end
    if pos.y > max_y then pos.y = max_y end

    local obstacles = map.colliders
    if not obstacles then return end

    for i = 1, #obstacles do
        local wall = obstacles[i]
        
        local p_left = pos.x + col.x_offset
        local p_right = p_left + col.width
        local p_top = pos.y + col.y_offset
        local p_bottom = p_top + col.height

        local w_left = wall.x
        local w_right = wall.x + wall.width
        local w_top = wall.y
        local w_bottom = wall.y + wall.height

        if p_right > w_left and p_left < w_right and p_bottom > w_top and p_top < w_bottom then
            local overlap_x = 0
            local overlap_y = 0

            if (p_left + p_right) / 2 < (w_left + w_right) / 2 then
                overlap_x = p_right - w_left 
            else
                overlap_x = p_left - w_right 
            end

            if (p_top + p_bottom) / 2 < (w_top + w_bottom) / 2 then
                overlap_y = p_bottom - w_top 
            else
                overlap_y = p_top - w_bottom 
            end

            if math.abs(overlap_x) < math.abs(overlap_y) then
                pos.x = pos.x - overlap_x
            else
                pos.y = pos.y - overlap_y
            end
        end
    end
end

function kaoru:draw(camera_obj)
    local anim_key = (self.is_moving and "walk_" or "idle_") .. self.direction
    
    if self.animations[anim_key] then
        self.animations[anim_key]:draw(self.sheet, self.x, self.y)
    end
end

return kaoru