#pragma semicolon 1
#pragma newdecls required

#define IsEmptyString(%1)	(%1[0] == 0)

public const float OFF_THE_MAP[3] = { 16383.0, 16383.0, -16383.0 };

public const char BuildingName[][][] =
{
	{"Dispenser", ""},
	{"Teleporter Entrance", "Teleporter Exit"},
	{"Sentry Gun", ""},
	{"Sapper", ""}
};

public const char ClassName[][] =
{
	"Unknown",
	"Scout",
	"Sniper",
	"Soldier",
	"Demoman",
	"Medic",
	"Heavy",
	"Pyro",
	"Spy",
	"Engineer"
};

enum // Collision_Group_t in const.h
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,			// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER, // Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,	// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,  // For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,			// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,		// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,			// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,	// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,		// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,	// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,	// ** sarysa TF2 note: Must be scripted, not passable on physics prop (Doors that the player shouldn't collide with)
	COLLISION_GROUP_DISSOLVING,		// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,		// ** sarysa TF2 note: I could swear the collision detection is better for this than NONE. (Nonsolid on client and server, pushaway in player code)

	COLLISION_GROUP_NPC_ACTOR,		// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,	// USed for NPCs in scripts that should not collide with each other

	LAST_SHARED_COLLISION_GROUP
};

void SetEntityModelScale(int entity, float scale)
{
	char buffer[16];
	FloatToString(scale, buffer, sizeof(buffer));
	
	SetVariantString(buffer);
	AcceptEntityInput(entity, "SetModelScale");
}

void UpdateAction(Action &current, Action changed)
{
	if(changed > current)
		current = changed;
}

bool TF2_GetItem(int client, int &weapon, int &pos)
{
	static int maxWeapons;
	if(!maxWeapons)
		maxWeapons = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	if(pos < 0)
		pos = 0;
	
	while(pos < maxWeapons)
	{
		weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", pos);
		pos++;
		
		if(weapon != -1)
		{
			if(GetEntProp(weapon, Prop_Send, "m_bDisguiseWeapon"))
				continue;
			
			return true;
		}
	}
	return false;
}

