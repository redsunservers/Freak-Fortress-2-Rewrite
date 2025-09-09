#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <dhooks>
//#include <adt_trie_sort>
#include <cfgmap>
#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#include <ff2r>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION	"Custom"

#define MAXTF2PLAYERS	MAXPLAYERS+1
#define FAR_FUTURE	100000000.0

int PlayersAlive[4];
bool SpecTeam;

ConVar CvarFriendlyFire;

#include "freak_fortress_2/customattrib.sp"
#include "freak_fortress_2/econdata.sp"
#include "freak_fortress_2/formula_parser.sp"
#include "freak_fortress_2/subplugin.sp"
#include "freak_fortress_2/tf2attributes.sp"
#include "freak_fortress_2/tf2items.sp"
#include "freak_fortress_2/tf2utils.sp"
#include "freak_fortress_2/vscript.sp"

#include "redsun_abilities/stocks.sp"
#include "redsun_abilities/sdkcalls.sp"
#include "redsun_abilities/sdkhooks.sp"

#include "redsun_abilities/improved_saxton.sp"
#include "redsun_abilities/vagineer.sp"

public Plugin myinfo =
{
	name		=	"Freak Fortress 2: Rewrite - Redsun Abilities",
	author		=	"redsun.tf",
	description	=	"vsh suggestions",
	version		=	PLUGIN_VERSION,
	url		=	"redsun.tf"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// FF2 Files
	Attrib_PluginLoad();
	CustomAttrib_PluginLoad();
	TF2Items_PluginLoad();
	TF2U_PluginLoad();
	TFED_PluginLoad();
	return APLRes_Success;
}

public void OnPluginStart()
{
	CvarFriendlyFire = FindConVar("mp_friendlyfire");

	HookEvent("player_builtobject", OnBuiltObject);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	
	// FF2 Files
	Attrib_PluginStart();
	CustomAttrib_PluginStart();
	Saxton_PluginStart();
	TF2U_PluginStart();
	TFED_PluginStart();
	VScript_PluginStart();

	// Redsun Files
	SDKCalls_PluginStart();

	// Subplugin Last
	Subplugin_PluginStart();
}

void FF2R_PluginLoaded()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientPutInServer(client);
			
			BossData cfg = FF2R_GetBossData(client);
			if(cfg)
			{
				FF2R_OnBossCreated(client, cfg, false);
				FF2R_OnBossEquipped(client, true);
			}
		}
	}
}

public void OnPluginEnd()
{
	OnMapEnd();
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			OnClientDisconnect(client);
			if(FF2R_GetBossData(client))
				FF2R_OnBossRemoved(client);
		}
	}
}

public void OnMapStart()
{
	Saxton_MapStart();
}

public void OnMapEnd()
{
	
}

public void OnLibraryAdded(const char[] name)
{
	Attrib_LibraryAdded(name);
	CustomAttrib_LibraryAdded(name);
	Subplugin_LibraryAdded(name);
	TF2U_LibraryAdded(name);
	TFED_LibraryAdded(name);
	VScript_LibraryAdded(name);
}

public void OnLibraryRemoved(const char[] name)
{
	Attrib_LibraryRemoved(name);
	CustomAttrib_LibraryRemoved(name);
	Subplugin_LibraryRemoved(name);
	TF2U_LibraryRemoved(name);
	TFED_LibraryRemoved(name);
	VScript_LibraryRemoved(name);
}

public void OnClientPutInServer(int client)
{
	SDKHooks_PutInServer(client);
}

public void OnClientDisconnect(int client)
{
	
}

public void OnGameFrame()
{
	Saxton_GameFrame();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	return Saxton_PlayerRunCmd(client, buttons);
}

public void FF2R_OnBossCreated(int client, BossData cfg, bool setup)
{
	Saxton_BossCreated(client, cfg, setup);
}

public void FF2R_OnBossEquipped(int client, bool weapons)
{
	Saxton_BossEquipped(client, weapons);
}

public void FF2R_OnBossRemoved(int client)
{
	Saxton_BossRemoved(client);
}

public void FF2R_OnAbility(int client, const char[] ability, AbilityData cfg)
{
	Saxton_Ability(client, ability);
	Vagineer_Ability(client, ability, cfg);
}

public void FF2R_OnAliveChanged(const int alive[4], const int total[4])
{
	for(int i; i < 4; i++)
	{
		PlayersAlive[i] = alive[i];
	}
	
	SpecTeam = (total[TFTeam_Unassigned] || total[TFTeam_Spectator]);
}

public Action OnStomp(int attacker, int victim, float &damageMultiplier, float &damageBonus, float &JumpPower)
{
	return Saxton_Stomp(attacker, victim);
}

static void OnBuiltObject(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int building = event.GetInt("index");

	if(client)
	{
		Vagineer_BuiltObject(client, building);
	}
}

static Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	Saxton_PlayerDeath(event);
	return Plugin_Continue;
}