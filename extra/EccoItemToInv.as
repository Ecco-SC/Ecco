#include "Ecco/Include"

CScheduledFunction@ RefreshInv;
string InvPrefix = "Ecco::";
string InvDefaultDescription = "This is an Ecco item.";
string InvDescriptionSuffix = "[NOTE] Special Event! Now collect all 25 badges to get a secret special reward!";

dictionary PlayerInv;

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
}

void MapInit(){
  Precache();
  InitEcco();
  @RefreshInv = g_Scheduler.SetInterval("Timer_RefreshInv", 3, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void Precache(){
  g_Game.PrecacheGeneric("sprites/null.spr");
  g_Game.PrecacheGeneric("sound/tfc/items/itembk2.wav");
  g_SoundSystem.PrecacheSound("tfc/items/itembk2.wav");
}

void Timer_RefreshInv(){
  for(int i=0; i<g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer =  g_PlayerFuncs.FindPlayerByIndex(i+1);
    if(pPlayer !is null){
      array<string> LastList = cast<array<string>>(PlayerInv[GetUniquePlayerId(pPlayer)]);
      array<string> InvList = e_PlayerInventory.GetInventory(pPlayer);
      
      // Check Add
      for(uint j=0; j<InvList.length(); j++){
        if(LastList.find(InvList[j]) < 0){ // has new item InvList[j]
          CItemInventory@ pItem = CreateInvEntity(InvList[j]);
          pItem.pev.origin = pPlayer.pev.origin;
          pItem.Use(@pPlayer, @pPlayer, USE_TOGGLE, 0.0F);
        }
      }
      
      // Check Remove - NOT WORKING! Due to InventoryList has some problems I guess
      for(uint j=0; j<LastList.length(); j++){
        if(InvList.find(LastList[j]) < 0){ // has item LastList[j] removed
          InventoryList@ pInv = pPlayer.get_m_pInventory();
          while(pInv !is null){
            CBaseEntity@ pEnity = pInv.hItem;
            CItemInventory@ pItem = cast<CItemInventory@>(pEnity);
            if(pItem !is null){
              if(pItem.pev.globalname == LastList[j]){
                pItem.Destroy();
              }
            }
            @pInv = pInv.pNext;
          }
        }
      }
      
      PlayerInv[GetUniquePlayerId(pPlayer)] = InvList;
    }
  }
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  if(pPlayer !is null){
    array<string> InvList = e_PlayerInventory.GetInventory(pPlayer);
    for(uint i=0; i<InvList.length(); i++){
      CItemInventory@ pItem = CreateInvEntity(InvList[i]);
      pItem.pev.origin = pPlayer.pev.origin;
      pItem.Use(@pPlayer, @pPlayer, USE_TOGGLE, 0.0F);
    }
    PlayerInv[GetUniquePlayerId(pPlayer)] = InvList;
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
}

CItemInventory@ CreateInvEntity(string InvName){
  CBaseEntity@ pEntity = null;
  CItemInventory@ pTarget = null;
  while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "item_inventory")) !is null){
    if(pEntity.pev.globalname == InvPrefix + InvName){
      @pTarget = cast<CItemInventory>(pEntity);
      break;
    }
  }
  if(pTarget is null){
    string InvDescription = InvDefaultDescription + "\n" + InvDescriptionSuffix;
    dictionary ScriptInfo = e_ScriptParser.RetrieveInfo("scripts/plugins/Ecco/scripts/" + InvName + ".echo");
    if(ScriptInfo.exists("description")){
      InvDescription = string(ScriptInfo["description"]) + "\n" + InvDescriptionSuffix;
    }
    dictionary pDictionary = {
      {"display_name", InvPrefix + InvName},
      {"description", InvDescription},
      {"item_icon", "null.spr"},
      {"holder_can_drop", "0"},
      {"carried_hidden", "1"},
      {"globalname", InvPrefix + InvName}
    };
    @pTarget = cast<CItemInventory>(g_EntityFuncs.CreateEntity("item_inventory", @pDictionary, true));
  }
  return pTarget;
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