#include "Ecco/Include"

dictionary PlayerJoined;
string LastNextMap = "";

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
}

void MapInit(){
  if(LastNextMap != g_Engine.mapname){
    PlayerJoined.deleteAll();
  }
  LastNextMap = GetNextMap();
  InitEcco();
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  if(pPlayer !is null){
    if(!PlayerJoined.exists(GetUniquePlayerId(pPlayer))){
      e_PlayerInventory.ChangeBalance(pPlayer, -e_PlayerInventory.GetBalance(pPlayer));
    }
    PlayerJoined.set(GetUniquePlayerId(pPlayer), true);
    return HOOK_HANDLED;
  }else{
    return HOOK_CONTINUE;
  }
}

string GetNextMap(){
  string nextMap = g_EngineFuncs.CVarGetString("mp_nextmap");
  if(nextMap == ""){
    nextMap = g_EngineFuncs.CVarGetString("mp_survival_nextmap");
  }
  return nextMap;
}

string GetUniquePlayerId(CBasePlayer@ pPlayer){
  string PlayerId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
  if(PlayerId == "STEAM_ID_LAN"){
    PlayerId = pPlayer.pev.netname;
  }else{
    PlayerId.Replace("STEAM_", "");
    PlayerId.Replace(":", "");
  }
  return PlayerId;
}