int TF2_GetClassnameSlot(const char[] classname, bool econ = false)
{
	if(StrContains(classname, "tf_weapon_"))
	{
		return -1;
	}
	else if(!StrContains(classname, "tf_weapon_scattergun") ||
	  !StrContains(classname, "tf_weapon_handgun_scout_primary") ||
	  !StrContains(classname, "tf_weapon_soda_popper") ||
	  !StrContains(classname, "tf_weapon_pep_brawler_blaster") ||
	  !StrContains(classname, "tf_weapon_rocketlauncher") ||
	  !StrContains(classname, "tf_weapon_particle_cannon") ||
	  !StrContains(classname, "tf_weapon_flamethrower") ||
	  !StrContains(classname, "tf_weapon_grenadelauncher") ||
	  !StrContains(classname, "tf_weapon_cannon") ||
	  !StrContains(classname, "tf_weapon_minigun") ||
	  !StrContains(classname, "tf_weapon_shotgun_primary") ||
	  !StrContains(classname, "tf_weapon_sentry_revenge") ||
	  !StrContains(classname, "tf_weapon_drg_pomson") ||
	  !StrContains(classname, "tf_weapon_shotgun_building_rescue") ||
	  !StrContains(classname, "tf_weapon_syringegun_medic") ||
	  !StrContains(classname, "tf_weapon_crossbow") ||
	  !StrContains(classname, "tf_weapon_sniperrifle") ||
	  !StrContains(classname, "tf_weapon_compound_bow"))
	{
		return TFWeaponSlot_Primary;
	}
	else if(!StrContains(classname, "tf_weapon_pistol") ||
	  !StrContains(classname, "tf_weapon_lunchbox") ||
	  !StrContains(classname, "tf_weapon_jar") ||
	  !StrContains(classname, "tf_weapon_handgun_scout_secondary") ||
	  !StrContains(classname, "tf_weapon_cleaver") ||
	  !StrContains(classname, "tf_weapon_shotgun") ||
	  !StrContains(classname, "tf_weapon_buff_item") ||
	  !StrContains(classname, "tf_weapon_raygun") ||
	  !StrContains(classname, "tf_weapon_flaregun") ||
	  !StrContains(classname, "tf_weapon_rocketpack") ||
	  !StrContains(classname, "tf_weapon_pipebomblauncher") ||
	  !StrContains(classname, "tf_weapon_laser_pointer") ||
	  !StrContains(classname, "tf_weapon_mechanical_arm") ||
	  !StrContains(classname, "tf_weapon_medigun") ||
	  !StrContains(classname, "tf_weapon_smg") ||
	  !StrContains(classname, "tf_weapon_charged_smg"))
	{
		return TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_re"))	// Revolver
	{
		return econ ? TFWeaponSlot_Secondary : TFWeaponSlot_Primary;
	}
	else if(!StrContains(classname, "tf_weapon_sa"))	// Sapper
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_Secondary;
	}
	else if(!StrContains(classname, "tf_weapon_i") || !StrContains(classname, "tf_weapon_pda_engineer_d"))	// Invis & Destory PDA
	{
		return econ ? TFWeaponSlot_Item1 : TFWeaponSlot_Building;
	}
	else if(!StrContains(classname, "tf_weapon_p"))	// Disguise Kit & Build PDA
	{
		return econ ? TFWeaponSlot_PDA : TFWeaponSlot_Grenade;
	}
	else if(!StrContains(classname, "tf_weapon_bu"))	// Builder Box
	{
		return econ ? TFWeaponSlot_Building : TFWeaponSlot_PDA;
	}
	else if(!StrContains(classname, "tf_weapon_sp"))	 // Spellbook
	{
		return TFWeaponSlot_Item1;
	}
	return TFWeaponSlot_Melee;
}

TFClassType GetClassOfName(const char[] buffer)
{
	TFClassType class = view_as<TFClassType>(StringToInt(buffer));
	if(class == TFClass_Unknown)
		class = TF2_GetClass(buffer);
	
	return class;
}

void GetClassWeaponClassname(TFClassType class, char[] name, int length)
{
	if(!StrContains(name, "saxxy"))
	{ 
		switch(class)
		{
			case TFClass_Scout:			strcopy(name, length, "tf_weapon_bat");
			case TFClass_Pyro, TFClass_Heavy:	strcopy(name, length, "tf_weapon_fireaxe");
			case TFClass_DemoMan:			strcopy(name, length, "tf_weapon_bottle");
			case TFClass_Engineer:			strcopy(name, length, "tf_weapon_wrench");
			case TFClass_Medic:			strcopy(name, length, "tf_weapon_bonesaw");
			case TFClass_Sniper:			strcopy(name, length, "tf_weapon_club");
			case TFClass_Spy:			strcopy(name, length, "tf_weapon_knife");
			default:				strcopy(name, length, "tf_weapon_shovel");
		}
	}
	else if(StrEqual(name, "tf_weapon_shotgun"))
	{
		switch(class)
		{
			case TFClass_Pyro:	strcopy(name, length, "tf_weapon_shotgun_pyro");
			case TFClass_Heavy:	strcopy(name, length, "tf_weapon_shotgun_hwg");
			case TFClass_Engineer:	strcopy(name, length, "tf_weapon_shotgun_primary");
			default:		strcopy(name, length, "tf_weapon_shotgun_soldier");
		}
	}
}

int TotalPlayersAliveEnemy(int team = -1)
{
	int amount;
	for(int i = SpecTeam ? 0 : 2; i < sizeof(PlayersAlive); i++)
	{
		if(i != team)
			amount += PlayersAlive[i];
	}
	
	return amount;
}

