#include "Include"

#include "core/ScoreToBalance"
#include "core/LoadInventory"
#include "core/BuyMenu"
#include "core/SmartPrecache"
#include "core/CBaseMenuItem"

const string szRootPath = "scripts/plugins/Eccogit/Ecco/";
const string szStorePath = "scripts/plugins/store/Ecco";
const string szConfigPath = "scripts/plugins/Eccogit/Ecco/config/";

bool IsMapAllowed;
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
	g_Module.ScriptInfo.SetContactInfo("Please Don't.\n    Version:" + IO::FileTotalReader(szRootPath + "Version"));

    EccoConfig::RefreshEccoConfig();

    EccoProcessVar::Register("%PLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.netname);});
    EccoProcessVar::Register("%RANDOMPLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, e_PlayerInventory.GetRandomPlayerName());});
    EccoProcessVar::Register("%BALANCE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, string(e_PlayerInventory.GetBalance(pPlayer)));});
    EccoProcessVar::Register("%SPACE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, " ");});
    EccoProcessVar::Register("%COST%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ return szInput.Replace(szName, pMenuItem.Cost);});
    EccoProcessVar::Register("%MENUNAME%", function(string szInput, string szName, CBaseMenuItem@ pMenuItem){ return szInput.Replace(szName, pMenuItem.Name);});

    e_ScriptParser.BuildItemList();

    Logger::Say(EccoConfig::GetLocateMessage("PluginReloaded"));
}

void MapInit(){
    InitEcco();

    g_Game.PrecacheModel("sprites/" + EccoConfig::GetConfig()["Ecco.BaseConfig", "MoneyIconPath"].getString());
    g_Game.PrecacheGeneric("sprites/" + EccoConfig::GetConfig()["Ecco.BaseConfig", "MoneyIconPath"].getString());
    SmartPrecache::PrecacheByList();

    EccoScoreBuffer::ResetPlayerBuffer();
    EccoScoreBuffer::RegisterTimer();

    IsMapAllowed = true;
    array<string>@ aryMaps = IO::FileLineReader(szRootPath + EccoConfig::GetConfig()["Ecco.BaseConfig", "BanMapPath"].getString(), function(string szLine){ if(szLine != g_Engine.mapname){return "\n";}return g_Engine.mapname;});
    if(aryMaps.length() > 0 && aryMaps[aryMaps.length() - 1] == g_Engine.mapname)
        IsMapAllowed = false;

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
    if(IsMapAllowed){
        EccoBuyMenu::ReadScriptList();
        IsMapAllowed = !EccoBuyMenu::IsEmpty();
    }
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
            Logger::Chat(pPlayer, EccoConfig::GetConfig()["Ecco.BaseConfig", "BuyMenuName"].getString() + " " + EccoConfig::GetLocateMessage("LocaleNotAllowed", @pPlayer));
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
                Logger::Chat(pPlayer, EccoConfig::GetConfig()["Ecco.BaseConfig", "BuyMenuName"].getString() + " " + EccoConfig::GetLocateMessage("NullPointerMenu") + szPointer);
        }
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
    if(IsMapAllowed){
        EccoScoreBuffer::ResetPlayerBuffer(@pPlayer);
        EccoInventoryLoader::LoadPlayerInventory(@pPlayer);
        e_PlayerInventory.RefreshHUD(@pPlayer);
    }
    return HOOK_HANDLED;
}