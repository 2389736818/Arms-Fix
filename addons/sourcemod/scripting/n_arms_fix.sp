#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

Handle armsHandle;
Handle modelHandle;

char defaultArms[][] = { "models/weapons/ct_arms.mdl", "models/weapons/t_arms.mdl" };
char defaultModels[][] = { "models/player/ctm_fbi.mdl", "models/player/tm_phoenix.mdl" };

public Plugin myinfo = {

	name = "Skin & Arms Fix",
	author = "NomisCZ (-N-)",
	description = "Arms fix",
	version = "1.1",
	url = "http://steamcommunity.com/id/olympic-nomis-p"
}

public void OnMapStart() {

	PrecacheModels();
}

public void OnPluginStart() {

    RegPluginLibrary("n_arms_fix");
    armsHandle = CreateGlobalForward("ArmsFix_OnArmsSafe", ET_Ignore, Param_Cell);
    modelHandle = CreateGlobalForward("ArmsFix_OnModelSafe", ET_Ignore, Param_Cell);
	
    HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
} 

void PrecacheModels() {

	for (int i = 0; i < sizeof(defaultArms); i++) {
		
		PrecacheModel(defaultArms[i]);
	}
	
	for (int i = 0; i < sizeof(defaultModels); i++) {
		
		PrecacheModel(defaultModels[i]);
	}
}

public Action Event_Spawn(Event event, const char[] name, bool dontBroadcast) {

	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (isValidClient(client) && IsPlayerAlive(client)) {
	
		CS_UpdateClientModel(client);

		SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
		
		int team = GetClientTeam(client);
		
		if (team == CS_TEAM_T) {
			
			SetEntityModel(client, defaultModels[1]);
			SetEntPropString(client, Prop_Send, "m_szArmsModel", defaultArms[1]);

		} else if (team == CS_TEAM_CT) {
			
			SetEntityModel(client, defaultModels[0]);
			SetEntPropString(client, Prop_Send, "m_szArmsModel", defaultArms[0]);
		}
		
		CreateTimer(0.2, Timer_CallForward, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
} 


public Action Timer_CallForward(Handle timer, int userid) {

	CallArmsForward(GetClientOfUserId(userid));
	CreateTimer(0.0, Timer_CallModelForward, userid, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CallModelForward(Handle timer, int userid) {

	CallModelForward(GetClientOfUserId(userid));
}

void CallModelForward(int client) {

    Call_StartForward(modelHandle);
    Call_PushCell(client);
    Call_Finish();
}

void CallArmsForward(int client) {

    Call_StartForward(armsHandle);
    Call_PushCell(client);
    Call_Finish();
}

bool isValidClient(int client, bool bot = false) {

	if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (bot ? IsFakeClient(client) : !IsFakeClient(client))) 
		return true;
	return false;
}