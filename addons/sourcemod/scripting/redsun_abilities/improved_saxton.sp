/*
	Rages for sarysa's improved version of Saxton Hale
	Replaced that stupid stun rage with actual physical fighting moves, which is far more appropriate for Saxton.

	"saxton_lunge"
	{
		// note that it's assumed the model has an override for condition 81
		// though 81's default works pretty well if you want the lunge to kind of looks like a kick
		// though saxton's getting a punch.
		"key"		"0" // key to use. 0 = reload, 1 = middle mouse, 2 = alt fire (not recommended)
		"cooldown"	"10.0" // cooldown between uses
		"ragecost"	"20.0" // rage cost
		"velocity"	"1100.0" // velocity of charge
		"damage"	"100.0" // damage dealt to any player it strikes. note that players can only be struck once per rage.
		"buildings"	"1" // 1 = destroys buildings, 0 = does nothing to them
		"knockback"	"200.0" // knockback intensity, added to the hale's own velocity so keep it low
		
		// collision needs to be artificial since he needs to be able to mow through players
		// so it's ahead of them to ensure he won't be stopped by obstacles
		"collisiondist"		"30.0" // collision cylinder distance from origin
		"collisionheight"	"95.0" // collision cylinder height
		"collisionradius"	"60.0" // collision cylinder radius
		
		"hitsound"	"weapons/fist_hit_world1.wav" // sound to play when hitting a target
		"hiteffect"	"taunt_headbutt_impact_stars" // effect to display when hitting a target
		
		// below allows you to constrain the hale's pitch, since numerous people expressed concern
		// about lunging straight up or down. it won't give an error, it'll just execute the move while overriding user's pitch
		"pitch"	"-45.0;45.0" // pitch min/max. if this is not set, there will be no constraints. values above abs(90) are useless
		
		// error messages
		"cooldownerror"		"Ability is on cooldown!"
		"norageerror"		"Not enough rage! %.0f rage required."
		"inwatererror"		"Can't use in water!" // these sorts of charge abilities suck in water, so it's blocked entirely
		"weightdownerror"	"Can't use during weighdown!" // if hale has weighdown active, this error occurs
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
	"sound_saxton_lunge"
	{
		"saxton_hale/saxton_hale_responce_rage2.wav"	""
	}

	"saxton_slam"
	{
		"key"			"1" // key to use. 0 = reload, 1 = middle mouse, 2 = alt fire (not recommended)
		"cooldown"		"15.0" // cooldown between uses
		"ragecost"		"30.0" // rage cost
		"propdelay"		"0.1" // initial delay, in which the trickery to execute his taunt will be done. too low and the taunt doesn't execute.
		"propdelay"		"models/sarysa/tauntprop.mdl" // path to the physics model, which is part of the trick allowing him to taunt in midair
		"gravitydelay"		"1.1" // time before his gravity skyrockets
		"gravitysetting"	"10.0" // gravity to set, recommend higher than weighdown which is 6.0
		"maxdamage"		"200.0" // damage at the epicenter
		"radius"		"1000.0" // radius (damage and knockback)
		"damagedecay"		"1.3" // damage decay exponent. higher exponent = faster decay over distance. 1.0 is linear decay. 0.0 is no decay. (not recommended)
		"buildingdamage"	"1.5" // building damage factor
		"knockback"		"1000.0" // knockback at the epicenter, decay is linear
		
		// error strings
		"cooldownerror"		"Ability is on cooldown!"
		"norageerror"		"Not enough rage! %.0f rage required."
		"notmidairerror"	"Can't use on the ground or in water!" // if hale is not in midair, this error occurs (reason for the midair requirement is it makes no sense in tight tunnels)
		"weightdownerror"	"Can't use during weighdown!" // if hale has weighdown active, this error occurs
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
	"sound_saxton_slam"
	{
		"saxton_hale/saxton_hale_responce_jump2.wav"	"0"
		"ambient/atmosphere/terrain_rumble1.wav"	"1"
	}

	"rage_saxton_berserk"
	{
		"duration"	"8.0" // duration
		"speed"		"490.0" // speed during rage. max is 520hups. set to 0.0 to not use feature.
		"attachment"	"hand_R;hand_L" // fist attachment names, semicolon separated (max two) [these two are not standard, you must put them in your model's QC]
		"tempclass"	"6" // temporary class change. 0 to not use. (6=heavy)
		
		// standard weapon stats
		"passive"
		{
			"weapon slot"	"2"
			"classname"	"tf_weapon_shovel"
		}
		
		// rage weapon stats
		"rage"
		{
			"weapon slot"	"2"
			"classname"	"tf_weapon_fists"
		}
		"arg6"	"tf_weapon_fists"
		"arg7"	"5"
		"arg8"	"1 ; 0.22 ; 15 ; 0 ; 137 ; 15.0 ; 6 ; 0.3 ; 208 ; 1 ; 209 ; 1 ; 68 ; -1" // weapon args (very reduced damage, no random crits, one-shot non wrangled buildings, fire rate bonus, ignite players on hit, minicrit ignited players
		"arg9"	"1" // weapon visibility
		
		"arg10"	"2" // weapon slot (2=melee)
		
		// flags. Add them up to get desired results:
		// 0x0001: Auto-fire
		// 0x0002: Flaming fists aesthetic
		// 0x0004: Add MegaHeal (knockback/airblast immune)
		"flags"	"0x0007"
		
		"plugin_name"	"ff2r_redsun_abilities"
	}

	"saxton_huds"
	{
		// necessary to get all these abilities in three HUDs. beyond three causes flicker.
		
		"hudy"			"0.62" // HUD Y
		"hudformat"		"\n%s\n%s\n\n%s\n%s\n%s" // overall format of HUD. first string is health (optional), rage% is second, third+fourth+fifth are lunge, slam, and berserk
		"displayhealth"		"1" // if 1, display health
		"displayrage"		"1" // if 1, display current rage
		"lungeready"		"Lunge ability READY. RELOAD (R) to use. (%.0f rage)" // lunge ready
		"lungenotready"		"Lunge ability not ready." // lunge not ready. rage is optional parameter, %.0f will be accepted.
		"slamready"		"Slam ability READY. MIDDLE MOUSE to use. (%.0f rage)" // slam ready
		"slamnotready"		"Slam ability not ready. (must be in midair)" // slam not ready. rage is optional parameter, %.0f will be accepted.
		"berserkready"		"Berserk ability READY. CALL FOR MEDIC (E) to use."
		"berserknotready"	"Berserk ability not ready."
		"normalcolor"		"0xFFFFFF" // normal color
		"alertcolor"		"0xC00000" // alert color
		"alertnotready"		"0" // if 1, use alert color for ability not ready (this is not standard rage notification behavior)
		"healthstr"		"Health: %d / %d" // health str
		"ragestr"		"Rage: %.0f%%" // rage str
		"alertlowhealth"	"1" // if 1, HP alert color when HP is one third of maximum. because why the hell not.
		
		"plugin_name"	"ff2r_redsun_abilities"
	}

	"saxton_advanced_options"
	{
		// this ability is optional. I'm only including it to show that it exists and to document the options.
		// all arguments are also optional.
		
		"lunge"		"" // additional conditions during lunge, semicolon separated. i.e. 5;42   [max 10]
		"slam"		"" // additional conditions during slam, semicolon separated. i.e. 5;42   [max 10]
		"berserk"	"33" // additional conditions during berserk, semicolon separated. i.e. 5;42   [max 10]
		
		// note that the default particles for saxton slam are hammer_impact_button_dust2 and hammer_impact_button_ring
		"effect1"	"" // override particle #1 for saxton slam. only one needs to exist for it to work.
		"effect2"	"" // override particle #2 for saxton slam. only one needs to exist for it to work.
		
		"slamconsole"		"saxton_slam" // slam kill name, only seen in console
		"lungeconsole"		"saxton_lunge" // lunge kill name, only seen in console
		"berserkconsole"	"saxton_berserk" // berserk kill name, only seen in console
		"slamgoomba"		"mantreads" // saxton slam goomba override
		"slamkillicon"		"firedeath" // saxton slam kill
		"lungegoomba"		"mantreads" // saxton lunge goomba override
		"lungekillicon"		"apocofists" // saxton lunge kill
		"berserkkillicon"	"vehicle" // saxton berserk kill
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
*/

#pragma semicolon 1
#pragma newdecls required

#define NOPE_AVI	"vo/engineer_no01.mp3"
#define MAX_CONDITIONS	10 // TF2 conditions (bleed, dazed, etc.)

static bool PluginActiveThisRound = false;

/**
 * Shared
 */
#define SAXTON_KEY_RELOAD 0
#define SAXTON_KEY_SPECIAL 1
#define SAXTON_KEY_ALT_FIRE 2
#define MAX_RAGE_SOUNDS 3

/**
 * Saxton Lunge
 */
#define SL_STRING "saxton_lunge"
#define SL_ANIM_COND view_as<TFCond>(TFCond_HalloweenKartDash)
#define SL_VERIFICATION_INTERVAL 0.05
#define SL_SOLIDIFY_INTERVAL 0.05
static bool SL_ActiveThisRound;
static bool SL_CanUse[MAXPLAYERS+1];
static bool SL_IsUsing[MAXPLAYERS+1]; // internal
static bool SL_KeyDown[MAXPLAYERS+1]; // internal
static float SL_InitialYaw[MAXPLAYERS+1]; // internal
static float SL_InitialPitch[MAXPLAYERS+1]; // internal, needed only for speed verification and proper push renewal
static float SL_OnCooldownUntil[MAXPLAYERS+1]; // internal
static float SL_NextPushAt[MAXPLAYERS+1]; // internal
static float SL_GraceEndsAt[MAXPLAYERS+1]; // internal
static float SL_ForceRageEndAt[MAXPLAYERS+1]; // internal
static bool SL_AlreadyHit[MAXPLAYERS+1]; // internal, victim use
static float SL_TrySolidifyAt; // internal
static int SL_TrySolidifyBossClientIdx; // static internal
static int SL_DesiredKey[MAXPLAYERS+1]; // based on arg1
static float SL_Cooldown[MAXPLAYERS+1]; // arg2
static float SL_RageCost[MAXPLAYERS+1]; // arg3
static float SL_Velocity[MAXPLAYERS+1]; // arg4
static float SL_Damage[MAXPLAYERS+1]; // arg5
static bool SL_DestroyBuildings[MAXPLAYERS+1]; // arg6
static float SL_BaseKnockback[MAXPLAYERS+1]; // arg7
static float SL_CollisionDistance[MAXPLAYERS+1]; // arg8
static float SL_CollisionHeight[MAXPLAYERS+1]; // arg9
static float SL_CollisionRadius[MAXPLAYERS+1]; // arg10
// arg11 only used at rage time
static char SL_HitSound[80]; // arg12, shared
static char SL_HitEffect[48]; // arg13
static char SL_CooldownError[256]; // arg16
static char SL_NotEnoughRageError[256]; // arg17
static char SL_InWaterError[256]; // arg18
static char SL_WeighdownError[256]; // arg19
 
