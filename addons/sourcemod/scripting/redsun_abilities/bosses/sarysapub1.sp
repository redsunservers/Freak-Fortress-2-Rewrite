/*
	Rages for Thi Barrett, a character of Rise of the Triad and a hale I'm working on.
	
	Note that ROTTProps and ROTTWeapons, if used by two bosses in a multi-boss setup, cannot be distinct for each boss.
	There's too much to monitor for it to be practical (especially data size-wise) to also have tons of player-sized arrays involved.
	
	ROTTProps: Spawns Rise of the Triad props with the RELOAD key. Some props are for utility (like jump pads/45deg jump pads) while others
		are damage rects. (like that spinning skewering thing) User can select between them with either SPECIAL or action slot.
	Known Issues: Trains will destroy props that are above (or presumably below) them.
		Due to the nature of the angle jump pads, they can easily spawn behind walls if user's back is to a wall. No real clean way around this.
	
	ROTTWeapons: E/G rage, gives the rager a random (they don't get to pick) weapon or powerup from ROTT.
	Credits: Asherkin and voogru I took some of their rocket spawning code, though I came up with my own brand of homing projectiles.
	Known Issues: For armor to work, the hale must have a melee weapon specified with one of the ROTT melee weapon rage(s). I don't use the three 
		vaccinator conditions because I've experienced rare crashes caused with those. (I'd rather not describe how it's done)
		For some weird reason some base weapon attributes are leaking in for me, which is why I only went with rocket launchers
		that are reskins of the default, or just don't matter in FF2 like the Black Box.
		Split and Drunk missile use lazy math which is obvious when you shoot upwards or downwards. I've decided not to care.
		Can't have real rocket jumping because of FF2 blocking self-damage and weighdown making crouching problematic, so 
		I've implemented a close-enough variety. Most players will pick up on it quickly.
	
	Overall Credits: Some snippets taken from core FF2 code.
		Friagram for pointing out some improvements for some of my earlier stocks.
 */

#pragma semicolon 1
#pragma newdecls required

static bool PluginActiveThisRound = false;

// ROTT shared HUD
static float ROTT_HudRefreshAt[MAXPLAYERS+1];
static Handle ROTT_SyncHud;

// ROTT props and sub-rages
#define RP_STRING "rage_rott_props"
#define MAX_PROP_NAME_LENGTH 41
#define PROP_INVALID -1
#define PROP_JUMP_PAD 0
#define PROP_ANGLE_PAD 1
#define PROP_SLICER 2
#define PROP_PLATFORM 3
#define PROP_COUNT 4
static bool RP_ActiveThisRound = false;
static bool RP_NoFallDamage = false; // arg18
static bool RP_CanUse[MAXPLAYERS+1]; // internal
static int RP_CurrentlySelectedProp[MAXPLAYERS+1]; // internal
static bool RP_SpecialKeyDown[MAXPLAYERS+1]; // internal
static bool RP_AltFireKeyDown[MAXPLAYERS+1]; // internal
static bool RP_ReloadKeyDown[MAXPLAYERS+1]; // internal
static bool RP_CanDeployProp[MAXPLAYERS+1][PROP_COUNT]; // arg1,3,5,6
static float RP_PropRageCost[MAXPLAYERS+1][PROP_COUNT]; // arg2,4,6,8
static char RP_PropName[PROP_COUNT][MAX_PROP_NAME_LENGTH]; // derived from various sub-rage args
static char RP_StrNotEnoughRage[170]; // arg15
static char RP_StrGroundOnly[170]; // arg16
static char RP_StrPlayerBlocking[170]; // arg17
static char RP_HUDMessage[170]; // arg19
static float RP_EffectTriggerInterval[PROP_COUNT]; // internal, with some derivation from some props
static int RP_PropHealth[PROP_COUNT]; // internal, with some derivation from some props

#define RPJP_STRING "rage_rott_jump_pad_info"
#define RPJP_EffectTriggerInterval 0.2
static float RPJP_JumpPadIntensity; // arg1
static int RPJP_JumpPadHealth; // arg2
static char RPJP_JumpPadModel[PLATFORM_MAX_PATH]; // arg3
static float RPJP_JumpPadCollision[2][3]; // arg4
static char RPJP_JumpPadSound[PLATFORM_MAX_PATH]; // arg10
static float RPJP_AnglePadIntensity; // arg11
static int RPJP_AnglePadHealth; // arg12
static char RPJP_AnglePadModel[PLATFORM_MAX_PATH]; // arg13
static float RPJP_AnglePadCollision[2][3];// arg14
static float RPJP_AnglePadDampeningFactor; // arg16

//#define RPS_STRING "rage_rott_slicer_info"
//#define RPP_STRING "rage_rott_platform_info"
#define RPSP_STRING "rage_rott_slicer_platform_info"
static float RPS_DelayBetweenChecks; // arg1
static float RPS_DamagePerCheck; // arg2
static bool RPS_NegatePushForce; // arg3
static char RPS_SlicerModel[PLATFORM_MAX_PATH]; // arg4
static float RPS_SlicerCollision[2][3];// arg5
static float RPS_DelayBeforeDamage; // arg6
static int RPP_PlatformHealth; // arg1
static char RPP_PlatformModel[PLATFORM_MAX_PATH]; // arg2

// error messages for props
#define RP_ERROR_STATE_NONE 0
#define RP_ERROR_STATE_NEED_RAGE 1
#define RP_ERROR_STATE_GROUND_ONLY 2
#define RP_ERROR_STATE_PLAYER_BLOCKING 3
#define RP_ERROR_STATE_UNKNOWN 4
static int RP_ActiveErrorState[MAXPLAYERS+1];
static float RP_DisplayErrorUntil[MAXPLAYERS+1];

// ROTT weapons
#define RW_STRING "rage_rott_weapons"
#define RW_MAX_WEAPONS 10
#define RW_MAX_GODMODE_SOUNDS 5
#define RW_INVALID_INDEX RW_MAX_WEAPONS
#define RW_MISSING_MELEE (RW_MAX_WEAPONS+1)
#define RW_MAX_MESSAGE_LENGTH 81
#define RW_TYPE_NORMAL 1
#define RW_TYPE_DRUNK 2
#define RW_TYPE_SPLIT 3
#define RW_TYPE_ARMOR 4
#define RW_TYPE_GOD_MODE 5
static int RW_ActiveThisRound;
static char RW_Messages[RW_MAX_WEAPONS+3][RW_MAX_MESSAGE_LENGTH];
static bool RW_CanUse[MAXPLAYERS+1]; // internal
static int RW_ActiveMessageIndex[MAXPLAYERS+1]; // internal
static float RW_MessageActiveUntil[MAXPLAYERS+1]; // internal
static int RW_ActiveWeaponSpec[MAXPLAYERS+1]; // internal
static bool RW_ArmorActive[MAXPLAYERS+1]; // internal
static float RW_ArmorActiveUntil[MAXPLAYERS+1]; // internal
static bool RW_GodModeActive[MAXPLAYERS+1]; // internal
static float RW_GodModeActiveUntil[MAXPLAYERS+1]; // internal
static float RW_NextGodModeSoundAt[MAXPLAYERS+1]; // internal
static int RW_WeaponCount[MAXPLAYERS+1]; // arg1
static float RW_HomingInterval; // arg3
static int RW_WeaponChances[MAXPLAYERS+1][RW_MAX_WEAPONS]; // arg4
// arg5 and arg6 not stored this way
// arg19 is an error message not stored here

// ROTT weapon info. only reason I'm storing them is so i.e. drunk missile doesn't suddenly get heatseeker logic on weapon switch.
static int RWI_Type[RW_MAX_WEAPONS]; // arg1
// args 2-5 are only needed at rage time
static float RWI_Duration[RW_MAX_WEAPONS]; // arg6, god mode and armor only
static int RWI_AdditionalProjectiles[RW_MAX_WEAPONS]; // arg7, drunk missile only
static float RWI_HomingDegreesPerSecond[RW_MAX_WEAPONS]; // arg8
static bool RWI_ObsessiveHoming[RW_MAX_WEAPONS]; // arg9
static int RWI_NumAdditionalExplosions[RW_MAX_WEAPONS]; // arg10
static float RWI_ExplosionInterval[RW_MAX_WEAPONS]; // arg11
static float RWI_RandomDeviationPerSecond[RW_MAX_WEAPONS]; // arg12
static int RWI_ModelOverrideIdx[RW_MAX_WEAPONS]; // arg13
static char RWI_ParticleOverride[RW_MAX_WEAPONS][48]; // arg14
// arg 15 is up there as RW_Messages
// arg 16 is only needed at rage time
static float RWI_LockOnAngle[RW_MAX_WEAPONS];
static float RWI_HomeAngle[RW_MAX_WEAPONS];

// ROTT monitored rockets
#define MAX_ROCKETS 30
#define FIREBOMB_EXPLOSION_RADIUS "150" // it's input as a string, so...lol
#define FIREBOMB_EXPLOSION_DISTANCE_BETWEEN 100.0
static int RMR_Spec[MAX_ROCKETS];
static int RMR_RocketEntRef[MAX_ROCKETS];
static float RMR_NextDeviationAt[MAX_ROCKETS];
static float RMR_HomingPerSecond[MAX_ROCKETS];
static float RMR_RandomDeviationPerSecond[MAX_ROCKETS];
static int RMR_CurrentHomingTarget[MAX_ROCKETS];
static bool RMR_CanRetarget[MAX_ROCKETS];
static float RMR_RocketVelocity[MAX_ROCKETS];
static bool RMR_HasTargeted[MAX_ROCKETS];
static int RMR_FirebombCount[MAX_ROCKETS];
static int RMR_FirebombsActivated[MAX_ROCKETS];
static int RMR_FirebombDamage[MAX_ROCKETS];
static int RMR_RocketOwner[MAX_ROCKETS];
static float RMR_FirebombInterval[MAX_ROCKETS];
static float RMR_ChainExplosionStartedAt[MAX_ROCKETS];
static float RMR_LastPosition[MAX_ROCKETS][3];
static float RMR_LastAngle[MAX_ROCKETS][3];

// queued rockets, since they can't be immediately identified on spawn
#define ROCKET_QUEUE_SIZE 5
static int RocketQueue[ROCKET_QUEUE_SIZE];
static int RocketBeingCreated = false; // prevent endless recursion with the rocket queue

