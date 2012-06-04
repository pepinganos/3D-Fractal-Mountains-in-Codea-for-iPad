FractalMountain = class()

function FractalMountain:init(size)
    rnd = math.random
    self.maxHeight = 0      

    self.terrainSize = size or 128
    self.plasma = {}    --Has terrainSize^2 elements, starting from 0

    radar = image(self.terrainSize, self.terrainSize)
    self:generateTerrain()

    self.verts = {}    --Starts from 1
    self.h = 20    -- It's the height scale

    for x = 0, self.terrainSize - 2 do
        for z = 0, self.terrainSize - 2 do
            table.insert(self.verts, vec3(x, self.plasma[x + z * self.terrainSize] * self.h, z))
            table.insert(self.verts, vec3(x+1, self.plasma[(x + 1) + (z + 1) * self.terrainSize] * self.h, z+1))
            table.insert(self.verts, vec3(x+1, self.plasma[(x + 1) + z * self.terrainSize] * self.h, z))
            
            table.insert(self.verts, vec3(x, self.plasma[x + z * self.terrainSize] * self.h, z))
            table.insert(self.verts, vec3(x, self.plasma[x + (z + 1) * self.terrainSize] * self.h, z+1))
            table.insert(self.verts, vec3(x+1, self.plasma[(x + 1) + (z + 1) * self.terrainSize] * self.h, z+1))
        end
    end

    self.m = mesh()
    self.m.vertices = self.verts
    
    if (GOURAUD) then self.m.colors = self:gouraudShading()
    else self.m.colors = self:flatShading() end
end

function FractalMountain:gouraudShading()
    local normals = {}
    local colors = {}
    local colorsXZ = {}
    
    --For each rectangle (6 vertex = 2 triangles)
    for i = 1, #self.verts, 6 do
        local t1 = self.verts[i]    --Consider only one of the 2 triangles of the face
        local t2 = self.verts[i+1]    --because they share the same normal
        local t3 = self.verts[i+2]
        
        local n = vec3()
        n.x = ((t1.y - t2.y) * (t1.z - t3.z)) - ((t1.z - t2.z) * (t1.y - t3.y))
        n.y = ((t1.z - t2.z) * (t1.x - t3.x)) - ((t1.x - t2.x) * (t1.z - t3.z))
        n.z = ((t1.x - t2.x) * (t1.y - t3.y)) - ((t1.y - t2.y) * (t1.x - t3.x))
        n = n:normalize()
        normals[self.verts[i].x + self.verts[i].z * self.terrainSize] = n
    end
    
    for x = 0, self.terrainSize - 1 do
        for z = 0, self.terrainSize - 1 do
            local c
            if(x > 0 and z > 0 and x < self.terrainSize - 1 and z < self.terrainSize - 1) then
                local n1 = normals[x + z * self.terrainSize]
                local n2 = normals[(x-1) + (z-1) * self.terrainSize]
                local n3 = normals[x + (z-1) * self.terrainSize]
                local n4 = normals[(x-1) + z * self.terrainSize]
    
                local n = (n1 + n2 + n3 + n4) / 4    --the average of the 4 normals
                n = n:normalize()

                local l = (light.pos - vec3(x, y, z)):normalize()
                local d = l:dot(n) * light.intensity + ambientLight
                local y = self.plasma[x + z * self.terrainSize]
                d = clamp(d, 0, 255)

                if (COLORIZE) then 
                    c = self:colorize(d, y)
                else
                    c = color(d, d, d)
                end
            else
                c = color(0)    --Border color
            end
            colorsXZ[x + z * self.terrainSize] = c
        end
    end

    for i, v in ipairs(self.verts) do
        local c = colorsXZ[v.x + v.z * self.terrainSize]
        table.insert(colors, c)
        radar:set(self.terrainSize - v.x, v.z, c)
    end
    return colors
end

