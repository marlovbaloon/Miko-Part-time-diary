-- status_menu.lua
local status_menu = {}

-- ============================================================
--  State
-- ============================================================
status_menu.isOpen     = false
status_menu.activeTab  = 1          -- 1=Status 2=Inventory 3=Equipment 4=Quest
status_menu.selectedItem       = 1
status_menu.selectedEquipSlot  = 1
status_menu.selectedQuest      = 1

-- Animation state (time-based easing)
status_menu.animT        = 0        -- current visual progress 0..1
status_menu.animFrom     = 0
status_menu.animTo       = 0
status_menu.animDuration = 0.35
status_menu.animElapsed  = 0
status_menu.animating    = false

local TABS      = { "STATUS", "INVENTORY", "EQUIPMENT", "QUEST" }
local NUM_TABS  = #TABS

-- ============================================================
--  Data
-- ============================================================
status_menu.data = {
    playerName   = "Takahiro Kaoru",
    age          = 14,
    affection    = 100,
    fatigue      = 0,
    maxAffection = 100,
    maxFatigue   = 100,

    items = {
        { name = "Black Pen",  desc = "A cheap ballpoint. Writes on anything.",  qty = 1, type = "Tool" },
        { name = "Wallet",     desc = "Contains 2,400 yen.",                     qty = 1, type = "Key"  },
        { name = "Bean Bread", desc = "Stale. Still edible.",                    qty = 3, type = "Food" },
        { name = "Notebook",   desc = "School notebook, half full.",             qty = 1, type = "Tool" },
        { name = "Hair Tie",   desc = "Simple black hair tie.",                  qty = 2, type = "Misc" },
    },

    equipment = {
        { slot = "Head",      item = "-" },
        { slot = "Body",      item = "Casual Clothes" },
        { slot = "Weapon",    item = "-" },
        { slot = "Accessory", item = "-" },
    },

    quests = {
        { name = "Getting Ready", desc = "Prepare your belongings before heading out.", status = "Active", progress = "0/1 Done" }
    }
}

-- ============================================================
--  Colors
-- ============================================================
local COL = {
    woodDark    = { 0.10, 0.06, 0.03, 0.96 },
    woodMid     = { 0.20, 0.12, 0.07, 1.00 },
    woodLight   = { 0.30, 0.19, 0.11, 1.00 },
    gold        = { 0.90, 0.75, 0.35, 1.00 },
    goldBright  = { 1.00, 0.88, 0.50, 1.00 },
    goldDim     = { 0.55, 0.42, 0.20, 1.00 },
    text        = { 0.95, 0.90, 0.80, 1.00 },
    textDim     = { 0.65, 0.60, 0.50, 1.00 },
    textHi      = { 1.00, 0.95, 0.70, 1.00 },
    barBg       = { 0.08, 0.04, 0.02, 1.00 },
    affection   = { 0.95, 0.45, 0.65, 1.00 },
    affectionHi = { 1.00, 0.65, 0.80, 1.00 },
    fatigue     = { 0.45, 0.55, 0.85, 1.00 },
    fatigueHi   = { 0.65, 0.75, 1.00, 1.00 },
    overlay     = { 0.00, 0.00, 0.00, 0.72 },
    select      = { 0.90, 0.75, 0.35, 0.22 },
    selectBrd   = { 1.00, 0.88, 0.50, 0.85 },
}

-- ============================================================
--  Helpers
-- ============================================================
local function easeOutCubic(t)  return 1 - (1 - t)^3  end
local function lerp(a, b, t)    return a + (b - a) * t end
local function lerpColor(c1, c2, t, a)
    return {
        lerp(c1[1], c2[1], t),
        lerp(c1[2], c2[2], t),
        lerp(c1[3], c2[3], t),
        a or lerp(c1[4] or 1, c2[4] or 1, t),
    }
end