// individual ROTT props and their management
#define MAX_PROPS 100
static int PROP_HighestSpawnedProp = -1;
static int PROP_EntRef[MAX_PROPS];
static int PROP_Type[MAX_PROPS];
static float PROP_NextTriggerTime[MAX_PROPS][MAXPLAYERS+1]; // yes, this has a large data size. but it's for the best.
static int PROP_OwnerUserId[MAX_PROPS];

void Sarysapub1_PluginStart()
{
	ROTT_SyncHud = CreateHudSynchronizer();
}

void Sarysapub1_BossCreated(int clientIdx, BossData boss, bool setup)
{
	if(setup)
		return;
	
	// ROTT weapons
	RW_ActiveMessageIndex[clientIdx] = 0;
	RW_MessageActiveUntil[clientIdx] = 0.0;
	RW_ArmorActive[clientIdx] = false;
	RW_ArmorActiveUntil[clientIdx] = 0.0;
	RW_GodModeActive[clientIdx] = false;
	RW_GodModeActiveUntil[clientIdx] = 0.0;

	// ROTT props
	RP_SpecialKeyDown[clientIdx] = false;
	RP_AltFireKeyDown[clientIdx] = false;
	RP_ReloadKeyDown[clientIdx] = false;
	RP_ActiveErrorState[clientIdx] = 0;
	RP_DisplayErrorUntil[clientIdx] = 0.0;
	RW_ArmorActive[clientIdx] = false;
	RW_GodModeActive[clientIdx] = false;

	// ROTT weapons
	AbilityData cfg = boss.GetAbility(RW_STRING);
	if (cfg)
	{
		if (!RW_ActiveThisRound)
		{
			for (int i = 0; i < ROCKET_QUEUE_SIZE; i++)
				RocketQueue[i] = -1;
			for (int i = 0; i < MAX_ROCKETS; i++)
				RMR_RocketEntRef[i] = 0;
		}

		PluginActiveThisRound = true;
		RW_ActiveThisRound = true;
		RW_CanUse[clientIdx] = true;
	
		// the overarching rage props
		RW_WeaponCount[clientIdx] = min(cfg.GetInt("weaponcount"), RW_MAX_WEAPONS);
		RW_HomingInterval = cfg.GetFloat("hominginterval");
		
		char chancesStr[RW_MAX_WEAPONS * 3];
		cfg.GetString("weaponchances", chancesStr, 30);
		char chancesStrs[RW_MAX_WEAPONS][4];
		ExplodeString(chancesStr, ";", chancesStrs, RW_MAX_WEAPONS, 4);
		for (int i = 0; i < RW_WeaponCount[clientIdx]; i++)
			RW_WeaponChances[clientIdx][i] = StringToInt(chancesStrs[i]);

		float maxAngleLockOn = cfg.GetFloat("anglelockon");
		float maxAngleHome = cfg.GetFloat("anglehome");
			
		// specific weapon info
		for (int i = 0; i < RW_WeaponCount[clientIdx]; i++)
		{
			static char actualRWIString[40];
			Format(actualRWIString, 40, "info%d", i);

			ConfigData info = cfg.GetSection(actualRWIString);
			if (!info)
			{
				RW_WeaponCount[clientIdx] = i;
				break;
			}
			
			RWI_Type[i] = info.GetInt("type");
			RWI_Duration[i] = info.GetFloat("duration");
			RWI_AdditionalProjectiles[i] = info.GetInt("additionalprojectiles");
			RWI_HomingDegreesPerSecond[i] = info.GetFloat("homingdegrees");
			RWI_ObsessiveHoming[i] = info.GetInt("obsessivehoming") == 1;
			RWI_NumAdditionalExplosions[i] = info.GetInt("additionalexplosions");
			RWI_ExplosionInterval[i] = info.GetFloat("explosioninterval");
			RWI_RandomDeviationPerSecond[i] = info.GetFloat("randomdeviation");
			RWI_ModelOverrideIdx[i] = ReadModelToInt(info, "modeloverride");
			info.GetString("particleoverride", RWI_ParticleOverride[i], 48);
			info.GetString("message", RW_Messages[i], RW_MAX_MESSAGE_LENGTH);
			ReplaceString(RW_Messages[i], RW_MAX_MESSAGE_LENGTH, "\\n", "\n");
			
			// overrides for lock on and homing angle
			RWI_LockOnAngle[i] = info.GetFloat("anglelockon");
			if(RWI_LockOnAngle[i] <= 0.0)
				RWI_LockOnAngle[i] = maxAngleLockOn;
			RWI_HomeAngle[i] = info.GetFloat("anglehome");
			if(RWI_HomeAngle[i] <= 0.0)
				RWI_HomeAngle[i] = maxAngleHome;
		}
		RW_Messages[RW_INVALID_INDEX] = "Weapon chances didn't add up to 100%.\nNotify your server admin.";
		RW_Messages[RW_MISSING_MELEE] = "Melee rage missing. Can't give armor.\nNotify your server admin.";
	}
	
	// ROTT props
	cfg = boss.GetAbility(RP_STRING);
	if (cfg)
	{
		if (!RP_ActiveThisRound)
		{
			PROP_HighestSpawnedProp = -1;
			for (int i = 0; i < MAX_PROPS; i++)
				PROP_Type[i] = PROP_INVALID;
		}

		PluginActiveThisRound = true;
		RP_ActiveThisRound = true;
		RP_CanUse[clientIdx] = true;
		RP_CurrentlySelectedProp[clientIdx] = -1;
		char buffer[16];
		for (int i = 0; i < 4; i++)
		{
			FormatEx(buffer, sizeof(buffer), "candeploy%d", i);
			RP_CanDeployProp[clientIdx][i] = cfg.GetBool(buffer);
			FormatEx(buffer, sizeof(buffer), "ragecost%d", i);
			RP_PropRageCost[clientIdx][i] = cfg.GetFloat(buffer);
			
			if (RP_CanDeployProp[clientIdx][i] && RP_CurrentlySelectedProp[clientIdx] == -1)
				RP_CurrentlySelectedProp[clientIdx] = i;
		}
		ReadCenterText(cfg, "notenoughrage", RP_StrNotEnoughRage);
		ReadCenterText(cfg, "groundonly", RP_StrGroundOnly);
		ReadCenterText(cfg, "playerblocking", RP_StrPlayerBlocking);
		RP_NoFallDamage = cfg.GetBool("nofalldamage");
		ReadCenterText(cfg, "hudmessage", RP_HUDMessage);

		// jump pad info
		ConfigData info = cfg.GetSection("jumppad");
		if (info)
		{
			RPJP_JumpPadIntensity = info.GetFloat("intensity");
			RPJP_JumpPadHealth = info.GetInt("health");
			ReadModel(info, "model", RPJP_JumpPadModel);
			ReadHull(info, "collision", RPJP_JumpPadCollision);
			info.GetString("name", RP_PropName[PROP_JUMP_PAD], MAX_PROP_NAME_LENGTH);
			
			ReadSound(info, "sound", RPJP_JumpPadSound);
			
			// also, these
			RP_EffectTriggerInterval[PROP_JUMP_PAD] = RPJP_EffectTriggerInterval;
			RP_PropHealth[PROP_JUMP_PAD] = RPJP_JumpPadHealth;
		}

		info = cfg.GetSection("angle");
		if (info)
		{
			RPJP_AnglePadIntensity = info.GetFloat("intensity");
			RPJP_AnglePadHealth = info.GetInt("health");
			ReadModel(info, "model", RPJP_AnglePadModel);
			ReadHull(info, "collision", RPJP_AnglePadCollision);
			info.GetString("name", RP_PropName[PROP_ANGLE_PAD], MAX_PROP_NAME_LENGTH);
			RPJP_AnglePadDampeningFactor = info.GetFloat("dampening");
			
			// also, these
			RP_EffectTriggerInterval[PROP_ANGLE_PAD] = RPJP_EffectTriggerInterval;
			RP_PropHealth[PROP_ANGLE_PAD] = RPJP_AnglePadHealth;
		}
		
		// slicer and platform info
		info = cfg.GetSection("slicer");
		if (info)
		{
			// SLICER
			RPS_DelayBetweenChecks = info.GetFloat("interval");
			RPS_DamagePerCheck = info.GetFloat("damage");
			RPS_NegatePushForce = info.GetBool("negatepush");
			ReadModel(info, "model", RPS_SlicerModel);
			ReadHull(info, "collison", RPS_SlicerCollision);
			RPS_DelayBeforeDamage = info.GetFloat("delay");
			info.GetString("name", RP_PropName[PROP_SLICER], MAX_PROP_NAME_LENGTH);
			
			// also, these
			RP_EffectTriggerInterval[PROP_SLICER] = RPS_DelayBetweenChecks;
			RP_PropHealth[PROP_SLICER] = 32000;
		}

		info = cfg.GetSection("platform");
		if (info)
		{
			// PLATFORM
			RPP_PlatformHealth = info.GetInt("health");
			ReadModel(info, "model", RPP_PlatformModel);
			info.GetString("name", RP_PropName[PROP_PLATFORM], MAX_PROP_NAME_LENGTH);
			
			// also, this
			RP_PropHealth[PROP_PLATFORM] = RPP_PlatformHealth;
		}
		
		if (RP_CurrentlySelectedProp[clientIdx] == -1)
			RP_CanUse[clientIdx] = false;
	}
	
	if (RW_CanUse[clientIdx] || RP_CanUse[clientIdx])
	{
		ROTT_UpdateHUD(clientIdx);
		ROTT_HudRefreshAt[clientIdx] = GetEngineTime();
	}
}

void Sarysapub1_BossRemoved(int clientIdx)
{
	// ROTT weapons
	RW_CanUse[clientIdx] = false;
	RW_ActiveMessageIndex[clientIdx] = 0;
	RW_MessageActiveUntil[clientIdx] = 0.0;
	RW_ArmorActive[clientIdx] = false;
	RW_ArmorActiveUntil[clientIdx] = 0.0;
	RW_GodModeActive[clientIdx] = false;
	RW_GodModeActiveUntil[clientIdx] = 0.0;

	// ROTT props
	RP_CanUse[clientIdx] = false;
	RP_SpecialKeyDown[clientIdx] = false;
	RP_AltFireKeyDown[clientIdx] = false;
	RP_ReloadKeyDown[clientIdx] = false;
	RP_ActiveErrorState[clientIdx] = 0;
	RP_DisplayErrorUntil[clientIdx] = 0.0;
	RW_ArmorActive[clientIdx] = false;
	RW_GodModeActive[clientIdx] = false;
	
	if (RP_ActiveThisRound || RW_ActiveThisRound)
	{
		// wait for all bosses to be removed
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsClientInGame(target))
			{
				if(RW_CanUse[target] || RP_CanUse[target])
					return;
			}
		}
	}

	RP_ActiveThisRound = false;
	RW_ActiveThisRound = false;
	RP_NoFallDamage = false;
}

