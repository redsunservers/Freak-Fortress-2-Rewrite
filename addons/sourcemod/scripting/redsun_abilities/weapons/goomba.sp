/*
	In-house goomba stomp
*/

#pragma semicolon 1
#pragma newdecls required

#define GOOMBA_SOUND	"goomba/rebound.wav"

static float GoombaCooldown[MAXPLAYERS+1];

void Goomba_MapStart()
{
	PrecacheSound(GOOMBA_SOUND);
	AddFileToDownloadsTable("sound/" ... GOOMBA_SOUND);
}

void Goomba_StartTouch(int client, int target)
{
	if(IsPlayerAlive(client) && target > 0 && target <= MaxClients && GetClientTeam(client) != GetClientTeam(target) && FF2R_GetClientMinion(client) != 2)
	{
		float gameTime = GetGameTime();
		if(fabs(GoombaCooldown[client] - gameTime) > 0.5)
		{
			float pos1[3], pos2[3], maxs[3];
			GetClientAbsOrigin(client, pos1);
			GetClientAbsOrigin(target, pos2);
			GetEntPropVector(target, Prop_Send, "m_vecMaxs", maxs);
			float height = maxs[2];
			float diff = pos1[2] - pos2[2];

			if(diff > height)
			{
				float vel[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vel);

				if(vel[2] < -360.0)
				{
					GoombaCooldown[client] = gameTime;

					if(Saxton_Stomp(client, target) >= Plugin_Handled)
						return;

					int health = GetClientHealth(target);

					int clientWeight = (FF2R_GetBossData(client) ? 1 : 0) + (FF2R_GetClientMinion(client) ? -1 : 0);
					int targetWeight = (FF2R_GetBossData(target) ? 1 : 0) + (FF2R_GetClientMinion(target) ? -1 : 0);

					// If heavy, don't recoil
					bool heavy = clientWeight > targetWeight;

					SetKillIcon("taunt_scout", "goomba");
					SDKHooks_TakeDamage(target, client, client, 500.0, DMG_PREVENT_PHYSICS_FORCE, .bypassHooks = false);
					SetKillIcon();

					AttachParticle(target, "mini_fireworks", 5.0);
					EmitSoundToAll(GOOMBA_SOUND, target, _, _, _, 0.7);

					// If any change, recoil
					if(!heavy && (!IsPlayerAlive(target) || health != GetClientHealth(target)))
					{
						float ang[3];
						GetClientEyeAngles(client, ang);
						GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
						ang[0] = DegToRad(ang[0]);
						ang[1] = DegToRad(ang[1]);
						vel[0] = 300.0 * Cosine(ang[0]) * Cosine(ang[1]);
						vel[1] = 300.0 * Cosine(ang[0]) * Sine(ang[1]);
						vel[2] = 400.0;

						DataPack pack = new DataPack();
						pack.WriteCell(GetClientUserId(client));
						for(int i; i < 3; i++)
						{
							pack.WriteFloat(vel[i]);
						}
						RequestFrame(PushClientFrame, pack);
					}
				}
			}
		}
	}
}

static void PushClientFrame(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		float vel[3];
		for(int i; i < 3; i++)
		{
			vel[i] = pack.ReadFloat();
		}

		TeleportEntity(client, _, _, vel);
	}

	delete pack;
}