-- ============================================================
--  Public API
-- ============================================================
function status_menu.toggle()
    status_menu.isOpen = not status_menu.isOpen
    local target = status_menu.isOpen and 1 or 0
    if target == status_menu.animT then return end
    status_menu.animFrom    = status_menu.animT
    status_menu.animTo      = target
    status_menu.animElapsed = 0
    status_menu.animating   = true
end

function status_menu.open()  if not status_menu.isOpen then status_menu.toggle() end end
function status_menu.close() if     status_menu.isOpen then status_menu.toggle() end end

function status_menu.init() end

function status_menu.update(dt)
    if not status_menu.animating then return end
    status_menu.animElapsed = status_menu.animElapsed + dt
    local t      = math.min(status_menu.animElapsed / status_menu.animDuration, 1)
    local easedT = easeOutCubic(t)
    status_menu.animT = status_menu.animFrom + (status_menu.animTo - status_menu.animFrom) * easedT
    if t >= 1 then
        status_menu.animating = false
        status_menu.animT     = status_menu.animTo
    end
end

-- ============================================================
--  Navigation
-- ============================================================
function status_menu:getMaxIndex()
    if self.activeTab == 2 then return #self.data.items
    elseif self.activeTab == 3 then return #self.data.equipment
    elseif self.activeTab == 4 then return #self.data.quests end
    return 1
end

function status_menu:getSelection()
    if self.activeTab == 2 then return self.selectedItem
    elseif self.activeTab == 3 then return self.selectedEquipSlot
    elseif self.activeTab == 4 then return self.selectedQuest end
    return 1
end

function status_menu:setSelection(i)
    if self.activeTab == 2 then self.selectedItem      = i
    elseif self.activeTab == 3 then self.selectedEquipSlot = i
    elseif self.activeTab == 4 then self.selectedQuest     = i end
end

function status_menu.keypressed(key)
    if key == "tab" then
        status_menu.toggle()
        return
    end
    if not status_menu.isOpen then return end

    if key == "a" or key == "left" then
        status_menu.activeTab = status_menu.activeTab - 1
        if status_menu.activeTab < 1 then status_menu.activeTab = NUM_TABS end
    elseif key == "d" or key == "right" then
        status_menu.activeTab = status_menu.activeTab + 1
        if status_menu.activeTab > NUM_TABS then status_menu.activeTab = 1 end
    elseif key == "w" or key == "up" then
        local i = status_menu:getSelection() - 1
        if i < 1 then i = status_menu:getMaxIndex() end
        status_menu:setSelection(i)
    elseif key == "s" or key == "down" then
        local i = status_menu:getSelection() + 1
        if i > status_menu:getMaxIndex() then i = 1 end
        status_menu:setSelection(i)
    end
end

function status_menu.gamepadpressed(_, button)
    if button == "leftshoulder" then
        status_menu.toggle()
        return
    end
    if not status_menu.isOpen then return end

    if     button == "dpup"    then status_menu.keypressed("up")
    elseif button == "dpdown"  then status_menu.keypressed("down")
    elseif button == "dpleft"  then status_menu.keypressed("left")
    elseif button == "dpright" then status_menu.keypressed("right")
    elseif button == "b"       then status_menu.close() end
end

-- ============================================================
--  Drawing primitives
-- ============================================================
local function drawPanelFrame(x, y, w, h)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", x + 6, y + 6, w, h, 12, 12)

    love.graphics.setColor(COL.woodDark)
    love.graphics.rectangle("fill", x, y, w, h, 12, 12)

    love.graphics.setColor(COL.woodMid)
    love.graphics.rectangle("fill", x + 6, y + 6, w - 12, h - 12, 8, 8)

    love.graphics.setColor(0, 0, 0, 0.10)
    for i = 1, 6 do
        local yy = y + 14 + (h - 28) * (i / 7)
        love.graphics.rectangle("fill", x + 14, yy, w - 28, 1)
    end

    love.graphics.setColor(COL.gold)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h, 12, 12)

    love.graphics.setColor(COL.goldDim)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 5, y + 5, w - 10, h - 10, 8, 8)

    local pts = {
        { x + 14, y + 14 }, { x + w - 14, y + 14 },
        { x + 14, y + h - 14 }, { x + w - 14, y + h - 14 },
    }
    for _, p in ipairs(pts) do
        love.graphics.setColor(COL.goldBright)
        love.graphics.circle("fill", p[1], p[2], 3.5)
        love.graphics.setColor(COL.goldDim)
        love.graphics.circle("line", p[1], p[2], 3.5)
    end