/**
 * Saxton Slam
 */
#define SS_STRING "saxton_slam"
#define SS_JUMP_FORCE 800.0
//hammer_impact_button was rejected by Chdata for the below
#define SS_EFFECT_GROUNDPOUND1 "hammer_impact_button_dust2"
#define SS_EFFECT_GROUNDPOUND2 "hammer_impact_button_ring"
static bool SS_ActiveThisRound;
static bool SS_CanUse[MAXPLAYERS+1];
static bool SS_IsUsing[MAXPLAYERS+1]; // internal
static bool SS_KeyDown[MAXPLAYERS+1]; // internal
static float SS_PreparingUntil[MAXPLAYERS+1]; // internal
static float SS_TauntingUntil[MAXPLAYERS+1]; // internal
static float SS_OnCooldownUntil[MAXPLAYERS+1]; // internal
static float SS_NoSlamUntil[MAXPLAYERS+1]; // internal, workaround for a bug where slam sometimes happens in midair
static bool SS_WasFirstPerson[MAXPLAYERS+1]; // internal
static int SS_DesiredKey[MAXPLAYERS+1]; // based on arg1
static float SS_Cooldown[MAXPLAYERS+1]; // arg2
static float SS_RageCost[MAXPLAYERS+1]; // arg3
static float SS_PropDelay[MAXPLAYERS+1]; // arg5
static char SS_PropModel[128]; // arg6
static float SS_GravityDelay[MAXPLAYERS+1]; // arg7
static float SS_GravitySetting[MAXPLAYERS+1]; // arg8
static float SS_MaxDamage[MAXPLAYERS+1]; // arg9
static float SS_Radius[MAXPLAYERS+1]; // arg10
static float SS_DamageDecayExponent[MAXPLAYERS+1]; // arg11
static float SS_BuildingDamageFactor[MAXPLAYERS+1]; // arg12
static float SS_Knockback[MAXPLAYERS+1]; // arg13
static float SS_PitchConstraint[MAXPLAYERS+1][2]; // arg14
// arg14 and arg15 only used at rage time
static char SS_CooldownError[256]; // arg16
static char SS_NotEnoughRageError[256]; // arg17
static char SS_NotMidairError[256]; // arg18
static char SS_WeighdownError[256]; // arg19
static int SS_SaxtonEntRef[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE, ...};

/**
 * Saxton Berserker
 */
#define SB_STRING "rage_saxton_berserk"
#define SB_FLAG_AUTO_FIRE 0x0001
#define SB_FLAG_FLAMING_FISTS 0x0002
#define SB_FLAG_MEGAHEAL 0x0004
#define SB_FLAG_IGNITE_SOLDIER 0x0008
#define SB_FLAG_WEAK_KNOCKBACK_IMMUNE 0x0010
static bool SB_ActiveThisRound;
static bool SB_CanUse[MAXPLAYERS+1];
static float SB_UsingUntil[MAXPLAYERS+1];
static float SB_FireExpiresAt[MAXPLAYERS+1]; // internal, victim use only
static bool SB_GiveRageRefund[MAXPLAYERS+1]; // internal, for extreme edge case
static int SB_FlameEntRefs[MAXPLAYERS+1][2]; // internal
static bool SB_IsFists[MAXPLAYERS+1]; // internal
static float SB_LastAttackAvailable[MAXPLAYERS+1]; // internal
static bool SB_IsAttack2[MAXPLAYERS+1]; // internal
static TFClassType SB_OriginalClass[MAXPLAYERS+1]; // internal
static float SB_Duration[MAXPLAYERS+1]; // arg1
// arg2-arg10 not stored
static float SB_Speed[MAXPLAYERS+1]; // arg11
// arg12 not stored
static TFClassType SB_TempClass[MAXPLAYERS+1]; // arg13
static int SB_Flags[MAXPLAYERS+1]; // arg19

/**
 * Saxton HUDs
 */
#define SH_STRING "saxton_huds" // a unified HUD, to prevent flicker
#define SH_MAX_HUD_FORMAT_LENGTH 30 // keep it short since it may be individualized in a multi-boss scenario and I don't want to waste too much data space
static bool SH_ActiveThisRound;
static bool SH_CanUse[MAXPLAYERS+1];
static float SH_NextHUDAt[MAXPLAYERS+1]; // internal
static int SH_LastHPValue[MAXPLAYERS+1]; // internal, for bullshit workaround
static Handle SH_NormalHUDHandle;
static Handle SH_AlertHUDHandle;
static float SH_HudY[MAXPLAYERS+1]; // arg1
static char SH_HudFormat[MAXPLAYERS+1][SH_MAX_HUD_FORMAT_LENGTH]; // arg2
static bool SH_DisplayHealth[MAXPLAYERS+1]; // arg3
static bool SH_DisplayRage[MAXPLAYERS+1]; // arg4
static char SH_LungeReadyStr[256]; // arg5, shared
static char SH_LungeNotReadyStr[256]; // arg6, shared
static char SH_SlamReadyStr[256]; // arg7, shared
static char SH_SlamNotReadyStr[256]; // arg8, shared
static char SH_BerserkReadyStr[256]; // arg9, shared
static char SH_BerserkNotReadyStr[256]; // arg10, shared
static int SH_NormalColor[MAXPLAYERS+1]; // arg11
static int SH_AlertColor[MAXPLAYERS+1]; // arg12
static bool SH_AlertIfNotReady[MAXPLAYERS+1]; // arg13
static char SH_HealthStr[256]; // arg14, shared
static char SH_RageStr[256]; // arg15, shared
static bool SH_AlertOnLowHP[MAXPLAYERS+1]; // arg16

/**
 * Saxton Advanced Options
 */
#define SAO_STRING "saxton_advanced_options"
static bool SAO_CanUse[MAXPLAYERS+1];
static TFCond SAO_LungeConditions[MAXPLAYERS+1][MAX_CONDITIONS]; // arg1
static TFCond SAO_SlamConditions[MAXPLAYERS+1][MAX_CONDITIONS]; // arg2
static TFCond SAO_BerserkConditions[MAXPLAYERS+1][MAX_CONDITIONS]; // arg3
// args 12-19 aren't initialized

void Saxton_PluginStart()
{
	SH_NormalHUDHandle = CreateHudSynchronizer(); // All you need to use ShowSyncHudText is to initialize this handle once in OnPluginStart()
	SH_AlertHUDHandle = CreateHudSynchronizer();  // Then use a unique handle for what hudtext you want sync'd to not overlap itself.
}

void Saxton_MapStart()
{
	PrecacheSound(NOPE_AVI);
}

void Saxton_BossRemoved(int clientIdx)
{
	SL_CanUse[clientIdx] = false;
	SS_CanUse[clientIdx] = false;
	SB_CanUse[clientIdx] = false;
	SH_CanUse[clientIdx] = false;
	SAO_CanUse[clientIdx] = false;
	SB_FireExpiresAt[clientIdx] = FAR_FUTURE;
			
	if(IsValidEntity(SS_SaxtonEntRef[clientIdx]))
	{
		RemoveEntity(EntRefToEntIndex(SS_SaxtonEntRef[clientIdx]));
		SS_SaxtonEntRef[clientIdx] = INVALID_ENT_REFERENCE;
	}

	// remove prethink. also fix gravity, because it leaks.
	if (SS_ActiveThisRound || SB_ActiveThisRound || SL_ActiveThisRound || SH_ActiveThisRound)
	{
		// wait for all bosses to be removed
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsClientInGame(target))
			{
				if(SL_CanUse[target] || SS_CanUse[clientIdx] || SB_CanUse[clientIdx] || SH_CanUse[clientIdx])
					return;
			}
		}
		
		// putting these first, in case anything here causes an error...it'll minimize the damage, but not eliminate.
		SS_ActiveThisRound = false;
		SB_ActiveThisRound = false;
		SL_ActiveThisRound = false;
		SH_ActiveThisRound = false;

		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsClientInGame(target))
			{
				// the below will leak across multiple rounds. at least on old versions of FF2.
				FF2R_SetClientHud(clientIdx, true);

				if (IsLivingPlayer(target))
				{
					// one of the rages immobilizes the hale briefly. don't let them remain stuck
					SetEntityMoveType(target, MOVETYPE_WALK);
					
					// gravity changes leak across multiple rounds
					SetEntityGravity(target, 1.0);
					
					if (SL_ActiveThisRound)
					{
						SetEntProp(target, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
					}
				}
			}
		}

		PluginActiveThisRound = false;
	}
}