int GetKillsOfWeaponRank(int rank = -1, int index = 0)
{
	switch(rank)
	{
		case 0:
		{
			return GetRandomInt(0, 9);
		}
		case 1:
		{
			return GetRandomInt(10, 24);
		}
		case 2:
		{
			return GetRandomInt(25, 44);
		}
		case 3:
		{
			return GetRandomInt(45, 69);
		}
		case 4:
		{
			return GetRandomInt(70, 99);
		}
		case 5:
		{
			return GetRandomInt(100, 134);
		}
		case 6:
		{
			return GetRandomInt(135, 174);
		}
		case 7:
		{
			return GetRandomInt(175, 224);
		}
		case 8:
		{
			return GetRandomInt(225, 274);
		}
		case 9:
		{
			return GetRandomInt(275, 349);
		}
		case 10:
		{
			return GetRandomInt(350, 499);
		}
		case 11:
		{
			if(index == 656)	// Holiday Punch
			{
				return GetRandomInt(500, 748);
			}
			else
			{
				return GetRandomInt(500, 749);
			}
		}
		case 12:
		{
			if(index == 656)	// Holiday Punch
			{
				return 749;
			}
			else
			{
				return GetRandomInt(750, 998);
			}
		}
		case 13:
		{
			if(index == 656)	// Holiday Punch
			{
				return GetRandomInt(750, 999);
			}
			else
			{
				return 999;
			}
		}
		case 14:
		{
			return GetRandomInt(1000, 1499);
		}
		case 15:
		{
			return GetRandomInt(1500, 2499);
		}
		case 16:
		{
			return GetRandomInt(2500, 4999);
		}
		case 17:
		{
			return GetRandomInt(5000, 7499);
		}
		case 18:
		{
			if(index == 656)	// Holiday Punch
			{
				return GetRandomInt(7500, 7922);
			}
			else
			{
				return GetRandomInt(7500, 7615);
			}
		}
		case 19:
		{
			if(index == 656)	// Holiday Punch
			{
				return GetRandomInt(7923, 8499);
			}
			else
			{
				return GetRandomInt(7616, 8499);
			}
		}
		case 20:
		{
			return GetRandomInt(8500, 9999);
		}
		default:
		{
			return GetRandomInt(0, 9999);
		}
	}
}