end

local function drawProgressBar(x, y, w, h, value, maxValue, colStart, colEnd)
    local ratio = math.max(0, math.min(1, value / maxValue))

    love.graphics.setColor(COL.barBg)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    if ratio > 0 then
        local fillW = w * ratio
        for i = 0, math.floor(fillW) do
            local t = i / math.max(fillW, 1)
            love.graphics.setColor(lerpColor(colStart, colEnd, t))
            love.graphics.rectangle("fill", x + i, y, 1, h)
        end
    end

    love.graphics.setColor(COL.goldDim)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)

    local font = love.graphics.getFont()
    local txt  = string.format("%d / %d", value, maxValue)
    local tw   = font:getWidth(txt)
    love.graphics.setColor(COL.textHi)
    love.graphics.print(txt, x + w - tw - 8, y + (h - font:getHeight()) * 0.5)
end

local function drawTab(x, y, w, h, label, isActive)
    if isActive then
        love.graphics.setColor(COL.gold)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
        love.graphics.setColor(COL.woodDark)
    else
        love.graphics.setColor(COL.woodLight)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
        love.graphics.setColor(COL.text)
    end

    local font = love.graphics.getFont()
    local tw   = font:getWidth(label)
    local th   = font:getHeight()
    love.graphics.print(label, x + (w - tw) * 0.5, y + (h - th) * 0.5)

    love.graphics.setColor(isActive and COL.goldBright or COL.goldDim)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
end

local function drawSelectedBg(x, y, w, h, isSelected)
    if isSelected then
        love.graphics.setColor(COL.select)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
        love.graphics.setColor(COL.selectBrd)
        love.graphics.setLineWidth(1.5)
        love.graphics.rectangle("line", x, y, w, h, 4, 4)
    else
        love.graphics.setColor(0, 0, 0, 0.30)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    end
end

-- ============================================================
--  Tab content
-- ============================================================
local function drawStatusTab(px, py, pw)
    local d  = status_menu.data
    local cx = px + 40
    local cy = py + 20
    local cw = pw - 80

    love.graphics.setColor(COL.goldBright) love.graphics.print("PLAYER", cx, cy)
    love.graphics.setColor(COL.text)       love.graphics.print(d.playerName, cx + 140, cy)

    cy = cy + 56
    love.graphics.setColor(COL.goldBright) love.graphics.print("AGE", cx, cy)
    love.graphics.setColor(COL.text)       love.graphics.print(tostring(d.age), cx + 140, cy)

    cy = cy + 56
    love.graphics.setColor(COL.goldBright) love.graphics.print("AFFECTION", cx, cy)
    drawProgressBar(cx + 140, cy - 2, cw - 150, 26,
                    d.affection, d.maxAffection, COL.affection, COL.affectionHi)

    cy = cy + 56
    love.graphics.setColor(COL.goldBright) love.graphics.print("FATIGUE", cx, cy)
    drawProgressBar(cx + 140, cy - 2, cw - 150, 26,
                    d.fatigue, d.maxFatigue, COL.fatigue, COL.fatigueHi)

    cy = cy + 56
    local status = d.fatigue >= 80 and "Exhausted"
                or d.fatigue >= 50 and "Tired"
                or "Fine"
    love.graphics.setColor(COL.textDim)
    love.graphics.print("STATUS: " .. status, cx, cy)
end