void Saxton_BossCreated(int clientIdx, BossData boss, bool setup)
{
	if(setup)
		return;
	
	Saxton_BossRemoved(clientIdx);

	AbilityData cfg = boss.GetAbility(SL_STRING);
	if (cfg)
	{
		PluginActiveThisRound = true;
		SL_ActiveThisRound = true;
		SL_CanUse[clientIdx] = true;
		SL_IsUsing[clientIdx] = false;
		SL_OnCooldownUntil[clientIdx] = 0.0;
		SL_TrySolidifyAt = FAR_FUTURE;

		SL_DesiredKey[clientIdx] = Saxton_GetKey(cfg, "key");
		SL_Cooldown[clientIdx] = cfg.GetFloat("cooldown");
		SL_RageCost[clientIdx] = cfg.GetFloat("ragecost");
		SL_Velocity[clientIdx] = cfg.GetFloat("velocity");
		SL_Damage[clientIdx] = cfg.GetFloat("damage");
		SL_DestroyBuildings[clientIdx] = cfg.GetBool("buildings");
		SL_BaseKnockback[clientIdx] = cfg.GetFloat("knockback");
		SL_CollisionDistance[clientIdx] = cfg.GetFloat("collisiondist");
		SL_CollisionHeight[clientIdx] = cfg.GetFloat("collisionheight");
		SL_CollisionRadius[clientIdx] = cfg.GetFloat("collisionradius");
		ReadSound(cfg, "hitsound", SL_HitSound);
		cfg.GetString("hiteffect", SL_HitEffect, 48);
		bool pcSuccess = ReadFloatRange(cfg, "pitch", SS_PitchConstraint[clientIdx]);
		ReadCenterText(cfg, "cooldownerror", SL_CooldownError);
		ReadCenterText(cfg, "norageerror", SL_NotEnoughRageError);
		ReadCenterText(cfg, "inwatererror", SL_InWaterError);
		ReadCenterText(cfg, "weightdownerror", SL_WeighdownError);

		// initialize key state
		SL_KeyDown[clientIdx] = (GetClientButtons(clientIdx) & SL_DesiredKey[clientIdx]) != 0;
		
		// fix pitch constraint
		if (!pcSuccess)
		{
			SS_PitchConstraint[clientIdx][0] = -90.0;
			SS_PitchConstraint[clientIdx][1] = 90.0;
		}
	}

	cfg = boss.GetAbility(SS_STRING);
	if (cfg)
	{
		PluginActiveThisRound = true;
		SS_ActiveThisRound = true;
		SS_CanUse[clientIdx] = true;
		SS_IsUsing[clientIdx] = false;
		SS_OnCooldownUntil[clientIdx] = 0.0;
		SS_PreparingUntil[clientIdx] = FAR_FUTURE;
		SS_TauntingUntil[clientIdx] = FAR_FUTURE;

		SS_DesiredKey[clientIdx] = Saxton_GetKey(cfg, "key");
		SS_Cooldown[clientIdx] = cfg.GetFloat("cooldown");
		SS_RageCost[clientIdx] = cfg.GetFloat("ragecost");
		SS_PropDelay[clientIdx] = cfg.GetFloat("propdelay");
		ReadModel(cfg, "propmodel", SS_PropModel);
		SS_GravityDelay[clientIdx] = cfg.GetFloat("gravitydelay");
		SS_GravitySetting[clientIdx] = cfg.GetFloat("gravitysetting");
		SS_MaxDamage[clientIdx] = cfg.GetFloat("maxdamage");
		SS_Radius[clientIdx] = cfg.GetFloat("radius");
		SS_DamageDecayExponent[clientIdx] = cfg.GetFloat("damagedecay");
		SS_BuildingDamageFactor[clientIdx] = cfg.GetFloat("buildingdamage");
		SS_Knockback[clientIdx] = cfg.GetFloat("knockback");
		ReadCenterText(cfg, "cooldownerror", SS_CooldownError);
		ReadCenterText(cfg, "norageerror", SS_NotEnoughRageError);
		ReadCenterText(cfg, "notmidairerror", SS_NotMidairError);
		ReadCenterText(cfg, "weightdownerror", SS_WeighdownError);

		// initialize key state
		SS_KeyDown[clientIdx] = (GetClientButtons(clientIdx) & SS_DesiredKey[clientIdx]) != 0;
		
		// create animating prop
		if (!IsEmptyString(SS_PropModel))
			SS_SaxtonEntRef[clientIdx] = CreateSaxtonProp();
	}

	cfg = boss.GetAbility(SB_STRING);
	if (cfg)
	{
		PluginActiveThisRound = true;
		SB_ActiveThisRound = true;
		SB_CanUse[clientIdx] = true;
		SB_UsingUntil[clientIdx] = FAR_FUTURE;
		SB_FlameEntRefs[clientIdx][0] = INVALID_ENT_REFERENCE;
		SB_FlameEntRefs[clientIdx][1] = INVALID_ENT_REFERENCE;
		SB_GiveRageRefund[clientIdx] = false;
		SB_IsAttack2[clientIdx] = false;
		SB_LastAttackAvailable[clientIdx] = GetGameTime();
		
		// not much to load here...
		SB_Duration[clientIdx] = cfg.GetFloat("duration");
		SB_Speed[clientIdx] = cfg.GetFloat("speed");
		SB_TempClass[clientIdx] = view_as<TFClassType>(cfg.GetInt("tempclass"));

		SB_Flags[clientIdx] = ReadHexOrDecString(cfg, "flags");
		SB_SwapWeapon(clientIdx, false);
	}

	cfg = boss.GetAbility(SH_STRING);
	if (cfg)
	{
		PluginActiveThisRound = true;
		SH_ActiveThisRound = true;
		SH_CanUse[clientIdx] = true;
		SH_NextHUDAt[clientIdx] = GetEngineTime();
		FF2R_SetClientHud(clientIdx, false);
		
		SH_HudY[clientIdx] = cfg.GetFloat("hudy");
		cfg.GetString("hudformat", SH_HudFormat[clientIdx], SH_MAX_HUD_FORMAT_LENGTH);
		ReplaceString(SH_HudFormat[clientIdx], SH_MAX_HUD_FORMAT_LENGTH, "\\n", "\n");
		SH_DisplayHealth[clientIdx] = cfg.GetBool("displayhealth");
		SH_DisplayRage[clientIdx] = cfg.GetBool("displayrage");
		ReadCenterText(cfg, "lungeready", SH_LungeReadyStr);
		ReadCenterText(cfg, "lungenotready", SH_LungeNotReadyStr);
		ReadCenterText(cfg, "slamready", SH_SlamReadyStr);
		ReadCenterText(cfg, "slamnotready", SH_SlamNotReadyStr);
		ReadCenterText(cfg, "berserkready", SH_BerserkReadyStr);
		ReadCenterText(cfg, "berserknotready", SH_BerserkNotReadyStr);
		SH_NormalColor[clientIdx] = ReadHexOrDecString(cfg, "normalcolor");
		SH_AlertColor[clientIdx] = ReadHexOrDecString(cfg, "alertcolor");
		SH_AlertIfNotReady[clientIdx] = cfg.GetBool("alertnotready");
		ReadCenterText(cfg, "healthstr", SH_HealthStr);
		ReadCenterText(cfg, "ragestr", SH_RageStr);
		SH_AlertOnLowHP[clientIdx] = cfg.GetBool("alertlowhealth");
	}
	
	cfg = boss.GetAbility(SAO_STRING);
	if (cfg)
	{
		SAO_CanUse[clientIdx] = true;
		ReadConditions(cfg, "lunge", SAO_LungeConditions[clientIdx]);
		ReadConditions(cfg, "slam", SAO_SlamConditions[clientIdx]);
		ReadConditions(cfg, "berserk", SAO_BerserkConditions[clientIdx]);
	}
}

void Saxton_BossEquipped(int clientIdx, bool weapons)
{
	if (weapons && SB_CanUse[clientIdx])
		SB_SwapWeapon(clientIdx, false);
	
	if (SH_CanUse[clientIdx])
		FF2R_SetClientHud(clientIdx, false);
}

void Saxton_Ability(int clientIdx, const char[] ability_name)
{
	if (!strcmp(ability_name, SB_STRING))
	{
		Rage_SaxtonBerserk(clientIdx);
	}
}

void Saxton_PreThink(int clientIdx)
{
	if (!IsLivingPlayer(clientIdx))
		return;
		
	if (SS_CanUse[clientIdx])
		SS_PreThink(clientIdx);
	if (SB_CanUse[clientIdx])
		SB_PreThink(clientIdx);
	if (SL_CanUse[clientIdx])
		SL_PreThink(clientIdx);
	if (SH_CanUse[clientIdx])
		SH_PreThink(clientIdx);
}

/**
 * Shared
 */
static int Saxton_GetKey(ConfigData cfg, const char[] arg_name)
{
	int keyId = cfg.GetInt(arg_name);
	if (keyId == SAXTON_KEY_RELOAD)
		return IN_RELOAD;
	else if (keyId == SAXTON_KEY_SPECIAL)
		return IN_ATTACK3;
	else if (keyId == SAXTON_KEY_ALT_FIRE)
		return IN_ATTACK2;
	
	return 0;
}

static void Saxton_GetKillStringWithDefault(BossData boss, const char[] abilityName, const char[] argName, char killStr[33], int clientIdx, const char[] defaultStr)
{
	if (SAO_CanUse[clientIdx])
	{
		AbilityData cfg = boss.GetAbility(abilityName);
		if(!cfg)
			return;
		
		cfg.GetString(argName, killStr, 33);
		if (!IsEmptyString(killStr))
			return; // good enough
	}
	
	strcopy(killStr, 33, defaultStr);
}

// only hooking this for situational kill icons
// p.s. scripts/mod_textures.txt. You're welcome.
static bool Saxton_TempGoomba = false;
void Saxton_PlayerDeath(Event event)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (IsLivingPlayer(attacker))
	{
		static char killWeapon[33];
		static char killName[33];
		bool override = false;
		
		BossData boss = FF2R_GetBossData(attacker);
		if (!boss)
			return;

		if (SS_CanUse[attacker] && SS_IsUsing[attacker])
		{
			override = true;
			if (Saxton_TempGoomba)
				Saxton_GetKillStringWithDefault(boss, SAO_STRING, "slamgoomba", killWeapon, attacker, "mantreads");
			else
				Saxton_GetKillStringWithDefault(boss, SAO_STRING, "slamkillicon", killWeapon, attacker, "firedeath");
			Saxton_GetKillStringWithDefault(boss, SAO_STRING, "slamconsole", killName, attacker, "saxton slam");
		}
		
		if (SL_CanUse[attacker] && SL_IsUsing[attacker])
		{
			override = true;
			if (Saxton_TempGoomba)
				Saxton_GetKillStringWithDefault(boss, SAO_STRING, "lungegoomba", killWeapon, attacker, "mantreads");
			else
				Saxton_GetKillStringWithDefault(boss, SAO_STRING, "lungekillicon", killWeapon, attacker, "apocofists");
			Saxton_GetKillStringWithDefault(boss, SAO_STRING, "lungeconsole", killName, attacker, "saxton lunge");
		}
		
		if (SB_CanUse[attacker] && SB_UsingUntil[attacker] != FAR_FUTURE)
		{
			override = true;
			Saxton_GetKillStringWithDefault(boss, SAO_STRING, "berserkkillicon", killWeapon, attacker, "vehicle");
			Saxton_GetKillStringWithDefault(boss, SAO_STRING, "berserkconsole", killName, attacker, "saxton berserk");
		}
		
		if (override)
		{
			event.SetString("weapon", killWeapon); // train
			event.SetString("weapon_logclassname", killName);
		}
	}
}