void Sarysapub1_Ability(int clientIdx, const char[] ability_name, AbilityData cfg)
{
	if (!strcmp(ability_name, RW_STRING))
		Rage_ROTTWeapons(clientIdx, cfg);
	// ROTT props not activated this way
}

void Sarysapub1_PluginEnd()
{
	for (int propIdx = PROP_HighestSpawnedProp; propIdx >= 0; propIdx--)
	{
		DestroyProp(propIdx, false);
	}
}

/**
 * Shared
 */
#define PROPS_MESSAGE_MAX 200
#define HUD_MESSAGE_MAX (RW_MAX_MESSAGE_LENGTH + 2 + PROPS_MESSAGE_MAX + 1 + PROPS_MESSAGE_MAX + 1 + PROPS_MESSAGE_MAX + 1)
static char ROTT_HudMessage[MAXPLAYERS+1][HUD_MESSAGE_MAX];
static void ROTT_UpdateHUD(int clientIdx)
{
	static char weaponMessage[RW_MAX_MESSAGE_LENGTH];
	static char errorMessage[PROPS_MESSAGE_MAX];
	static char propsMessage[PROPS_MESSAGE_MAX];
	static char debugMessage[PROPS_MESSAGE_MAX];
	
	if (RW_ActiveThisRound && RW_CanUse[clientIdx])
	{
		if (RW_ActiveMessageIndex[clientIdx] == -1)
			weaponMessage[0] = 0;
		else
			weaponMessage = RW_Messages[RW_ActiveMessageIndex[clientIdx]];
	}
	
	if (RP_ActiveThisRound && RP_CanUse[clientIdx])
	{
		int curProp = RP_CurrentlySelectedProp[clientIdx];
		Format(propsMessage, PROPS_MESSAGE_MAX, RP_HUDMessage, RP_PropName[curProp], RP_PropRageCost[clientIdx][curProp]);
		
		if (RP_ActiveErrorState[clientIdx] != RP_ERROR_STATE_NONE && RP_DisplayErrorUntil[clientIdx] > GetEngineTime())
		{
			if (RP_ActiveErrorState[clientIdx] == RP_ERROR_STATE_NEED_RAGE)
				errorMessage = RP_StrNotEnoughRage;
			else if (RP_ActiveErrorState[clientIdx] == RP_ERROR_STATE_GROUND_ONLY)
				errorMessage = RP_StrGroundOnly;
			else if (RP_ActiveErrorState[clientIdx] == RP_ERROR_STATE_PLAYER_BLOCKING)
				errorMessage = RP_StrPlayerBlocking;
			else if (RP_ActiveErrorState[clientIdx] == RP_ERROR_STATE_UNKNOWN)
				errorMessage = "Unknown error. Could not create prop.";
		}
		else
		{
			errorMessage = "";
			RP_ActiveErrorState[clientIdx] = RP_ERROR_STATE_NONE;
		}
	}
	
	Format(ROTT_HudMessage[clientIdx], HUD_MESSAGE_MAX, "%s\n%s\n%s\n%s", weaponMessage, errorMessage, propsMessage, debugMessage);
	ReplaceString(ROTT_HudMessage[clientIdx], HUD_MESSAGE_MAX, "\\n", "\n");
}

/**
 * ROTT Weapons
 */
static void Rage_ROTTWeapons(int clientIdx, AbilityData cfg)
{
	// pick a random weapon
	int randomInt = GetRandomInt(1, 100);
	
	int weaponSpec = -1;
	int add = 0;
	for (int i = 0; i < RW_WeaponCount[clientIdx]; i++)
	{
		add += RW_WeaponChances[clientIdx][i];
		if (add >= randomInt)
		{
			weaponSpec = i;
			break;
		}
	}
	
	if (weaponSpec == -1)
	{
		PrintToServer("[sarysapub1] ERROR: Player didn't get a weapon because the chances didn't add up to 100%. (player rolled %d)", randomInt);
		RW_ActiveMessageIndex[clientIdx] = RW_INVALID_INDEX;
		RW_MessageActiveUntil[clientIdx] = GetEngineTime() + 20.0;
		return;
	}
	
	// get our actual ability info
	static char actualRWIString[40];
	Format(actualRWIString, 40, "info%d", weaponSpec);
	ConfigData info = cfg.GetSection(actualRWIString);
	
	// special for armor
	if (RWI_Type[weaponSpec] == RW_TYPE_ARMOR)
	{
		// start the timer
		RW_ArmorActive[clientIdx] = true;
		RW_ArmorActiveUntil[clientIdx] = GetEngineTime() + RWI_Duration[weaponSpec];
	}

	// read in the weapon to give to the player
	//int clipSize = info.GetInt("clip");
	char weaponName[64];
	info.GetString("classname", weaponName, sizeof(weaponName));
	
	// sarysa updated 2014-09-09, with armor gaining support for providing a rocket launcher
	// we can no longer assume no weapon name is safe
	if (strlen(weaponName) > 3)
	{
		int slot = TF2_GetClassnameSlot(weaponName);

		// sarysa updated 2014-09-23
		// if the hale already has a weapon, check the clip.
		// if it's lower than the clip of the int weapon, 
		/*bool shouldAddWeapon = true;
		if (RWI_Type[weaponSpec] != RW_TYPE_ARMOR && slot >= TFWeaponSlot_Primary && slot < TFWeaponSlot_Item1)
		{
			int oldWeapon = GetPlayerWeaponSlot(clientIdx, TFWeaponSlot_Primary);
			if (IsValidEntity(oldWeapon))
			{
				int oldClip = GetEntProp(oldWeapon, Prop_Send, "m_iClip1");
				if (oldClip > 0)
				{
					shouldAddWeapon = false;
					if (oldClip < clipSize)
						SetEntProp(oldWeapon, Prop_Send, "m_iClip1", clipSize);
				}
			}
		}
	
		if (shouldAddWeapon)*/
		{
			if (slot >= TFWeaponSlot_Primary && slot < TFWeaponSlot_Item1)
				TF2_RemoveWeaponSlot(clientIdx, slot);
			
			bool equip = true;
			TF2Items_CreateFromCfg(clientIdx, weaponName, info, equip);

			// change the active weapon spec
			RW_ActiveWeaponSpec[clientIdx] = weaponSpec;

			// stuff specific to god mode
			if (RWI_Type[weaponSpec] == RW_TYPE_GOD_MODE)
			{
				SetEntProp(clientIdx, Prop_Data, "m_takedamage", 0);
				TF2_AddCondition(clientIdx, TFCond_Ubercharged, -1.0);
				TF2_AddCondition(clientIdx, TFCond_MegaHeal, -1.0);

				RW_GodModeActive[clientIdx] = true;
				RW_GodModeActiveUntil[clientIdx] = GetEngineTime() + RWI_Duration[weaponSpec];
				RW_NextGodModeSoundAt[clientIdx] = GetEngineTime() + 2.5;
			}
		}
	}
		
	// display the message to the user
	RW_ActiveMessageIndex[clientIdx] = weaponSpec;
	RW_MessageActiveUntil[clientIdx] = GetEngineTime() + 5.0;
	ROTT_UpdateHUD(clientIdx);
	
	// play the rage sound
	IntToString(weaponSpec, actualRWIString, 40);
	FF2R_EmitBossSoundToAll("sound_rott_weapon", clientIdx, actualRWIString, .volume = 3.0);
}

static int DuplicateRocket(int clientIdx, int baseRocket, float speed, float spawnAngles[3], float zOffset)
{
	// create our rocket. no matter what, it's going to spawn, even if it ends up being out of map
	char classname[48] = "CTFProjectile_Rocket";
	char entname[48] = "tf_projectile_rocket";
	int rocket = CreateEntityByName(entname);
	if (!IsValidEntity(rocket))
	{
		PrintToServer("[sarysapub1] Error: Invalid entity %s. Won't spawn rocket.", entname);
		return -1;
	}
	
	// get spawn position from the base rocket
	float spawnPosition[3];
	GetEntPropVector(baseRocket, Prop_Send, "m_vecOrigin", spawnPosition);
	spawnPosition[2] += zOffset; // fixes problem of int rocket colliding with old one
	
	// determine velocity
	float spawnVelocity[3];
	GetAngleVectors(spawnAngles, spawnVelocity, NULL_VECTOR, NULL_VECTOR);
	spawnVelocity[0] *= speed;
	spawnVelocity[1] *= speed;
	spawnVelocity[2] *= speed;
	
	// deploy!
	SetEntProp(rocket, Prop_Send, "m_bCritical", GetEntProp(baseRocket, Prop_Send, "m_bCritical"));
	int damageOffset = FindSendPropInfo(classname, "m_iDeflected") + 4; // credit to voogru
	SetEntDataFloat(rocket, damageOffset, GetEntDataFloat(baseRocket, damageOffset), true);
	SetEntProp(rocket, Prop_Send, "m_nSkin", 1); // set skin to blue team's
	SetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity", clientIdx);
	SetVariantInt(GetClientTeam(clientIdx));
	AcceptEntityInput(rocket, "TeamNum", -1, -1, 0);
	SetVariantInt(GetClientTeam(clientIdx));
	AcceptEntityInput(rocket, "SetTeam", -1, -1, 0); 
	
	// I found this offset while trying to fix the sudden-explode issue with these rockets. it's another instance
	// of the owner entity, so why the hell not copy this over...probably useful for some things.
	int testOffset = FindSendPropInfo(classname, "m_bCritical") - 4;
	SetEntDataEnt2(rocket, testOffset, GetEntDataEnt2(baseRocket, testOffset), true);
	TeleportEntity(rocket, spawnPosition, spawnAngles, spawnVelocity);
	DispatchSpawn(rocket);
	
	SetEntProp(rocket, Prop_Send, "m_nSolidType", GetEntProp(baseRocket, Prop_Send, "m_nSolidType"));
	SetEntProp(rocket, Prop_Send, "m_usSolidFlags", GetEntProp(baseRocket, Prop_Send, "m_usSolidFlags"));
	SetEntProp(rocket, Prop_Send, "m_CollisionGroup", GetEntProp(baseRocket, Prop_Send, "m_CollisionGroup"));
	SetEntDataEnt2(rocket, testOffset, GetEntDataEnt2(baseRocket, testOffset), true);
	
	// to get stats from the user's melee weapon
	SetEntPropEnt(rocket, Prop_Send, "m_hOriginalLauncher", GetEntPropEnt(baseRocket, Prop_Send, "m_hOriginalLauncher"));
	SetEntPropEnt(rocket, Prop_Send, "m_hLauncher", GetEntPropEnt(baseRocket, Prop_Send, "m_hLauncher"));

	// must reskin after spawn
	SetEntProp(rocket, Prop_Send, "m_nModelIndex", GetEntProp(baseRocket, Prop_Send, "m_nModelIndex"));
	
	return rocket;
}

