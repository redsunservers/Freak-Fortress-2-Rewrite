#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <dhooks>
#include <tf_econ_data>
#include <tf_econ_dynamic>
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

#define TFTeam_Unassigned	0
#define TFTeam_Spectator	1
#define TFTeam_Red		2
#define TFTeam_Blue		3
#define TFTeam_MAX		4

int PlayersAlive[4];
bool SpecTeam;
char KillIcon[64];
char KillName[64];

ConVar CvarFriendlyFire;

#include "freak_fortress_2/econdata.sp"
#include "freak_fortress_2/formula_parser.sp"
#include "freak_fortress_2/subplugin.sp"
#include "freak_fortress_2/tf2attributes.sp"
#include "freak_fortress_2/tf2items.sp"
#include "freak_fortress_2/tf2utils.sp"
#include "freak_fortress_2/vscript.sp"

#include "redsun_abilities/stocks.sp"
#include "redsun_abilities/customattrib.sp"
#include "redsun_abilities/custommelee.sp"
#include "redsun_abilities/dhooks.sp"
#include "redsun_abilities/sdkcalls.sp"
#include "redsun_abilities/sdkhooks.sp"

#include "redsun_abilities/weapons/goomba.sp"

#include "redsun_abilities/bosses/announcer.sp"
#include "redsun_abilities/bosses/improved_saxton.sp"
#include "redsun_abilities/bosses/rock.sp"
#include "redsun_abilities/bosses/sarysapub1.sp"
#include "redsun_abilities/bosses/spellbook.sp"
#include "redsun_abilities/bosses/vagineer.sp"

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
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("deploy_buff_banner", OnDeployBanner);
	
	// FF2 Files
	Attrib_PluginStart();
	TF2U_PluginStart();
	TFED_PluginStart();
	VScript_PluginStart();

	// Redsun Files
	DHooks_PluginStart();
	SDKCalls_PluginStart();
	SDKHook_PluginStart();
	Sarysapub1_PluginStart();
	Saxton_PluginStart();

	// Subplugin Last
	Subplugin_PluginStart();
}

public void OnAllPluginsLoaded()
{
	CustomAttrib_AllPluginsLoaded();
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
	CustomMelee_PluginEnd();
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
	CustomMelee_MapStart();
	Goomba_MapStart();
	Saxton_MapStart();
}

public void OnMapEnd()
{
	
}

public void OnLibraryAdded(const char[] name)
{
	Attrib_LibraryAdded(name);
	SDKHook_LibraryAdded(name);
	Subplugin_LibraryAdded(name);
	TF2U_LibraryAdded(name);
	TFED_LibraryAdded(name);
	VScript_LibraryAdded(name);
}

public void OnLibraryRemoved(const char[] name)
{
	Attrib_LibraryRemoved(name);
	SDKHook_LibraryRemoved(name);
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
	Sarysapub1_GameFrame();
	Saxton_GameFrame();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	Sarysapub1_PlayerRunCmd(client, buttons);
	return Saxton_PlayerRunCmd(client, buttons);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	Sarysapub1_EntityCreated(entity, classname);
	SDKHooks_EntityCreated(entity, classname);
}

public void OnEntityDestroyed(int entity)
{
	CustomMelee_EntityRemoved(entity);
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	CustomMelee_CalcIsAttackCritical(weapon, weaponname);
	return Plugin_Continue;
}

public void FF2R_OnBossCreated(int client, BossData cfg, bool setup)
{
	Sarysapub1_BossCreated(client, cfg, setup);
	Saxton_BossCreated(client, cfg, setup);
}

public void FF2R_OnBossEquipped(int client, bool weapons)
{
	Saxton_BossEquipped(client, weapons);
}

public void FF2R_OnBossRemoved(int client)
{
	Sarysapub1_BossRemoved(client);
	Saxton_BossRemoved(client);
}

public void FF2R_OnAbility(int client, const char[] ability, AbilityData cfg)
{
	Rock_Ability(client, ability, cfg);
	Sarysapub1_Ability(client, ability, cfg);
	Saxton_Ability(client, ability);
	Spellbook_Ability(client, ability, cfg);
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

static void OnBuiltObject(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int building = event.GetInt("index");

	if(client)
	{
		Vagineer_BuiltObject(client, building);
	}
}

void SetKillIcon(const char[] icon = "", const char[] name = "")
{
	strcopy(KillIcon, sizeof(KillIcon), icon);
	strcopy(KillName, sizeof(KillName), name);
}

static Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	Saxton_PlayerDeath(event);

	if(KillIcon[0])
	{
		event.SetString("weapon", KillIcon);
		if(KillName[0])
			event.SetString("weapon_logclassname", KillName);
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

static void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(client)
	{
		Announcer_PlayerSpawn(client);
	}
}

static void OnDeployBanner(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("buff_owner"));

	if(client)
	{
		CustomAttrib_DeployBanner(client);
	}
}