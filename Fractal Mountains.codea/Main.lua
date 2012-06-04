-- Fractal terrains. Pepe Enguídanos (pepinganos) 201205 
-- Thanx to Nat for his great Controller library


    GOURAUD = true    -- Gouraud or flat shading
    COLORIZE = true    -- Colorize the map according to hight

function setup()
    displayMode(STANDARD)
    displayMode(FULLSCREEN)
    
    parameter("CamHeight", 0, 50, 5)
    parameter("FieldOfView", 10, 120, 80)
    parameter("Haze", 0, 200, 0)    -- Testing parameter
    
    gradient = image(1, 2)
    gradient:set(1, 1, color(185, 65, 27, 255))
    gradient:set(1, 2, color(5, 17, 243, 255))
    
    light = {}
    light.pos = vec3(100, 150, 200)    -- Position of the light source
    light.intensity = 200         -- 0 to 255
    ambientLight = 55    -- 0 to 255
    --For optimal results, light.intensity + ambientLight
    --shouldn't be more than 255

    terrain = FractalMountain(128)    -- only powers of 2!!!
    
    myCamera = MyCamera()

    -- Setup the controller
    cTurn = vec2(0,0)
    cMove = vec2(0,0)
    controller = SplitScreen {
        left = controllerMove(),
        right = controllerTurn()
    }    
    controller:activate()
end

function draw()
    background(33, 33, 195, 255)

    perspective(FieldOfView, WIDTH/HEIGHT) --Set screen ratio and FoV

    myCamera:update()

    terrain:draw()
    
    ortho()    -- Restore orthographic projection
    viewMatrix(matrix())    -- Restore the view matrix to the identity

    tint(255, 255, 255, Haze)
    sprite(gradient, WIDTH / 2, HEIGHT / 2, WIDTH, HEIGHT)

    tint(255, 255, 255, 187)
    sprite(radar, radar.width / 2, HEIGHT - radar.height / 2)

    controller:draw()    --Draw the sticks

    -- Draw a label at the top of the screen
    font("MyriadPro-Bold")
    fill(255, 255, 255, 255)
    fontSize(30)
    text("Fractal Mountains", WIDTH / 2, HEIGHT - 30)
end


function controllerMove()
    return VirtualStick {
        moved = function(v) cMove = v end,
        released = function(v) cMove = vec2(0,0) end
    }
end

function controllerTurn()
    return VirtualStick {
        moved = function(v) cTurn = v end,
        released = function(v)  cTurn = vec2(0,0) end
    }
end