static void Saxton_AddConditions(int clientIdx, const TFCond conditions[MAX_CONDITIONS])
{
	if (!SAO_CanUse[clientIdx])
		return;

	for (int i = 0; i < MAX_CONDITIONS; i++)
		if (conditions[i] > view_as<TFCond>(0))
			TF2_AddCondition(clientIdx, conditions[i], -1.0);
}

static void Saxton_RemoveConditions(int clientIdx, const TFCond conditions[MAX_CONDITIONS])
{
	if (!SAO_CanUse[clientIdx])
		return;

	for (int i = 0; i < MAX_CONDITIONS; i++)
		if (conditions[i] > view_as<TFCond>(0) && TF2_IsPlayerInCondition(clientIdx, conditions[i]))
			TF2_RemoveCondition(clientIdx, conditions[i]);
}

Action Saxton_Stomp(int attacker, int victim)
{
	if ((SS_ActiveThisRound && SS_CanUse[attacker] && SS_IsUsing[attacker]) || (SL_ActiveThisRound && SL_CanUse[attacker] && SL_IsUsing[attacker]))
	{
		Saxton_TempGoomba = true;
		SDKHooks_TakeDamage(victim, attacker, attacker, SS_MaxDamage[attacker], DMG_GENERIC, -1);
		Saxton_TempGoomba = false;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

/**
 * Saxton Lunge
 */
static bool SL_RageAvailable(int clientIdx, float curTime, bool reportError)
{
	BossData boss = FF2R_GetBossData(clientIdx);
	if (!boss)
		return false;
		
	if (GetBossCharge(boss, "0") < SL_RageCost[clientIdx])
	{
		if (reportError)
		{
			if (!IsEmptyString(SL_NotEnoughRageError))
				PrintCenterText(clientIdx, SL_NotEnoughRageError, SL_RageCost[clientIdx]);
			Nope(clientIdx);
		}
		return false;
	}

	if (GetEntityGravity(clientIdx) == 6.0)
	{
		if (reportError)
		{
			if (!IsEmptyString(SL_WeighdownError))
				PrintCenterText(clientIdx, SL_WeighdownError);
			Nope(clientIdx);
		}
		return false;
	}
	
	if (IsFullyInWater(clientIdx))
	{
		if (reportError)
		{
			if (!IsEmptyString(SL_InWaterError))
				PrintCenterText(clientIdx, SL_InWaterError);
			Nope(clientIdx);
		}
		return false;
	}
	
	if (SL_OnCooldownUntil[clientIdx] > curTime)
	{
		if (reportError)
		{
			if (!IsEmptyString(SL_CooldownError))
				PrintCenterText(clientIdx, SL_CooldownError);
			Nope(clientIdx);
		}
		return false;
	}
	
	// fail silently if the user is stunned or taunting
	if (TF2_IsPlayerInCondition(clientIdx, TFCond_Dazed) || TF2_IsPlayerInCondition(clientIdx, TFCond_Taunting))
		return false;
		
	// don't allow while other rages are active
	if ((SL_CanUse[clientIdx] && SL_IsUsing[clientIdx]) || (SS_CanUse[clientIdx] && SS_IsUsing[clientIdx]) || (SB_CanUse[clientIdx] && SB_UsingUntil[clientIdx] != FAR_FUTURE))
		return false;
	
	// all conditions passed
	return true;
}

static void SL_Initiate(int clientIdx, float curTime)
{
	// remove rage
	BossData boss = FF2R_GetBossData(clientIdx);
	if (!boss)
		return;
	SetBossCharge(boss, "0", GetBossCharge(boss, "0") - SL_RageCost[clientIdx]);

	// rage sound and initializations
	FF2R_EmitBossSoundToAll("sound_saxton_lunge", clientIdx);
	SL_OnCooldownUntil[clientIdx] = curTime + SL_Cooldown[clientIdx];
	SL_NextPushAt[clientIdx] = curTime + SL_VERIFICATION_INTERVAL;
	SL_GraceEndsAt[clientIdx] = curTime + 0.1; // grace for still being on the ground, without this the rage ends immediately
	SL_ForceRageEndAt[clientIdx] = curTime + 1.0; // my code would allow people to surf endlessly on some maps. need to have to have a raw time limit.
	SL_IsUsing[clientIdx] = true;
	for (int victim = 1; victim <= MaxClients; victim++)
	{
		// set a neutral collision group to allow the hell to mow through enemies
		if (IsLivingPlayer(victim))
			SetEntProp(victim, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);
		SL_AlreadyHit[victim] = false;
	}

	// add condition 81 and megaheal
	TF2_AddCondition(clientIdx, SL_ANIM_COND, -1.0);
	TF2_AddCondition(clientIdx, TFCond_MegaHeal, -1.0);
	Saxton_AddConditions(clientIdx, SAO_LungeConditions[clientIdx]);

	// get eye angles, store pitch and yaw which are needed for renewal and collision
	static float angles[3];
	GetClientEyeAngles(clientIdx, angles);
	
	// added for 1.0.0: constrain pitch
	angles[0] = fmin(SS_PitchConstraint[clientIdx][1], fmax(SS_PitchConstraint[clientIdx][0], angles[0]));
	
	SL_InitialYaw[clientIdx] = angles[1];
	SL_InitialPitch[clientIdx] = angles[0];

	// push the hale
	static float velocity[3];
	GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(velocity, SL_Velocity[clientIdx]);
	if ((GetEntityFlags(clientIdx) & FL_ONGROUND) != 0 || GetEntProp(clientIdx, Prop_Send, "m_nWaterLevel") >= 1)
		velocity[2] = fmax(velocity[2], 310.0);
	else
		velocity[2] += 50.0; // a little boost to alleviate arcing issues
	TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, velocity);

	// disable charge abilities during the rage.
	DisableChargesFor(clientIdx, 2.0);
}

static void SL_OnPlayerRunCmd(int clientIdx, int buttons, float curTime)
{
	bool keyDown = (buttons & SL_DesiredKey[clientIdx]) != 0;
	if (keyDown && !SL_KeyDown[clientIdx] && SL_RageAvailable(clientIdx, curTime, true))
	{
		SL_Initiate(clientIdx, curTime);
	}
	
	SL_KeyDown[clientIdx] = keyDown;
}

// special line of sight check since displacements can easily screw up origin to origin checks
// there'll be some bullshit misses but this is one of those rare cases attacks going through walls would be too common
static bool SL_HasLineOfSight(float bossPos[3], float victimPos[3], float zOffset)
{
	static float tmpPos[3];
	bossPos[2] += zOffset;
	victimPos[2] += zOffset;
	TR_TraceRayFilter(bossPos, victimPos, MASK_PLAYERSOLID, RayType_EndPoint, TraceWallsOnly);
	TR_GetEndPosition(tmpPos);
	bossPos[2] -= zOffset;
	victimPos[2] -= zOffset;
	tmpPos[2] -= zOffset;
	
	return tmpPos[0] == victimPos[0] && tmpPos[1] == victimPos[1] && tmpPos[2] == victimPos[2];
}

static void SL_HitSoundsAndEffects(int clientIdx, int victim, float victimPos[3])
{
	if (strlen(SL_HitSound) > 3)
	{
		PseudoAmbientSound(victim, SL_HitSound[clientIdx]);
		PseudoAmbientSound(victim, SL_HitSound[clientIdx]);
	}
	
	if (!IsEmptyString(SL_HitEffect))
	{
		victimPos[2] += 41.5;
		ParticleEffectAt(victimPos, SL_HitEffect, 1.0);
		victimPos[2] -= 41.5;
	}
}

static void SL_PreThink(int clientIdx)
{
	float curTime = GetEngineTime();
	
	if (SL_IsUsing[clientIdx])
	{
		// end rage now if player hit ground or water
		if (curTime >= SL_ForceRageEndAt[clientIdx] || (curTime >= SL_GraceEndsAt[clientIdx] && ((GetEntityFlags(clientIdx) & FL_ONGROUND) != 0) || IsFullyInWater(clientIdx)))
		{
			SL_IsUsing[clientIdx] = false;
			if (TF2_IsPlayerInCondition(clientIdx, SL_ANIM_COND))
				TF2_RemoveCondition(clientIdx, SL_ANIM_COND);
			if (TF2_IsPlayerInCondition(clientIdx, TFCond_MegaHeal))
				TF2_RemoveCondition(clientIdx, TFCond_MegaHeal);
			Saxton_RemoveConditions(clientIdx, SAO_LungeConditions[clientIdx]);
			SL_TrySolidifyAt = curTime;
			SL_TrySolidifyBossClientIdx = clientIdx;
			return;
		}

		// need to do a little work to determine the collision cylinder origin, which needs to be in front of the hale
		static float angles[3];
		angles[0] = 0.0; // ignore pitch for now
		angles[1] = SL_InitialYaw[clientIdx];
		static float bossPos[3];
		GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", bossPos);
		static float hitPos[3];
		TR_TraceRayFilter(bossPos, angles, MASK_PLAYERSOLID, RayType_Infinite, TraceWallsOnly);
		TR_GetEndPosition(hitPos);
		float distance = GetVectorDistance(bossPos, hitPos);

		// constrain the distance of origin a little so it's not on top of a wall boundary,
		// and of course so it's not greater than the set limit
		if (distance >= SL_CollisionDistance[clientIdx])
			constrainDistance(bossPos, hitPos, distance, SL_CollisionDistance[clientIdx] - 0.1);
		else
			constrainDistance(bossPos, hitPos, distance, distance - 0.1);
			
		//PrintToServer("hitPos vs bossPos: %f,%f,%f vs %f,%f,%f     colrad=%f", hitPos[0], hitPos[1], hitPos[2], bossPos[0], bossPos[1], bossPos[2], SL_CollisionRadius[clientIdx]);

		// check collision every tick
		for (int victim = 1; victim <= MaxClients; victim++)
		{
			if (SL_AlreadyHit[victim] || !IsLivingPlayer(victim) || victim == clientIdx)
				continue;

			// cylinder collision check
			static float victimPos[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
			if (!CylinderCollision(hitPos, victimPos, SL_CollisionRadius[clientIdx], hitPos[2] - 103.0, hitPos[2] + SL_CollisionHeight[clientIdx]))
				continue;

			// so it's close enough. ensure we don't hit through a wall.
			if (SL_HasLineOfSight(hitPos, victimPos, 41.5))
			{
				SL_AlreadyHit[victim] = true;
				SL_HitSoundsAndEffects(clientIdx, victim, victimPos);

				// knockback first, this one takes the hale's velocity into account
				static float haleVelocity[3];
				GetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", haleVelocity);
				haleVelocity[2] = 0.0;
				static float velocity[3];
				GetVectorAnglesTwoPoints(hitPos, victimPos, angles);
				GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(velocity, SL_BaseKnockback[clientIdx] + SL_Velocity[clientIdx]); //getLinearVelocity(haleVelocity));
				if ((GetEntityFlags(victim) & FL_ONGROUND) != 0 && velocity[2] < 300.0) // minimum Z, gives victims lift
					velocity[2] = 300.0;
				else if (velocity[2] < 50.0)
					velocity[2] = 50.0; // if someone's jumping, keep them from falling too quickly and body blocking the hale
				TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);

				// damage is simple enough
				if (SL_Damage[clientIdx] > 0.0)
					SDKHooks_TakeDamage(victim, clientIdx, clientIdx, SL_Damage[clientIdx] * 0.33, DMG_CRIT, .bypassHooks = false);
			}
		}

		// check buildings if applicable. hopefully doing this every frame isn't _too_ expensive.
		if (SL_DestroyBuildings[clientIdx]) for (int pass = 0; pass <= 2; pass++)
		{
			static char classname[48];
			if (pass == 0) classname = "obj_sentrygun";
			else if (pass == 1) classname = "obj_dispenser";
			else if (pass == 2) classname = "obj_teleporter";

			int building = MaxClients + 1;
			while ((building = FindEntityByClassname(building, classname)) != -1)
			{
				if (GetEntProp(building, Prop_Send, "m_bCarried") || GetEntProp(building, Prop_Send, "m_bPlacing"))
					continue;

				static float buildingPos[3];
				GetEntPropVector(building, Prop_Send, "m_vecOrigin", buildingPos);
				if (!CylinderCollision(hitPos, buildingPos, SL_CollisionRadius[clientIdx], hitPos[2] - 103.0, hitPos[2] + SL_CollisionHeight[clientIdx]))
					continue;

				if (SL_HasLineOfSight(hitPos, buildingPos, 41.5))
				{
					SL_HitSoundsAndEffects(clientIdx, building, buildingPos);
					SDKHooks_TakeDamage(building, clientIdx, clientIdx, 9999.0, DMG_GENERIC, -1);
				}
			}
		}

		// next validity check
		if (curTime >= SL_NextPushAt[clientIdx])
		{
			// keep refreshing x/y. this also prevents air strafing
			static float velocity[3];
			GetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", velocity);
			float currentZ = velocity[2];
			velocity[2] = 0.0;
			if (getLinearVelocity(velocity) < 100.0) // close enough to stopping
			{
				static float pushVel[3];
				angles[0] = SL_InitialPitch[clientIdx];
				angles[1] = SL_InitialYaw[clientIdx];
				GetAngleVectors(angles, pushVel, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(pushVel, SL_Velocity[clientIdx]);
				
				// reint the x/y push but maintain existing Z, lest this rage never end
				pushVel[2] = currentZ;
				TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, pushVel);
			}
			
			SL_NextPushAt[clientIdx] = curTime + SL_VERIFICATION_INTERVAL;
		}
	}
}

/**
 * Saxton Slam
 */
static float SS_CalculateDamage(int clientIdx, float distance)
{
	float damage;
	if (SS_DamageDecayExponent[clientIdx] <= 0.0)
		damage = SS_MaxDamage[clientIdx];
	else if (SS_DamageDecayExponent[clientIdx] == 1.0)
		damage = SS_MaxDamage[clientIdx] * (1.0 - (distance / SS_Radius[clientIdx]));
	else
	{
		damage = SS_MaxDamage[clientIdx] - (SS_MaxDamage[clientIdx] * (Pow(Pow(SS_Radius[clientIdx], SS_DamageDecayExponent[clientIdx]) -
			Pow(SS_Radius[clientIdx] - distance, SS_DamageDecayExponent[clientIdx]), 1.0 / SS_DamageDecayExponent[clientIdx]) / SS_Radius[clientIdx]));
	}
		
	return fmax(1.0, damage);
}

static bool SS_RageAvailable(int clientIdx, float curTime, bool reportError)
{
	BossData boss = FF2R_GetBossData(clientIdx);
	if (!boss)
		return false;
		
	if (GetBossCharge(boss, "0") < SS_RageCost[clientIdx])
	{
		if (reportError)
		{
			if (!IsEmptyString(SS_NotEnoughRageError))
				PrintCenterText(clientIdx, SS_NotEnoughRageError, SS_RageCost[clientIdx]);
			Nope(clientIdx);
		}
		return false;
	}

	if (GetEntityGravity(clientIdx) == 6.0)
	{
		if (reportError)
		{
			if (!IsEmptyString(SS_WeighdownError))
				PrintCenterText(clientIdx, SS_WeighdownError);
			Nope(clientIdx);
		}
		return false;
	}
	
	if (GetEntityFlags(clientIdx) & (FL_ONGROUND | FL_SWIM | FL_INWATER))
	{
		if (reportError)
		{
			if (!IsEmptyString(SS_NotMidairError))
				PrintCenterText(clientIdx, SS_NotMidairError);
			Nope(clientIdx);
		}
		return false;
	}
	
	if (SS_OnCooldownUntil[clientIdx] > curTime)
	{
		if (reportError)
		{
			if (!IsEmptyString(SS_CooldownError))
				PrintCenterText(clientIdx, SS_CooldownError);
			Nope(clientIdx);
		}
		return false;
	}
	
	// fail silently if the user is stunned or taunting
	if (TF2_IsPlayerInCondition(clientIdx, TFCond_Dazed) || TF2_IsPlayerInCondition(clientIdx, TFCond_Taunting))
		return false;
		
	// don't allow while other rages are active
	if ((SS_CanUse[clientIdx] && SS_IsUsing[clientIdx]) || (SL_CanUse[clientIdx] && SL_IsUsing[clientIdx]) || (SB_CanUse[clientIdx] && SB_UsingUntil[clientIdx] != FAR_FUTURE))
		return false;
	
	// all conditions passed
	return true;
}

static void SS_CreateEarthquake(int clientIdx)
{
	float amplitude = 16.0;
	float radius = SS_Radius[clientIdx];
	float duration = 5.0;
	float frequency = 255.0;

	int earthquake = CreateEntityByName("env_shake");
	if (IsValidEntity(earthquake))
	{
		static float halePos[3];
		GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", halePos);
	
		DispatchKeyValueFloat(earthquake, "amplitude", amplitude);
		DispatchKeyValueFloat(earthquake, "radius", radius * 2);
		DispatchKeyValueFloat(earthquake, "duration", duration + 2.0);
		DispatchKeyValueFloat(earthquake, "frequency", frequency);

		SetVariantString("spawnflags 4"); // no physics (physics is 8), affects people in air (4)
		AcceptEntityInput(earthquake, "AddOutput");

		// create
		DispatchSpawn(earthquake);
		TeleportEntity(earthquake, halePos, NULL_VECTOR, NULL_VECTOR);

		AcceptEntityInput(earthquake, "StartShake", 0);
		CreateTimer(duration + 0.1, Timer_RemoveEntity, EntIndexToEntRef(earthquake), TIMER_FLAG_NO_MAPCHANGE);
	}
}

static void SS_Initiate(int clientIdx, float curTime)
{
	// remove rage
	BossData boss = FF2R_GetBossData(clientIdx);
	if (!boss)
		return;
	SetBossCharge(boss, "0", GetBossCharge(boss, "0") - SS_RageCost[clientIdx]);
	
	// remove FOV effect, fixing an issue where lunge immediately followed by slam traps user in a higher FOV
	SetEntProp(clientIdx, Prop_Send, "m_iFOV", GetEntProp(clientIdx, Prop_Send, "m_iDefaultFOV"));
	SetEntPropFloat(clientIdx, Prop_Send, "m_flFOVTime", 0.0);
	
	FF2R_EmitBossSoundToAll("sound_saxton_slam", clientIdx, "0");
	SS_TauntingUntil[clientIdx] = curTime + SS_PropDelay[clientIdx];
	SS_NoSlamUntil[clientIdx] = SS_TauntingUntil[clientIdx] + 0.2;
	SS_PreparingUntil[clientIdx] = curTime + SS_GravityDelay[clientIdx];
	SS_OnCooldownUntil[clientIdx] = curTime + SS_Cooldown[clientIdx];
	SS_IsUsing[clientIdx] = true;
	TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0})); // stop velocity

	// set immobile and immovable
	SetEntityMoveType(clientIdx, MOVETYPE_NONE);
	TF2_AddCondition(clientIdx, TFCond_MegaHeal, -1.0);
	Saxton_AddConditions(clientIdx, SAO_SlamConditions[clientIdx]);

	// force third person during the rage
	SS_WasFirstPerson[clientIdx] = (GetEntProp(clientIdx, Prop_Send, "m_nForceTauntCam") == 0);
	SetVariantInt(1);
	AcceptEntityInput(clientIdx, "SetForcedTauntCam");

	// force the taunt. if the prop is good, this'll work.
	if(IsValidEntity(SS_SaxtonEntRef[clientIdx]))
	{
		SetEntityRenderMode(clientIdx, RENDER_TRANSCOLOR);
		SetEntityRenderColor(clientIdx, 255, 255, 255, 0);
		
		SetVariantString("taunt_party_trick");
		AcceptEntityInput(EntRefToEntIndex(SS_SaxtonEntRef[clientIdx]), "SetAnimation");
	}

	// disable charge abilities during the rage.
	DisableChargesFor(clientIdx, SS_GravityDelay[clientIdx] + 1.0);
}

