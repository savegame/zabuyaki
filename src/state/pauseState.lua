pauseState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local hint_y_offset = 80
local menu_x_offset = 0

local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_paused = love.graphics.newText( gfx.font.kimberley, "PAUSED" )
local txt_items = { "CONTINUE", "QUICK SAVE", "QUIT" }

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function pauseState:enter()
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME * 0.75)
    menu_state = 1
    mouse_x, mouse_y = 0,0
    sfx.play("sfx","menu_cancel")

    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
end

function pauseState:leave()
end

--Only P1 can use menu / options
function pauseState:player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_select")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return pauseState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function pauseState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    self:player_input(Control1)
end

function pauseState:draw()
    love.graphics.setCanvas()
    push:start()
    if canvas[1] then
        local darken_screen = 0.75
        love.graphics.setBlendMode("alpha", "premultiplied")
        love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
        love.graphics.draw(canvas[1], 0,0, nil, 0.5) --bg
        love.graphics.setColor(GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
            GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
            GLOBAL_SETTING.SHADOW_OPACITY * darken_screen,
            GLOBAL_SETTING.SHADOW_OPACITY * darken_screen)
        love.graphics.draw(canvas[2], 0,0, nil, 0.5) --shadows
        love.graphics.setColor(255 * darken_screen, 255 * darken_screen, 255 * darken_screen, 255)
        love.graphics.draw(canvas[3], 0,0, nil, 0.5) --sprites + fg
        love.graphics.setBlendMode("alpha")
    end
    if stage.mode == "normal" then
        drawPlayersBars()
    end
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy )
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(55, 55, 55, 255)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 + 1, 40 + 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 - 1, 40 + 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 + 1, 40 - 1 )
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2 - 1, 40 - 1 )
    love.graphics.setColor(255, 255, 255, 220 + math.sin(time)*35)
    love.graphics.draw(txt_paused, (screen_width - txt_paused:getWidth()) / 2, 40)

    show_debug_indicator()
    push:finish()
end

function pauseState:confirm( x, y, button, istouch )
     if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            return Gamestate.pop()
        elseif menu_state == #menu then
            sfx.play("sfx","menu_cancel")
            return Gamestate.switch(titleState)
        end
    end
end

function pauseState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function pauseState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function pauseState:keypressed(key, unicode)
end