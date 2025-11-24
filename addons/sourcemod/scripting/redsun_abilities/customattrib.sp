#pragma semicolon 1
#pragma newdecls required

static int WallClimbCombo[MAXPLAYERS+1];

void CustomAttrib_AllPluginsLoaded()
{
	TF2EconDynAttribute attrib = new TF2EconDynAttribute();

	attrib.SetName("convert team on hit");
	attrib.SetClass("redsun.announcergun");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "");
	attrib.Register();

	attrib.SetName("banner rocket barrage");
	attrib.SetClass("redsun.bannerbarrage");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Barrage of %s rockets on use");
	attrib.Register();

	attrib.SetName("banner zombie summon");
	attrib.SetClass("redsun.bannersummon");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Spawns up to %s Zombie Scouts on use");
	attrib.Register();

	attrib.SetName("banner speed ammo");
	attrib.SetClass("redsun.bannerspeedammo");
	attrib.SetDescriptionFormat("precentage");
	attrib.SetCustom("description_ff2_string", "x%s movement speed and ammo regen on use");
	attrib.Register();

	attrib.SetName("add damagetype");
	attrib.SetClass("redsun.adddmgtype");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "");
	attrib.Register();

	attrib.SetName("remove damagetype");
	attrib.SetClass("redsun.adddmgtype");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "");
	attrib.Register();

	attrib.SetName("ignite on hit");
	attrib.SetClass("redsun.ignitehit");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "On Hit: Ignites target for %s seconds");
	attrib.Register();

	attrib.SetName("wall climb");
	attrib.SetClass("redsun.wallclimbhealth");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Able to climb walls but consumes %s health");
	attrib.Register();

	attrib.SetName("wall climb limit");
	attrib.SetClass("redsun.wallclimblimit");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Can climb %s times before touching the ground");
	attrib.Register();

	attrib.SetName("wall climb height");
	attrib.SetClass("redsun.wallclimbheight");
	attrib.SetDescriptionFormat("precentage");
	attrib.SetCustom("description_ff2_string", "x%s climb height multiplier");
	attrib.Register();

	attrib.SetName("wall climb speed");
	attrib.SetClass("redsun.wallclimbspeed");
	attrib.SetDescriptionFormat("precentage");
	attrib.SetCustom("description_ff2_string", "x%s climb horizontal velocity multiplier");
	attrib.Register();

	attrib.SetName("projectile explodes");
	attrib.SetClass("redsun.projectileexplodes");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Projectile explodes dealing %s damage");
	attrib.Register();

	attrib.SetName("heal on any hit");
	attrib.SetClass("redsun.healanyhit");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Restores %s health on dealing damage");
	attrib.Register();

	attrib.SetName("extra damage falloff");
	attrib.SetClass("redsun.sniperdmgfalloff");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "Damage is affected by range");
	attrib.Register();

	attrib.SetClass("redsun.displayonly");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "%s");
	attrib.SetName("A DISPLAY ONLY");
	attrib.Register();
	attrib.SetName("B DISPLAY ONLY");
	attrib.Register();

	delete attrib;
}

stock Action CustomAttrib_PlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType)
{
	Action action;

	float value;
	if(weapon != -1 && HasEntProp(weapon, Prop_Send, "m_AttributeList"))
	{
		if(Attrib_Get(weapon, "convert team on hit", value))
		{
			UpdateAction(action, Announcer_ConvertPlayer(value, victim, attacker, damage, damagetype, weapon, critType));
		}

		if(Attrib_Get(weapon, "add damagetype", value))
		{
			damagetype |= RoundFloat(value);
			UpdateAction(action, Plugin_Changed);
		}

		if(Attrib_Get(weapon, "remove damagetype", value))
		{
			damagetype &= ~RoundFloat(value);
			UpdateAction(action, Plugin_Changed);
		}

		if(Attrib_Get(weapon, "ignite on hit", value))
			TF2_IgnitePlayer(victim, attacker, value);

		if(Attrib_Get(weapon, "extra damage falloff", value))
		{
			float pos1[3], pos2[3];
			GetClientAbsOrigin(victim, pos1);
			GetClientAbsOrigin(attacker, pos2);

			value *= value;

			float distance = GetVectorDistance(pos1, pos2, true);
			if(distance > value)
			{
				float nerf = 1.0 + ((((distance - value) / value)) * 0.5);
				if(nerf > 2.0)
					nerf = 2.0;
				
				damage /= nerf;
			}
		}
	}
	
	if(attacker > 0 && attacker <= MaxClients)
	{
		value = Attrib_FindOnPlayer(attacker, "heal on any hit");
		if(value)
			SetEntityHealth(attacker, GetClientHealth(attacker) + RoundFloat(value));
	}

	return action;
}