int GetKillsOfCosmeticRank(int rank = -1, int index = 0)
{
	switch(rank)
	{
		case 0:
		{
			if(index == 133 || index == 444 || index == 655)	// Gunboats, Mantreads, or Spirit of Giving
			{
				return 0;
			}
			else
			{
				return GetRandomInt(0, 14);
			}
		}
		case 1:
		{
			if(index == 133 || index == 444 || index == 655)	// Gunboats, Mantreads, or Spirit of Giving
			{
				return GetRandomInt(1, 2);
			}
			else
			{
				return GetRandomInt(15, 29);
			}
		}
		case 2:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(3, 4);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(3, 6);
			}
			else
			{
				return GetRandomInt(30, 49);
			}
		}
		case 3:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(5, 6);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(7, 11);
			}
			else
			{
				return GetRandomInt(50, 74);
			}
		}
		case 4:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(7, 9);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(12, 19);
			}
			else
			{
				return GetRandomInt(75, 99);
			}
		}
		case 5:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(10, 13);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(20, 27);
			}
			else
			{
				return  GetRandomInt(100, 134);
			}
		}
		case 6:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(14, 17);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(28, 36);
			}
			else
			{
				return GetRandomInt(135, 174);
			}
		}
		case 7:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(18, 22);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(37, 46);
			}
			else
			{
				return GetRandomInt(175, 249);
			}
		}
		case 8:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(23, 27);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(47, 56);
			}
			else
			{
				return GetRandomInt(250, 374);
			}
		}
		case 9:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(28, 34);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(57, 67);
			}
			else
			{
				return GetRandomInt(375, 499);
			}
		}
		case 10:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(35, 49);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(68, 78);
			}
			else
			{
				return GetRandomInt(500, 724);
			}
		}
		case 11:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(50, 74);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(79, 90);
			}
			else
			{
				return GetRandomInt(725, 999);
			}
		}
		case 12:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(75, 98);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(91, 103);
			}
			else
			{
				return GetRandomInt(1000, 1499);
			}
		}
		case 13:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return 99;
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(104, 119);
			}
			else
			{
				return GetRandomInt(1500, 1999);
			}
		}
		case 14:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(100, 149);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(120, 137);
			}
			else
			{
				return GetRandomInt(2000, 2749);
			}
		}
		case 15:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(150, 249);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(138, 157);
			}
			else
			{
				return GetRandomInt(2750, 3999);
			}
		}
		case 16:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(250, 499);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(158, 178);
			}
			else
			{
				return GetRandomInt(4000, 5499);
			}
		}
		case 17:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(500, 749);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(179, 209);
			}
			else
			{
				return GetRandomInt(5500, 7499);
			}
		}
		case 18:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(750, 783);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(210, 249);
			}
			else
			{
				return GetRandomInt(7500, 9999);
			}
		}
		case 19:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(784, 849);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(250, 299);
			}
			else
			{
				return GetRandomInt(10000, 14999);
			}
		}
		case 20:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(850, 999);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(300, 399);
			}
			else
			{
				return GetRandomInt(15000, 19999);
			}
		}
		default:
		{
			if(index == 133 || index == 444)	// Gunboats or Mantreads
			{
				return GetRandomInt(0, 999);
			}
			else if(index == 655)	// Spirit of Giving
			{
				return GetRandomInt(0, 399);
			}
			else
			{
				return GetRandomInt(0, 19999);
			}
		}
	}
}

float GetBossCharge(ConfigData cfg, const char[] slot, float defaul = 0.0)
{
	int length = strlen(slot)+7;
	char[] buffer = new char[length];
	Format(buffer, length, "charge%s", slot);
	return cfg.GetFloat(buffer, defaul);
}

void SetBossCharge(ConfigData cfg, const char[] slot, float amount)
{
	int length = strlen(slot)+7;
	char[] buffer = new char[length];
	Format(buffer, length, "charge%s", slot);
	cfg.SetFloat(buffer, amount);
}

void TF2_SetBuildingOwner(int building, int client)
{
	SetEntPropEnt(building, Prop_Send, "m_hBuilder", client);
	SDKCall_AddObject(client, building);
}

void TF2_SetBuildingTeam(int building, int team, int newBuilder = -1)
{
	int builder = GetEntPropEnt(building, Prop_Send, "m_hBuilder");
	
	//Remove the building from the original builder so it doesn't explode on team switch
	SDKCall_RemoveObject(builder, building);
	
	//Set its team. If we were attempting to do this by changing its TeamNum ent prop, Sentries would act derpy by actively trying to shoot itself
	SetVariantInt(team);
	AcceptEntityInput(building, "SetTeam");
	SetEntProp(building, Prop_Send, "m_nSkin", team-2);
	
	//Set a new builder and give them the building, if specified
	if(newBuilder != -1)
		TF2_SetBuildingOwner(building, newBuilder);
	
	switch(view_as<TFObjectType>(GetEntProp(building, Prop_Send, "m_iObjectType")))
	{
		case TFObject_Sentry:
		{
			//Mini-sentries use different skins, adjust accordingly
			if (GetEntProp(building, Prop_Send, "m_bMiniBuilding"))
				SetEntProp(building, Prop_Send, "m_nSkin", team);
			
			//Reset wrangler shield and player-controlled status to change team colors
			//If the sentry is still being wrangled, the values will automatically adjust themselves next frame
			if (GetEntProp(building, Prop_Send, "m_nShieldLevel") > 0)
			{
				SetEntProp(building, Prop_Send, "m_bPlayerControlled", false);
				SetEntProp(building, Prop_Send, "m_nShieldLevel", 0);
			}
		}
		case TFObject_Dispenser:
		{
			//Disable the dispenser's screen, it's better than having it not change team color
			int screen = MaxClients+1;
			while ((screen = FindEntityByClassname(screen, "vgui_screen")) > MaxClients)
			{
				if (GetEntPropEnt(screen, Prop_Send, "m_hOwnerEntity") == building)
					AcceptEntityInput(screen, "Kill");
			}
		}
		case TFObject_Teleporter:
		{
			//Disable teleporters for a little bit to reset the effects' colors
			TF2_StunBuilding(building, 0.1);
		}
	}
}