static void SS_OnPlayerRunCmd(int clientIdx, int buttons, float curTime)
{
	bool keyDown = (buttons & SS_DesiredKey[clientIdx]) != 0;
	if (keyDown && !SS_KeyDown[clientIdx] && SS_RageAvailable(clientIdx, curTime, true))
		SS_Initiate(clientIdx, curTime);
	
	SS_KeyDown[clientIdx] = keyDown;
}

static void SS_PreThink(int clientIdx)
{
	float curTime = GetEngineTime();
	
	if (SS_IsUsing[clientIdx])
	{
		if (curTime >= SS_TauntingUntil[clientIdx])
		{
			SS_TauntingUntil[clientIdx] = FAR_FUTURE;
			SetEntityMoveType(clientIdx, MOVETYPE_WALK);
			TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, SS_JUMP_FORCE})); // simulate a high jump
		}
		
		if (SS_PreparingUntil[clientIdx] != FAR_FUTURE && SS_TauntingUntil[clientIdx] == FAR_FUTURE)
		{
			if (curTime >= SS_PreparingUntil[clientIdx])
			{
				SS_PreparingUntil[clientIdx] = FAR_FUTURE;
				TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, -100.0})); // give them a head start downward
				SetEntityGravity(clientIdx, SS_GravitySetting[clientIdx]); // set gravity now
			}
			else
			{
				// if player hits a ceiling, suspend them in midair until it's time to fall
				static float velocity[3];
				GetEntPropVector(clientIdx, Prop_Data, "m_vecVelocity", velocity);
				if (velocity[2] < 0.0)
				{
					velocity[2] = 0.0;
					TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, velocity);
				}
			}
		}
	
		if (SS_PreparingUntil[clientIdx] == FAR_FUTURE)
		{
			if (curTime >= SS_NoSlamUntil[clientIdx] && (GetEntityFlags(clientIdx) & FL_ONGROUND) != 0)
			{
				// damage nearby players, but make this unhooked damage if it's under two thirds of the user's HP
				// or if it's a spy.
				static float halePos[3];
				GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", halePos);
				
				// either use override particle or default
				static char effect1[48];
				static char effect2[48];
				bool override = false;
				if (SAO_CanUse[clientIdx])
				{
					BossData boss = FF2R_GetBossData(clientIdx);
					AbilityData ability;
					if(boss && (ability = boss.GetAbility(SAO_STRING)))
					{
						ability.GetString("effect1", effect1, 48);
						ability.GetString("effect2", effect2, 48);
						if (!IsEmptyString(effect1) || !IsEmptyString(effect2))
							override = true;
					}
				}
				
				if (!override)
				{
					effect1 = SS_EFFECT_GROUNDPOUND1;
					effect2 = SS_EFFECT_GROUNDPOUND2;
				}
	
				if (!IsEmptyString(effect1))
					ParticleEffectAt(halePos, effect1, 1.0);
				if (!IsEmptyString(effect2))
					ParticleEffectAt(halePos, effect2, 1.0);
				
				for (int victim = 1; victim <= MaxClients; victim++)
				{
					if (!IsLivingPlayer(victim) || victim == clientIdx)
						continue;
					else if (IsTreadingWater(victim) || IsFullyInWater(victim) || CheckGroundClearance(victim, 80.0, true))
						continue;
						
					static float victimPos[3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
					float distance = GetVectorDistance(halePos, victimPos);
					if (distance >= SS_Radius[clientIdx])
						continue;
					
					// knockback first
					static float angles[3];
					static float velocity[3];
					GetVectorAnglesTwoPoints(halePos, victimPos, angles);
					GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(velocity, SS_Knockback[clientIdx]);
					if ((GetEntityFlags(victim) & FL_ONGROUND) != 0 && velocity[2] < 300.0) // minimum Z, gives victims lift
						velocity[2] = 300.0;
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);
						
					// apply the damage
					if (SS_MaxDamage[clientIdx] > 0.0)
					{
						float damage = SS_CalculateDamage(clientIdx, distance);
						SDKHooks_TakeDamage(victim, clientIdx, clientIdx, damage, DMG_PREVENT_PHYSICS_FORCE, .bypassHooks = false);
					}
				}
				
				// damage nearby buildings
				if (SS_MaxDamage[clientIdx] > 0.0 && SS_BuildingDamageFactor[clientIdx] > 0.0)
				{
					int building = MaxClients + 1;
					while ((building = FindEntityByClassname(building, "obj_*")) != -1)
					{
						if (GetEntProp(building, Prop_Send, "m_bCarried") || GetEntProp(building, Prop_Send, "m_bPlacing"))
							continue;
					
						static float buildingPos[3];
						GetEntPropVector(building, Prop_Send, "m_vecOrigin", buildingPos);
						float distance = GetVectorDistance(buildingPos, halePos);
						if (distance >= SS_Radius[clientIdx])
							continue;
							
						float damage = SS_CalculateDamage(clientIdx, distance);
						SDKHooks_TakeDamage(building, clientIdx, clientIdx, damage * SS_BuildingDamageFactor[clientIdx], DMG_GENERIC, -1);
					}
				}
				
				FF2R_EmitBossSoundToAll("sound_saxton_slam", clientIdx, "1");
				SS_CreateEarthquake(clientIdx);
			}
			
			// end the rage if on ground or in water. (in water, it'll fail to do damage)
			if (curTime >= SS_NoSlamUntil[clientIdx] && ((GetEntityFlags(clientIdx) & FL_ONGROUND) != 0 || IsFullyInWater(clientIdx)))
			{
				SS_IsUsing[clientIdx] = false;
				if (TF2_IsPlayerInCondition(clientIdx, TFCond_MegaHeal))
					TF2_RemoveCondition(clientIdx, TFCond_MegaHeal);
				Saxton_RemoveConditions(clientIdx, SAO_SlamConditions[clientIdx]);
				
				SetEntityRenderMode(clientIdx, RENDER_TRANSCOLOR);
				SetEntityRenderColor(clientIdx, 255, 255, 255, 255);

				SetEntityGravity(clientIdx, 1.0);
				
				if (SS_WasFirstPerson[clientIdx])
				{
					SetVariantInt(0);
					AcceptEntityInput(clientIdx, "SetForcedTauntCam");
				}
			}
			else
			{
				// ensure gravity hasn't been changed, i.e. by default_abilities
				if (GetEntityGravity(clientIdx) != SS_GravitySetting[clientIdx])
					SetEntityGravity(clientIdx, SS_GravitySetting[clientIdx]);
			}
		}
		
		static float SS_SaxPos[3], SS_SaxAng[3];
		GetClientAbsOrigin(clientIdx, SS_SaxPos);
		GetClientEyeAngles(clientIdx, SS_SaxAng);
		
		SS_SaxAng[0] = 0.0;
		SS_SaxAng[2] = 0.0;
		if(IsValidEntity(SS_SaxtonEntRef[clientIdx]))
			TeleportEntity(EntRefToEntIndex(SS_SaxtonEntRef[clientIdx]), SS_SaxPos, SS_SaxAng, NULL_VECTOR);
	}
	else
	{
		if(IsValidEntity(SS_SaxtonEntRef[clientIdx]))
			TeleportEntity(EntRefToEntIndex(SS_SaxtonEntRef[clientIdx]), OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
	}
}

