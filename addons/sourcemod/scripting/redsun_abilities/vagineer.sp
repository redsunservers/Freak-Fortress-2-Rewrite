/*
	Vagineer from VSH Rewrite

	
	"rage_vagineer_sentry"
	{
		"slot"		"0"	// Ability slot

		"pda"
		{
			// Weapon Config
		}
		"builder"
		{
			// Weapon Config
		}
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
*/

#pragma semicolon 1
#pragma newdecls required

#define MAX_AMMO_LEVEL_1	75

void Vagineer_Ability(int client, const char[] ability, AbilityData cfg)
{
	if(!StrContains(ability, "rage_vagineer_sentry", false))
	{
		if(GetPlayerWeaponSlot(client, TFWeaponSlot_Grenade) == -1)
		{
			ConfigData weapon = cfg.GetSection("pda");
			if(weapon)
			{
				bool equip = true;
				TF2Items_CreateFromCfg(client, "tf_weapon_pda_engineer_build", weapon, equip);
			}
		}

		if(GetPlayerWeaponSlot(client, TFWeaponSlot_PDA) == -1)
		{
			ConfigData weapon = cfg.GetSection("builder");
			if(weapon)
			{
				int entity = TF2Items_CreateFromCfg(client, "tf_weapon_builder", weapon);
				if(entity != -1)
				{
					// Only allow building sentries
					SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, view_as<int>(TFObject_Dispenser));
					SetEntProp(entity, Prop_Send, "m_aBuildableObjectTypes", false, _, view_as<int>(TFObject_Teleporter));
				}
			}
		}
		
		SetEntProp(client, Prop_Send, "m_iAmmo", 130, _, 3);
		FakeClientCommandEx(client, "build 2 0");
	}
}

void Vagineer_BuiltObject(int client, int building)
{
	BossData boss = FF2R_GetBossData(client);
	if(boss == null || boss.GetAbility("rage_vagineer_sentry") == null)
		return;
	
	int health = TotalPlayersAliveEnemy(GetClientTeam(client)) * 100 + 200;
	
	SetEntProp(building, Prop_Send, "m_bCarryDeploy", true);
	SetEntData(building, FindSendPropInfo("CObjectSentrygun", "m_flPercentageConstructed") - 8, health);	// m_iHealthOnPickup
	
	SetVariantInt(health);
	AcceptEntityInput(building, "SetHealth");	// Sets sentry health
	
	SDKCall_RemoveObject(client, building);		// Make the boss not the sentry's original owner so he gets to potentially build more of them

	RequestFrame(SentryFrame, EntIndexToEntRef(building));
}

static void SentryFrame(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == INVALID_ENT_REFERENCE)
		return;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
	if(owner < 1 || owner > MaxClients || !IsPlayerAlive(owner))
	{
		SetVariantInt(999999);
		AcceptEntityInput(entity, "RemoveHealth");
		return;
	}

	RequestFrame(SentryFrame, ref);
	
	if(GetEntPropFloat(entity, Prop_Send, "m_flModelScale") != 1.22)
		SetEntityModelScale(entity, 1.22);
	
	if(GetEntProp(entity, Prop_Send, "m_bDisabled"))
		SetEntProp(entity, Prop_Send, "m_bDisabled", false);
	
	// m_iState: 0 is being carried or in the process of building, 1 is idle (can be either enabled or disabled), 2 is shooting at a target or being wrangled, 3 is in the process of upgrading
	if(GetEntProp(entity, Prop_Send, "m_iState") > 0)
	{
		static int offsetState;
		if(!offsetState)
			offsetState = FindSendPropInfo("CObjectSentrygun", "m_iState");
		
		// Set turn rate super crazy
		SetEntData(entity, offsetState + 24, 1000);	// m_iBaseTurnRate
		SetEntDataFloat(entity, offsetState + 44, GetRandomFloat(-90.0, 90.0));	// m_vecGoalAngles.x
		SetEntDataFloat(entity, offsetState + 48, GetRandomFloat(0.0, 360.0));	// m_vecGoalAngles.y
		
		static int offsetAmmo;
		if(!offsetAmmo)
			offsetAmmo = FindSendPropInfo("CObjectSentrygun", "m_iAmmoShells");
		
		int oldAmmo = GetEntData(entity, offsetAmmo + 16);	// m_iOldAmmoShells
		if(oldAmmo == 0)
		{
			// Sentry finished construction, start filling ammo
			SetEntProp(entity, Prop_Send, "m_iAmmoShells", MAX_AMMO_LEVEL_1);
			SetEntData(entity, offsetAmmo + 4, MAX_AMMO_LEVEL_1);	// m_iMaxAmmoShells
			SetEntData(entity, offsetAmmo + 16, MAX_AMMO_LEVEL_1);	// m_iOldAmmoShells
		}
		else
		{
			int ammo = GetEntProp(entity, Prop_Send, "m_iAmmoShells");
			if(ammo == 0)
			{
				// No more ammo to shoot
				SetVariantInt(999999);
				AcceptEntityInput(entity, "RemoveHealth");
			}
			else if(ammo < oldAmmo)
			{
				// Sentry just shoot ammo, update values and reduce sentry health
				SetEntData(entity, offsetAmmo + 4, ammo);	// m_iMaxAmmoShells
				SetEntData(entity, offsetAmmo + 16, ammo);	// m_iOldAmmoShells
				
				float percentage = float(oldAmmo - ammo) / MAX_AMMO_LEVEL_1;
				
				int healthloss = RoundToFloor(percentage * float(GetEntProp(entity, Prop_Send, "m_iMaxHealth")));
				SetVariantInt(healthloss);
				AcceptEntityInput(entity, "RemoveHealth");
			}
		}
	}
}