stock Action CustomAttrib_ObjectTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action;
	
	if(weapon != -1 && HasEntProp(weapon, Prop_Send, "m_AttributeList"))
	{
		float value;
		if(Attrib_Get(weapon, "convert team on hit", value))
		{
			UpdateAction(action, Announcer_ConvertBuilding(victim, attacker, damage, damagetype, weapon));
		}

		if(Attrib_Get(weapon, "add damagetype", value))
		{
			damagetype |= RoundFloat(value);
			UpdateAction(action, Plugin_Changed);
		}

		if(Attrib_Get(weapon, "remove damagetype", value))
		{
			damagetype &= ~RoundFloat(value);
			UpdateAction(action, Plugin_Changed);
		}
	}

	return action;
}

void CustomAttrib_PlayerRunCmd(int client)
{
	if(WallClimbCombo[client])
	{
		if(GetEntityFlags(client) & FL_ONGROUND)
			WallClimbCombo[client] = 0;
	}
}

void CustomAttrib_CalcIsAttackCritical(int client, int weapon)
{
	float value;
	if(Attrib_Get(weapon, "wall climb", value))
	{
		bool buffed = TF2_IsPlayerInCondition(client, TFCond_CritCola);

		if(!buffed && GetClientHealth(client) <= RoundToCeil(value))
			return;

		if(!buffed && Attrib_Get(weapon, "wall climb limit", value))
		{
			if(RoundFloat(value) <= WallClimbCombo[client])
				return;
		}

		float pos[3], vec[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, vec);

		//Check for colliding entities
		Handle trace = TR_TraceRayFilterEx(pos, vec, MASK_PLAYERSOLID, RayType_Infinite, Trace_DontHitEntity, client);
		if(TR_DidHit(trace))
		{
			int entity = TR_GetEntityIndex(trace);
			
			char classname[64];
			GetEntityClassname(entity, classname, sizeof(classname));
			if(!StrEqual(classname, "worldspawn") && StrContains(classname, "prop_") == -1)
				return;
			
			TR_GetPlaneNormal(trace, vec);
			GetVectorAngles(vec, vec);

			if((vec[0] < 30.0 || vec[0] > 330.0) && vec[0] > -30.0)
			{
				TR_GetEndPosition(vec, trace);
				float dist = GetVectorDistance(pos, vec, true);
				if(dist < 10000.0)
				{
					float height = 1.0;
					Attrib_Get(weapon, "wall climb height", value);

					float speed = 1.0;
					Attrib_Get(weapon, "wall climb speed", value);

					GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
					vec[0] *= speed;
					vec[1] *= speed;
					vec[2] = 750.0 * height;
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
					
					WallClimbCombo[client]++;

					if(!buffed && value)
						SDKHooks_TakeDamage(client, 0, client, value, DMG_PREVENT_PHYSICS_FORCE);
					
					SetEntityFlags(client, GetEntityFlags(client) & ~FL_ONGROUND);
				}
			}
		}

		delete trace;
	}
}

void CustomAttrib_ProjectileTouch(int client, int weapon, int projectile)
{
	float value;
	if(Attrib_Get(weapon, "projectile explodes", value))
	{
		TF2_AddCondition(client, TFCond_Buffed, 0.01);

		float pos[3];
		GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos);
		TF2_Explode(client, pos, value, 150.0, "ExplosionCore_MidAir", "Weapon_Airstrike.Explosion");
	}
}

