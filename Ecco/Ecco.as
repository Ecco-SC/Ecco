#include "Include"

#include "core/CBaseMenuItem"
#include "core/EccoPlayerStorage"
#include "core/BuyMenu"
#include "core/EccoHook"
#include "core/Command"
#include "core/Hook"
//如果你的Config文件不在默认位置，这行必须被修改
//You have to edit this line if your config file is not in default position
const string szConfigPath = "scripts/plugins/Ecco/config/";

string szRootPath = "scripts/plugins/Ecco/";
string szStorePath = "scripts/plugins/store/Ecco/";

bool bAborted = false;
bool IsMapAllowed;
string szLastNextMap = g_Engine.mapname;
bool bShouldCleanScore = true;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Ecco team");

    if(!EccoConfig::RefreshEccoConfig()){
        bAborted = true;
        return;
    }

    szRootPath = EccoConfig::pConfig.BaseConfig.PluginsRootPath;
    szStorePath = EccoConfig::pConfig.BaseConfig.PluginsStorePath;

    EccoProcessVar::Register("%PLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.netname);});
    EccoProcessVar::Register("%RANDOMPLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, EccoPlayerInventory::GetRandomPlayerName());});
    EccoProcessVar::Register("%BALANCE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, string(EccoPlayerInventory::GetBalance(pPlayer)));});
    EccoProcessVar::Register("%SPACE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, " ");});
    EccoProcessVar::Register("%COST%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ 
        return szInput.Replace(szName, 
            pMenuItem.Flags & MenuItemFlag::FLAG_HIDECOST == 0 ? string(pMenuItem.Cost) : "");
        }
    );
    EccoProcessVar::Register("%MENUNAME%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ return szInput.Replace(szName, pMenuItem.Name);});
    EccoProcessVar::Register("%PLAYERHP%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.health);});
    EccoProcessVar::Register("%PLAYERAP%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.armorvalue);});
    EccoProcessVar::Register("%PLAYERTEAM%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.team);});

    Command::Register("help", "", "获取帮助信息", "", function(CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd, const bool bChat){
        for(uint i = 0; i < Command::aryCmdList.length(); i++){
            if(!Command::aryCmdList[i].IsEmpty()){
                CClinetCmd@ eCme = cast<CClinetCmd@>(Command::aryCmdList[i]);
                if(g_PlayerFuncs.AdminLevel(pPlayer) < int(eCme.AdminLevel))
                    continue;
                Logger::Console(pPlayer, "| " + EccoUtility::PadSpace(24, eCme.Name) + " | " + 
                        eCme.HelpInfo + " | " + eCme.DescribeInfo + " | " + 
                        EccoUtility::GetAdminLevelString(eCme.AdminLevel));
            }
        }
        return true;
    });
    Command::Register("lang", "[Language]", "设置语言/Set Display Language", "", function(CBasePlayer@ pPlayer, const CCommand@ pArgs, const CClinetCmd@ pCmd, const bool bChat){
        if(!EccoBuyMenu::SetLanguage(@pPlayer, pArgs.Arg(1))){
            array<string>@ aryKeys = EccoBuyMenu::dicRoots.getKeys();
            string szTemp = "";
            for(uint i = 0; i <  aryKeys.length();i++){
                szTemp += EccoUtility::PadSpace(6, aryKeys[i]) + "|";
            }
            Logger::Console(pPlayer, szTemp);
            return false;
        }
        return true;
    });

    EccoScriptParser::BuildItemList();

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @Hook::ClientSay);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @Hook::ClientPutInServer);

    EccoInclude::AddonListBuilder();
    EccoInclude::PluginInit();

    string szVersion = IO::FileTotalReader(szRootPath + "Version");
    string szContactInfo = "Ecco\nhttps://github.com/Ecco-SC/Ecco\nVersion:" + szVersion;
    g_Module.ScriptInfo.SetContactInfo(EccoInclude::AddAddonInfo(szContactInfo));
        string szBanner = """

     /$$$$$$$$  /$$$$$$   /$$$$$$   /$$$$$$ 
    | $$_____/ /$$__  $$ /$$__  $$ /$$__  $$
    | $$      | $$  \__/| $$  \__/| $$  \ $$
    | $$$$$   | $$      | $$      | $$  | $$
    | $$__/   | $$      | $$      | $$  | $$
    | $$      | $$    $$| $$    $$| $$  | $$
    | $$$$$$$$|  $$$$$$/|  $$$$$$/|  $$$$$$/
    |________/ \______/  \______/  \______/ 

                            Ver: {Version}
                            Load Time: {Time}
    """;
    string szTime;
    DateTime().Format(szTime, "%Y-%m-%d %H:%M");
    array<string> aryBanner = szBanner.Replace("{Version}", szVersion).Replace("{Time}", szTime).Split("\n");
    for(uint i = 0; i < aryBanner.length(); i++){
        Logger::WriteLine(aryBanner[i]);
    }
    Logger::Say(EccoConfig::pConfig.LocaleSetting.PluginReloaded);
}
void MapInit(){
    if(bAborted)
        return;
    g_Game.PrecacheModel("sprites/" + EccoConfig::pConfig.BaseConfig.MoneyIconPath);
    g_Game.PrecacheGeneric("sprites/" + EccoConfig::pConfig.BaseConfig.MoneyIconPath);

    IsMapAllowed = true;
    array<string>@ aryMaps = IO::FileLineReader(szRootPath + EccoConfig::pConfig.BaseConfig.BanMapPath, function(string szLine){ if(szLine != g_Engine.mapname){return "\n";}return g_Engine.mapname;});
    if(aryMaps.length() > 0 && aryMaps[aryMaps.length() - 1] == g_Engine.mapname)
        IsMapAllowed = false;

    if(IsMapAllowed)
        EccoBuyMenu::BuildMenu();
    
    switch(EccoConfig::pConfig.BaseConfig.SereisMapCheckMethod){
        //经典模式
        case 0: {
            bShouldCleanScore = szLastNextMap != g_Engine.mapname;
            szLastNextMap = EccoUtility::GetNextMap();
            break;
        }
        //LCS
        case 1:{
            bShouldCleanScore = EccoUtility::GetLCS(szLastNextMap, g_Engine.mapname) < EccoConfig::pConfig.BaseConfig.SereisMapLCSCheckRatio;
            szLastNextMap = g_Engine.mapname;
            break;
        }
        //混合模式
        case 2:{
            string szTemp = EccoUtility::GetNextMap();
            if(szTemp.IsEmpty()){
                bShouldCleanScore = EccoUtility::GetLCS(szLastNextMap, g_Engine.mapname) < EccoConfig::pConfig.BaseConfig.SereisMapLCSCheckRatio;
                szLastNextMap = g_Engine.mapname;
            }
            else{
                bShouldCleanScore = szLastNextMap != g_Engine.mapname;
                szLastNextMap = szTemp;
            }
            break;
        }
        default: if(!bShouldCleanScore){bShouldCleanScore = true;}break;
    }
    
    EccoPlayerStorage::ResetPlayerBuffer();
    EccoPlayerStorage::RemoveTimer();
    if(IsMapAllowed)
        EccoPlayerStorage::RegisterTimer();
        
    EccoInclude::MapInit();
}
void MapActivate(){
    if(bAborted)
        return;
    EccoInclude::MapActivate();
}
void MapStart(){
    if(bAborted)
        return;
    EccoInclude::MapStart();
}