LoadScript("vector2")

local scrSize=Vector2:new{x=0,y=0}

local char=Vector2:new{x=16,y=96}
local charAttack=0
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

local enemies={
  {x=4,y=4,life=1}, 
  {x=18,y=6,life=1},
  {x=26,y=10,life=1},
  {x=34,y=14,life=1}
}
local enemyFrame=0

function Init()
  local displaySize=Display()
  scrSize.x=displaySize.x
  scrSize.y=displaySize.y  
end

function Update(timeDelta)
  CharMovementUpdate();
  CharAttackUpdate();
  UpdateScreenShake();
  ScrollPosition(scroll.x + shakeOffset.x, scroll.y + shakeOffset.y)
end

function Draw()
  RedrawDisplay()
  DrawEnemies()
  DrawChar()
  --DrawDebug()
end

function DrawDebug()
  local str = "x:" .. char.x .. ",y:" .. char.y
  DrawText(str,0,200,4,"medium",15)
end

function DrawChar()

  -- facing north
  if (charFacing == 0) then
    DrawSpriteBlock(6,char.x,char.y,2,2,charFrame >= charWalkFrInt)

    if (charAttack > 0) then
      DrawSpriteBlock(37,char.x+4,char.y-8)
    end

  -- facing south
  elseif (charFacing == 1) then
    DrawSpriteBlock(0,char.x,char.y,2,2,charFrame >= charWalkFrInt)

    if (charAttack > 0) then
      DrawSpriteBlock(37,char.x+4,char.y+16,1,1,false,true)
    end

  -- facing west
  elseif (charFacing == 2) then
    local id = 4
    if (charFrame < charWalkFrInt) then id = 2; end

    DrawSpriteBlock(id,char.x,char.y,2,2,true)

    if (charAttack > 0) then
      DrawSpriteBlock(36,char.x-8,char.y+4,1,1,true,false)
    end

  -- facing east
  else
    local id = 4
    if (charFrame < charWalkFrInt) then id = 2; end

    DrawSpriteBlock(id,char.x,char.y,2,2,false)

    if (charAttack > 0) then
      DrawSpriteBlock(36,char.x+16,char.y+4)
    end
  end
end

function DrawEnemies()
  local t = enemyFrame/60 * math.pi * 2
  local offset = math.sin(t)

  if     offset > 0.5  then offset = 1
  elseif offset < -0.5 then offset = -1
  else   offset = 0 
  end

  for key,val in ipairs(enemies) do
    if val.life > 0 then
      DrawSpriteBlock(64,val.x*8,val.y*8+offset,2,2,false)
    end
  end

  enemyFrame = enemyFrame+1
  if (enemyFrame >= 60) then enemyFrame = 0 end
end

function CharAttackUpdate()
  charAttack = charAttack-1
  if Button(Buttons.A, InputState.Down, 0) then
    charAttack = 10
  end

  -- check if we hit an enemy
  if (charAttack > 0) then

    local attackPoint = Vector2:new{x=char.x,y=char.y}
    
    if     (charFacing == 0) then attackPoint.y = char.y - 16
    elseif (charFacing == 1) then attackPoint.y = char.y + 16
    elseif (charFacing == 2) then attackPoint.x = char.x - 16
    elseif (charFacing == 3) then attackPoint.x = char.x + 16
    end

    for key,val in ipairs(enemies) do
      if val.life > 0 then

        local r1={x1=attackPoint.x, x2=attackPoint.x+16, y1=attackPoint.y, y2=attackPoint.y+16}
        local r2={x1=val.x*8,       x2=val.x*8+16,       y1=val.y*8,       y2=val.y*8+16}

        if IsIntersect(r1,r2) then
          val.life = val.life-1
          shakeTime = 10
        end
      end
    end
  end

end

function IsIntersect(r1,r2)

  if r1.x2 < r2.x1 or r1.x1 > r2.x2 then return false end 
  if r1.y2 < r2.y1 or r1.y1 > r2.y2 then return false end

  return true
end

function CharMovementUpdate()

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

  local newFacing = charFacing
  
  -- detect facing vertical
  if     (new.y < char.y) then newFacing = 0
  elseif (new.y > char.y) then newFacing = 1
  end

  -- detect facing horizontal, may override vertical facing
  if     (new.x < char.x) then newFacing = 2
  elseif (new.x > char.x) then newFacing = 3
  end

  -- don't move if facing changes
  if (newFacing != charFacing) then
    charFacing = newFacing
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
  local magnitude=1
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
