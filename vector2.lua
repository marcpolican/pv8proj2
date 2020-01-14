-- Meta class
Vector2 = {x = 0, y = 0}

-- Derived class method new

function Vector2:new (o,x,y)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.x = x or 0
   self.y = y or 0
   return o
end

-- Derived class method printArea

--function Rectangle:printArea ()
--   print("The area of Rectangle is ",self.area)
--end