/**
 * Saxton Berserker
 */
static void SB_SwapWeapon(int clientIdx, bool isRage)
{
	BossData boss = FF2R_GetBossData(clientIdx);
	if (!boss)
		return;
		
	if (!isRage)
	{
		for (int i = 0; i < 2; i++)
		{
			if (SB_FlameEntRefs[clientIdx][i] != INVALID_ENT_REFERENCE)
			{
				Timer_RemoveEntity(INVALID_HANDLE, SB_FlameEntRefs[clientIdx][i]);
				SB_FlameEntRefs[clientIdx][i] = INVALID_ENT_REFERENCE;
			}
		}
	}

	static char weaponName[36];

	AbilityData ability = boss.GetAbility(SB_STRING);
	
	ConfigData weapon = ability.GetSection(isRage ? "rage" : "passive");
	if(weapon)
	{
		weapon.GetString("classname", weaponName, sizeof(weaponName));

		int slot = weapon.GetInt("weapon slot", -99);
		if(slot == -99)
			slot = TF2_GetClassnameSlot(weaponName);
		
		if(slot >= 0 && slot < 6)
			TF2_RemoveWeaponSlot(clientIdx, slot);

		bool equip = true;
		TF2Items_CreateFromCfg(clientIdx, weaponName, weapon, equip);
	}
		
	SB_IsFists[clientIdx] = strcmp(weaponName, "tf_weapon_fists") == 0;
	if (SB_IsFists[clientIdx] && isRage && (SB_Flags[clientIdx] & SB_FLAG_FLAMING_FISTS) != 0)
	{
		static char attachmentStr[98];
		ability.GetString("attachment", attachmentStr, sizeof(attachmentStr));
		if (!IsEmptyString(attachmentStr))
		{
			static char attachmentStrs[2][48];
			ExplodeString(attachmentStr, ";", attachmentStrs, 2, 48);
			for (int i = 0; i < 2; i++)
			{
				if (!IsEmptyString(attachmentStrs[i]))
				{
					int particle = AttachParticleToAttachment(clientIdx, "superrare_burning1", attachmentStrs[i]);
					if (IsValidEntity(particle))
						SB_FlameEntRefs[clientIdx][i] = EntIndexToEntRef(particle);
				}
			}
		}
	}
}
 
