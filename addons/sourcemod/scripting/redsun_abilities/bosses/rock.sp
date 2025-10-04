/*
	The Rock
	
	"rage_rock_condition"
	{
		"slot"		"0"	// Ability slot

		"conditions"
		{
			"28"	"15.0"	// Index and Duration
		}
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
	
	"rage_rock_exploding"
	{
		"slot"		"0"		// Ability slot
		"duration"	"15.0"		// Duration
		"radius"	"80.0"		// Radius
		"damage"	"9999.0"	// Damage Per Second
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
*/

#pragma semicolon 1
#pragma newdecls required

void Rock_Ability(int client, const char[] ability, AbilityData cfg)
{
	if(!StrContains(ability, "rage_rock_condition", false))
	{
		ConfigData conds = cfg.GetSection("conditions");
		if(conds)
		{
			StringMapSnapshot snap = conds.Snapshot();

			int length = snap.Length;
			for(int i; i < length; i++)
			{
				int size = snap.KeyBufferSize(i) + 1;
				char[] key = new char[size];
				snap.GetKey(i, key, size);

				int index = StringToInt(key);
				TF2_AddCondition(client, view_as<TFCond>(index), conds.GetFloat(key));
			}

			delete snap;
		}
	}
	else if(!StrContains(ability, "rage_rock_exploding", false))
	{
		DataPack pack;
		CreateDataTimer(0.1, RockExplodeTimer, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(GetClientUserId(client));
		pack.WriteFloat(cfg.GetFloat("duration", 5.0) + GetGameTime());
		pack.WriteFloat(cfg.GetFloat("damage", 9999.0) / 10.0);
		pack.WriteFloat(cfg.GetFloat("radius", 100.0));
	}
}

static Action RockExplodeTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client && FF2R_GetBossData(client))
	{
		if(GetGameTime() < pack.ReadFloat())
		{
			int entity = CreateEntityByName("env_explosion");
			if(entity != -1)
			{
				float pos[3];
				GetClientAbsOrigin(client, pos);

				DispatchKeyValueFloat(entity, "iMagnitude", pack.ReadFloat());
				DispatchKeyValueFloat(entity, "iRadiusOverride", pack.ReadFloat());
				DispatchKeyValueVector(entity, "origin", pos);
				DispatchKeyValue(entity, "spawnflags", "1916"); // No effects

				SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
				
				DispatchSpawn(entity);

				AcceptEntityInput(entity, "Explode");
				AcceptEntityInput(entity, "Kill");

				return Plugin_Continue;
			}
		}
	}
	
	return Plugin_Stop;
}