void TF2_StunBuilding(int building, float duration)
{
	SetEntProp(building, Prop_Send, "m_bDisabled", true);
	CreateTimer(duration, Timer_EnableBuilding, EntIndexToEntRef(building));
}

static Action Timer_EnableBuilding(Handle timer, int ref)
{
	int building = EntRefToEntIndex(ref);
	if(building != -1)
		SetEntProp(building, Prop_Send, "m_bDisabled", false);
	
	return Plugin_Continue;
}

void TF2_ShowAnnotation(int[] clients, int count, int target, const char[] message, float duration = 5.0, const char[] sound = "")
{
	//Create an annotation and show it to a specified array of clients
	Event event = CreateEvent("show_annotation");
	event.SetInt("id", target);				//Make its ID match the target, just so it's assigned to something unique
	event.SetInt("follow_entindex", target);
	event.SetFloat("lifetime", duration);
	event.SetString("text", message);
	event.SetString("play_sound", sound);		//If this is missing, it'll try to play a sound with an empty filepath
	
	for(int i = 0; i < count; i++)
	{
		//No point in showing the annotation to the target
		if(clients[i] != target)
			event.FireToClient(clients[i]);
	}
	
	event.Cancel();
}

float fabs(float value)
{
	return value < 0.0 ? -value : value;
}

int CreateParticleEffect(const char[] effectName = "", const float position[3] = NULL_VECTOR, int attachment = -1, float duration = 0.0, bool voided = true, int controlPoint = -1)
{
	int particle = CreateEntityByName("info_particle_system");
	if(particle != -1)
	{
		if(!IsNullVector(position))
		{
			TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		}
		else if(attachment != -1)
		{
			float pos[3];
			GetEntPropVector(attachment, Prop_Send, "m_vecOrigin", pos);
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
		}
		
		//SetEntPropFloat(particle, Prop_Data, "m_flSimulationTime", GetGameTime());
		DispatchKeyValue(particle, "effect_name", effectName[0] ? effectName : "3rd_trail");
		DispatchSpawn(particle);

		if(attachment != -1)
		{
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", attachment, particle);
		}

		if(controlPoint != -1)
		{
			SetEntPropEnt(particle, Prop_Send, "m_hControlPointEnts", controlPoint);
			SetEntProp(particle, Prop_Send, "m_iControlPointParents", controlPoint);
		}

		if(effectName[0])
		{
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
		}

		SetEdictFlags(particle, (GetEdictFlags(particle) & ~FL_EDICT_ALWAYS));	
		
		if(duration > 0.0)
		{
			if(voided)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				char buffer[64];
				FormatEx(buffer, sizeof(buffer), "OnUser1 !self:Kill::%f:1", duration);
				SetVariantString(buffer);
				AcceptEntityInput(particle, "AddOutput");
				AcceptEntityInput(particle, "FireUser1");
			}
		}	
	}
	return particle;
}

stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype=-1, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0)
{
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	if(tblidx == INVALID_STRING_TABLE)
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}

	// find particle index
	static char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for(int i; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}

	if(stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);

	if(entindex != -1)
		TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if(customcolors == 2)
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
	}

	if(controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if(controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}

	TE_SendToAll(delay);
}

/**
 * method
 * 0 = Set, then remove
 * 1 = Multiply, then divide
 * 2 = Add, then subtract
 */
