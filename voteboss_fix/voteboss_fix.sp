
#include <sourcemod>

public Plugin myinfo =  
{
	name = "voteboss fix", 
	author = "TxMax", 
	description = "fix can not voteboss for not in first round when connect 修复因为加入后提示不在第一回合不能投票tank或witch进度", 
	version = 0.1.0,
	url = "N/A"
};

public bool OnClientConnect(){
    char sMap[64];
    GetCurrentMap(sMap, sizeof(sMap));
    ServerCommand("changelevel %s", sMap);
    ServerCommand("sm plugins unload voteboss_fix");
    return true;
}