static void MonitorRocket(int clientIdx, int rocket, float velocity)
{
	int spec = RW_ActiveWeaponSpec[clientIdx];
	
	// so even if we don't need to monitor a rocket, we may still need to reskin it
	if (RWI_ModelOverrideIdx[spec] != -1)
		SetEntProp(rocket, Prop_Send, "m_nModelIndex", RWI_ModelOverrideIdx[spec]);
		
	// trail override
	if (!IsEmptyString(RWI_ParticleOverride[spec]))
	{
		CreateParticleEffect(RWI_ParticleOverride[spec], _, rocket, 10.0);
	}
	
	// mandatory sunbeams effect for god mode. gotta make it more god-like looking as in ROTT :P
	if (RWI_Type[spec] == RW_TYPE_GOD_MODE)
	{
		CreateParticleEffect("superrare_beams1", _, rocket, 10.0);
	}
	
	// do we really, truly need to monitor this rocket?
	// now that there's fake rocket jumping, yes.
	//if (RWI_HomingDegreesPerSecond[spec] <= 0.0 && RWI_RandomDeviationPerSecond[spec] <= 0.0 && RWI_NumAdditionalExplosions[spec] <= 0)
	//{
	//	if (PRINT_DEBUG_SPAM)
	//		PrintToServer("[sarysapub1] Rocket created but does not need to be monitored.");
	//	return;
	//}
	
	// find a free spot
	int rocketIdx = -1;
	for (int i = 0; i < MAX_ROCKETS; i++)
	{
		if (RMR_RocketEntRef[i] == 0)
		{
			rocketIdx = i;
			break;
		}
	}
	
	// delete last rocket if somehow there's more than 30
	if (rocketIdx == -1)
	{
		RemoveRocketAt(0, false);
		rocketIdx = MAX_ROCKETS - 1;
	}
	
	// now just do copies and inits, simple stuff
	RMR_Spec[rocketIdx] = spec;
	RMR_RocketEntRef[rocketIdx] = EntIndexToEntRef(rocket);
	RMR_NextDeviationAt[rocketIdx] = GetEngineTime() + RW_HomingInterval;
	RMR_HomingPerSecond[rocketIdx] = RWI_HomingDegreesPerSecond[spec];
	RMR_RandomDeviationPerSecond[rocketIdx] = RWI_RandomDeviationPerSecond[spec];
	RMR_CurrentHomingTarget[rocketIdx] = -1;
	RMR_CanRetarget[rocketIdx] = !RWI_ObsessiveHoming[spec];
	RMR_RocketVelocity[rocketIdx] = velocity;
	RMR_HasTargeted[rocketIdx] = false;
	RMR_FirebombCount[rocketIdx] = RWI_NumAdditionalExplosions[spec];
	RMR_FirebombsActivated[rocketIdx] = 0;
	int damageOffset = FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4; // credit to voogru
	RMR_FirebombDamage[rocketIdx] = RoundFloat(GetEntDataFloat(rocket, damageOffset));
	RMR_RocketOwner[rocketIdx] = clientIdx;
	RMR_FirebombInterval[rocketIdx] = RWI_ExplosionInterval[spec];
	RMR_ChainExplosionStartedAt[rocketIdx] = 0.0;
	GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", RMR_LastPosition[rocketIdx]);
	GetEntPropVector(rocket, Prop_Send, "m_angRotation", RMR_LastAngle[rocketIdx]);
	
	// efficiency, no sense doing the deviation check if there's no homing/deviation
	if (RMR_RandomDeviationPerSecond[rocketIdx] <= 0.0 && RMR_HomingPerSecond[rocketIdx] <= 0.0)
		RMR_NextDeviationAt[rocketIdx] = 999999.0;
}

static void RemoveRocketAt(int rocketIdx, bool keepAlive)
{
	int rocket = EntRefToEntIndex(RMR_RocketEntRef[rocketIdx]);
	if (IsValidEntity(rocket) && !keepAlive)
		AcceptEntityInput(rocket, "kill");
		
	for (int i = rocketIdx; i < MAX_ROCKETS - 1; i++)
	{
		RMR_Spec[i] = RMR_Spec[i+1];
		RMR_RocketEntRef[i] = RMR_RocketEntRef[i+1];
		RMR_NextDeviationAt[i] = RMR_NextDeviationAt[i+1];
		RMR_HomingPerSecond[i] = RMR_HomingPerSecond[i+1];
		RMR_RandomDeviationPerSecond[i] = RMR_RandomDeviationPerSecond[i+1];
		RMR_CurrentHomingTarget[i] = RMR_CurrentHomingTarget[i+1];
		RMR_CanRetarget[i] = RMR_CanRetarget[i+1];
		RMR_RocketVelocity[i] = RMR_RocketVelocity[i+1];
		RMR_HasTargeted[i] = RMR_HasTargeted[i+1];
		RMR_FirebombCount[i] = RMR_FirebombCount[i+1];
		RMR_FirebombsActivated[i] = RMR_FirebombsActivated[i+1];
		RMR_FirebombDamage[i] = RMR_FirebombDamage[i+1];
		RMR_RocketOwner[i] = RMR_RocketOwner[i+1];
		RMR_FirebombInterval[i] = RMR_FirebombInterval[i+1];
		RMR_ChainExplosionStartedAt[i] = RMR_ChainExplosionStartedAt[i+1];
		RMR_LastPosition[i][0] = RMR_LastPosition[i+1][0];
		RMR_LastPosition[i][1] = RMR_LastPosition[i+1][1];
		RMR_LastPosition[i][2] = RMR_LastPosition[i+1][2];
		RMR_LastAngle[i][0] = RMR_LastAngle[i+1][0];
		RMR_LastAngle[i][1] = RMR_LastAngle[i+1][1];
		RMR_LastAngle[i][2] = RMR_LastAngle[i+1][2];
	}
	RMR_RocketEntRef[MAX_ROCKETS - 1] = 0;
}

void Sarysapub1_EntityCreated(int rocket, const char[] classname)
{
	if (!RW_ActiveThisRound || strcmp(classname, "tf_projectile_rocket"))
		return;
		
	// don't let this execute while rockets are being created by me
	if (RocketBeingCreated)
		return;
		
	//PrintToServer("[sarysapub1] Rocket created... %d / %s", rocket, classname);
		
	// queue it up, as it hasn't been configured yet and is not ready for tracking or duplication
	for (int i = 0; i < ROCKET_QUEUE_SIZE; i++)
	{
		if (RocketQueue[i] == -1)
		{
			RocketQueue[i] = EntIndexToEntRef(rocket);
			break;
		}
	}
}

#define SPLIT_ANGLE_OFFSET 45.0
#define DRUNK_ANGLE_OFFSET 22.5
static void TestRocket(int rocket)
{
	int clientIdx = GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity");
	if (clientIdx == -1 || !RW_CanUse[clientIdx])
		return;
		
	// so it's the player's rocket. now do we care?
	int spec = RW_ActiveWeaponSpec[clientIdx];
	
	// figure out its velocity
	float vecVelocity[3];
	GetEntPropVector(rocket, Prop_Send, "m_vInitialVelocity", vecVelocity);
	float speed = getLinearVelocity(vecVelocity);
		
	// monitor the base rocket first
	MonitorRocket(clientIdx, rocket, speed);
		
	// stuff to do for split missile
	if (RWI_Type[spec] == RW_TYPE_SPLIT || RWI_Type[spec] == RW_TYPE_DRUNK)
	{
		RocketBeingCreated = true;
		
		// before turning the rocket, need to store its angle for the second rocket
		static float storedAngle[3];
		static float rocketAngle[3];
		GetEntPropVector(rocket, Prop_Send, "m_angRotation", storedAngle);
		
		if (RWI_Type[spec] == RW_TYPE_SPLIT)
		{
			// just change the yaw and velocity (split only)
			rocketAngle[0] = storedAngle[0];
			rocketAngle[1] = fixAngle(storedAngle[1] + SPLIT_ANGLE_OFFSET);
			rocketAngle[2] = storedAngle[2];
			GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
			vecVelocity[0] *= speed;
			vecVelocity[1] *= speed;
			vecVelocity[2] *= speed;
			TeleportEntity(rocket, NULL_VECTOR, rocketAngle, vecVelocity);
			
			// spawn a second rocket and monitor it
			rocketAngle[0] = storedAngle[0];
			rocketAngle[1] = fixAngle(storedAngle[1] - SPLIT_ANGLE_OFFSET);
			rocketAngle[2] = storedAngle[2];
			int newRocket = DuplicateRocket(clientIdx, rocket, speed, rocketAngle, 0.1);
			if (IsValidEntity(newRocket))
				MonitorRocket(clientIdx, newRocket, speed);
		}
		else if (RWI_Type[spec] == RW_TYPE_DRUNK)
		{
			// spawn more missiles
			for (int i = 0; i < RWI_AdditionalProjectiles[spec]; i++)
			{
				int mod = i % 4;
				rocketAngle[0] = fixAngle(storedAngle[0] + (mod == 2 ? DRUNK_ANGLE_OFFSET : (mod == 3 ? -DRUNK_ANGLE_OFFSET : 0.0)));
				rocketAngle[1] = fixAngle(storedAngle[1] + (mod == 0 ? DRUNK_ANGLE_OFFSET : (mod == 1 ? -DRUNK_ANGLE_OFFSET : 0.0)));
				rocketAngle[2] = storedAngle[2];
				int newRocket = DuplicateRocket(clientIdx, rocket, speed, rocketAngle, 0.1 * float(i+1));
				if (IsValidEntity(newRocket))
					MonitorRocket(clientIdx, newRocket, speed);
			}
		}
		
			
		RocketBeingCreated = false;
	}
}