local function drawInventoryTab(px, py, pw, ph)
    local d      = status_menu.data
    local listX  = px + 40
    local listY  = py + 20
    local listW  = pw * 0.50 - 40
    local listH  = ph - 60
    local rowH   = 36

    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 6, 6)
    love.graphics.setColor(COL.goldDim)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", listX, listY, listW, listH, 6, 6)

    local font = love.graphics.getFont()
    for i, item in ipairs(d.items) do
        local ry = listY + 6 + (i - 1) * rowH
        if ry + rowH > listY + listH then break end
        local sel = (i == status_menu.selectedItem)
        drawSelectedBg(listX + 4, ry, listW - 8, rowH - 4, sel)

        love.graphics.setColor(sel and COL.textHi or COL.text)
        love.graphics.print(item.name, listX + 14, ry + 8)

        local qty = "x" .. item.qty
        local tw  = font:getWidth(qty)
        love.graphics.setColor(sel and COL.goldBright or COL.textDim)
        love.graphics.print(qty, listX + listW - tw - 14, ry + 8)
    end

    local detX = px + pw * 0.55
    local detY = listY
    local detW = pw - (detX - px) - 40
    local detH = listH

    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", detX, detY, detW, detH, 6, 6)
    love.graphics.setColor(COL.goldDim)
    love.graphics.rectangle("line", detX, detY, detW, detH, 6, 6)

    local item = d.items[status_menu.selectedItem]
    if item then
        love.graphics.setColor(COL.goldBright)
        love.graphics.print(item.name, detX + 16, detY + 16)

        love.graphics.setColor(COL.gold)
        love.graphics.print("Type: " .. item.type, detX + 16, detY + 52)
        love.graphics.print("Qty:  " .. item.qty, detX + 16, detY + 76)

        love.graphics.setColor(COL.goldDim)
        love.graphics.line(detX + 16, detY + 108, detX + detW - 16, detY + 108)

        love.graphics.setColor(COL.text)
        love.graphics.printf(item.desc, detX + 16, detY + 124, detW - 32)
    end
end

local function drawEquipmentTab(px, py, pw)
    local d     = status_menu.data
    local cx    = px + 40
    local cy    = py + 20
    local slotW = pw - 80
    local slotH = 60

    for i, eq in ipairs(d.equipment) do
        local sy  = cy + (i - 1) * (slotH + 8)
        local sel = (i == status_menu.selectedEquipSlot)
        drawSelectedBg(cx, sy, slotW, slotH, sel)

        love.graphics.setColor(sel and COL.goldBright or COL.gold)
        love.graphics.print(eq.slot, cx + 16, sy + 20)

        local empty = (eq.item == "-")
        love.graphics.setColor(empty and COL.textDim or (sel and COL.textHi or COL.text))
        love.graphics.print(eq.item, cx + 180, sy + 20)
    end
end

local function drawQuestTab(px, py, pw, ph)
    local d      = status_menu.data
    local cx     = px + 40
    local cy     = py + 20
    local questW = pw - 80
    local questH = 78

    if #d.quests == 0 then
        love.graphics.setColor(COL.textDim)
        love.graphics.printf("No quests available.", cx, cy, questW, "center")
        return
    end

    local font = love.graphics.getFont()
    for i, q in ipairs(d.quests) do
        local qy  = cy + (i - 1) * (questH + 8)
        if qy + questH > py + ph then break end
        local sel = (i == status_menu.selectedQuest)
        drawSelectedBg(cx, qy, questW, questH, sel)

        love.graphics.setColor(sel and COL.textHi or COL.text)
        love.graphics.print(q.name, cx + 16, qy + 12)

        local badge = { 0.75, 0.75, 0.75, 1 }
        if     q.status == "Active"   then badge = { 0.55, 0.90, 0.55, 1 }
        elseif q.status == "Locked"   then badge = { 0.85, 0.45, 0.45, 1 }
        elseif q.status == "Complete" then badge = { 0.55, 0.75, 1.00, 1 } end
        love.graphics.setColor(badge)
        local sw = font:getWidth(q.status)
        love.graphics.print(q.status, cx + questW - sw - 16, qy + 12)

        love.graphics.setColor(COL.textDim)
        love.graphics.printf(q.desc, cx + 16, qy + 38, questW - 32)

        if q.progress and q.progress ~= "-" then
            love.graphics.setColor(COL.gold)
            love.graphics.print(q.progress, cx + 16, qy + 56)
        end
    end
