#include <sourcemod>
#include <smlib>
#include <sdkhooks>

#define MAX_FILE_LEN 80
new Handle:g_CvarSesismi = INVALID_HANDLE;
new String:g_Sesismi[MAX_FILE_LEN];
bool yazildi = false;

public Plugin:myinfo = 
{
	name = "İsyan Ses & Yazı",
	author = "Caferly`",
	description = "Mahkum isyan başlattığında bir isyan sesi çalar ve ekranda yazı çıkar.",
	version = "1.1"
}

public OnPluginStart()
{
	g_CvarSesismi = CreateConVar("sm_isyan_sesi", "sound/caferly/caferly-isyan.mp3", "Isyan Sesi"); 
	HookEvent("round_start", Event_RoundStart);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	yazildi = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(i && IsClientInGame(i) && IsClientConnected(i) && !IsFakeClient(i))   {
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}

public OnMapStart()
{

	
	GetConVarString(g_CvarSesismi, g_Sesismi, MAX_FILE_LEN);
	decl String:buffer[MAX_FILE_LEN];
	PrecacheSound(g_Sesismi, true);
	Format(buffer, sizeof(buffer), "sound/%s", g_Sesismi);
	AddFileToDownloadsTable(buffer);
	
	decl String:mapName[64];
	GetCurrentMap(mapName, sizeof(mapName));
	
	if(!((StrContains(mapName, "jb_", false) != -1) || (StrContains(mapName, "jail_", false)!= -1)))
	{
		SetFailState("Bu plugin sadece jail maplarinda calismaktadir.. - - - Eklenti Caferly Tarafından Yapılmıştır.");
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) 
{
	new iAttacker;
	if(attacker>64)
		iAttacker = GetClientOfUserId(attacker);
	else
		iAttacker = attacker;
	
	if(iAttacker > 0)
	{	
		decl String:isim[32];
		GetClientName(iAttacker, isim, sizeof(isim));
		
		if(GetClientTeam(iAttacker) == 2 && GetClientTeam(victim) == 3) {
				for (int i = 1; i <= MaxClients; i++)
			{
				if(i && IsClientInGame(i) && IsClientConnected(i) && !IsFakeClient(i))   {
					if(!yazildi)
					{
						PrintToChat(i," \x02[Caferly] \x04%s \x10İsimli Mahkum İsyan Başlattı.",isim);
						PrintHintTextToAll("→ %s İsimli Mahkum İsyan Başlattı. ←");
						yazildi = true
						ClientCommand(i,"play *%s", g_Sesismi)
						sil();
					}
				}
			}
		}
	}
}

public sil() {
		for (int i = 1; i <= MaxClients; i++) 
	{
		if(i && IsClientInGame(i) && IsClientConnected(i) && !IsFakeClient(i))   {
			SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}