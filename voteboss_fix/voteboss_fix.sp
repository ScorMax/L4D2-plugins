
#include <sourcemod>

public Plugin myinfo =  
{
	name = "voteboss fix", 
	author = "TxMax", 
	description = "fix can not voteboss for not in first round when connect 修复因为加入后提示不在第一回合不能投票tank或witch进度", 
	version = "0.2.0",
	url = "https://github.com/ScorMax/L4D2-plugins/tree/main/voteboss_fix"
};

static bool executeOnce=false;

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen){
    if(!executeOnce){
        ServerCommand("sm_forcematch zonemod");
        executeOnce=true;
    }
    return true;
}