void CustomAttrib_DeployBanner(int client)
{
	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);

	if(weapon != -1)
	{
		float value;
		if(Attrib_Get(weapon, "banner rocket barrage", value))
		{
			int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
			if(primary != -1)
			{
				ApplyTempAttribute(primary, "fire rate bonus HIDDEN", 0.1, 5.0);

				char classname[36];
				GetEntityClassname(primary, classname, sizeof(classname));
				if(!StrContains(classname, "tf_weapon_particle_cannon"))
				{
					ApplyTempAttribute(primary, "Reload time increased", 0.1, 5.0);
				}
				else
				{
					ApplyTempAttribute(primary, "crits_become_minicrits", 1.0, 5.0);
					SetEntProp(primary, Prop_Data, "m_iClip1", GetEntProp(primary, Prop_Data, "m_iClip1") + RoundFloat(value));
				}
			}
		}

		if(Attrib_Get(weapon, "banner zombie summon", value))
		{
			SummonZombies(client, RoundFloat(value));
		}

		if(Attrib_Get(weapon, "banner speed ammo", value))
		{
			ApplyTempAttribute(weapon, "move speed bonus", value, 9.5);
			ApplyTempAttribute(weapon, "ammo regen", 100.0, 10.1);
			TF2_AddCondition(client, TFCond_Dazed, 0.001);
		}
	}
}

static void SummonZombies(int client, int amount)
{
	if(amount > 0)
	{
		int team = GetClientTeam(client);

		float pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		
		int victims;
		int[] victim = new int[MaxClients - 1];
		for(int target = 1; target <= MaxClients; target++)
		{
			if(client == target || !IsClientInGame(target))
				continue;
			
			if(FF2R_GetBossData(target) || IsPlayerAlive(target) || FF2R_GetClientMinion(target))
				continue;
			
			if(GetClientTeam(target) != team || TF2_GetPlayerClass(target) == TFClass_Engineer)
				continue;
			
			victim[victims] = target;
			victims++;
		}

		if(victims > amount)
			victims = amount;
		
		for(int i; i < victims; i++)
		{
			int target = victim[i];
			
			ChangeClientTeam(target, team);
			FF2R_SetClientMinion(target, 2);

			int desired = GetEntProp(target, Prop_Send, "m_iDesiredPlayerClass");
			TF2_SetPlayerClass(target, TFClass_Scout);
			
			TF2_RespawnPlayer(target);
			SetEntProp(target, Prop_Send, "m_bDucked", true);
			SetEntityFlags(target, GetEntityFlags(target) | FL_DUCKING);

			TeleportEntity(target, pos);
			
			TF2_AddCondition(target, TFCond_HalloweenKartNoTurn, 2.0);
			TF2_AddCondition(target, TFCond_UberchargedCanteen, 2.0);
			TF2_AddCondition(target, TFCond_CritOnDamage, _, client);
			ClientCommand(target, "playgamesound ui/system_message_alert.wav");

			SetEntProp(target, Prop_Send, "m_iDesiredPlayerClass", desired);

			TF2_RemoveAllWeapons(target);

			static WeaponData weapon;
			if(!weapon.Index)
			{
				// Weapon
				weapon.Setup("tf_weapon_bat", 190, "", true);
				weapon.Quality = 0;
				weapon.Level = 1;
			}

			int entity = TF2Items_CreateFromStruct(target, weapon);
			if(entity != -1)
			{
				SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", target);
				Attrib_Set(entity, "heal on hit for rapidfire", 15.0);
				Attrib_Set(entity, "mod weapon blocks healing", 1.0);
				Attrib_Set(entity, "reduced_healing_from_medics", 0.0);
				Attrib_Set(entity, "mult_patient_overheal_penalty_active", 0.0);
				CreateTimer(0.3, ZombieHealthDegen, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}

			SetVariantString("TLK_RESURRECTED");
			AcceptEntityInput(target, "SpeakResponseConcept");
		}
	}
}

static Action ZombieHealthDegen(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		float lost;
		Attrib_Get(entity, "max health additive penalty", lost);
		if(lost > -124.0)
			Attrib_Set(entity, "max health additive penalty", lost - 1.0);

		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(owner > 0 && owner <= MaxClients && IsPlayerAlive(owner))
		{
			SDKHooks_TakeDamage(owner, owner, owner, lost <= -124.0 ? 100.0 : 2.0, DMG_GENERIC);
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}