static void SB_PreThink(int clientIdx)
{
	if (SB_UsingUntil[clientIdx] != FAR_FUTURE)
	{
		if (GetEngineTime() >= SB_UsingUntil[clientIdx])
		{
			SB_UsingUntil[clientIdx] = FAR_FUTURE;
			if (TF2_GetPlayerClass(clientIdx) != SB_OriginalClass[clientIdx])
				TF2_SetPlayerClass(clientIdx, SB_OriginalClass[clientIdx], _, false);
			SB_SwapWeapon(clientIdx, false);
			if (TF2_IsPlayerInCondition(clientIdx, TFCond_MegaHeal))
				TF2_RemoveCondition(clientIdx, TFCond_MegaHeal);
			Saxton_RemoveConditions(clientIdx, SAO_BerserkConditions[clientIdx]);
			FF2R_UpdateBossAttributes(clientIdx);
		}
		else
			SetEntPropFloat(clientIdx, Prop_Send, "m_flMaxspeed", SB_Speed[clientIdx]);
	}
	
	if (SB_GiveRageRefund[clientIdx])
	{
		SB_GiveRageRefund[clientIdx] = false;
		BossData boss = FF2R_GetBossData(clientIdx);
		if (boss)
			SetBossCharge(boss, "0", 100.0);
	}
}