function FractalMountain:flatShading()
    local colors = {}
    --For each rectangle (6 vertex = 2 triangles)
    for i = 1, #self.verts, 6 do
        local t1 = self.verts[i]    --Consider only one of the 2 triangles of the face
        local t2 = self.verts[i+1]    --because they share the same normal
        local t3 = self.verts[i+2]
        
        local n = vec3()
        n.x = ((t1.y - t2.y) * (t1.z - t3.z)) - ((t1.z - t2.z) * (t1.y - t3.y))
        n.y = ((t1.z - t2.z) * (t1.x - t3.x)) - ((t1.x - t2.x) * (t1.z - t3.z))
        n.z = ((t1.x - t2.x) * (t1.y - t3.y)) - ((t1.y - t2.y) * (t1.x - t3.x))
        n = n:normalize()
        local l = (light.pos - self.verts[i]):normalize()
        local d = l:dot(n) * light.intensity + ambientLight
        d = clamp(d, 0,255)

        if (COLORIZE) then
            c = self:colorize(d, self.verts[i].y / self.h)
        else
            c = color(d, d, d)
        end

        for j = 0, 5 do    --The same color for the "6 vertices" of the rectangle
            colors[i+j] = c
        end
        radar:set(self.terrainSize - self.verts[i].x, self.verts[i].z, c)
    end 
    return colors
end

function FractalMountain:colorize(d, y)
    -- Returns a color based on height
    -- "y" (the height) is between 0 and maxHeight
    -- "d" is the intensity of the light

    local c = color(d, d, d)
    local brown = color(181, 101, 23, 255)
    local green = color(29, 193, 24, 255)
    local l = d / 255
    if (y < self.maxHeight * .8) then     
        c = color(brown.r*l,brown.g*l,brown.b*l)
    end
    if (y < self.maxHeight * .50) then
        c = color(green.r*l,green.g*l,green.b*l)
    end
    if (y < self.maxHeight * .30) then
        c = color(31, 41, 113, 255)
    end
    return c
end

function FractalMountain:draw()
    self.m:draw()
end

function FractalMountain:generateTerrain()
    --terrainSize must be a power of 2, otherwise we get gaps 
    --Start calculating with 4 random corners
    self:divideGrid (0, 0, self.terrainSize, rnd(), rnd(), rnd(), rnd())
end

function FractalMountain:divideGrid(x, y, lenght, c1, c2, c3, c4)
    local newLenght = lenght / 2
    if (lenght < 2) then --Keep calculating until size is less than 2
        local c = c1 + c2 + c3 + c4    --c is between 0 end 4
        self. plasma[x + y * self.terrainSize] = c --Plot the point
        self. maxHeight = math.max(self.maxHeight, c)
    return end
    
    --Calculate the average of the 4 corners and add a random displacement 
    local middle = (c1 + c2 + c3 + c4) / 4 + (rnd() - 0.5) * 3 * newLenght / self.terrainSize

    --Calculate new edges
    local edge1 = (c1 + c2) / 2
    local edge2 = (c2 + c3) / 2
    local edge3 = (c3 + c4) / 2
    local edge4 = (c4 + c1) / 2
            
    --Clamp middle between 0 and 1
    if (middle < 0) then middle = 0
    elseif (middle > 1) then middle = 1 end
        
    --Recursevely call this function for each one of the 4 new rectangles
    self:divideGrid(x, y, newLenght, c1, edge1, middle, edge4)
    self:divideGrid(x + newLenght, y, newLenght, edge1, c2, edge2, middle)
    self:divideGrid(x + newLenght, y + newLenght, newLenght, middle, edge2, c3, edge3)
    self:divideGrid(x, y + newLenght, newLenght, edge4, middle, edge3, c4)
end

function FractalMountain:heightInPos(x, z)
    --Interpolate position between 4 vertex
    local x1 = math.floor(x)
    local x2 = math.ceil(x)
    local z1 = math.floor(z)
    local z2 = math.ceil(z)

    local posX = x - x1
    local posZ = z - z1

    local x1z1 =self. plasma[x1 + z1 * self.terrainSize]
    local x1z2 =self. plasma[x1 + z2 * self.terrainSize]
    local x2z1 =self. plasma[x2 + z1 * self.terrainSize]
    local x2z2 =self. plasma[x2 + z2 * self.terrainSize]

    local interpX1 = (x1z2 - x1z1) * posZ + x1z1
    local interpX2 = (x2z2 - x2z1) * posZ + x2z1
    
    return ((interpX2 - interpX1) * posX + interpX1) * self. h
end