// specific to rott weapons, someday if I do proper homing outside of this it shouldn't be hale-central
static bool RW_IsValidHomingTarget(int target, int owner)
{
	if (!IsLivingPlayer(target))
		return false;
	else if (GetClientTeam(target) == GetClientTeam(owner))
		return false;
	else if (TF2_IsPlayerInCondition(target, TFCond_Cloaked) || TF2_IsPlayerInCondition(target, TFCond_Stealthed))
		return false;
	else if (TF2_IsPlayerInCondition(target, TFCond_Disguised) && GetEntProp(target, Prop_Send, "m_nDisguiseTeam") == GetClientTeam(owner))
		return false;
		
	return true;
}

/**
 * ROTT Props
 */
Action Sarysapub1_TakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	if (RP_NoFallDamage)
		if (damagetype & DMG_FALL && attacker == 0 && inflictor == 0) // allow world fall damage
			return Plugin_Stop;
	
	if (RW_ActiveThisRound)
	{
		if (RW_ArmorActive[victim])
		{
			if ((damagetype & DMG_BLAST) != 0 || (damagetype & DMG_BURN) != 0 || (damagetype & DMG_BULLET) != 0)
			{
				damage = 0.0;
				damagetype |= DMG_PREVENT_PHYSICS_FORCE;
				return Plugin_Changed; // seems that crits are getting through, and nothing I can do about mini-crits.
			}
		}
	}

	return Plugin_Continue;
}
 
static Action OnPropDamaged(int prop, int& attacker, int& inflictor, 
							float& damage, int& damagetype, int& weapon, 
							float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsLivingPlayer(attacker))
		return Plugin_Continue;
	
	if ((damagetype & DMG_CLUB) && FF2R_GetBossData(attacker))
	{
		// allow bosses to 2-shot the props with melee
		damage = float(GetEntProp(prop, Prop_Data, "m_iMaxHealth") / 2);
	}

	Event event = CreateEvent("npc_hurt", true);
	event.SetInt("entindex", prop);
	event.SetInt("attacker_player", GetClientUserId(attacker));
	event.SetInt("weaponid", weapon);
	event.SetInt("damageamount", RoundFloat(damage));
	event.SetInt("health", GetEntProp(prop, Prop_Data, "m_iHealth") - RoundFloat(damage));
	event.FireToClient(attacker);
	event.Cancel();
	
	return Plugin_Changed;
}

static void RP_SetErrorState(int clientIdx, int errorState)
{
	if (errorState != RP_ERROR_STATE_NONE)
		EmitSoundToClient(clientIdx, NOPE_AVI);
		
	RP_ActiveErrorState[clientIdx] = errorState;
	RP_DisplayErrorUntil[clientIdx] = GetEngineTime() + 5.0;
	ROTT_UpdateHUD(clientIdx);
}

static void IncrementProp(int clientIdx)
{
	if (RP_CurrentlySelectedProp[clientIdx] == -1)
		return;
		
	int oldSelection = RP_CurrentlySelectedProp[clientIdx];
	for (int i = oldSelection + 1; i < PROP_COUNT; i++)
	{
		if (RP_CanDeployProp[clientIdx][i])
		{
			RP_CurrentlySelectedProp[clientIdx] = i;
			break;
		}
	}
	
	if (RP_CurrentlySelectedProp[clientIdx] == oldSelection)
	{
		for (int i = 0; i < oldSelection; i++)
		{
			if (RP_CanDeployProp[clientIdx][i])
			{
				RP_CurrentlySelectedProp[clientIdx] = i;
				break;
			}
		}
	}
		
	ROTT_UpdateHUD(clientIdx);
}

static bool SpawnProp(int clientIdx)
{
	int propType = RP_CurrentlySelectedProp[clientIdx];
	if (propType < 0 || propType >= PROP_COUNT)
	{
		PrintToServer("[sarysapub1] Somehow user selected an invalid ROTT prop.");
		RP_SetErrorState(clientIdx, RP_ERROR_STATE_UNKNOWN);
		return false; // wtf?
	}
	
	// make sure there's sufficient 
	BossData cfg = FF2R_GetBossData(clientIdx);
	float rageCost = RP_PropRageCost[clientIdx][propType];
	if (GetBossCharge(cfg, "0") < rageCost)
	{
		RP_SetErrorState(clientIdx, RP_ERROR_STATE_NEED_RAGE);
		return false;
	}
	
	// make sure user is on ground if it's the slicer
	if (propType == PROP_SLICER && (GetEntityFlags(clientIdx) & FL_ONGROUND) == 0)
	{
		RP_SetErrorState(clientIdx, RP_ERROR_STATE_GROUND_ONLY);
		return false;
	}
	
	// get our spawn point. the model should be configured correctly so we can place it on the user's coordinates.
	float spawnPoint[3];
	GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", spawnPoint);
	
	// if it's any solid prop, make sure it's not spawned in a location that could trap another player
	if (propType != PROP_SLICER)
	{
		for (int victim = 1; victim <= MaxClients; victim++)
		{
			if (clientIdx == victim || !IsLivingPlayer(victim))
				continue;
				
			// need to do a cylinder test in a potential blocking radius, which is pretty big (I set max distance high [70.0] to be paranoid)
			static float victimOrigin[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimOrigin);
			
			// that 108.0 is a generous 25.0 for the prop and 83.0 for the height of a player
			// needs to be even more stringent for the angle pad
			if (CylinderCollision(spawnPoint, victimOrigin, (propType == PROP_ANGLE_PAD ? 100.0 : 70.0), spawnPoint[2] - 108.0, propType == PROP_ANGLE_PAD ? (spawnPoint[2] + 25.0) : (spawnPoint[2] - 0.01)))
			{
				RP_SetErrorState(clientIdx, RP_ERROR_STATE_PLAYER_BLOCKING);
				return false;
			}
		}
	}
	
	// create the entity
	int prop = CreateEntityByName("prop_physics_override");
	if (!IsValidEntity(prop))
	{
		PrintToServer("[sarysapub1] Failed to create physics prop.");
		RP_SetErrorState(clientIdx, RP_ERROR_STATE_UNKNOWN);
		return false;
	}
	
	// everything but slicer can take damage
	SetEntProp(prop, Prop_Data, "m_takedamage", propType == PROP_SLICER ? 0 : 2);
	
	// give it the same angle of rotation as the player, but override the pitch
	float propAngles[3];
	GetEntPropVector(clientIdx, Prop_Data, "m_angRotation", propAngles);
	propAngles[0] = propType == PROP_ANGLE_PAD ? 45.0 : 0.0;
	SetEntPropVector(prop, Prop_Data, "m_angRotation", propAngles);
	
	// set the model
	char modelName[PLATFORM_MAX_PATH];
	if (propType == PROP_JUMP_PAD)
	{
		modelName = RPJP_JumpPadModel;
	}
	else if (propType == PROP_ANGLE_PAD)
	{
		modelName = RPJP_AnglePadModel;
	}
	else if (propType == PROP_SLICER)
	{
		modelName = RPS_SlicerModel;
	}
	else if (propType == PROP_PLATFORM)
	{
		modelName = RPP_PlatformModel;
	}
	
	if (strlen(modelName) < 3)
	{
		AcceptEntityInput(prop, "kill");
		PrintToServer("[sarysapub1] ERROR: Model not set for one of your props. Cannot spawn it.");
		RP_SetErrorState(clientIdx, RP_ERROR_STATE_UNKNOWN);
		return false;
	}
	SetEntityModel(prop, modelName);
	
	// angle pad needs to be moved 50HU behind the player so they don't get stuck
	if (propType == PROP_ANGLE_PAD)
	{
		float testAngles[3];
		testAngles[0] = 0.0;
		testAngles[1] = propAngles[1];
		float spawnOffset[3];
		GetAngleVectors(testAngles, spawnOffset, NULL_VECTOR, NULL_VECTOR);
		spawnOffset[0] = (-spawnOffset[0]) * 50.0;
		spawnOffset[1] = (-spawnOffset[1]) * 50.0;
		spawnOffset[2] = RPJP_AnglePadCollision[1][2]; // raise it up so it's not half in the ground
		
		spawnPoint[0] += spawnOffset[0];
		spawnPoint[1] += spawnOffset[1];
		spawnPoint[2] += spawnOffset[2];
	}
	
	// spawn and move it
	DispatchSpawn(prop);
	TeleportEntity(prop, spawnPoint, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(prop, Prop_Data, "m_takedamage", propType == PROP_SLICER ? 0 : 2); // looks familiar.
	
	// set its health
	SetEntProp(prop, Prop_Data, "m_iMaxHealth", RP_PropHealth[propType]);
	SetEntProp(prop, Prop_Data, "m_iHealth", RP_PropHealth[propType]);
	
	// set its collision and movement
	SetEntityMoveType(prop, MOVETYPE_NONE);
	SetEntityCollisionGroup(prop, 0); // fun fact, there is collision with players, but this flag keeps players from getting trapped upon approaching the prop.
	if (propType == PROP_SLICER)
	{
		SetEntProp(prop, Prop_Send, "m_usSolidFlags", 0x04); // not solid
		SetEntProp(prop, Prop_Send, "m_nSolidType", 0); // not solid
	}
		
	// damage hook it (need to let boss easily destroy it with melee, but not other weapons)
	SDKHook(prop, SDKHook_OnTakeDamage, OnPropDamaged);
	
	// find an open prop, or destroy an old one
	int propIdx = PROP_HighestSpawnedProp + 1;
	if (propIdx >= MAX_PROPS)
	{
		// oldest prop is always 0
		DestroyProp(0, true);
		
		propIdx = PROP_HighestSpawnedProp + 1;
		if (propIdx >= MAX_PROPS)
		{
			PrintToServer("[sarysapub1] ERROR: Prop index is max props somehow...");
			propIdx = MAX_PROPS - 1;
		}
	}

	// initialize prop info
	PROP_HighestSpawnedProp = propIdx;
	PROP_EntRef[propIdx] = EntIndexToEntRef(prop);
	PROP_Type[propIdx] = propType;
	PROP_OwnerUserId[propIdx] = GetClientUserId(clientIdx);
	float triggerTime = GetEngineTime() + (propType == PROP_SLICER ? RPS_DelayBeforeDamage : 0.0) - RP_EffectTriggerInterval[propType];
	for (int i = 1; i <= MaxClients; i++)
		PROP_NextTriggerTime[propIdx][i] = triggerTime;
		
	// trigger certain effects on the prop creator now, ignoring the collision check
	if (propType == PROP_JUMP_PAD)
		RP_TriggerJumpPad(clientIdx, propIdx);
	else if (propType == PROP_ANGLE_PAD)
		RP_TriggerAnglePad(clientIdx, propIdx, propAngles);
		
	// spend the rage
	SetBossCharge(cfg, "0", GetBossCharge(cfg, "0") - rageCost);
		
	return true; // yay it works
}

static void DestroyProp(int propIdx, bool reorder)
{
	int prop = EntRefToEntIndex(PROP_EntRef[propIdx]);
	if (IsValidEntity(prop))
		RemoveEntity(prop);
	
	if (reorder)
	{
		// this is expensive. do it sparingly.
		for (int i = propIdx; i < PROP_HighestSpawnedProp; i++)
		{
			PROP_EntRef[i] = PROP_EntRef[i+1];
			PROP_Type[i] = PROP_Type[i+1];
			PROP_OwnerUserId[i] = PROP_OwnerUserId[i+1];
			for (int j = 0; j <= MaxClients; j++)
				PROP_NextTriggerTime[i][j] = PROP_NextTriggerTime[i+1][j];
		}
		PROP_HighestSpawnedProp--;
	}
	else
		PROP_EntRef[propIdx] = -1;
}

#define JUMP_PAD_DEFAULT_INTENSITY 1000.0
static void RP_TriggerJumpPad(int clientIdx, int propIdx)
{
	// respect any existing velocity, but completely override Z
	static float playerVelocity[3];
	GetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", playerVelocity);
	playerVelocity[2] = JUMP_PAD_DEFAULT_INTENSITY * RPJP_JumpPadIntensity;
	SetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", playerVelocity);
	TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, playerVelocity);

	// play the sound
	if (strlen(RPJP_JumpPadSound) > 3)
		PlaySoundLocal(clientIdx, RPJP_JumpPadSound, true, 2);
		
	// set trigger time
	PROP_NextTriggerTime[propIdx][clientIdx] = GetEngineTime() + RP_EffectTriggerInterval[PROP_JUMP_PAD];
}

