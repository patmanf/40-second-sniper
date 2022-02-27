require "/scripts/vec2.lua"

function init()
	script.setUpdateDelta(30)
	
	stillTimer = 0
	shootTime = 40
	lastPos = mcontroller.position()
	
	parameters = {
		movementSettings = {collisionEnabled = false},
		damageTeam = {type = "indiscriminate"},
		damageType = "IgnoresDef",
		power = math.huge,
		speed = 500,
		processing = "?scalenearest=3;1",
		periodicActions = {
			{
				["time"] = 0.22,
				["repeat"] = false,
				action = "sound",
				options = {"/sfx/gun/sniper3.ogg"}
			},
			{
				["time"] = 0.01,
				["repeat"] = true,
				action = "particle",
				specification = {
					type = "ember",
					color = {0,0,0,0},
					light = {100,100,50},
					timeToLive = 0.01
				}
			}
		}
	}
	
	message.setHandler("pat_trainedsniper", fire)
end

function update(dt)
	local pos = mcontroller.position()
	
	if vec2.eq(pos, lastPos) and world.type() ~= "unknown" and status.resource("health") > 0 then
		stillTimer = stillTimer + dt
		
		if stillTimer >= shootTime then
			stillTimer = shootTime - 1
			fire(pos)
		end
	elseif stillTimer > 0 then
		stillTimer = math.max(0, stillTimer - dt * 4)
	end
	
	lastPos = pos
end

function fire(pos)
	local angle = math.random(50, 80) / 180 * math.pi
	if math.random(0, 1) == 0 then
		angle = angle * -1
	end
	local vec = vec2.rotate({0, -1}, angle)
	local fpos = vec2.add(pos or mcontroller.position(), vec2.mul(vec, -150))
	
	world.spawnProjectile("standardbullet", fpos, nil, vec, false, parameters)
end