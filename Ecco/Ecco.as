#include "Include"

#include "core/ScoreToBalance"
#include "core/LoadInventory"
#include "core/BuyMenu"

bool IsMapAllowed;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
	g_Module.ScriptInfo.SetContactInfo("Please Don't.");
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
  InitEcco();
}

void MapInit(){
  Precache();
  EccoScoreBuffer::RegisterTimer();
  IsMapAllowed = true;
  
  File@ file = g_FileSystem.OpenFile("scripts/plugins/Ecco/BannedMaps.txt", OpenFile::READ);
  if(file !is null && file.IsOpen()){
    while(!file.EOFReached()){
      string sLine;
      file.ReadLine(sLine);
      if(sLine == g_Engine.mapname){
        IsMapAllowed = false;
        continue;
      }
    }
    file.Close();
  }
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
  if(IsMapAllowed){
    EccoBuyMenu::ReadScriptList();
    EccoBuyMenu::InitializeBuyMenu();
    IsMapAllowed = !EccoBuyMenu::IsEmpty();
  }
}

void Precache(){
  g_Game.PrecacheGeneric("sprites/misc/dollar.spr");
  g_Game.PrecacheGeneric("sprites/misc/deduct.spr");
  g_Game.PrecacheGeneric("sprites/misc/add.spr");
}


HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ cArgs = pParams.GetArguments();
  if(pPlayer !is null && (cArgs[0].ToLowercase() == "!buy" || cArgs[0].ToLowercase() == "/buy")){
    pParams.ShouldHide = true;
    if(IsMapAllowed){
      EccoBuyMenu::OpenBuyMenu(pPlayer);
      return HOOK_HANDLED;
    }else{
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, string(EccoConfig["BuyMenuName"]) + " " + string(EccoConfig["LocaleNotAllowed"]) +"\n");
    }
  }
  return HOOK_CONTINUE;
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  if(IsMapAllowed){
    EccoInventoryLoader::LoadPlayerInventory(pPlayer);
    EccoScoreBuffer::ResetPlayerBuffer(pPlayer);
  }
  e_PlayerInventory.RefreshHUD(pPlayer);
  return HOOK_HANDLED;
}