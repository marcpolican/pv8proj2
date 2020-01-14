LoadScript("vector2")

local scrSize=Vector2:new{x=0,y=0}

local char=Vector2:new{x=16,y=96}
local charSpd=1
local charSize=Vector2:new{x=14,y=15}
local charFrame=0
local charFacing=1 -- 0=north, 1=south, 2=west, 3=east
local charWalkFrInt=10

local scroll=Vector2:new{x=0,y=0}
local scrollMax=Vector2:new{x=96,y=64}

local shakeTime=0
local shakeDir=Vector2:new{x=0,y=0}
local shakeOffset=Vector2:new{x=0,y=0}

local enemies={{x=4,y=4}, {x=18,y=6}}

function Init()
  local displaySize=Display()
  scrSize.x=displaySize.x
  scrSize.y=displaySize.y  
end

function Update(timeDelta)
  CharMovement();
  UpdateScreenShake();
  ScrollPosition(scroll.x + shakeOffset.x, scroll.y + shakeOffset.y)
end

function Draw()
  RedrawDisplay()
  DrawEnemies()
  DrawChar()
  DrawDebug()
end

function DrawDebug()
  local str = "x:" .. char.x .. ",y:" .. char.y
  DrawText(str,0,200,4,"medium",15)
end

function DrawChar()

  -- facing north
  if (charFacing == 0) then
    DrawSpriteBlock(6,char.x,char.y,2,2,charFrame >= charWalkFrInt)

  -- facing south
  elseif (charFacing == 1) then
    DrawSpriteBlock(0,char.x,char.y,2,2,charFrame >= charWalkFrInt)

  -- facing west
  elseif (charFacing == 2) then
    if (charFrame < charWalkFrInt) then
      DrawSpriteBlock(2,char.x,char.y,2,2,true)
    else
      DrawSpriteBlock(4,char.x,char.y,2,2,true)
    end

  -- facing east
  else
    if (charFrame < charWalkFrInt) then
      DrawSpriteBlock(2,char.x,char.y,2,2,false)
    else
      DrawSpriteBlock(4,char.x,char.y,2,2,false)
    end
  end
end

function DrawEnemies()
  for key,val in ipairs(enemies) do
    DrawSpriteBlock(64,val.x*8,val.y*8,2,2,false)
  end
end

function CharMovement()

  local new=Vector2:new{x=char.x, y=char.y}

  -- going left
  if Button(Buttons.Left,InputState.Down,0) then
    new.x = char.x-charSpd;

  -- going right
  elseif Button(Buttons.Right,InputState.Down,0) then
    new.x = char.x+charSpd;

  end

  -- going up
  if Button(Buttons.Up,InputState.Down,0) then
    new.y = char.y-charSpd

  -- going down
  elseif Button(Buttons.Down,InputState.Down,0) then
    new.y = char.y+charSpd

  end

  -- if didn't move lets get out of here
  if (char.x == new.x and char.y == new.y) then
    return
  end
  
  -- detect facing vertical
  if (new.y < char.y) then
    charFacing=0
  elseif (new.y > char.y) then
    charFacing=1
  end

  -- detect facing horizontal, may override vertical facing
  if (new.x < char.x) then
    charFacing=2
  elseif (new.x > char.x) then
    charFacing=3
  end

  -- check if will hit enemy
  if (WillCharCollide(new.x,new.y,10)) then 
    shakeTime = 18
    return
  end

  -- check collisions with walls, allow sliding
  if (WillCharCollide(new.x, new.y, 0) == false) then
    char.x = new.x
    char.y = new.y
    charFrame = (charFrame+1) % (charWalkFrInt*2)

  elseif (WillCharCollide(char.x, new.y, 0) == false) then
    char.y = new.y
    charFrame = (charFrame+1) % (charWalkFrInt*2)

  elseif (WillCharCollide(new.x, char.y, 0) == false) then
    char.x = new.x
    charFrame = (charFrame+1) % (charWalkFrInt*2)
  end

  -- compute tilemap scroll 
  local relX = (char.x-scroll.x) / scrSize.x
  local relY = (char.y-scroll.y) / scrSize.y

  if (relX < 0.5 and scroll.x > 0) then
    scroll.x = scroll.x-1
  elseif (relX > 0.5 and scroll.x < scrollMax.x) then
    scroll.x = scroll.x+1
  end

  if (relY < 0.5 and scroll.y > 0) then
    scroll.y = scroll.y-1
  elseif (relY > 0.5 and scroll.y < scrollMax.y) then
    scroll.y = scroll.y+1
  end

end

function WillCharCollide(x,y,checkFlag)

  -- top left
  local flag = Flag(x/8, y/8)
  if (flag == checkFlag) then return true end

  -- top right
  flag = Flag((x+charSize.x)/8, y/8)
  if (flag == checkFlag) then return true end

  -- bottom right
  flag = Flag((x+charSize.x)/8, (y+charSize.y)/8)
  if (flag == checkFlag) then return true end

  -- bottom left
  flag = Flag(x/8, (y+charSize.y)/8)
  if (flag == checkFlag) then return true end

  return false
end

function UpdateScreenShake()
  if (shakeTime <= 0) then return end;

  local multiples=3
  local magnitude=3
  local step = shakeTime % multiples;
  if (step == 0) then
    shakeDir.x = (math.random() * magnitude * 2) - magnitude
    shakeDir.y = (math.random() * magnitude * 2) - magnitude
  end

  local t = multiples-step/multiples;

  shakeOffset.x = shakeDir.x * t;
  shakeOffset.y = shakeDir.y * t;
  shakeTime = shakeTime - 1

  if (shakeTime == 0) then
    shakeOffset.x = 0
    shakeOffset.y = 0
  end
end
