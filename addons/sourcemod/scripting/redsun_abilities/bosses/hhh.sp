/*
	HHH Jr. from VSH Rewrite
	
	"rage_hhh_ghost"
	{
		"slot"		"0"					// Ability slot
		"model"		"models/props_halloween/ghost.mdl"	// Model swap
		"duration"	"8.0"					// Ability duration
		"interval"	"3"					// Damage every X frames
		"damage"	"1.0"					// Damage dealt per interval
		"radius"	"400.0"					// Effect radius
		"leech"		"1.0"					// Boss healing per victim per interval
		"building"	"3.0"					// Building damage multiplier
		"pull"		"30.0"					// Pull force
		"spook"		"150"					// Spook every X frames
		
		"plugin_name"	"ff2r_redsun_abilities"
	}

	"sound_hhh_ghost"
	{
	}
*/

#pragma semicolon 1
#pragma newdecls required

#define GHOST_MODEL	"models/props_halloween/ghost.mdl"
#define PARTICLE_GHOST	"ghost_appearation"
#define PARTICLE_BEAM	"passtime_beam"

static int ParticleRef[MAXENTITIES] = {INVALID_ENT_REFERENCE, ...};

void HHH_Ability(int client, const char[] ability, AbilityData cfg)
{
	if(!StrContains(ability, "rage_hhh_ghost", false))
	{
		char buffer[PLATFORM_MAX_PATH];
		cfg.GetString("model", buffer, sizeof(buffer), GHOST_MODEL);
		if(buffer[0])
			PrecacheModel(buffer);
		
		SetVariantString(buffer);
		AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
		
		float origin[3];
		GetClientAbsOrigin(client, origin);
		
		//Create poof particle
		CreateParticleEffect(PARTICLE_GHOST, origin, _, 3.0);
		
		//Create "centre" particle dummy for beams to connect it
		origin[2] += 42.0;
		ParticleRef[client] = EntIndexToEntRef(CreateParticleEffect("", origin, client));
		
		//Stun and Fly
		float duration = cfg.GetFloat("duration", 8.0);
		//TF2_StunPlayer(client, duration, 0.0, TF_STUNFLAG_GHOSTEFFECT|TF_STUNFLAG_NOSOUNDOREFFECT, 0);
		TF2_AddCondition(client, TFCond_SwimmingNoEffects, duration);
		TF2_AddCondition(client, TFCond_ImmuneToPushback, duration);
		SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + duration);
		
		//Get active weapon and dont render
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
			SetEntityRenderColor(weapon, _, _, _, 0);
		}
		
		//Thirdperson
		SetVariantInt(true);
		AcceptEntityInput(client, "SetForcedTauntCam");

		float radius = cfg.GetFloat("radius", 400.0);

		DataPack pack = new DataPack();
		RequestFrame(HHH_GhostFrame, pack);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteFloat(duration + GetGameTime());
		pack.WriteCell(cfg.GetInt("interval", 3));
		pack.WriteFloat(cfg.GetFloat("damage", 1.0));
		pack.WriteFloat(radius * radius);
		pack.WriteFloat(cfg.GetFloat("leech", 1.0));
		pack.WriteFloat(cfg.GetFloat("building", 3.0));
		pack.WriteFloat(cfg.GetFloat("pull", 10.0));
		pack.WriteCell(cfg.GetInt("spook", 150));
	}
}

