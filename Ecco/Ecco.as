#include "Include"

#include "core/ScoreToBalance"
#include "core/LoadInventory"
#include "core/BuyMenu"
#include "core/SmartPrecache"

const string szRootPath = "scripts/plugins/Ecco/Ecco/";
const string szStorePath = "scripts/plugins/store/";

bool IsMapAllowed;
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
	g_Module.ScriptInfo.SetContactInfo("Please Don't.");

    EccoProcessVar::Register("%PLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, pPlayer.pev.netname);});
    EccoProcessVar::Register("%RANDOMPLAYER%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, e_PlayerInventory.GetRandomPlayerName());});
    EccoProcessVar::Register("%BALANCE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, string(e_PlayerInventory.GetBalance(pPlayer)));});
    EccoProcessVar::Register("%SPACE%", function(string szInput, string szName, CBasePlayer@ pPlayer){ return szInput.Replace(szName, " ");});

    e_ScriptParser.BuildItemList();
}

void MapInit(){
    InitEcco();

    g_Game.PrecacheGeneric("sprites/misc/dollar.spr");
    SmartPrecache::PrecacheByList();

    EccoScoreBuffer::RegisterTimer();

    IsMapAllowed = true;
    array<string>@ aryMaps = IO::FileLineReader(szRootPath + "BannedMaps.txt", function(string szLine){ if(szLine != g_Engine.mapname){return "\n";}return g_Engine.mapname;});
    if(aryMaps.length() > 0 && aryMaps[aryMaps.length() - 1] == g_Engine.mapname)
        IsMapAllowed = false;

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
    if(IsMapAllowed){
        EccoBuyMenu::ReadScriptList();
        IsMapAllowed = !EccoBuyMenu::IsEmpty();
    }
}

HookReturnCode onChat(SayParameters@ pParams){
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    
    string arg = pParams.GetArguments()[0];
    if(pPlayer !is null && (arg.StartsWith("!") || arg.StartsWith("/"))){
        if(arg.SubString(1).ToLowercase() != "buy")
            return HOOK_CONTINUE;
         pParams.ShouldHide = true;
        if(!IsMapAllowed){
            Logger::Chat(pPlayer, string(EccoConfig["BuyMenuName"]) + " " + string(EccoConfig["LocaleNotAllowed"]));
            return HOOK_CONTINUE;
        }
        EccoBuyMenu::OpenBuyMenu(pPlayer);
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
    if(IsMapAllowed){
        EccoInventoryLoader::LoadPlayerInventory(pPlayer);
        EccoScoreBuffer::ResetPlayerBuffer(pPlayer);
        e_PlayerInventory.RefreshHUD(pPlayer);
    }
    return HOOK_HANDLED;
}