#pragma semicolon 1
#pragma newdecls required

void SetEntityModelScale(int entity, float scale)
{
	char buffer[16];
	FloatToString(scale, buffer, sizeof(buffer));
	
	SetVariantString(buffer);
	AcceptEntityInput(entity, "SetModelScale");
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
		
		if(GetEntProp(weapon, Prop_Send, "m_bDisguiseWeapon"))
			continue;
		
		if(weapon != -1)
			return true;
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
