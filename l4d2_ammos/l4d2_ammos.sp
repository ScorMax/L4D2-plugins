#include <sourcemod>
#include <builtinvotes>
public Plugin myinfo =  
{
	name = "l4d2_ammos", 
	author = "TxMax", 
	description = "弹药设置", 
	version = "0.1.0",
	url = "https://github.com/ScorMax/L4D2-plugins/tree/main/l4d2_ammos"
};

Handle
	g_hVote = null;
int chooseNum=0;
char chooseDescription[64];

public void OnPluginStart()   
{
	RegConsoleCmd("sm_ammos", VoteAmmos);
}



public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client))
		CreateTimer(12.5, g_hTimerAnnounce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}


public Action g_hTimerAnnounce(Handle timer, any client)
{
	if ((client = GetClientOfUserId(client)) && IsClientInGame(client))
		PrintToChat(client, "\x04[提示]\x05聊天窗输入指令\x03!ammos\x05打开弹药设置投票菜单.");
	return Plugin_Continue;
}

public Action VoteAmmos(int client, int args)
{
	if (client == 0) {
		return Plugin_Handled;
	}

	VoteAmmosMenu(client);
	return Plugin_Handled;
}

void VoteAmmosMenu(int client)
{
	Menu menu = new Menu(VoteAmmosMenuHandler);
	menu.SetTitle("弹药设置");

	menu.AddItem("1", "正常备弹");
	menu.AddItem("2", "2倍备弹");
	menu.AddItem("3", "3倍备弹");
	menu.AddItem("4", "4倍备弹");
	menu.AddItem("5", "5倍备弹");
	menu.AddItem("6", "6倍备弹");
	menu.AddItem("7", "7倍备弹");
	menu.AddItem("7", "7倍备弹");
	menu.AddItem("8", "8倍备弹");
	menu.AddItem("9", "无限备弹");
	menu.AddItem("10", "开启无限前置子弹不换弹");
	menu.AddItem("11", "关闭无限前置子弹不换弹");

	menu.ExitButton = true;
	menu.Display(client, 300);

}

int VoteAmmosMenuHandler(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_End) {
		delete menu;
		// PrintToChatAll("ConfigsMenuHandler MenuAction_End");

	} 
	else if (action == MenuAction_Cancel) {
		// PrintToChatAll("ConfigsMenuHandler MenuAction_Cancel");
	} 
	else if (action == MenuAction_Select) {
		char sItem[32],description[32];
		if(menu.GetItem(itemNum, sItem, sizeof(sItem),_,description,sizeof(description)))
		{
			chooseNum=StringToInt(sItem);
			chooseDescription=description;
			if (StartMatchVote(client, description)) {
				FakeClientCommand(client, "Vote Yes");
			} 
		}
	}

	return 0;
}

bool StartMatchVote(int client, const char[] descrption)
{

	if (!IsBuiltinVoteInProgress()) {
		int iNumPlayers = 0;
		int[] iPlayers = new int[MaxClients];

		//list of non-spectators players
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientInGame(i) || IsFakeClient(i)) {
				continue;
			}

			iPlayers[iNumPlayers++] = i;
		}

		g_hVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
		SetBuiltinVoteArgument(g_hVote, descrption);
		SetBuiltinVoteInitiator(g_hVote, client);
		SetBuiltinVoteResultCallback(g_hVote, MatchVoteResultHandler);
		DisplayBuiltinVote(g_hVote, iPlayers, iNumPlayers, 20);

		return true;
	}

	return false;
}

public void VoteActionHandler(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
	switch (action) {
		case BuiltinVoteAction_End: {
			delete vote;
			g_hVote = null;
		}
		case BuiltinVoteAction_Cancel: {
			DisplayBuiltinVoteFail(vote, view_as<BuiltinVoteFailReason>(param1));
		}
	}
}

public void MatchVoteResultHandler(Handle vote, int num_votes, int num_clients, \
										const int[][] client_info, int num_items, const int[][] item_info)
{
	for (int i = 0; i < num_items; i++) {
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES) {
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_votes * 0.67)) {
				DisplayBuiltinVotePass(vote, chooseDescription);
				int ammo_assaultrifle_max=360;
				int ammo_shotgun_max=72;
				int ammo_autoshotgun_max=90;
				int ammo_huntingrifle_max=150;
				int ammo_sniperrifle_max=180;
				int ammo_smg_max=650;
				int ammo_grenadelauncher_max=30;
				if(chooseNum>=1&&chooseNum<=8){
					ServerCommand("sm_cvar ammo_assaultrifle_max %d",chooseNum*ammo_assaultrifle_max);
					ServerCommand("sm_cvar ammo_shotgun_max %d",chooseNum*ammo_shotgun_max);
					ServerCommand("sm_cvar ammo_autoshotgun_max %d",chooseNum*ammo_autoshotgun_max);
					ServerCommand("sm_cvar ammo_huntingrifle_max %d",chooseNum*ammo_huntingrifle_max);
					ServerCommand("sm_cvar ammo_sniperrifle_max %d",chooseNum*ammo_sniperrifle_max);
					ServerCommand("sm_cvar ammo_smg_max %d",chooseNum*ammo_smg_max);
					ServerCommand("sm_cvar ammo_grenadelauncher_max %d",chooseNum*ammo_grenadelauncher_max);
				}
				else if(chooseNum==9){
					ServerCommand("sm_cvar ammo_assaultrifle_max %d",-2);
					ServerCommand("sm_cvar ammo_shotgun_max %d",-2);
					ServerCommand("sm_cvar ammo_autoshotgun_max %d",-2);
					ServerCommand("sm_cvar ammo_huntingrifle_max %d",-2);
					ServerCommand("sm_cvar ammo_sniperrifle_max %d",-2);
					ServerCommand("sm_cvar ammo_smg_max %d",-2);
					ServerCommand("sm_cvar ammo_grenadelauncher_max %d",-2);
				}
				else if(chooseNum==10){
					ServerCommand("sm_cvar sv_infinite_ammo 1");
				}
				else if(chooseNum==11){
					ServerCommand("sm_cvar sv_infinite_ammo 0");
				}
				return;
			}
		}
	}
	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
}