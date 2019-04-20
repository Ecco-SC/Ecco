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
namespace EccoBase{
  void Activate(){
    e_ScriptParser.Register("include", CustomMacro(Macro_include));
    e_ScriptParser.Register("money", CustomMacro(Macro_money));
    e_ScriptParser.Register("addinv", CustomMacro(Macro_addinv));
    e_ScriptParser.Register("delinv", CustomMacro(Macro_delinv));
    e_ScriptParser.Register("maxhealth", CustomMacro(Macro_maxhealth));
    e_ScriptParser.Register("maxarmor", CustomMacro(Macro_maxarmor));
    e_ScriptParser.Register("say", CustomMacro(Macro_say));
    e_ScriptParser.Register("broadcast", CustomMacro(Macro_broadcast));
    e_ScriptParser.Register("give", CustomMacro(Macro_give));
    e_ScriptParser.Register("log", CustomMacro(Macro_log));
    e_ScriptParser.Register("hurt", CustomMacro(Macro_hurt));
    e_ScriptParser.Register("heal", CustomMacro(Macro_heal));
    e_ScriptParser.Register("armor", CustomMacro(Macro_armor));
    e_ScriptParser.Register("maxspeed", CustomMacro(Macro_maxspeed));
    e_ScriptParser.Register("gravity", CustomMacro(Macro_gravity));
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
    g_Game.AlertMessage(at_console, "[ERROR - Ecco::Echo::EchoBase] " + string(ArgsAmount) + " argument(s) are not allowed for " + MacroName + "\n");
  }

  bool Macro_include(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        Success = e_ScriptParser.ExecuteFile("scripts/plugins/Ecco/scripts/" + args[0], pPlayer);
        break;
      case 2:
        Success = e_ScriptParser.ExecuteFile("scripts/plugins/Ecco/scripts/" + args[0], FindPlayerByName(args[1], pPlayer));
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
        e_PlayerInventory.ChangeBalance(pPlayer, atoi(args[0]));
        break;
      case 2:
        e_PlayerInventory.ChangeBalance(FindPlayerByName(args[1], pPlayer), atoi(args[0]));
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
        Success = e_PlayerInventory.AddInventory(pPlayer, args[0]);
        break;
      case 2:
        Success = e_PlayerInventory.AddInventory(FindPlayerByName(args[1], pPlayer), args[0]);
        break;
      default:
        ErrorInfo("addinv", args.length());
        Success = false;
    }
    if(!Success){
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, string(EccoConfig["LocaleAlreadyHave"])+"\n"); // TODO
    }
    return Success;
  }

  bool Macro_delinv(CBasePlayer@ pPlayer, array<string>@ args){
    bool Success = true;
    switch(args.length()){
      case 1:
        Success = e_PlayerInventory.RemoveInventory(pPlayer, args[0]);
        break;
      case 2:
        Success = e_PlayerInventory.RemoveInventory(FindPlayerByName(args[1], pPlayer), args[0]);
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
    CBasePlayer@ targetPlayer = null;
    switch(args.length()){
      case 1:
        if(pPlayer.HasNamedPlayerItem(args[0]) is null){
          pPlayer.GiveNamedItem(args[0], 0, 0);
        }else{
          g_EntityFuncs.Create(args[0], pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
        }
        break;
      case 2:
        @targetPlayer = FindPlayerByName(args[1], pPlayer);
        if(targetPlayer.HasNamedPlayerItem(args[0]) is null){
          targetPlayer.GiveNamedItem(args[0], 0, 0);
        }else{
          g_EntityFuncs.Create(args[0], targetPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
        }
        break;
      default:
        ErrorInfo("give", args.length());
        return false;
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
        pPlayer.m_flMaxSpeed = atof(args[0]);
        break;
      case 2:
        @targetPlayer = FindPlayerByName(args[1], pPlayer);
        targetPlayer.m_flMaxSpeed = atof(args[0]);
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
        pPlayer.m_flEffectGravity = atof(args[0]);
        break;
      case 2:
        @targetPlayer = FindPlayerByName(args[1], pPlayer);
        targetPlayer.m_flEffectGravity = atof(args[0]);
        break;
      default:
        ErrorInfo("gravity", args.length());
        return false;
    }
    return true;
  }
}