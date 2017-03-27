-- Debug graphics output

function saveCanvas(canvas, name)
    local image = canvas:newImageData( )
    local filedata = image:encode("png",(name or "_")..".png")
end

function saveAllCanvasesToPng()
    for i = 1, 3 do
        saveCanvas(canvas[i], "canvas"..i)
    end
end

function saveStageToPng()
    if not stage then
        return
    end
    local cp = stage.background
    local canvas = love.graphics.newCanvas(cp.width, cp.height)
    love.graphics.setCanvas(canvas)
    --love.graphics.setBlendMode("alpha", "premultiplied")
    --love.graphics.setColor(255, 255, 255, 255)
    --love.graphics.setBackgroundColor(255, 255, 255)
    cp:drawAll()
    saveCanvas(canvas, "stage")
    love.graphics.setCanvas()
    canvas = nil
end
