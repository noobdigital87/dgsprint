local iplayer = {}

local states = {
	is_sprinting = false
}

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()

    	if not iplayer[name] then
        	iplayer[name] = states
    	end
end)

core.register_on_leaveplayer(function(player)
    	local name = player:get_player_name()
    	iplayer[name] = nil
end)

local states = {
	is_sprinting = false
}

local JUMP_BOOST = 0.1
local SPEED_BOOST = 0.8

local monoids = core.get_modpath("player_monoids")
local pova_mod = core.get_modpath("pova")
local mod_playerphysics = core.get_modpath("playerphysics")

local function Sprint(player, sprinting)

	if not player then return end

	local name = player:get_player_name()
	local def = player:get_physics_override() -- get player physics

	if sprinting == true and not iplayer[name].is_sprinting then
		iplayer[name].is_sprinting = true
		if pova_mod then
			pova.add_override(name, "sprint", {
					speed = SPEED_BOOST, jump = JUMP_BOOST})

			pova.do_override(player)
		elseif monoids then
			iplayer[name].sprint = player_monoids.speed:add_change(
					player, def.speed + SPEED_BOOST)

			iplayer[name].jump = player_monoids.jump:add_change(
					player, def.jump + JUMP_BOOST)

		elseif mod_playerphysics then
			playerphysics.add_physics_factor(player, "speed", "dg_sprint:sprint",
					def.speed + SPEED_BOOST)

			playerphysics.add_physics_factor(player, "jump", "dg_sprint:jump",
					def.jump + JUMP_BOOST)
		else
			player:set_physics_override({
				speed = def.speed + SPEED_BOOST,
				jump = def.jump + JUMP_BOOST,
			})

		end
	elseif sprinting == false and iplayer[name].is_sprinting then
		iplayer[name].is_sprinting = false
		if pova_mod then
			pova.del_override(name, "dg_sprint:sprint")
			pova.do_override(player)
		elseif monoids then
			player_monoids.speed:del_change(player, iplayer[name].sprint)
			player_monoids.jump:del_change(player, iplayer[name].jump)
		elseif mod_playerphysics then
			playerphysics.remove_physics_factor(player, "dg_sprint:sprint")
			playerphysics.remove_physics_factor(player, "dg_sprint:jump")
		else
			player:set_physics_override({
				speed = def.speed - SPEED_BOOST,
				jump = def.jump - JUMP_BOOST,
			})

		end
	end
end

core.register_globalstep(function(dtime)
	local players = core.get_connected_players()
	for _, player in ipairs(players) do
		Sprint(player, true)
	end
	
end)