static void RP_TriggerAnglePad(int clientIdx, int propIdx, float propAngles[3])
{
	// get the player's current velocity and dampen it if necessary
	static float playerVelocity[3];
	GetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", playerVelocity);
	playerVelocity[0] *= (1.0 - RPJP_AnglePadDampeningFactor);
	playerVelocity[1] *= (1.0 - RPJP_AnglePadDampeningFactor);
	playerVelocity[2] = 0.0;
	
	// get velocity vectors for this jump pad
	float intensity = (JUMP_PAD_DEFAULT_INTENSITY * 2.0 / 3.0) * RPJP_AnglePadIntensity;
	float tmpVelocity[3];
	GetAngleVectors(propAngles, tmpVelocity, NULL_VECTOR, NULL_VECTOR);
	tmpVelocity[0] *= intensity;
	tmpVelocity[1] *= intensity;
	tmpVelocity[2] *= intensity;
	
	// add the two vectors and change the player's trajectory (cancel out any opposing momentum)
	if (signIsDifferent(playerVelocity[0], tmpVelocity[0]))
		playerVelocity[0] = tmpVelocity[0];
	else
		playerVelocity[0] += tmpVelocity[0];
	if (signIsDifferent(playerVelocity[1], tmpVelocity[1]))
		playerVelocity[1] = tmpVelocity[1];
	else
		playerVelocity[1] += tmpVelocity[1];
	playerVelocity[2] += fabs(tmpVelocity[2]);
	SetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", playerVelocity);
	TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, playerVelocity);

	// play the sound
	if (strlen(RPJP_JumpPadSound) > 3)
		PlaySoundLocal(clientIdx, RPJP_JumpPadSound, true, 2);

	// set trigger time
	PROP_NextTriggerTime[propIdx][clientIdx] = GetEngineTime() + RP_EffectTriggerInterval[PROP_ANGLE_PAD];
}

static void RP_TriggerSlicer(int clientIdx, int propIdx)
{
	// uber check
	if (!TF2_IsPlayerInCondition(clientIdx, TFCond_Ubercharged))
	{
		// damage the player, including self-damage
		int owner = GetClientOfUserId(PROP_OwnerUserId[propIdx]);
		if (!IsLivingPlayer(owner))
			owner = clientIdx;
		
		SetKillIcon("helicopter", "rott_slicer");
		SDKHooks_TakeDamage(clientIdx, owner, owner, RPS_DamagePerCheck, DMG_GENERIC | (RPS_NegatePushForce ? DMG_PREVENT_PHYSICS_FORCE : 0), -1);
		SetKillIcon();
	}

	// set trigger time
	PROP_NextTriggerTime[propIdx][clientIdx] = GetEngineTime() + RP_EffectTriggerInterval[PROP_SLICER];
}

/**
 * OnPlayerRunCmd/OnGameFrame
 */
