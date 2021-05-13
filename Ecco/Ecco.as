#include "Include"

#include "core/EccoPlayerStorage"
#include "core/LoadInventory"
#include "core/BuyMenu"
#include "core/SmartPrecache"
#include "core/CBaseMenuItem"
#include "core/EccoHook"

string szRootPath = "scripts/plugins/Eccogit/Ecco/";
string szStorePath = "scripts/plugins/store/Ecco/";
const string szConfigPath = "scripts/plugins/Eccogit/Ecco/config/";

bool bAborted = false;
bool IsMapAllowed;
string szLastNextMap = g_Engine.mapname;
bool bShouldCleanScore = true;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF");

    if(!EccoConfig::RefreshEccoConfig()){
        bAborted = true;
        return;
    }

    szRootPath = EccoConfig::GetConfig()["Ecco.BaseConfig", "PluginsRootPath"].getString();
    szStorePath = EccoConfig::GetConfig()["Ecco.BaseConfig", "PluginsStorePath"].getString();

    EccoProcessVar::Register("%PLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.netname);});
    EccoProcessVar::Register("%RANDOMPLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, e_PlayerInventory.GetRandomPlayerName());});
    EccoProcessVar::Register("%BALANCE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, string(e_PlayerInventory.GetBalance(pPlayer)));});
    EccoProcessVar::Register("%SPACE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, " ");});
    EccoProcessVar::Register("%COST%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ return szInput.Replace(szName, pMenuItem.Cost);});
    EccoProcessVar::Register("%MENUNAME%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ return szInput.Replace(szName, pMenuItem.Name);});
    EccoProcessVar::Register("%PLAYERHP%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.health);});
    EccoProcessVar::Register("%PLAYERAP%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.armorvalue);});
    EccoProcessVar::Register("%PLAYERTEAM%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.team);});

    e_ScriptParser.BuildItemList();

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);

    EccoInclude::AddonListBuilder();
    EccoInclude::PluginInit();

    string szBanner = """

     /$$$$$$$$  /$$$$$$   /$$$$$$   /$$$$$$ 
    | $$_____/ /$$__  $$ /$$__  $$ /$$__  $$
    | $$      | $$  \__/| $$  \__/| $$  \ $$
    | $$$$$   | $$      | $$      | $$  | $$
    | $$__/   | $$      | $$      | $$  | $$
    | $$      | $$    $$| $$    $$| $$  | $$
    | $$$$$$$$|  $$$$$$/|  $$$$$$/|  $$$$$$/
    |________/ \______/  \______/  \______/ 

    """;
    string szVersion = IO::FileTotalReader(szRootPath + "Version");
    string szContactInfo = szBanner + "\nhttps://github.com/DrAbcrealone/Ecco\nVersion:" + szVersion;
    g_Module.ScriptInfo.SetContactInfo(EccoInclude::AddAddonInfo(szContactInfo));

    string szLine = "==============================";
    string szTime;
    DateTime().Format(szTime, "%Y-%m-%d %H:%M");
    Logger::WriteLine(szLine);
    Logger::WriteLine(szBanner);
    Logger::WriteLine("    Ver: " + szVersion);
    Logger::WriteLine("    Time: " + szTime);
    Logger::WriteLine(szLine);
    Logger::Say(EccoConfig::GetLocateMessage("PluginReloaded"));
}

void MapInit(){
    if(bAborted)
        return;
    g_Game.PrecacheModel("sprites/" + EccoConfig::GetConfig()["Ecco.BaseConfig", "MoneyIconPath"].getString());
    g_Game.PrecacheGeneric("sprites/" + EccoConfig::GetConfig()["Ecco.BaseConfig", "MoneyIconPath"].getString());
    SmartPrecache::PrecacheByList();

    IsMapAllowed = true;
    array<string>@ aryMaps = IO::FileLineReader(szRootPath + EccoConfig::GetConfig()["Ecco.BaseConfig", "BanMapPath"].getString(), function(string szLine){ if(szLine != g_Engine.mapname){return "\n";}return g_Engine.mapname;});
    if(aryMaps.length() > 0 && aryMaps[aryMaps.length() - 1] == g_Engine.mapname)
        IsMapAllowed = false;

    if(IsMapAllowed)
        EccoBuyMenu::ReadScriptList();
    
    switch(EccoConfig::GetConfig()["Ecco.BaseConfig", "SereisMapCheckMethod"].getInt()){
        //经典模式
        case 0: {
            bShouldCleanScore = szLastNextMap != g_Engine.mapname;
            szLastNextMap = EccoUtility::GetNextMap();
            break;
        }
        //LCS
        case 1:{
            bShouldCleanScore = EccoUtility::GetLCS(szLastNextMap, g_Engine.mapname) < EccoConfig::GetConfig()["Ecco.BaseConfig", "SereisMapLCSCheckRatio"].getFloat();
            szLastNextMap = g_Engine.mapname;
            break;
        }
        //混合模式
        case 2:{
            string szTemp = EccoUtility::GetNextMap();
            if(szTemp.IsEmpty()){
                bShouldCleanScore = EccoUtility::GetLCS(szLastNextMap, g_Engine.mapname) < EccoConfig::GetConfig()["Ecco.BaseConfig", "SereisMapLCSCheckRatio"].getFloat();
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

HookReturnCode onChat(SayParameters@ pParams){
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ pCommand = pParams.GetArguments();
    string arg = pCommand[0];
    if(pPlayer !is null && (arg.StartsWith("!") || arg.StartsWith("/"))){
        if(arg.SubString(1).ToLowercase() != EccoConfig::GetConfig()["Ecco.BuyMenu", "OpenShopTrigger"].getString())
            return HOOK_CONTINUE;
        pParams.ShouldHide = true;
        if(!IsMapAllowed){
            Logger::Chat(pPlayer, EccoConfig::GetLocateMessage("ChatLogTitle", @pPlayer) + " " + EccoConfig::GetLocateMessage("LocaleNotAllowed", @pPlayer));
            return HOOK_CONTINUE;
        }
        if(EccoBuyMenu::IsEmpty()){
            Logger::Chat(pPlayer, EccoConfig::GetLocateMessage("ChatLogTitle", @pPlayer) + " " + EccoConfig::GetLocateMessage("EmptyBuyList", @pPlayer));
            return HOOK_CONTINUE;
        }
        if(pCommand.ArgC() <= 1)
            EccoBuyMenu::OpenBuyMenu(pPlayer);
        else{
            CBaseMenuItem@ pItem = EccoBuyMenu::pRoot;
            string szPointer = "";
            if(atoi(pCommand[1]) > 0){
                for(int i = 1; i < pCommand.ArgC();i++){
                @pItem = pItem[Math.clamp(0, pItem.length() - 1 ,atoi(pCommand[i]) - 1)];
                    szPointer = pCommand[i];
                    if(pItem.IsTerminal)
                        break;
                }
            }
            else{
                for(int i = 1; i < pCommand.ArgC();i++){
                    @pItem = pItem[pCommand[i]];
                    szPointer = pCommand[i];
                    if(@pItem is null|| pItem.IsTerminal)
                        break;
                }
            }
            if(@pItem !is null)
                pItem.Excute(@pPlayer);
            else
                Logger::Chat(pPlayer, EccoConfig::GetLocateMessage("ChatLogTitle", @pPlayer) + 
                    " " + EccoConfig::GetLocateMessage("NullPointerMenu") + szPointer);
        }
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
    if(IsMapAllowed){
        switch(EccoConfig::GetConfig()["Ecco.BaseConfig", "StorePlayerScore"].getInt()){
            case 2: break;
            case 1: if(bShouldCleanScore == false){break;}
            case 0: {
                if(EccoPlayerStorage::Exists(@pPlayer)){
                    EccoPlayerStorage::CPlayerStorageDataItem@ pItem = EccoPlayerStorage::pData.Get(@pPlayer);
                    DateTime pNow;
                    if(pItem.szLastPlayMap == g_Engine.mapname && (pNow - pItem.pLastUpdateTime).GetSeconds() < EccoConfig::GetConfig()["Ecco.BaseConfig", "ClearMaintenanceTimeMax"].getInt())
                        break;
                    else{
                        pItem.szLastPlayMap = g_Engine.mapname;
                        pItem.pLastUpdateTime = pNow;
                    }
                }
            }
            default: e_PlayerInventory.SetBalance(@pPlayer, EccoConfig::GetConfig()["Ecco.BaseConfig", "PlayerStartScore"].getInt());break;
        }
        EccoPlayerStorage::ResetPlayerBuffer(@pPlayer);
        EccoInventoryLoader::LoadPlayerInventory(@pPlayer);
        e_PlayerInventory.RefreshHUD(@pPlayer);
    }
    return HOOK_HANDLED;
}
