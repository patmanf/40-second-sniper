require "/scripts/vec2.lua"

local Cfg
local Random
local LastPos
local StillTimer = 0

function init()
  Random = sb.makeRandomSource()
  
  Cfg = root.assetJson("/pat/trainedsniper.sussy")
  Cfg.repeatSeconds = Cfg.shootSeconds - Cfg.repeatSeconds
  
  Cfg.angleRange[1] = math.rad(Cfg.angleRange[1])
  Cfg.angleRange[2] = math.rad(Cfg.angleRange[2])
  if Cfg.projectileParams.power == -1 then
    Cfg.projectileParams.power = math.huge
  end

  LastPos = mcontroller.position()

  script.setUpdateDelta(Cfg.updateDelta)
  message.setHandler("pat_trainedsniper", fire)
end

function update(dt)
  if world.getProperty("invinciblePlayers") or world.getProperty("nonCombat") then return end

  local pos = mcontroller.position()

  if vec2.eq(pos, LastPos) then
    StillTimer = StillTimer + dt

    if StillTimer >= Cfg.shootSeconds then
      StillTimer = Cfg.repeatSeconds
      fire()
    end
  else
    StillTimer = 0
    LastPos = pos
  end
end

function fire()
  local angle = Random:randf(Cfg.angleRange[1], Cfg.angleRange[2])

  local spawnPos = vec2.withAngle(angle, Cfg.distance)
  local aimVec = vec2.withAngle(angle + sb.nrand(Cfg.inaccuracy, 0), -1)

  if Random:randb() then
    spawnPos[1] = -spawnPos[1]
    aimVec[1] = -aimVec[1]
  end

  spawnPos = vec2.add(mcontroller.position(), spawnPos)

  world.spawnProjectile(Cfg.projectileType, spawnPos, nil, aimVec, false, Cfg.projectileParams)
end