#define TARGET_Z_OFFSET 40.0
void Sarysapub1_GameFrame()
{
	if (!PluginActiveThisRound)
		return;

	float curTime = GetEngineTime();

	// ROTT Props
	if (RP_ActiveThisRound)
	{
		// this is a very taxing method. try to alleviate it somewhat by getting all player living states and origins early
		static float clientBounds[MAXPLAYERS+1][3];
		static bool clientValid[MAXPLAYERS+1];
		static bool onGround[MAXPLAYERS+1];
		for (int clientIdx = 1; clientIdx <= MaxClients; clientIdx++)
		{
			clientValid[clientIdx] = IsLivingPlayer(clientIdx);
			if (clientValid[clientIdx])
			{
				GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", clientBounds[clientIdx]);
				onGround[clientIdx] = (GetEntityFlags(clientIdx) & FL_ONGROUND) != 0;
			}
		}
		
		for (int propIdx = PROP_HighestSpawnedProp; propIdx >= 0; propIdx--)
		{
			int prop = EntRefToEntIndex(PROP_EntRef[propIdx]);
			if (!IsValidEntity(prop))
			{
				DestroyProp(propIdx, true);
				continue;
			}

			// if the prop is a platform, there is no logic to worry about
			if (PROP_Type[propIdx] == PROP_PLATFORM)
				continue;
				
			// get prop bounds
			static float propBounds[3];
			GetEntPropVector(prop, Prop_Send, "m_vecOrigin", propBounds);

			// collision tests on all living players
			if (PROP_Type[propIdx] == PROP_JUMP_PAD) // can do a more accurate test with this one
			{
				for (int clientIdx = 1; clientIdx <= MaxClients; clientIdx++)
				{
					if (!clientValid[clientIdx] || !onGround[clientIdx])
						continue;
					
					// do a cylinder collision test
					if (CylinderCollision(propBounds, clientBounds[clientIdx], RPJP_JumpPadCollision[0][0], propBounds[2] + RPJP_JumpPadCollision[0][2], propBounds[2] + RPJP_JumpPadCollision[1][2]))
					{
						if (PROP_NextTriggerTime[propIdx][clientIdx] <= curTime)
						{
							// push 'em up!
							RP_TriggerJumpPad(clientIdx, propIdx);
						}
					}
				}
			}
			else if (PROP_Type[propIdx] == PROP_ANGLE_PAD)
			{
				// get prop angles
				static float propAngles[3];
				GetEntPropVector(prop, Prop_Send, "m_angRotation", propAngles);
				
				// get proper collision min/max
				static float collisionMin[3];
				collisionMin[0] = propBounds[0] + RPJP_AnglePadCollision[0][0];
				collisionMin[1] = propBounds[1] + RPJP_AnglePadCollision[0][1];
				collisionMin[2] = propBounds[2] + RPJP_AnglePadCollision[0][2];
				static float collisionMax[3];
				collisionMax[0] = propBounds[0] + RPJP_AnglePadCollision[1][0];
				collisionMax[1] = propBounds[1] + RPJP_AnglePadCollision[1][1];
				collisionMax[2] = propBounds[2] + RPJP_AnglePadCollision[1][2];
				
				for (int clientIdx = 1; clientIdx <= MaxClients; clientIdx++)
				{
					if (!clientValid[clientIdx])
						continue;
						
					// do a rectangle collision test
					if (WithinBounds(clientBounds[clientIdx], collisionMin, collisionMax))
					{
						if (PROP_NextTriggerTime[propIdx][clientIdx] <= curTime)
						{
							// push 'em!
							RP_TriggerAnglePad(clientIdx, propIdx, propAngles);
						}
					}
				}
			}
			else // if (PROP_Type[propIdx] == PROP_SLICER) [currently implied]
			{
				for (int clientIdx = 1; clientIdx <= MaxClients; clientIdx++)
				{
					if (!clientValid[clientIdx])
						continue;
					
					// need a modifier that depends on if the player's ducking
					float zMod = (GetEntityFlags(clientIdx) & FL_DUCKING) == 0 ? 83.0 : 63.0;

					// do a bounds check along the player, since this thing will be shorter than a player but larger than 20 HU tall
					if (CylinderCollision(propBounds, clientBounds[clientIdx], RPS_SlicerCollision[0][0], (propBounds[2] + RPS_SlicerCollision[0][2]) - zMod, propBounds[2] + RPS_SlicerCollision[1][2]))
					{
						// can we trigger the effect?
						if (PROP_NextTriggerTime[propIdx][clientIdx] <= curTime)
						{
							// damage them
							RP_TriggerSlicer(clientIdx, propIdx);

							PROP_NextTriggerTime[propIdx][clientIdx] = curTime + RP_EffectTriggerInterval[PROP_SLICER];
						}
					}
				}
			}
		}
	}

	// ROTT Weapons
	if (RW_ActiveThisRound)
	{
		// manage homing rockets and firebomb
		for (int rocketIdx = MAX_ROCKETS - 1; rocketIdx >= 0; rocketIdx--)
		{
			if (RMR_RocketEntRef[rocketIdx] == 0)
				continue;
			
			int rocket = EntRefToEntIndex(RMR_RocketEntRef[rocketIdx]);
			if (!IsValidEntity(rocket))
			{
				// firebombs managed by a dead entity
				if (RMR_FirebombsActivated[rocketIdx] < RMR_FirebombCount[rocketIdx])
				{
					// abort if the owner is dead
					if (!IsLivingPlayer(RMR_RocketOwner[rocketIdx]))
					{
						RemoveRocketAt(rocketIdx, true);
						continue;
					}
				
					if (RMR_ChainExplosionStartedAt[rocketIdx] == 0.0)
					{
						RMR_ChainExplosionStartedAt[rocketIdx] = curTime;
						
						// tweak the origin based on pitch, to prevent minor obstacles from blocking explosions (only major ones should)
						if (RMR_LastAngle[rocketIdx][0] < 0.0) // rocket was fired up
							RMR_LastPosition[rocketIdx][2] -= 20.0;
						else if (RMR_LastAngle[rocketIdx][0] > 0.0) // rocket was fired down
							RMR_LastPosition[rocketIdx][2] += 20.0;
					}
				
					if (RMR_ChainExplosionStartedAt[rocketIdx] + (float(1 + RMR_FirebombsActivated[rocketIdx]) * RMR_FirebombInterval[rocketIdx]) <= curTime)
					{
						RMR_FirebombsActivated[rocketIdx]++;
						float minDistance = FIREBOMB_EXPLOSION_DISTANCE_BETWEEN * float(RMR_FirebombsActivated[rocketIdx]);
						float tmpVec[3];
						float firebombAngles[3];
						firebombAngles[0] = 0.0; // in ROTT 2013 and ROTT 1994, the firebomb's pitch was always 0.0
						
						for (int i = 0; i < 4; i++)
						{
							firebombAngles[1] = fixAngle(RMR_LastAngle[rocketIdx][1] + (float(i) * 90.0));
							Handle trace = TR_TraceRayFilterEx(RMR_LastPosition[rocketIdx], firebombAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, Trace_WallsOnly);
							TR_GetEndPosition(tmpVec, trace);
							CloseHandle(trace);
							float distance = GetVectorDistance(RMR_LastPosition[rocketIdx], tmpVec);
							if (distance >= minDistance)
							{
								// test passed. constrain the distance and trigger an explosion.
								constrainDistance(RMR_LastPosition[rocketIdx], tmpVec, distance, minDistance);
								int firebomb = CreateEntityByName("env_explosion");
								char intAsString[12];
								Format(intAsString, 12, "%d", RMR_FirebombDamage[rocketIdx]);
								DispatchKeyValue(firebomb, "iMagnitude", intAsString);
								DispatchKeyValueFloat(firebomb, "DamageForce", 1.0);
								DispatchKeyValue(firebomb, "spawnflags", "0");
								DispatchKeyValue(firebomb, "iRadiusOverride", FIREBOMB_EXPLOSION_RADIUS);
								
								// set data pertinent to the user
								SetEntPropEnt(firebomb, Prop_Send, "m_hOwnerEntity", RMR_RocketOwner[rocketIdx]);
								//Format(intAsString, 12, "%d", RMR_RocketOwner[rocketIdx]); // not this way (but ff2 blocks it anyway)
								//DispatchKeyValue(firebomb, "ignoredEntity", intAsString);
								
								// spawn
								TeleportEntity(firebomb, tmpVec, NULL_VECTOR, NULL_VECTOR);
								DispatchSpawn(firebomb);
								
								// explode!
								AcceptEntityInput(firebomb, "Explode");
								AcceptEntityInput(firebomb, "kill");
							}
						}
					}
				
					// don't cease tracking this rocket until all explosions execute
					if (RMR_FirebombsActivated[rocketIdx] < RMR_FirebombCount[rocketIdx])
						continue;
				}
			
				RemoveRocketAt(rocketIdx, false);
				continue;
			}
			
			// if this rocket has been airblasted, it becomes an ordinary RED rocket (...I know...)
			int owner = GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity");
			if (!IsLivingPlayer(owner))
			{
				RemoveRocketAt(rocketIdx, true);
				continue;
			}
			
			//PrintToServer("deltaTime=%f    interval=%f    randomdev=%f   nda=%f", deltaTime, RW_HomingInterval, RMR_RandomDeviationPerSecond[rocketIdx], RMR_NextDeviationAt[rocketIdx]);
			if (RMR_NextDeviationAt[rocketIdx] <= curTime)
			{
				float deltaTime = (curTime - RMR_NextDeviationAt[rocketIdx]) + RW_HomingInterval;
				
				// get the angles and mess with them first
				static float rocketAngle[3];
				GetEntPropVector(rocket, Prop_Send, "m_angRotation", rocketAngle);
			
				// missile homing
				if (RMR_HomingPerSecond[rocketIdx] > 0.0)
				{
					static float targetOrigin[3];
					static float rocketOrigin[3];
					GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketOrigin);
					static float tmpAngles[3];
					static float tmpOrigin[3];
				
					// first, check if the current target is not out of homing range or dead
					if (RMR_CurrentHomingTarget[rocketIdx] != -1)
					{
						int target = EntRefToEntIndex(RMR_CurrentHomingTarget[rocketIdx]);
						if (!RW_IsValidHomingTarget(target, owner))
						{
							RMR_CurrentHomingTarget[rocketIdx] = -1;
						}
						else
						{
							GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetOrigin);
							targetOrigin[2] += TARGET_Z_OFFSET; // target their midsection
							
							// first do a ray trace. if that fails, target lost.
							GetRayAngles(rocketOrigin, targetOrigin, tmpAngles);
							Handle trace = TR_TraceRayFilterEx(rocketOrigin, tmpAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, Trace_WallsOnly);
							TR_GetEndPosition(tmpOrigin, trace);
							CloseHandle(trace);
							if (GetVectorDistance(rocketOrigin, targetOrigin, true) > GetVectorDistance(rocketOrigin, tmpOrigin, true))
							{
								RMR_CurrentHomingTarget[rocketIdx] = -1;
							}
							else
							{
								// check the angles to ensure the rocket can still "see" the player, which is just a lazy check of pitch and yaw
								// though it's almost always going to be yaw that fails first
								if (!AngleWithinTolerance(rocketAngle, tmpAngles, RWI_HomeAngle[RMR_Spec[rocketIdx]]))
								{
									RMR_CurrentHomingTarget[rocketIdx] = -1;
								}
							}
						}
					}
					
					// see it homing can be (re)started
					if (RMR_CurrentHomingTarget[rocketIdx] == -1 && !(!RMR_CanRetarget[rocketIdx] && RMR_HasTargeted[rocketIdx]))
					{
						float nearestValidDistance = 9999.0 * 9999.0;
						float testDist = 0.0;
						int nearestValidTarget = -1;
					
						// find the closest target within tolerance
						for (int target = 1; target <= MaxClients; target++)
						{
							if (!RW_IsValidHomingTarget(target, owner))
								continue;
								
							GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetOrigin);
							targetOrigin[2] += TARGET_Z_OFFSET;
							testDist = GetVectorDistance(rocketOrigin, targetOrigin, true);
							
							// least distance so far?
							if (testDist < nearestValidDistance)
							{
								GetRayAngles(rocketOrigin, targetOrigin, tmpAngles);
								Handle trace = TR_TraceRayFilterEx(rocketOrigin, tmpAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, Trace_WallsOnly);
								TR_GetEndPosition(tmpOrigin, trace);
								CloseHandle(trace);
								
								// wall test passed?
								if (testDist < GetVectorDistance(rocketOrigin, tmpOrigin, true))
								{
									// angle tolerance passed?
									if (AngleWithinTolerance(rocketAngle, tmpAngles, RWI_LockOnAngle[RMR_Spec[rocketIdx]]))
									{
										nearestValidTarget = target;
										nearestValidDistance = testDist;
									}
								}
							}
						}
						
						// if we've locked on, reflect this
						if (nearestValidTarget != -1)
						{
							RMR_CurrentHomingTarget[rocketIdx] = EntIndexToEntRef(nearestValidTarget);
							RMR_HasTargeted[rocketIdx] = true;
						}
					}
					
					// now home! tmpAngles is already what we want it to be.
					if (RMR_CurrentHomingTarget[rocketIdx] != -1)
					{
						float maxAngleDeviation = deltaTime * RMR_HomingPerSecond[rocketIdx];
						
						for (int i = 0; i < 2; i++)
						{
							if (fabs(rocketAngle[i] - tmpAngles[i]) <= RWI_HomeAngle[RMR_Spec[rocketIdx]])
							{
								if (rocketAngle[i] - tmpAngles[i] < 0.0)
									rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - rocketAngle[i]);
								else
									rocketAngle[i] -= fmin(maxAngleDeviation, rocketAngle[i] - tmpAngles[i]);
							}
							else // it wrapped around
							{
								float tmpRocketAngle = rocketAngle[i];
							
								if (rocketAngle[i] - tmpAngles[i] < 0.0)
									tmpRocketAngle += 360.0;
								else
									tmpRocketAngle -= 360.0;
									
								if (tmpRocketAngle - tmpAngles[i] < 0.0)
									rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - tmpRocketAngle);
								else
									rocketAngle[i] -= fmin(maxAngleDeviation, tmpRocketAngle - tmpAngles[i]);
							}
							
							rocketAngle[i] = fixAngle(rocketAngle[i]);
						}
					}
				}
				
				// random deviation for drunk missile
				if (RMR_RandomDeviationPerSecond[rocketIdx] > 0.0)
				{
					float maxAngleDeviation = deltaTime * RMR_RandomDeviationPerSecond[rocketIdx];
					rocketAngle[0] = fixAngle(rocketAngle[0] + RandomNegative(GetRandomFloat(0.0, maxAngleDeviation)));
					rocketAngle[1] = fixAngle(rocketAngle[1] + RandomNegative(GetRandomFloat(0.0, maxAngleDeviation)));
				}
				
				// now use the old velocity and tweak it to match the int angles
				float vecVelocity[3];
				GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
				vecVelocity[0] *= RMR_RocketVelocity[rocketIdx];
				vecVelocity[1] *= RMR_RocketVelocity[rocketIdx];
				vecVelocity[2] *= RMR_RocketVelocity[rocketIdx];
				
				// apply both changes
				TeleportEntity(rocket, NULL_VECTOR, rocketAngle, vecVelocity);
				
				RMR_NextDeviationAt[rocketIdx] = curTime + RW_HomingInterval;
			}
			
			// always need to get these if there'll be a firebomb
			if (RMR_FirebombCount[rocketIdx] > 0)
			{
				GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", RMR_LastPosition[rocketIdx]);
				GetEntPropVector(rocket, Prop_Send, "m_angRotation", RMR_LastAngle[rocketIdx]);
			}
		}
		
		// test int rockets
		for (int i = 0; i < ROCKET_QUEUE_SIZE; i++)
		{
			if (RocketQueue[i] != -1)
			{
				int rocket = EntRefToEntIndex(RocketQueue[i]);
				if (IsValidEntity(rocket))
					TestRocket(rocket);
				RocketQueue[i] = -1;
			}
		}
	}
	
	for (int clientIdx = 1; clientIdx <= MaxClients; clientIdx++)
	{
		if (!IsLivingPlayer(clientIdx))
			continue;

		// ROTT weapons
		if (RW_ActiveThisRound && RW_CanUse[clientIdx])
		{
			if (RW_ActiveMessageIndex[clientIdx] != -1 && RW_MessageActiveUntil[clientIdx] <= GetEngineTime())
			{
				RW_ActiveMessageIndex[clientIdx] = -1;
				ROTT_UpdateHUD(clientIdx);
			}

			// is it time to remove armor and/or god mode?
			if (RW_ArmorActive[clientIdx] && RW_ArmorActiveUntil[clientIdx] <= GetEngineTime())
			{
				RW_ArmorActive[clientIdx] = false;
			}

			if (RW_GodModeActive[clientIdx] && RW_GodModeActiveUntil[clientIdx] <= GetEngineTime())
			{
				SetEntProp(clientIdx, Prop_Data, "m_takedamage", 2);
				if (TF2_IsPlayerInCondition(clientIdx, TFCond_Ubercharged))
					TF2_RemoveCondition(clientIdx, TFCond_Ubercharged);
				if (TF2_IsPlayerInCondition(clientIdx, TFCond_MegaHeal))
					TF2_RemoveCondition(clientIdx, TFCond_MegaHeal);
				TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Primary); // remove the nearly bottomless rocket launcher
				SetEntPropEnt(clientIdx, Prop_Data, "m_hActiveWeapon", GetPlayerWeaponSlot(clientIdx, TFWeaponSlot_Melee));
				RW_GodModeActive[clientIdx] = false;
			}
			else if (RW_GodModeActive[clientIdx] && RW_NextGodModeSoundAt[clientIdx] <= GetEngineTime())
			{
				FF2R_EmitBossSoundToAll("sound_rott_godmode", clientIdx);
				RW_NextGodModeSoundAt[clientIdx] = GetEngineTime() + 5.0;
			}
		}

		// HUD
		if ((RP_ActiveThisRound || RW_ActiveThisRound) && (RP_CanUse[clientIdx] || RW_CanUse[clientIdx]))
		{
			if (ROTT_HudRefreshAt[clientIdx] <= GetEngineTime())
			{
				if(GameRules_GetRoundState() != RoundState_TeamWin)
				{
					// going with the FF2 timer values, since I'd like it to be fairly responsive
					SetHudTextParams(-1.0, 0.6, 0.15, 255, 255, 255, 255);
					ShowSyncHudText(clientIdx, ROTT_SyncHud, ROTT_HudMessage[clientIdx]);
				}

				ROTT_HudRefreshAt[clientIdx] = GetEngineTime() + 0.1;
			}
		}
	}
}
 
