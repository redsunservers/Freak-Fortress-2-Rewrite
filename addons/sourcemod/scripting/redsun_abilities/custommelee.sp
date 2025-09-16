/*
	Fixes the client melee hit sound when it fails to hit
*/

#pragma semicolon 1
#pragma newdecls required

enum struct MeleeData
{
	float MeleeRange;
	float MeleeBounds;

	// When needed, can add stuff like custom hit sounds
}

static IntMap MeleeSavedData;
static bool GlobalNextSound[MAXPLAYERS+1];

void CustomMelee_MapStart()
{
	delete MeleeSavedData;
	MeleeSavedData = new IntMap();
}

void CustomMelee_EntityRemoved(int entity)
{
	if(MeleeSavedData)
		MeleeSavedData.Remove(entity);
}

void CustomMelee_PluginEnd()
{
	int entity = -1;
	while((entity = FindEntityByClassname(entity, "tf_weap*")) != -1)
	{
		if(MeleeSavedData.ContainsKey(entity))
		{
			RestoreMeleeData(entity);
		}
	}
}

Action CustomMelee_HookSound(int clients[MAXPLAYERS], int &numClients, int &entity, int &channel)
{
	if(channel == SNDCHAN_STATIC && entity > 0 && entity <= MaxClients)
	{
		// Play the server-sided sound to the client
		if(GlobalNextSound[entity])
		{
			GlobalNextSound[entity] = false;

			clients[numClients] = entity;
			numClients++;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

void CustomMelee_CalcIsAttackCritical(int weapon, const char[] classname)
{
	if(TF2_GetClassnameSlot(classname) != TFWeaponSlot_Melee)
		return;

	// Ignore spy knives with this logic for now
	if(StrEqual(classname, "tf_weapon_knife"))
		return;
	
	SaveMeleeData(weapon);
}

void CustomMelee_DoSwingTracePre(int weapon)
{
	RestoreMeleeData(weapon);
}

void CustomMelee_DoSwingTracePost(int weapon, bool hit)
{
	if(MeleeSavedData.ContainsKey(weapon))
	{
		Attrib_Set(weapon, "melee bounds multiplier", 0.0);
		Attrib_Set(weapon, "melee range multiplier", 0.0);
		
		if(hit)
		{
			// Play the server-sided sound to the client
			int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
			if(client > 0 && client <= MaxClients)
			{
				char classname[36];
				GetEntityClassname(weapon, classname, sizeof(classname));
				if(!StrEqual(classname, "tf_weapon_knife"))
					GlobalNextSound[client] = true;
			}
		}
	}
}

static void SaveMeleeData(int weapon)
{
	float bounds = 1.0;
	float range = 1.0;
	Attrib_Get(weapon, "melee bounds multiplier", bounds);
	Attrib_Get(weapon, "melee range multiplier", range);

	if(bounds > 0.0 || range > 0.0 || !MeleeSavedData.ContainsKey(weapon))
	{
		MeleeData data;
		MeleeSavedData.GetArray(weapon, data, sizeof(data));
		
		data.MeleeBounds = bounds;
		data.MeleeRange = range;
		
		MeleeSavedData.SetArray(weapon, data, sizeof(data));
	}

	Attrib_Set(weapon, "melee bounds multiplier", 0.0);
	Attrib_Set(weapon, "melee range multiplier", 0.0);
}

static void RestoreMeleeData(int weapon)
{
	MeleeData data;
	if(MeleeSavedData.GetArray(weapon, data, sizeof(data)))
	{
		if(data.MeleeBounds > 0.0)
			Attrib_Set(weapon, "melee bounds multiplier", data.MeleeBounds);
		
		if(data.MeleeRange > 0.0)
			Attrib_Set(weapon, "melee range multiplier", data.MeleeRange);
	}
}