static void HHH_GhostFrame(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		if(GetGameTime() < pack.ReadFloat() && IsPlayerAlive(client) && FF2R_GetBossData(client))	// Duration
		{
			static int frames;
			if(((++frames) % pack.ReadCell()) == 0)	// Interval
			{
				float damage = pack.ReadFloat();
				float radius = pack.ReadFloat();
				float leech = pack.ReadFloat();
				float buildMulti = pack.ReadFloat();
				float pull = pack.ReadFloat();

				float totalHealing;

				float origin[3];
				GetClientAbsOrigin(client, origin);
				origin[2] += 42.0;
				
				//Arrays of spooked clients
				int[] spooked = new int[MaxClients];
				int length = 0;
				
				//Player interaction
				for(int victim = 1; victim <= MaxClients; victim++)
				{
					if(victim == client)
						continue;
					
					bool spook = false;
					
					if(IsClientInGame(victim) && IsPlayerAlive(victim) && GetClientTeam(victim) != GetClientTeam(client))
					{
						float targetOrigin[3];
						GetClientAbsOrigin(victim, targetOrigin);
						targetOrigin[2] += 42.0;
						if(GetVectorDistance(origin, targetOrigin, true) <= radius && IsPointsClear(origin, targetOrigin))
						{
							//Victim got spooked
							spook = true;
							spooked[length] = victim;
							length++;
								
							//Pull victim towards boss
							if(pull)
							{
								float pullVelocity[3];
								MakeVectorFromPoints(targetOrigin, origin, pullVelocity);
								
								//We don't want players to helplessly hover slightly above ground if the boss is above them, so we don't modify their vertical velocity
								pullVelocity[2] = 0.0;
								
								NormalizeVector(pullVelocity, pullVelocity);
								ScaleVector(pullVelocity, pull);
								
								//Consider their current velocity
								float targetVelocity[3];
								GetEntPropVector(victim, Prop_Data, "m_vecVelocity", targetVelocity);
								AddVectors(targetVelocity, pullVelocity, pullVelocity);
								
								TeleportEntity(victim, _, _, pullVelocity);
							}

							//Set time when victim entered
							if(ParticleRef[victim] == INVALID_ENT_REFERENCE)
							{
								ParticleRef[victim] = EntIndexToEntRef(CreateParticleEffect(PARTICLE_BEAM, targetOrigin, victim, .controlPoint = EntRefToEntIndex(ParticleRef[client])));
							}

							int health = GetClientHealth(victim);
							SDKHooks_TakeDamage(victim, client, client, damage, DMG_PREVENT_PHYSICS_FORCE);

							if(leech && health != GetClientHealth(victim))	//Health is lost
							{
								totalHealing += leech;
							}
						}
					}
					
					//Check if beam ent need to be killed, from out of range or client death/disconnect
					if(!spook && ParticleRef[victim] != INVALID_ENT_REFERENCE)
					{
						Timer_RemoveEntity(null, ParticleRef[victim]);
						ParticleRef[victim] = INVALID_ENT_REFERENCE;
					}
				}
				
				//Building interaction -- you basically just damage them
				if(buildMulti > 0.0)
				{
					int building = MaxClients+1;
					
					while((building = FindEntityByClassname(building, "obj_*")) > MaxClients)
					{
						bool bLinked = false;
						if(GetEntProp(building, Prop_Send, "m_iTeamNum") != GetClientTeam(client))
						{
							float targetOrigin[3];
							GetEntPropVector(building, Prop_Send, "m_origin", targetOrigin);
							
							//Teleporters are tiny, so the beam must be down low
							char classname[32];
							GetEntityClassname(building, classname, sizeof(classname));
							if(StrEqual(classname, "obj_teleporter"))
								targetOrigin[2] += 5.0;
							else
								targetOrigin[2] += 42.0;
							
							if(GetVectorDistance(origin, targetOrigin, true) <= radius && IsPointsClear(origin, targetOrigin))
							{
								bLinked = true;

								if(ParticleRef[building] == INVALID_ENT_REFERENCE)
								{
									ParticleRef[building] = EntIndexToEntRef(CreateParticleEffect(PARTICLE_BEAM, targetOrigin, building, .controlPoint = EntRefToEntIndex(ParticleRef[client])));
								}

								SDKHooks_TakeDamage(building, client, client, damage * buildMulti, DMG_PREVENT_PHYSICS_FORCE);
							}
								
							if(!bLinked && ParticleRef[building] != INVALID_ENT_REFERENCE)
							{
								Timer_RemoveEntity(null, ParticleRef[building]);
								ParticleRef[building] = INVALID_ENT_REFERENCE;
							}
						}
					}
				}

				if(totalHealing > 0.0)
				{
					int healing = RoundFloat(totalHealing);
					ApplyAllyHealEvent(client, client, healing);
					SetEntityHealth(client, GetClientHealth(client) + healing);
				}
				
				//Random Spook effects, 2.5 sec cooldown
				if((frames % pack.ReadCell()) == 0)
				{
					if(length != 0)
					{
						SortIntegers(spooked, length, Sort_Random);
						
						//Visual/Sound effects
						for(int i = 0; i < length; i++)
						{
							ScreenFade(spooked[i], 1000, 0, 1, 160, 56, 204, 160);
							
							//Attempt to change to a random weapon slot
							FakeClientCommand(spooked[i], "slot%d", GetRandomInt(1, 3));
						}

						FF2R_EmitBossSound(spooked, length, "sound_hhh_ghost", client);
						
						//Random teleports
						if(length >= 2)
						{
							int teleport1 = spooked[length-2];
							int teleport2 = spooked[length-1];
							
							float pos1[3], pos2[3];
							GetClientAbsOrigin(teleport1, pos1);
							GetClientAbsOrigin(teleport2, pos2);

							SetEntProp(teleport1, Prop_Send, "m_bDucked", true);
							SetEntityFlags(teleport1, GetEntityFlags(teleport1) | FL_DUCKING);
							TeleportEntity(teleport1, pos2);
							
							SetEntProp(teleport2, Prop_Send, "m_bDucked", true);
							SetEntityFlags(teleport2, GetEntityFlags(teleport2) | FL_DUCKING);
							TeleportEntity(teleport2, pos1);
						}
					}
				}
			}

			RequestFrame(HHH_GhostFrame, pack);
			return;
		}
		else
		{
			//Update model
			BossData boss = FF2R_GetBossData(client);
			if(boss)
			{
				char buffer[PLATFORM_MAX_PATH];
				boss.GetString("model", buffer, sizeof(buffer));
				SetVariantString(buffer);
				AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
			}
			
			//Create poof particle
			float origin[3];
			GetClientAbsOrigin(client, origin);
			CreateParticleEffect(PARTICLE_GHOST, origin, _, 3.0);
		
			//Get active weapon and make it visible again
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(weapon))
			{
				SetEntityRenderMode(weapon, RENDER_NORMAL);
				SetEntityRenderColor(weapon, _, _, _, 255);
			}
			
			//Firstperson
			SetVariantInt(false);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}
	}
	
	for(int entity; entity < sizeof(ParticleRef); entity++)
	{
		if(ParticleRef[entity] != INVALID_ENT_REFERENCE)
		{
			Timer_RemoveEntity(null, ParticleRef[entity]);
			ParticleRef[entity] = INVALID_ENT_REFERENCE;
		}
	}

	delete pack;
}