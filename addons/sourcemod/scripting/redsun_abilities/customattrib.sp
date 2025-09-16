#pragma semicolon 1
#pragma newdecls required

void CustomAttrib_AllPluginsLoaded()
{
	TF2EconDynAttribute attrib = new TF2EconDynAttribute();

	attrib.SetName("convert team on hit");
	attrib.SetClass("redsun.announcergun");
	attrib.SetDescriptionFormat("additive");
	attrib.SetCustom("description_ff2_string", "");
	attrib.Register();

	delete attrib;
}

stock Action CustomAttrib_PlayerTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType)
{
	Action action;

	if(weapon != -1 && HasEntProp(weapon, Prop_Send, "m_AttributeList"))
	{
		float value;
		if(CustomAttrib_Get(weapon, "convert team on hit", value))
		{
			UpdateAction(action, Announcer_ConvertPlayer(value, victim, attacker, damage, damagetype, weapon, critType));
		}
	}

	return action;
}

stock Action CustomAttrib_ObjectTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action;
	
	if(weapon != -1 && HasEntProp(weapon, Prop_Send, "m_AttributeList"))
	{
		float value;
		if(CustomAttrib_Get(weapon, "convert team on hit", value))
		{
			UpdateAction(action, Announcer_ConvertBuilding(victim, attacker, damage, damagetype, weapon));
		}
	}

	return action;
}
