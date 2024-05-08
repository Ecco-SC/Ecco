/*

  Useful Variables:
  %PLAYER%   %RANDOMPLAYER%   %BALANCE%
  
  Commands:
  include [script name] (playername) - Execute another script (as the player or as someone else)
  money [amount] (playername) - Change someone's balance;
  addinv [script name] (playername)- Add some script to player's inventory, which, however, executes every time player joins
  delinv [script name] (playername)- Remove some script from player's inventory, which, however, executes every time player joins
  maxhealth [amount] (playername)- Set a player's max health.
  maxarmor [amount] (playername)- Set a player's max armor.
  say [text] - Say something in player's chat box.
  broadcast [text] - Say something in everyone's chat box.
  give [classname] (playername) - Give player a weapon / an item.
  log [text] - Log the following content to the server.
  hurt (damage) (playername)  - Kill or hurt a player
  heal (amount) (playername)  - Heal or completely heal a player
  armor (amount) (playername) - Charge or fully charge a player's armor
  maxspeed [float value] (playername)  - Set a player's max speed.
  gravity [float value] (playername) - Set a player's gravity.
  
*/
namespace EccoAddon{
namespace EccoBase{
  void PluginInit(){
    EccoScriptParser::Register(CEccoMarco("include", Macro_include));
    EccoScriptParser::Register(CEccoMarco("money", Macro_money));
    EccoScriptParser::Register(CEccoMarco("addinv", Macro_addinv));
    EccoScriptParser::Register(CEccoMarco("delinv", Macro_delinv));
    EccoScriptParser::Register(CEccoMarco("maxhealth", Macro_maxhealth));
    EccoScriptParser::Register(CEccoMarco("maxarmor", Macro_maxarmor));
    EccoScriptParser::Register(CEccoMarco("say", Macro_say));
    EccoScriptParser::Register(CEccoMarco("broadcast", Macro_broadcast));
    EccoScriptParser::Register(CEccoMarco("give", Macro_give));
    EccoScriptParser::Register(CEccoMarco("log", Macro_log));
    EccoScriptParser::Register(CEccoMarco("hurt", Macro_hurt));
    EccoScriptParser::Register(CEccoMarco("heal", Macro_heal));
    EccoScriptParser::Register(CEccoMarco("armor", Macro_armor));
    EccoScriptParser::Register(CEccoMarco("maxspeed", Macro_maxspeed));
    EccoScriptParser::Register(CEccoMarco("gravity", Macro_gravity));
  }

  string GetAuthor(){
      return "Paranoid_AF";
  }

  string GetContactInfo(){
      return "Please don't";
  }

  CBasePlayer@ FindPlayerByName(string Name, CBasePlayer@ Default){
    CBasePlayer@ pPlayer = null;
    for(int i=1; i<=g_Engine.maxClients; i++){
      @pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
      if(pPlayer !is null){
        if(pPlayer.pev.netname == Name){
          break;
        }
      }
    }
    if(pPlayer !is null){
      return pPlayer;
    }else{
      return Default;
    }
  }

  void ErrorInfo(string MacroName, int ArgsAmount){
    Logger::Log("[ERROR - Ecco::Echo::EchoBase] " + string(ArgsAmount) + " argument(s) are not allowed for " + MacroName);
  }

  bool Macro_include(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        Success = EccoScriptParser::ExecuteFile("scripts/plugins/Ecco/scripts/" + args[0] + ".echo", pPlayer);
        break;
      case 2:
        Success = EccoScriptParser::ExecuteFile("scripts/plugins/Ecco/scripts/" + args[0] + ".echo", FindPlayerByName(args[1], pPlayer));
        break;
      default:
        ErrorInfo("include", args.length());
        Success =  false;
    }
    return Success;
  }
  
