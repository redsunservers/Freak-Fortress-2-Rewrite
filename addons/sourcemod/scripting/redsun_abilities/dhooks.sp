#pragma semicolon 1
#pragma newdecls required

void DHooks_PluginStart()
{
	GameData gamedata = new GameData("ff2");

	CreateDetour(gamedata, "CTFWeaponBaseMelee::DoSwingTraceInternal", DHook_DoSwingTracePre, DHook_DoSwingTracePost);

	delete gamedata;
}

static void CreateDetour(GameData gamedata, const char[] name, DHookCallback preCallback = INVALID_FUNCTION, DHookCallback postCallback = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if(detour)
	{
		if(preCallback!=INVALID_FUNCTION && !detour.Enable(Hook_Pre, preCallback))
			SetFailState("[Gamedata] Failed to enable pre detour: %s", name);
		
		if(postCallback!=INVALID_FUNCTION && !detour.Enable(Hook_Post, postCallback))
			SetFailState("[Gamedata] Failed to enable post detour: %s", name);

		delete detour;
	}
	else
	{
		SetFailState("[Gamedata] Could not find %s", name);
	}
}

static MRESReturn DHook_DoSwingTracePre(int entity, DHookReturn ret, DHookParam param)
{
	CustomMelee_DoSwingTracePre(entity);
	return MRES_Ignored;
}

static MRESReturn DHook_DoSwingTracePost(int entity, DHookReturn ret, DHookParam param)
{
	CustomMelee_DoSwingTracePost(entity, ret.Value);
	return MRES_Ignored;
}