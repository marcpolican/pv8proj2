local delay=0
local delayTime=2
local totalSprites=200
local char=nil
local charX=16
local charY=96
local scrWidth=0
local scrHeight=0

local horMovCnt=0
local charSpd=1
local charW=14
local charH=15
local deltaSpd=0.25
local jumpHeight=20
local jumpCur=0
local jumpDir=0
local charFrame=0
local charFacing=1 -- 0=north, 1=south, 2=west, 3=east
local charWalkFrInt=10
local scroll=NewPoint(0,0)
local scrollMax=NewPoint(96,64)

function Init()
  local displaySize=Display()
  scrWidth=displaySize.x
  scrHeight=displaySize.y  
end

function Update(timeDelta)
  CharMovement();
  ScrollPosition(scroll.x, scroll.y)
end

function Draw()
  RedrawDisplay()
  DrawChar()
  DrawDebug()
end

function DrawDebug()
  local str = "x:" .. charX .. ",y:" .. charY
  DrawText(str,0,200,4,"medium",15)

end

function DrawChar()

  if (charFacing == 0) then
    DrawSpriteBlock(6,charX,charY,2,2,charFrame >= charWalkFrInt)

  elseif (charFacing == 1) then
    DrawSpriteBlock(0,charX,charY,2,2,charFrame >= charWalkFrInt)

  elseif (charFacing == 2) then
    if (charFrame < charWalkFrInt) then
      DrawSpriteBlock(2,charX,charY,2,2,true)
    else
      DrawSpriteBlock(4,charX,charY,2,2,true)
    end

  else
    if (charFrame < charWalkFrInt) then
      DrawSpriteBlock(2,charX,charY,2,2,false)
    else
      DrawSpriteBlock(4,charX,charY,2,2,false)
    end
  end




end

function CharMovement()

  local newX=charX
  local newY=charY
  local moved=false

  -- going left
  if Button(Buttons.Left,InputState.Down,0) then
    newX = charX-charSpd;
    moved=true

  -- going right
  elseif Button(Buttons.Right,InputState.Down,0) then
    newX = charX+charSpd;
    moved=true

  end

  -- going up
  if Button(Buttons.Up,InputState.Down,0) then
    newY = charY-charSpd
    moved=true

  -- going down
  elseif Button(Buttons.Down,InputState.Down,0) then
    newY = charY+charSpd
    moved=true

  end

  if (moved == false) then
    return
  end
  
  if (newY < charY) then
    charFacing=0
  elseif (newY > charY) then
    charFacing=1
  end

  if (newX < charX) then
    charFacing=2
  elseif (newX > charX) then
    charFacing=3
  end

  if (WillCharCollide(newX, newY) == false) then
    charX = newX
    charY = newY
    charFrame = (charFrame+1) % (charWalkFrInt*2)
  elseif (WillCharCollide(charX, newY) == false) then
    charY = newY
    charFrame = (charFrame+1) % (charWalkFrInt*2)
  elseif (WillCharCollide(newX, charY) == false) then
    charX = newX
    charFrame = (charFrame+1) % (charWalkFrInt*2)
  end

  local relX = (charX-scroll.x) / scrWidth
  local relY = (charY-scroll.y) / scrHeight

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

function WillCharCollide(x,y)

  local flag = Flag(x/8, y/8)
  if (flag == 0) then return true end

  flag = Flag((x+charW)/8, y/8)
  if (flag == 0) then return true end

  flag = Flag((x+charW)/8, (y+charH)/8)
  if (flag == 0) then return true end

  flag = Flag(x/8, (y+charH)/8)
  if (flag == 0) then return true end

  return false
end