void ApplyTempAttribute(int entity, const char[] name, float value, float duration, int method = 0)
{
	switch(method)
	{
		case 0:
		{
			Attrib_Set(entity, name, value);
		}
		case 1:
		{
			float previous = 1.0;
			Attrib_Get(entity, name, previous);
			Attrib_Set(entity, name, previous * value);
		}
		case 2:
		{
			float previous = 0.0;
			Attrib_Get(entity, name, previous);
			Attrib_Set(entity, name, previous + value);
		}
	}

	DataPack pack;
	CreateDataTimer(duration, RemoveAttribTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteString(name);
	pack.WriteFloat(value);
	pack.WriteCell(method);
}

static Action RemoveAttribTimer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		char name[64];
		pack.ReadString(name, sizeof(name));
		
		float value = pack.ReadFloat();
		int method = pack.ReadCell();

		switch(method)
		{
			case 0:
			{
				Attrib_Remove(entity, name);
			}
			case 1:
			{
				float previous = 1.0;
				Attrib_Get(entity, name, previous);
				Attrib_Set(entity, name, previous / value);
			}
			case 2:
			{
				float previous = 0.0;
				Attrib_Get(entity, name, previous);
				Attrib_Set(entity, name, previous - value);
			}
		}
	}

	return Plugin_Continue;
}

Action Timer_RemoveEntity(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(entity != -1)
	{
		TeleportEntity(entity, { 16383.0, 16383.0, -16383.0 }); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Continue;
}

bool IsPointsClear(const float pos1[3], const float pos2[3])
{
	TR_TraceRayFilter(pos1, pos2, MASK_PLAYERSOLID, RayType_EndPoint, TraceRay_DontHitPlayersAndObjects);
	return !TR_DidHit();
}

void ScreenFade(int client, int duration, int time, int flags, int r, int g, int b, int a)
{
	BfWrite bf = view_as<BfWrite>(StartMessageOne("Fade", client));
	bf.WriteShort(duration * 500);
	bf.WriteShort(time);
	bf.WriteShort(flags);
	bf.WriteByte(r);
	bf.WriteByte(g);
	bf.WriteByte(b);
	bf.WriteByte(a);
	EndMessage();
}

void ApplyAllyHealEvent(int healer, int patient, int amount)
{
	Event event = CreateEvent("player_healed", true);

	event.SetInt("healer", GetClientUserId(healer));
	event.SetInt("patient", GetClientUserId(patient));
	event.SetInt("amount", amount);

	event.Fire();
}

stock void TF2_Explode(int iAttacker = -1, float flPos[3], float flDamage, float flRadius, const char[] strParticle, const char[] strSound)
{
	int iBomb = CreateEntityByName("tf_generic_bomb");
	DispatchKeyValueVector(iBomb, "origin", flPos);
	DispatchKeyValueFloat(iBomb, "damage", flDamage);
	DispatchKeyValueFloat(iBomb, "radius", flRadius);
	DispatchKeyValue(iBomb, "health", "1");
	DispatchKeyValue(iBomb, "explode_particle", strParticle);
	DispatchKeyValue(iBomb, "sound", strSound);
	DispatchSpawn(iBomb);

	if (iAttacker == -1)
		AcceptEntityInput(iBomb, "Detonate");
	else
		SDKHooks_TakeDamage(iBomb, 0, iAttacker, 9999.0);
}

bool Trace_WallsOnly(int entity, int contentsMask)
{
	return false;
}

bool Trace_DontHitEntity(int entity, int contentsMask, any data)
{
	return entity != data;
}

bool TraceRay_DontHitPlayersAndObjects(int entity, int contentsMask, int data)
{
	if(entity > 0 && entity <= MaxClients)
		return false;
	
	static char classname[8];
	GetEntityClassname(entity, classname, sizeof(classname));
	return StrContains(classname, "obj_") != 0;
}