end

-- ============================================================
--  Main draw
-- ============================================================
function status_menu.draw(virtualWidth, virtualHeight)
    if status_menu.animT <= 0.001 then return end

    -- บันทึกและแยกสถานะกราฟิกทั้งหมดออกด้วย push("all") ป้องกันสีและฟิลเตอร์รั่วไปเลเยอร์อื่น
    love.graphics.push("all")

    local sw = virtualWidth  or love.graphics.getWidth()
    local sh = virtualHeight or love.graphics.getHeight()
    local ease = status_menu.animT

    local pad    = math.max(6, sw * 0.02)
    local slideY = (1 - ease) * (sh * 0.1)

    local panelW = math.min(820, sw - pad * 2)
    local panelH = math.min(560, sh - pad * 2)
    local panelX = (sw - panelW) * 0.5
    local panelY = (sh - panelH) * 0.5 + slideY

    -- dim overlay
    love.graphics.setColor(COL.overlay[1], COL.overlay[2], COL.overlay[3],
                           COL.overlay[4] * ease)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- panel glow
    for i = 1, 3 do
        local a = (0.16 - i * 0.04) * ease
        love.graphics.setColor(COL.gold[1], COL.gold[2], COL.gold[3], a)
        love.graphics.setLineWidth(i * 3)
        love.graphics.rectangle("line",
            panelX - i * 2, panelY - i * 2,
            panelW + i * 4, panelH + i * 4, 10, 10)
    end

    drawPanelFrame(panelX, panelY, panelW, panelH)

    -- title
    local font   = love.graphics.getFont()
    local title  = "STATUS"
    local tw     = font:getWidth(title)
    love.graphics.setColor(COL.goldBright)
    love.graphics.print(title, panelX + (panelW - tw) * 0.5, panelY + 14)

    love.graphics.setColor(COL.gold)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(panelX + 20, panelY + 46,
                       panelX + panelW - 20, panelY + 46)

    -- tabs
    local tabLabels = { "STATUS", "ITEMS", "EQUIP", "QUEST" }
    local tabY = panelY + 54
    local tabH = math.max(22, sh * 0.045)
    local tabGap = 4
    local tabW = (panelW - pad * 2 - tabGap * (NUM_TABS - 1)) / NUM_TABS

    for i, name in ipairs(tabLabels) do
        local tx = panelX + pad + (i - 1) * (tabW + tabGap)
        drawTab(tx, tabY, tabW, tabH, name, i == status_menu.activeTab)
    end

    -- content
    local contentTop = tabY + tabH + 10
    local contentH   = panelH - (contentTop - panelY) - 30

    love.graphics.setScissor(panelX + 4, contentTop, panelW - 8, contentH)
    if     status_menu.activeTab == 1 then drawStatusTab   (panelX, contentTop, panelW)
    elseif status_menu.activeTab == 2 then drawInventoryTab(panelX, contentTop, panelW, contentH)
    elseif status_menu.activeTab == 3 then drawEquipmentTab(panelX, contentTop, panelW)
    elseif status_menu.activeTab == 4 then drawQuestTab    (panelX, contentTop, panelW, contentH)
    end
    love.graphics.setScissor()

    -- footer
    love.graphics.setColor(COL.textDim)
    local hint = "WASD/Arrows: Nav   A/D: Tab   LB/Tab: Close"
    local hw   = font:getWidth(hint)
    love.graphics.print(hint,
        panelX + (panelW - hw) * 0.5,
        panelY + panelH - 22)

    -- คืนค่าสีและสถานะกราฟิกทั้งหมดให้เป็นปกติ ป้องกันสีเหลืองตกค้างไปเลเยอร์เกมหลัก
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

return status_menu