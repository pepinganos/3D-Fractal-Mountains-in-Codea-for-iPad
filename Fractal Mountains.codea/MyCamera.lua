MyCamera = class()

function MyCamera:init(pos, vel, speed)
    self.pos = pos or vec3(terrain.terrainSize / 2 +.1, 10, 10)
    self.vel = vel or vec3(1, 0, 1)
    self.speed = speed or 0
    self.headTilt = 0
end

function MyCamera:update()
------To prevent Controller errors:
    if(cMove * 1 ~= cMove) then
        print("Controller error (Left stick)")
        return 
    end
    if(cTurn * 1 ~= cTurn) then
        print("Controller error (Right stick)")
        return 
    end
-------------------------------------------------
    local camVel2D = vec2(self.vel.x, self.vel.z)
    local camPos2D = vec2(self.pos.x, self.pos.z)

    radar:set(terrain.terrainSize - camPos2D.x, camPos2D.y, color(255, 255, 0))

    camVel2D = camVel2D:rotate(cTurn.x / 10)    --Turn left and right

    local perpCamVel2D = camVel2D:normalize():rotate(90)    --Move left and right
    camPos2D.x = camPos2D.x + perpCamVel2D.x * cMove.x/10
    camPos2D.y = camPos2D.y + perpCamVel2D.y * cMove.x/10

    self.speed = cMove.y/7    --Move forward and backward

    --Don't leave the field
    camPos2D.x = clamp(camPos2D.x, 10, terrain.terrainSize - 10)
    camPos2D.y = clamp(camPos2D.y, 10, terrain.terrainSize - 10)

    self.headTilt = clamp(self.headTilt + cTurn.y / 10, -2, 2)    --Limit headTilt

    local height = terrain:heightInPos(camPos2D.x, camPos2D.y) + CamHeight 

    camera(camPos2D.x, height, camPos2D.y,                --Position
           camPos2D.x + camVel2D.x, height + self.headTilt, camPos2D.y + camVel2D.y,  --Direction
           0,1,0)
    
    self.vel.x = camVel2D.x
    self.vel.z = camVel2D.y
    
    self.pos.x = camPos2D.x
    self.pos.z = camPos2D.y

    self.pos = self.pos + self.vel:normalize() * self.speed
end