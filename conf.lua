function love.conf(t)
    -- Logical resolution GBA
    t.window.width  = 240 * 3   -- 720 
    t.window.height = 160 * 3   -- 480
    t.window.title  = "Miko Part-time Diary"
    t.window.resizable = true
    t.window.vsync = 1
    t.console = false
end