  bool Macro_money(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        EccoPlayerInventory::ChangeBalance(pPlayer, atoi(args[0]));
        break;
      case 2:
        EccoPlayerInventory::ChangeBalance(FindPlayerByName(args[1], pPlayer), atoi(args[0]));
        break;
      default:
        ErrorInfo("money", args.length());
        Success = false;
    }
    return Success;
  }

  bool Macro_addinv(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        Success = EccoPlayerInventory::AddInventory(pPlayer, args[0]);
        break;
      case 2:
        Success = EccoPlayerInventory::AddInventory(FindPlayerByName(args[1], pPlayer), args[0]);
        break;
      default:
        ErrorInfo("addinv", args.length());
        Success = false;
    }
    if(!Success)
      Logger::Chat(pPlayer,EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.LocaleAlreadyHave, @pPlayer));
    return Success;
  }

  bool Macro_delinv(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        Success = EccoPlayerInventory::RemoveInventory(pPlayer, args[0]);
        break;
      case 2:
        Success = EccoPlayerInventory::RemoveInventory(FindPlayerByName(args[1], pPlayer), args[0]);
        break;
      default:
        ErrorInfo("delinv", args.length());
        Success = false;
    }
    return Success;
  }

  bool Macro_maxhealth(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ Check = null;
    switch(args.length()){
      case 1:
        pPlayer.pev.max_health = atoi(args[0]);
        break;
      case 2:
        @Check = FindPlayerByName(args[1], pPlayer);
        Check.pev.max_health = atoi(args[0]);
        break;
      default:
        ErrorInfo("maxhealth", args.length());
        return false;
    }
    return true;
  }

  bool Macro_maxarmor(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ Check = null;
    switch(args.length()){
      case 1:
        pPlayer.pev.armortype = atoi(args[0]);
        break;
      case 2:
        @Check = FindPlayerByName(args[1], pPlayer);
        Check.pev.armortype = atoi(args[0]);
        break;
      default:
        ErrorInfo("maxarmor", args.length());
        return false;
    }
    return true;
  }
 
  bool Macro_say(CBasePlayer@ pPlayer, array<string>@ args){
    string Content = "";
    for(int i=0; i<int(args.length()); i++){
      Content += args[i] + " ";
    }
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, Content+"\n");
    return true;
  }
  
  bool Macro_broadcast(CBasePlayer@ pPlayer, array<string>@ args){
    string Content = "";
    for(int i=0; i<int(args.length()); i++){
      Content += args[i] + " ";
    }
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, Content+"\n");
    return true;
  }
  
    bool Macro_give(CBasePlayer@ pPlayer, array<string>@ args){
        CBasePlayer@ tPlayer = null;
        switch(args.length()){
            case 1: @tPlayer = pPlayer; break;
            case 2: @tPlayer = FindPlayerByName(args[1], pPlayer); break;
            default: ErrorInfo("give", args.length()); return false;
        }
        if(@tPlayer !is null){
            if(tPlayer.HasNamedPlayerItem(args[0]) !is null){
                if(!EccoConfig::pConfig.BuyMenu.AllowBuyOwned){
                    Logger::Chat(pPlayer,EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.LocaleAlreadyHave, @pPlayer));
                    return false;
                }
                else{
                    if(EccoConfig::pConfig.BuyMenu.GenerateOwnedReplica)
                        g_EntityFuncs.Create(args[0], tPlayer.GetOrigin(), g_vecZero, false).KeyValue("m_flCustomRespawnTime", "-1");
                    else
                        tPlayer.GiveNamedItem(args[0], 0, 0);
                }
            }
            else
                tPlayer.GiveNamedItem(args[0], 0, 0);
        }
        return true;
    }

  bool Macro_log(CBasePlayer@ pPlayer, array<string>@ args){
    string Content = "";
    for(int i=0; i<int(args.length()); i++){
      Content += args[i] + " ";
    }
    g_Log.PrintF("[MACRO - Ecco::Echo] "+Content+"\n");
    return true;
  }

  bool Macro_hurt(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ Check = null;
    switch(args.length()){
      case 0:
        pPlayer.pev.health = 0;
        pPlayer.Killed(pPlayer.pev, GIB_NORMAL);
        break;
      case 1:
        @Check = FindPlayerByName(args[0], Check);
        if(Check is null){
          pPlayer.pev.health -= atoi(args[0]);
          if(pPlayer.pev.health <= 0){
            pPlayer.Killed(pPlayer.pev, GIB_NORMAL);
          }
        }else{
          Check.pev.health = 0;
          Check.Killed(Check.pev, GIB_NORMAL);
        }
        break;
      case 2:
        @Check = FindPlayerByName(args[1], pPlayer);
        Check.pev.health -= atoi(args[0]);
        if(Check.pev.health <= 0){
          Check.Killed(Check.pev, GIB_NORMAL);
        }
        break;
      default:
        ErrorInfo("hurt", args.length());
        return false;
    }
    return true;
  }

  bool Macro_heal(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ Check = null;
    switch(args.length()){
      case 0:
        pPlayer.pev.health = pPlayer.pev.max_health;
        break;
      case 1:
        @Check = FindPlayerByName(args[0], Check);
        if(Check is null){
          pPlayer.pev.health += atoi(args[0]);
        }else{
          Check.pev.health = Check.pev.max_health;
        }
        break;
      case 2:
        @Check = FindPlayerByName(args[1], pPlayer);
        Check.pev.health += atoi(args[0]);
        break;
      default:
        ErrorInfo("heal", args.length());
        return false;
    }
    return true;
  }
  
  bool Macro_armor(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ Check = null;
    switch(args.length()){
      case 0:
        pPlayer.pev.armorvalue = pPlayer.pev.armortype;
        break;
      case 1:
        @Check = FindPlayerByName(args[0], Check);
        if(Check is null){
          pPlayer.pev.armorvalue += atoi(args[0]);
        }else{
          Check.pev.armorvalue = Check.pev.armortype;
        }
        break;
      case 2:
        @Check = FindPlayerByName(args[1], pPlayer);
        Check.pev.armorvalue += atoi(args[0]);
        break;
      default:
        ErrorInfo("armor", args.length());
        return false;
    }
    return true;
  }
  
  bool Macro_maxspeed(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ targetPlayer = null;
    switch(args.length()){
      case 1:
        pPlayer.SetMaxSpeedOverride(int(atof(args[0])));
        pPlayer.m_flEffectSpeed = atof(args[0]);
        break;
      case 2:
        @targetPlayer = FindPlayerByName(args[1], pPlayer);
        targetPlayer.SetMaxSpeedOverride(int(atof(args[0])));
        targetPlayer.m_flEffectSpeed = atof(args[0]);
        break;
      default:
        ErrorInfo("maxspeed", args.length());
        return false;
    }
    return true;
  }
  
  bool Macro_gravity(CBasePlayer@ pPlayer, array<string>@ args){
    CBasePlayer@ targetPlayer = null;
    switch(args.length()){
      case 1:
        pPlayer.pev.gravity = atof(args[0]) / 100.0f;
        break;
      case 2:
        @targetPlayer = FindPlayerByName(args[1], pPlayer);
        targetPlayer.pev.gravity = atof(args[0]) / 100.0f;
        break;
      default:
        ErrorInfo("gravity", args.length());
        return false;
    }
    return true;
  }
}
}