void Sarysapub1_PlayerRunCmd(int clientIdx, int buttons)
{
	if (!PluginActiveThisRound)
		return;

	// ROTT props
	if (RP_ActiveThisRound && RP_CanUse[clientIdx])
	{
		if ((!RP_SpecialKeyDown[clientIdx] && (buttons & IN_ATTACK3)) || (!RP_AltFireKeyDown[clientIdx] && (buttons & IN_ATTACK2)))
			SpawnProp(clientIdx);
			
		if (!RP_ReloadKeyDown[clientIdx] && (buttons & IN_RELOAD))
			IncrementProp(clientIdx);
			
		RP_SpecialKeyDown[clientIdx] = (buttons & IN_ATTACK3) != 0;
		RP_AltFireKeyDown[clientIdx] = (buttons & IN_ATTACK2) != 0;
		RP_ReloadKeyDown[clientIdx] = (buttons & IN_RELOAD) != 0;
		
		// error state
		if (RP_ActiveErrorState[clientIdx] != RP_ERROR_STATE_NONE && RP_DisplayErrorUntil[clientIdx] <= GetEngineTime())
		{
			RP_ActiveErrorState[clientIdx] = RP_ERROR_STATE_NONE;
			ROTT_UpdateHUD(clientIdx);
		}
	}
}

/**
 * General helper stocks, some original, some taken/modified from other sources
 */
static void PlaySoundLocal(int clientIdx, char[] soundPath, bool followPlayer = true, int stack = 1)
{
	// play a speech sound that travels normally, local from the player.
	static float playerPos[3];
	GetClientEyePosition(clientIdx, playerPos);
	//PrintToServer("eye pos=%f,%f,%f     sound=%s", playerPos[0], playerPos[1], playerPos[2], soundPath);
	for (int i = 0; i < stack; i++)
		EmitAmbientSound(soundPath, playerPos, followPlayer ? clientIdx : SOUND_FROM_WORLD);
}

static bool IsLivingPlayer(int clientIdx)
{
	if (clientIdx <= 0 || clientIdx >= MAXPLAYERS+1)
		return false;
		
	return IsClientInGame(clientIdx) && IsPlayerAlive(clientIdx);
}

static void ParseHull(char hullStr[197], float hull[2][3])
{
	char hullStrs[2][197 / 2];
	char vectorStrs[3][197 / 6];
	ExplodeString(hullStr, " ", hullStrs, 2, 197 / 2);
	for (int i = 0; i < 2; i++)
	{
		ExplodeString(hullStrs[i], ",", vectorStrs, 3, 197 / 6);
		hull[i][0] = StringToFloat(vectorStrs[0]);
		hull[i][1] = StringToFloat(vectorStrs[1]);
		hull[i][2] = StringToFloat(vectorStrs[2]);
	}
}

static void ReadHull(ConfigData cfg, const char[] arg_name, float hull[2][3])
{
	static char hullStr[197];
	cfg.GetString(arg_name, hullStr, 197);
	ParseHull(hullStr, hull);
}

static void ReadSound(ConfigData cfg, const char[] arg_name, char soundFile[PLATFORM_MAX_PATH])
{
	cfg.GetString(arg_name, soundFile, PLATFORM_MAX_PATH);
	if (strlen(soundFile) > 3)
		PrecacheSound(soundFile);
}

static void ReadModel(ConfigData cfg, const char[] arg_name, char modelFile[PLATFORM_MAX_PATH])
{
	cfg.GetString(arg_name, modelFile, PLATFORM_MAX_PATH);
	if (strlen(modelFile) > 3)
		PrecacheModel(modelFile);
}

static int ReadModelToInt(ConfigData cfg, const char[] arg_name)
{
	static char modelFile[PLATFORM_MAX_PATH];
	cfg.GetString(arg_name, modelFile, PLATFORM_MAX_PATH);
	if (strlen(modelFile) > 3)
		return PrecacheModel(modelFile);
	return -1;
}

static void ReadCenterText(ConfigData cfg, const char[] arg_name, char centerText[170])
{
	cfg.GetString(arg_name, centerText, 170);
	ReplaceString(centerText, 170, "\\n", "\n");
}

static float fixAngle(float angle)
{
	int sanity = 0;
	while (angle < -180.0 && (sanity++) <= 10)
		angle = angle + 360.0;
	while (angle > 180.0 && (sanity++) <= 10)
		angle = angle - 360.0;
		
	return angle;
}

static int min(int n1, int n2)
{
	return n1 < n2 ? n1 : n2;
}

static float fmin(float n1, float n2)
{
	return n1 < n2 ? n1 : n2;
}

static bool WithinBounds(float point[3], float min[3], float max[3])
{
	return point[0] >= min[0] && point[0] <= max[0] &&
		point[1] >= min[1] && point[1] <= max[1] &&
		point[2] >= min[2] && point[2] <= max[2];
}

static bool CylinderCollision(float cylinderOrigin[3], float colliderOrigin[3], float maxDistance, float zMin, float zMax)
{
	if (colliderOrigin[2] < zMin || colliderOrigin[2] > zMax)
		return false;

	static float tmpVec1[3];
	tmpVec1[0] = cylinderOrigin[0];
	tmpVec1[1] = cylinderOrigin[1];
	tmpVec1[2] = 0.0;
	static float tmpVec2[3];
	tmpVec2[0] = colliderOrigin[0];
	tmpVec2[1] = colliderOrigin[1];
	tmpVec2[2] = 0.0;
	
	return GetVectorDistance(tmpVec1, tmpVec2, true) <= maxDistance * maxDistance;
}

static float getLinearVelocity(float vecVelocity[3])
{
	return SquareRoot((vecVelocity[0] * vecVelocity[0]) + (vecVelocity[1] * vecVelocity[1]) + (vecVelocity[2] * vecVelocity[2]));
}

static float RandomNegative(float val)
{
	return val * (GetRandomInt(0, 1) == 1 ? 1.0 : -1.0);
}

static void GetRayAngles(float startPoint[3], float endPoint[3], float angle[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPoint[0] - startPoint[0];
	tmpVec[1] = endPoint[1] - startPoint[1];
	tmpVec[2] = endPoint[2] - startPoint[2];
	GetVectorAngles(tmpVec, angle);
}

static bool AngleWithinTolerance(float entityAngles[3], float targetAngles[3], float tolerance)
{
	static bool tests[2];
	
	for (int i = 0; i < 2; i++)
		tests[i] = fabs(entityAngles[i] - targetAngles[i]) <= tolerance || fabs(entityAngles[i] - targetAngles[i]) >= 360.0 - tolerance;
	
	return tests[0] && tests[1];
}

static void constrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance)
{
	if (distance <= maxDistance)
		return; // nothing to do
		
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

static bool signIsDifferent(const float one, const float two)
{
	return one < 0.0 && two > 0.0 || one > 0.0 && two < 0.0;
}