static Action SB_OnPlayerRunCmd(int clientIdx, int& buttons)
{
	if (SB_UsingUntil[clientIdx] == FAR_FUTURE || (SB_Flags[clientIdx] & SB_FLAG_AUTO_FIRE) == 0)
		return Plugin_Continue;
	
	int weapon = GetEntPropEnt(clientIdx, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(weapon))
		return Plugin_Continue;
		
	float nextAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
	if (!SB_IsFists[clientIdx])
	{
		if (GetGameTime() >= nextAttack)
		{
			buttons |= IN_ATTACK;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	
	if (nextAttack > SB_LastAttackAvailable[clientIdx])
		SB_IsAttack2[clientIdx] = !SB_IsAttack2[clientIdx];
	SB_LastAttackAvailable[clientIdx] = nextAttack;
	
	// minimize the pressing of buttons to when they're needed. this minimizes accidental super jumps, etc.
	if (GetGameTime() >= nextAttack)
	{
		buttons |= (SB_IsAttack2[clientIdx] ? IN_ATTACK2 : IN_ATTACK);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

static void Rage_SaxtonBerserk(int clientIdx)
{
	// freak instance, but entirely possible
	if ((SL_CanUse[clientIdx] && SL_IsUsing[clientIdx]) || (SS_CanUse[clientIdx] && SS_IsUsing[clientIdx]))
	{
		SB_GiveRageRefund[clientIdx] = true;
		Nope(clientIdx);
		return;
	}

	if (SB_UsingUntil[clientIdx] == FAR_FUTURE) // in case of ragespam
	{
		SB_OriginalClass[clientIdx] = TF2_GetPlayerClass(clientIdx);
		if (SB_TempClass[clientIdx] > TFClass_Unknown && SB_TempClass[clientIdx] != SB_OriginalClass[clientIdx])
			TF2_SetPlayerClass(clientIdx, SB_TempClass[clientIdx], _, false);
		SB_SwapWeapon(clientIdx, true);
		FF2R_UpdateBossAttributes(clientIdx);
	}
	SB_UsingUntil[clientIdx] = GetEngineTime() + SB_Duration[clientIdx];
	if (SB_Flags[clientIdx] & SB_FLAG_MEGAHEAL)
		TF2_AddCondition(clientIdx, TFCond_MegaHeal, -1.0);
	Saxton_AddConditions(clientIdx, SAO_BerserkConditions[clientIdx]);
	DisableChargesFor(clientIdx, SB_Duration[clientIdx]);
}

/**
 * Saxton HUDs
 */
static void SH_PreThink(int clientIdx)
{
	if (GetClientButtons(clientIdx) & IN_SCORE)
		return; // Don't show hud when player is viewing scoreboard, as it will only flash violently

	float curTime = GetEngineTime();
	
	if (curTime >= SH_NextHUDAt[clientIdx] && GameRules_GetRoundState() != RoundState_TeamWin)
	{
		SH_NextHUDAt[clientIdx] = curTime + 0.1;
		BossData boss = FF2R_GetBossData(clientIdx);
		if (!boss)
			return;
		
		// format health str
		static char healthStr[80];
		healthStr = "";
#if defined VSP_VERSION
		int hp = FF2_GetBossMax(bossIdx);
#else
		int hp = GetEntProp(clientIdx, Prop_Send, "m_iHealth"); // see my rant about this at the bottom of this file.
#endif
		if (abs(hp - SH_LastHPValue[clientIdx]) <= 5) // this way it'll be wrong, but relatively stable in appearance
			hp = SH_LastHPValue[clientIdx];
		else
			SH_LastHPValue[clientIdx] = hp;
		int maxHP = boss.GetInt("maxhealth");
		if (SH_DisplayHealth[clientIdx])
			Format(healthStr, sizeof(healthStr), SH_HealthStr, hp, maxHP);
		bool healthIsAlert = (SH_AlertOnLowHP[clientIdx] ? (hp * 3 <= maxHP) : false);

		// format rage str
		static char rageStr[80];
		rageStr = "";
		if (SH_DisplayRage[clientIdx])
			FormatEx(rageStr, sizeof(rageStr), SH_RageStr, GetBossCharge(boss, "0"));
			
		// format ability strs
		static char lungeStr[256];
		bool lungeAvailable = (SL_CanUse[clientIdx] && SL_RageAvailable(clientIdx, curTime, false));
		if (!SL_CanUse[clientIdx])
			lungeStr = "";
		else
			FormatEx(lungeStr, sizeof(lungeStr), (lungeAvailable ? SH_LungeReadyStr : SH_LungeNotReadyStr), SL_RageCost[clientIdx]);
		bool lungeIsAlert = (lungeAvailable && !SH_AlertIfNotReady[clientIdx]) || (!lungeAvailable && SH_AlertIfNotReady[clientIdx]);

		static char slamStr[256];
		bool slamAvailable = (SS_CanUse[clientIdx] && SS_RageAvailable(clientIdx, curTime, false));
		if (!SS_CanUse[clientIdx])
			slamStr = "";
		else
			FormatEx(slamStr, sizeof(slamStr), (slamAvailable ? SH_SlamReadyStr : SH_SlamNotReadyStr), SS_RageCost[clientIdx]);
		bool slamIsAlert = (slamAvailable && !SH_AlertIfNotReady[clientIdx]) || (!slamAvailable && SH_AlertIfNotReady[clientIdx]);

		static char berserkStr[256];
		bool berserkAvailable = GetBossCharge(boss, "0") >= 100.0;
		if (!SB_CanUse[clientIdx])
			berserkStr = "";
		else
			FormatEx(berserkStr, sizeof(berserkStr), (berserkAvailable ? SH_BerserkReadyStr : SH_BerserkNotReadyStr), 100.0); // redundant percent in case someone slips up
		bool berserkIsAlert = (berserkAvailable && !SH_AlertIfNotReady[clientIdx]) || (!berserkAvailable && SH_AlertIfNotReady[clientIdx]);

		// normal HUD
		SetHudTextParams(-1.0, SH_HudY[clientIdx], 0.15, GetR(SH_NormalColor[clientIdx]), GetG(SH_NormalColor[clientIdx]), GetB(SH_NormalColor[clientIdx]), 192);
		ShowSyncHudText(clientIdx, SH_NormalHUDHandle, SH_HudFormat[clientIdx], (!healthIsAlert ? healthStr : ""), rageStr, (!lungeIsAlert ? lungeStr : ""), (!slamIsAlert ? slamStr : ""), (!berserkIsAlert ? berserkStr : ""));
		
		// alert HUD
		SetHudTextParams(-1.0, SH_HudY[clientIdx], 0.15, GetR(SH_NormalColor[clientIdx]), GetG(SH_AlertColor[clientIdx]), GetB(SH_AlertColor[clientIdx]), 192);
		ShowSyncHudText(clientIdx, SH_AlertHUDHandle, SH_HudFormat[clientIdx], (healthIsAlert ? healthStr : ""), "", (lungeIsAlert ? lungeStr : ""), (slamIsAlert ? slamStr : ""), (berserkIsAlert ? berserkStr : ""));
	}
}

/**
 * OnPlayerRunCmd/OnGameFrame
 */
void Saxton_GameFrame()
{
	if (!PluginActiveThisRound)
		return;
	
	float curTime = GetEngineTime();
	
	// this is best done on the game frame since it'll be either before or after movement checks are made
	// reducing the likelihood of this failing
	if (SL_ActiveThisRound)
	{
		if (curTime >= SL_TrySolidifyAt)
		{
			static float bossPos[3];
			GetEntPropVector(SL_TrySolidifyBossClientIdx, Prop_Send, "m_vecOrigin", bossPos);
			static float mins[3];
			static float maxs[3];
			mins[0] = bossPos[0] - 50.0;
			mins[1] = bossPos[1] - 50.0;
			mins[2] = bossPos[2] - 85.0;
			maxs[0] = bossPos[0] + 50.0;
			maxs[1] = bossPos[1] + 50.0;
			maxs[2] = bossPos[2] + 85.0;
		
			bool fail = false;
			for (int victim = 1; victim <= MaxClients; victim++)
			{
				if (!IsLivingPlayer(victim) || FF2R_GetBossData(victim))
					continue;
					
				static float victimPos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
				if (victimPos[0] >= mins[0] && victimPos[0] <= maxs[0] &&
					victimPos[1] >= mins[1] && victimPos[1] <= maxs[1] &&
					victimPos[2] >= mins[2] && victimPos[2] <= maxs[2])
				{
					fail = true;
					break;
				}
			}
			
			if (fail)
				SL_TrySolidifyAt = curTime + SL_SOLIDIFY_INTERVAL;
			else
			{
				SL_TrySolidifyAt = FAR_FUTURE;
				for (int victim = 1; victim <= MaxClients; victim++)
					if (IsLivingPlayer(victim))
						SetEntProp(victim, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PLAYER);
			}
		}
	}
	
	// also need the game frame for removing excess fire
	if (SB_ActiveThisRound)
	{
		for (int victim = 1; victim <= MaxClients; victim++)
		{
			if (IsLivingPlayer(victim) && curTime >= SB_FireExpiresAt[victim])
			{
				SB_FireExpiresAt[victim] = FAR_FUTURE;
				if (TF2_IsPlayerInCondition(victim, TFCond_OnFire))
					TF2_RemoveCondition(victim, TFCond_OnFire);
			}
		}
	}
}
 
Action Saxton_PlayerRunCmd(int clientIdx, int& buttons)
{
	if (!PluginActiveThisRound)
		return Plugin_Continue;
	else if (!IsLivingPlayer(clientIdx))
		return Plugin_Continue;
		
	Action ret = Plugin_Continue;
		
	if (SS_ActiveThisRound && SS_CanUse[clientIdx])
		SS_OnPlayerRunCmd(clientIdx, buttons, GetEngineTime());
	if (SL_ActiveThisRound && SL_CanUse[clientIdx])
		SL_OnPlayerRunCmd(clientIdx, buttons, GetEngineTime());
	if (SB_ActiveThisRound && SB_CanUse[clientIdx])
		ret = SB_OnPlayerRunCmd(clientIdx, buttons);
	
	return ret;
}

/**
 * General helper statics, some original, some taken/modified from other sources
 */
static int ParticleEffectAt(float position[3], char[] effectName, float duration = 0.1)
{
	if (strlen(effectName) < 3)
		return -1; // nothing to display
		
	int particle = CreateEntityByName("info_particle_system");
	if (particle != -1)
	{
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "effect_name", effectName);
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		if (duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return particle;
}

// adapted from the above and Friagram's halloween 2013 (which standing alone did not work for me)
static int AttachParticleToAttachment(int entity, const char[] particleType, const char[] attachmentPoint) // m_vecAbsOrigin. you're welcome.
{
	int particle = CreateEntityByName("info_particle_system");
	
	if (!IsValidEntity(particle))
		return -1;

	static char targetName[128];
	static float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);

	FormatEx(targetName, sizeof(targetName), "target%i", entity);
	DispatchKeyValue(entity, "targetname", targetName);

	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", targetName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(targetName);
	AcceptEntityInput(particle, "SetParent", particle, particle, 0);
	SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", entity);
	
	SetVariantString(attachmentPoint);
	AcceptEntityInput(particle, "SetParentAttachment");

	if (!IsEmptyString(particleType))
	{
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
	}
	return particle;
}

static Action Timer_RemoveEntity(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if (IsValidEntity(entity))
		RemoveEntity(entity);
	
	return Plugin_Continue;
}

static bool IsLivingPlayer(int clientIdx)
{
	if (clientIdx <= 0 || clientIdx > MaxClients)
		return false;
		
	return IsClientInGame(clientIdx) && IsPlayerAlive(clientIdx);
}

static void ParseFloatRange(char[] rangeStr, float& min, float& max)
{
	char rangeStrs[2][32];
	ExplodeString(rangeStr, ";", rangeStrs, 2, 32);
	min = StringToFloat(rangeStrs[0]);
	max = StringToFloat(rangeStrs[1]);
}

static bool ReadFloatRange(ConfigData cfg, const char[] arg_name, float range[2])
{
	static char rangeStr[66];
	cfg.GetString(arg_name, rangeStr, 66);
	ParseFloatRange(rangeStr, range[0], range[1]); // do this even if the length is invalid, for static backwards comatibility
	return (strlen(rangeStr) >= 3); // minimum length for valid range is 3
}

static void ReadSound(ConfigData cfg, const char[] arg_name, char soundFile[80])
{
	cfg.GetString(arg_name, soundFile, 80);
	if (strlen(soundFile) > 3)
		PrecacheSound(soundFile);
}

static void ReadModel(ConfigData cfg, const char[] arg_name, char modelFile[128])
{
	cfg.GetString(arg_name, modelFile, 128);
	if (strlen(modelFile) > 3)
		PrecacheModel(modelFile);
}

static void ReadCenterText(ConfigData cfg, const char[] arg_name, char centerText[256])
{
	cfg.GetString(arg_name, centerText, 256);
	ReplaceString(centerText, 256, "\\n", "\n");
}

static void ReadConditions(ConfigData cfg, const char[] arg_name, TFCond conditions[MAX_CONDITIONS])
{
	static char conditionStr[MAX_CONDITIONS * 4];
	static char conditionStrs[MAX_CONDITIONS][4];
	cfg.GetString(arg_name, conditionStr, sizeof(conditionStr));
	int count = ExplodeString(conditionStr, ";", conditionStrs, MAX_CONDITIONS, 4);
	for (int i = 0; i < MAX_CONDITIONS; i++)
	{
		if (i >= count)
			conditions[i] = view_as<TFCond>(0);
		else
			conditions[i] = view_as<TFCond>(StringToInt(conditionStrs[i]));
	}
}

static bool TraceWallsOnly(int entity, int contentsMask)
{
	return false;
}

// really wish that the original GetVectorAngles() worked this way.
static void GetVectorAnglesTwoPoints(const float startPos[3], const float endPos[3], float angles[3])
{
	static float tmpVec[3];
	tmpVec[0] = endPos[0] - startPos[0];
	tmpVec[1] = endPos[1] - startPos[1];
	tmpVec[2] = endPos[2] - startPos[2];
	GetVectorAngles(tmpVec, angles);
}

// this version ignores obstacles
static stock void PseudoAmbientSound(int clientIdx, char[] soundPath, int count=1, float radius=1000.0, bool skipSelf=false, bool skipDead=false, float volumeFactor=1.0)
{
	static float emitterPos[3];
	static float listenerPos[3];
	if (!IsLivingPlayer(clientIdx)) // updated 2015-01-16 to allow non-players...finally.
		GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", emitterPos);
	else
		GetClientEyePosition(clientIdx, emitterPos);
	for (int listener = 1; listener <= MaxClients; listener++)
	{
		if (!IsClientInGame(listener))
			continue;
		else if (skipSelf && listener == clientIdx)
			continue;
		else if (skipDead && !IsLivingPlayer(listener))
			continue;
			
		GetClientEyePosition(listener, listenerPos);
		float distance = GetVectorDistance(emitterPos, listenerPos);
		if (distance >= radius)
			continue;
		
		float volume = (radius - distance) / radius;
		if (volume <= 0.0)
			continue;
		else if (volume > 1.0)
			volume = 1.0;
		
		for (int i = 0; i < count; i++)
			EmitSoundToClient(listener, soundPath, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, volume);
	}
}

static int abs(int x)
{
	return x < 0 ? -x : x;
}

static float fmin(float n1, float n2)
{
	return n1 < n2 ? n1 : n2;
}

static float fmax(float n1, float n2)
{
	return n1 > n2 ? n1 : n2;
}

static int ReadHexOrDecInt(char[] hexOrDecString)
{
	if (StrContains(hexOrDecString, "0x") == 0)
	{
		int result = 0;
		for (int i = 2; i < 10 && hexOrDecString[i] != 0; i++)
		{
			result = result<<4;
				
			if (hexOrDecString[i] >= '0' && hexOrDecString[i] <= '9')
				result += hexOrDecString[i] - '0';
			else if (hexOrDecString[i] >= 'a' && hexOrDecString[i] <= 'f')
				result += hexOrDecString[i] - 'a' + 10;
			else if (hexOrDecString[i] >= 'A' && hexOrDecString[i] <= 'F')
				result += hexOrDecString[i] - 'A' + 10;
		}
		
		return result;
	}
	else
		return StringToInt(hexOrDecString);
}

static int ReadHexOrDecString(ConfigData cfg, const char[] arg_name)
{
	static char hexOrDecString[12];
	cfg.GetString(arg_name, hexOrDecString, 12);
	return ReadHexOrDecInt(hexOrDecString);
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

static void constrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance)
{
	if (distance <= maxDistance)
		return; // nothing to do
		
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

static int GetR(int c) { return abs((c>>16)&0xff); }
static int GetG(int c) { return abs((c>>8 )&0xff); }
static int GetB(int c) { return abs((c    )&0xff); }

static void Nope(int clientIdx)
{
	EmitSoundToClient(clientIdx, NOPE_AVI);
}

static bool CheckGroundClearance(int clientIdx, float minClearance, bool failInWater)
{
	// standing? automatic fail.
	if (GetEntityFlags(clientIdx) & FL_ONGROUND)
		return false;
	else if (failInWater && (GetEntityFlags(clientIdx) & (FL_SWIM | FL_INWATER)))
		return false;
		
	// need to do a trace
	static float origin[3];
	GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", origin);
	
	Handle trace = TR_TraceRayFilterEx(origin, view_as<float>({90.0,0.0,0.0}), (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
	static float endPos[3];
	TR_GetEndPosition(endPos, trace);
	CloseHandle(trace);
	
	// only Z should change, so this is easy.
	return origin[2] - endPos[2] >= minClearance;
}

// need to distinguish being fully in water and not, which is a little more complicated than it should be
static bool IsFullyInWater(int clientIdx)
{
	int flags = GetEntityFlags(clientIdx);
	if ((flags & (FL_SWIM | FL_INWATER)) == 0)
		return false;

	int waterLevel = GetEntProp(clientIdx, Prop_Send, "m_nWaterLevel");
	if (waterLevel <= 1)
		return false;
		
	return true;
}

static bool IsTreadingWater(int clientIdx)
{
	return (GetEntityFlags(clientIdx) & FL_ONGROUND) == 0 && GetEntProp(clientIdx, Prop_Send, "m_nWaterLevel") == 1;
}

static int CreateSaxtonProp()
{
	int iSaxton = CreateEntityByName("prop_dynamic");
	if(IsValidEntity(iSaxton))
	{
		DispatchKeyValue(iSaxton, "model", SS_PropModel);
		
		DispatchSpawn(iSaxton);
		
		TeleportEntity(iSaxton, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR);
		
		SetVariantString("stand_MELEE");
		AcceptEntityInput(iSaxton, "SetDefaultAnimation");
		SetVariantString("stand_MELEE");
		AcceptEntityInput(iSaxton, "SetAnimation");
		
		return EntIndexToEntRef(iSaxton);
	}
	return INVALID_ENT_REFERENCE;
}

static void DisableChargesFor(int clientIdx, float extraTime)
{
	BossData boss = FF2R_GetBossData(clientIdx);
	AbilityData ability;
	if(boss && (ability = boss.GetAbility("special_mobility")))
	{
		float delayTo = GetGameTime() + extraTime;
		float currentTime;
		if(ability.GetBool("incooldown"))
		{
			currentTime = ability.GetFloat("delay");
		}
		else
		{
			ability.SetBool("incooldown", true);
		}

		if(currentTime < delayTo)
			ability.SetFloat("delay", delayTo);
	}
}
