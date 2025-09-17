/*
	Redmond & Blutarch from VSH Rewrite

	"rage_spellbook"
	{
		"slot"		"0"	// Ability slot
		"type"		"0"	// Spell index
		"charges"	"1"	// Spell uses

		"spellbook"
		{
			// Weapon Config
		}
		
		"plugin_name"	"ff2r_redsun_abilities"
	}
*/

#pragma semicolon 1
#pragma newdecls required

void Spellbook_Ability(int client, const char[] ability, AbilityData cfg)
{
	if(!StrContains(ability, "rage_spellbook", false))
	{
		int spellbook = GetSpellbook(client);
		if(spellbook == -1)
		{
			ConfigData weapon = cfg.GetSection("spellbook");
			if(weapon)
			{
				bool equip = false;
				spellbook = TF2Items_CreateFromCfg(client, "tf_weapon_spellbook", weapon, equip);
				if(spellbook == -1)
					return;
			}
		}

		SetEntProp(spellbook, Prop_Send, "m_iSelectedSpellIndex", cfg.GetInt("type"));
		SetEntProp(spellbook, Prop_Send, "m_iSpellCharges", cfg.GetInt("charges", 1));

		KeyValues kv = new KeyValues("+use_action_slot_item_server");
		FakeClientCommandKeyValues(client, kv);
		delete kv;
		
		kv = new KeyValues("-use_action_slot_item_server");
		FakeClientCommandKeyValues(client, kv);
		delete kv;
	}
}

static int GetSpellbook(int client)
{
	int entity = MaxClients+1;
	while((entity = FindEntityByClassname(entity, "tf_weapon_spellbook")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWeapon"))
			return entity;
	}
	
	return -1;
}