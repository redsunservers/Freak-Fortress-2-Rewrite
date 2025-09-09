#pragma semicolon 1
#pragma newdecls required

void SDKHooks_PutInServer(int client)
{
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

static Action OnPreThink(int client)
{
	Saxton_PreThink(client);
	return Plugin_Continue;
}