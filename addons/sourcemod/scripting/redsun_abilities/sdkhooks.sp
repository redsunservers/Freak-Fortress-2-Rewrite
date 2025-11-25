#pragma semicolon 1
#pragma newdecls required

#tryinclude <tf_ontakedamage>

#define OTD_LIBRARY	"tf_ontakedamage"

#if !defined __tf_ontakedamage_included
enum CritType
{
	CritType_None = 0,
	CritType_MiniCrit,
	CritType_Crit
};
#endif

static bool OTDLoaded;

void SDKHook_PluginStart()
{
	OTDLoaded = LibraryExists(OTD_LIBRARY);

	if(!OTDLoaded)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
				SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
		}
	}

	AddNormalSoundHook(HookSound);
}

void SDKHook_LibraryAdded(const char[] name)
{
	if(!OTDLoaded && StrEqual(name, OTD_LIBRARY))
	{
		OTDLoaded = true;
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
				SDKUnhook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
		}
	}
}

void SDKHook_LibraryRemoved(const char[] name)
{
	if(OTDLoaded && StrEqual(name, OTD_LIBRARY))
	{
		OTDLoaded = false;
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
				SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
		}
	}
}

void SDKHooks_PutInServer(int client)
{
	if(!OTDLoaded)
		SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
	
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnPlayerTakeDamagePost);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	SDKHook(client, SDKHook_StartTouch, OnStartTouch);
}

void SDKHooks_EntityCreated(int entity, const char[] classname)
{
	if(!StrContains(classname, "obj_"))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnObjectTakeDamage);
	}
	else if(!StrContains(classname, "tf_projectile_"))
	{
		SDKHook(entity, SDKHook_StartTouchPost, OnProjectileTouch);
	}
}

static Action OnPreThink(int client)
{
	Saxton_PreThink(client);
	return Plugin_Continue;
}

static Action OnStartTouch(int client, int target)
{
	Goomba_StartTouch(client, target);
	return Plugin_Continue;
}

static Action OnPlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CritType crit = (damagetype & DMG_CRIT) ? CritType_Crit : CritType_None;
	return TF2_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom, crit);
}

public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType)
{
	Action action;

	if(inflictor != -1 && FF2R_GetBossData(victim))
	{
		char classname[32];
		if(GetEntityClassname(inflictor, classname, sizeof(classname)) && !StrContains(classname, "obj_sentrygun"))
		{
			float pos1[3], pos2[3];
			GetClientAbsOrigin(victim, pos1);
			GetEntPropVector(inflictor, Prop_Send, "m_vecOrigin", pos2);
			if(GetVectorDistance(pos1, pos2, true) > 50000.0)
			{
				action = Plugin_Changed;
				damagetype |= DMG_PREVENT_PHYSICS_FORCE;
			}
		}
	}

	UpdateAction(action, CustomAttrib_PlayerTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom, critType));
	UpdateAction(action, Announcer_PlayerTakeDamage(victim, attacker, damage));
	UpdateAction(action, Sarysapub1_TakeDamage(victim, attacker, inflictor, damage, damagetype));

	return action;
}

static void OnPlayerTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
}

static Action OnObjectTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action;
	
	UpdateAction(action, CustomAttrib_ObjectTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom));
	
	return action;
}

static void OnProjectileTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner > 0 && owner <= MaxClients)
	{
		int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		if(weapon != -1)
		{
			CustomAttrib_ProjectileTouch(owner, weapon, entity);
		}
	}
}

static Action HookSound(int clients[MAXPLAYERS], int &numClients, char sample[256], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[256], int &seed)
{
	return CustomMelee_HookSound(clients, numClients, entity, channel);
}