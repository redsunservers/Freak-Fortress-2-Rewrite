/*
	Announcer from VSH Rewrite
*/

#pragma semicolon 1
#pragma newdecls required

static Handle ConvertTimer[MAXPLAYERS+1];

void Announcer_PlayerSpawn(int client)
{
	// Respawned, cancel the timer
	if(ConvertTimer[client])
	{
		SetEntityFlags(client, (GetEntityFlags(client) & ~FL_NOTARGET));
		delete ConvertTimer[client];
	}
}

Action Announcer_ConvertPlayer(float time, int victim, int &attacker, float &damage, int &damagetype, int &weapon, CritType &critType)
{
	// Don't convert other bosses or minions
	if(FF2R_GetBossData(victim) || FF2R_GetClientMinion(victim))
	{
		damagetype |= DMG_CRIT;
		critType = CritType_Crit;
		return Plugin_Changed;
	}

	if(ConvertTimer[victim])
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	int team = GetClientTeam(attacker);

	// Remove when we add spectator support (CTeam sdkcalls)
	if(team <= TFTeam_Spectator)
		return Plugin_Continue;
	
	SetEntityFlags(victim, (GetEntityFlags(victim) | FL_NOTARGET));

	DataPack pack = new DataPack();
	ConvertTimer[victim] = CreateTimer(0.0, AnnouncerSwapTimer, pack);
	pack.WriteCell(victim);
	pack.WriteCell(GetClientUserId(victim));
	pack.WriteFloat(GetGameTime() + time);
	pack.WriteCell(team);

	//Alert teammates, herself and unconverted minions that the victim is about to change teams
	TFClassType class = TF2_GetPlayerClass(victim);
	if(class >= TFClass_Unknown && view_as<int>(class) < sizeof(ClassName))
	{
		char message[64];
		FormatEx(message, sizeof(message), "A%s %s was hit and will switch teams!", class == TFClass_Engineer ? "n" : "", ClassName[class]);
		AnnouncerShowAnnotation(attacker, victim, message, time);
	}

	FF2R_EmitBossSoundToClient(attacker, "sound_announcer_swap", attacker, "1");
	FF2R_EmitBossSoundToClient(victim, "sound_announcer_swap", attacker, "2");
	FF2R_EmitBossSoundToClient(victim, "sound_announcer_swap", attacker, "3");
	
	damage = 0.0;
	return Plugin_Handled;
}

Action Announcer_ConvertBuilding(int victim, int &attacker, float &damage, int &damagetype, int &weapon)
{
	//Alert teammates, herself and unconverted minions that the entity has changed teams
	int type = GetEntProp(victim, Prop_Send, "m_iObjectType");
	int mode = GetEntProp(victim, Prop_Send, "m_iObjectMode");
	if(type >= 0 && type < sizeof(BuildingName) && mode >= 0 && mode < sizeof(BuildingName[]))
	{
		char message[64];
		FormatEx(message, sizeof(message), "A %s was hit and has switched teams!", BuildingName[type][mode]);
		AnnouncerShowAnnotation(attacker, victim, message, 3.0);
	}
	
	TF2_SetBuildingTeam(victim, GetClientTeam(attacker), attacker);
	FF2R_EmitBossSoundToClient(attacker, "sound_announcer_swap", attacker, "4");

	damage = 0.0;
	return Plugin_Handled;
}

Action Announcer_PlayerTakeDamage(int victim, int &attacker, float &damage)
{
	// "Friendly" state
	if(ConvertTimer[victim] || ConvertTimer[attacker])
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

static Action AnnouncerSwapTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();

	if(GetClientOfUserId(pack.ReadCell()))
	{
		if(IsPlayerAlive(client))
		{
			float convertAt = pack.ReadFloat();
			float gameTime = GetGameTime();

			if(convertAt > gameTime)
			{
				int time = RoundToCeil(convertAt - gameTime);
				PrintCenterText(client, "YOU'RE SWAPPING TEAMS IN %d SECOND%s", time, time > 1 ? "S" : "");
				ConvertTimer[client] = CreateTimer(1.0, AnnouncerSwapTimer, pack);
				return Plugin_Continue;
			}

			PrintCenterText(client, "YOU'RE NOW IN BOSS TEAM");
			
			int team = pack.ReadCell();
			
			//Need to detach buildings from engineers before switching teams so they don't explode
			int entity = MaxClients+1;
			while((entity = FindEntityByClassname(entity, "obj_*")) > MaxClients)
			{
				//Even when keeping the same builder, the "original builder" will be detached from the entity
				if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
					TF2_SetBuildingTeam(entity, team);
			}
			
			PrintCenterText(client, "YOU'RE NOW IN BOSS TEAM");
			
			SetEntProp(client, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(client, team);
			SetEntProp(client, Prop_Send, "m_lifeState", 0);
			
			//...and add them all back
			entity = MaxClients+1;
			while ((entity = FindEntityByClassname(entity, "obj_*")) > MaxClients)
			{
				if (GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
					SDKCall_AddObject(client, entity);
			}
			
			int i;
			while(TF2_GetItem(client, entity, i))
			{
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
			}

			i = 0;
			while(TF2U_GetWearable(client, entity, i))
			{
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
			}
			
			//Refill health
			SetEntityHealth(client, SDKCall_GetMaxHealth(client));
			
			//Refill ammo (jank)
			entity = CreateEntityByName("item_ammopack_full");
			SetVariantString("OnPlayerTouch !self:Kill::0:1");
			AcceptEntityInput(entity, "AddOutput");
			SetVariantString("OnUser4 !self:Kill::0.1:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser4");
			
			DispatchSpawn(entity);
			SetEntityRenderMode(entity, RENDER_NONE);
			
			float pos[3];
			GetClientAbsOrigin(client, pos);
			TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
			
			//Give crit resistance 
			TF2_AddCondition(client, TFCond_DefenseBuffed);

			// Prevent pickups
			FF2R_SetClientMinion(client, true);
		}
		
		//Allow sentries to target this fella from now on
		SetEntityFlags(client, (GetEntityFlags(client) & ~FL_NOTARGET));
	}

	ConvertTimer[client] = null;
	return Plugin_Continue;
}

static void AnnouncerShowAnnotation(int boss, int target, const char[] message, float duration)
{
	int team = GetClientTeam(boss);

	int[] clients = new int[MaxClients];
	int count = 0;
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(client != target && IsClientInGame(client))
		{
			if(GetClientTeam(client) == team)
				clients[count++] = client;
		}
	}
	
	if(count < 1)
		return;
	
	TF2_ShowAnnotation(clients, count, target, message, duration);
}