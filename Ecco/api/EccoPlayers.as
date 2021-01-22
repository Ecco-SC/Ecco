class EccoPlayerInventory{
  int GetBalance(CBasePlayer@ pPlayer){
    int Balance = 0;
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/Ecco-" + GetUniquePlayerId(pPlayer) + ".txt", OpenFile::READ);
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        if(sLine.Length() > 0){
          Balance = atoi(sLine);
          break;
        }
      }
      file.Close();
    }
    return Balance;
  }

  array<string> GetInventory(CBasePlayer@ pPlayer){
    array<string> Inventory = {};
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/Ecco-" + GetUniquePlayerId(pPlayer) + ".txt", OpenFile::READ);
    if(file !is null && file.IsOpen()){
      bool IsFirstLine = true;
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        if(IsFirstLine){
          IsFirstLine = false;
          continue;
        }else{
          if(sLine != "" && sLine.Find(";", 0) == String::INVALID_INDEX){
            Inventory.insertLast(sLine);
          }
        }
      }
      file.Close();
    }
    return Inventory;
  }

  dictionary RetrieveInfo(CBasePlayer@ pPlayer){
    dictionary UserInfo;
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/Ecco-" + GetUniquePlayerId(pPlayer) + ".txt", OpenFile::READ);
    string RandomScript = "";
    bool IsReadingRandom = false;
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        if(int(sLine.Length()) > 0){
          int FirstSymbol = int(sLine.FindFirstOf(";", 0));
          if(FirstSymbol <= 0 || FirstSymbol == int(sLine.Length())){
            continue;
          }else{
            string InfoName = sLine.SubString(0, FirstSymbol);
            InfoName.Replace(" ", "");
            string InfoContent = sLine.SubString(FirstSymbol);
            for(int i=1; i<int(InfoContent.Length()); i++){
              if(InfoContent[i] == " "){
                continue;
              }else{
                InfoContent = InfoContent.SubString(i);
                break;
              }
            }
            UserInfo.set(InfoName, InfoContent);
          }
        }
      }
      file.Close();
    }
    return UserInfo;
  }

  int ChangeBalance(CBasePlayer@ pPlayer, int Amount){
    int Balance = GetBalance(pPlayer);
    array<string> Inventory = GetInventory(pPlayer);
    Balance += Amount;
    dictionary PlayerInfo = RetrieveInfo(pPlayer);
    WriteInData(pPlayer, Balance, Inventory, PlayerInfo);
    
    if(Amount > 0){
      ShowScoringHUD(pPlayer, Amount);
    }
    if(Amount < 0){
      ShowDeductHUD(pPlayer, -Amount);
    }
    
    return Balance;
  }

  void SetInfo(CBasePlayer@ pPlayer, string Name, string Info){
    int Balance = GetBalance(pPlayer);
    array<string> Inventory = GetInventory(pPlayer);
    dictionary PlayerInfo = RetrieveInfo(pPlayer);
    PlayerInfo.set(Name, Info);
    
    WriteInData(pPlayer, Balance, Inventory, PlayerInfo);
  }

  bool RemoveInventory(CBasePlayer@ pPlayer, string ItemName){
    bool HasRemoved = false;
    int Balance = GetBalance(pPlayer);
    array<string> Inventory = GetInventory(pPlayer);
    int ItemPosition = Inventory.find(ItemName);
    if(ItemPosition >= 0){
      Inventory.removeAt(ItemPosition);
      HasRemoved = true;
    }
    dictionary PlayerInfo = RetrieveInfo(pPlayer);
    WriteInData(pPlayer, Balance, Inventory, PlayerInfo);
    
    return HasRemoved;
  }

  bool AddInventory(CBasePlayer@ pPlayer, string ItemName){
    int Balance = GetBalance(pPlayer);
    array<string> Inventory = GetInventory(pPlayer);
    if(Inventory.find(ItemName) >= 0){
      return false;
    }
    Inventory.insertLast(ItemName);
    dictionary PlayerInfo = RetrieveInfo(pPlayer);
    WriteInData(pPlayer, Balance, Inventory, PlayerInfo);
    return true;
  }
  
  void RefreshHUD(CBasePlayer@ pPlayer){
    int ConfigFlag = atoi(string(EccoConfig["ShowMoneyHUD"]));
    if(ConfigFlag == 1 || ConfigFlag == 2){
      if(pPlayer !is null){
        HUDNumDisplayParams params;
        int Balance = GetBalance(pPlayer);
        if(Balance >= 0){
          params.value = Balance;
          params.spritename = "misc/dollar.spr";
          params.color1 = RGBA_SVENCOOP;
        }else{
          params.value = -Balance;
          params.spritename = "misc/deduct.spr";
          params.color1 = RGBA_RED;
        }
        params.channel = 3;
        params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
        params.x = 0.5;
        params.y = 0.9;
        params.defdigits = 1;
        params.maxdigits = 6;
        g_PlayerFuncs.HudNumDisplay(pPlayer, params);
      }
    }
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

  private void WriteInData(CBasePlayer@ pPlayer, int Balance, array<string> Inventory, dictionary PlayerInfo){
    string Content = string(Balance);
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/Ecco-" + GetUniquePlayerId(pPlayer) + ".txt", OpenFile::WRITE);
    if(file !is null && file.IsOpen()){
      for(int i=0; i<int(Inventory.length()); i++){
        Content += "\n" + Inventory[i];
      }
      
      array<string> dictKeys = PlayerInfo.getKeys();
      for(int i=0; i<int(dictKeys.length()); i++){
        Content += "\n" + dictKeys[i] + "; " +string(PlayerInfo[dictKeys[i]]);
      }
      file.Write(Content);
      file.Close();
    }
  }

  private void ShowDeductHUD(CBasePlayer@ pPlayer, int amount){
    int ConfigFlag = atoi(string(EccoConfig["ShowMoneyHUD"]));
    if(ConfigFlag == 1 || ConfigFlag == 3){
      if(pPlayer !is null){
        HUDNumDisplayParams params;
        params.channel = 4;
        params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
        params.value = amount;
        params.fadeinTime = 0.15;
        params.holdTime = 1;
        params.fadeoutTime = 0.15;
        params.x = 0.5;
        params.y = 0.858;
        params.defdigits = 1;
        params.maxdigits = 4;
        params.color1 = RGBA_RED;
        params.spritename = "misc/deduct.spr";
        RefreshHUD(pPlayer);
        g_PlayerFuncs.HudNumDisplay(pPlayer, params);
      }
    }
  }

  private void ShowScoringHUD(CBasePlayer@ pPlayer, int amount){
    int ConfigFlag = atoi(string(EccoConfig["ShowMoneyHUD"]));
    if(ConfigFlag == 1 || ConfigFlag == 3){
      if(pPlayer !is null){
        HUDNumDisplayParams params;
        params.channel = 4;
        params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
        params.value = amount;
        params.fadeinTime = 0.15;
        params.holdTime = 1;
        params.fadeoutTime = 0.15;
        params.x = 0.5;
        params.y = 0.855;
        params.defdigits = 1;
        params.maxdigits = 4;
        params.color1 = RGBA_GREEN;
        params.spritename = "misc/add.spr";
        RefreshHUD(pPlayer);
        g_PlayerFuncs.HudNumDisplay(pPlayer, params);
      }
    }
  }
  
  CBasePlayer@ FindPlayerById(string UniquePlayerId){
    CBasePlayer@ pPlayer;
    int pCount=g_PlayerFuncs.GetNumPlayers();
    for(int i=1;i<=pCount;i++)
    {
      @pPlayer=g_PlayerFuncs.FindPlayerByIndex(i);
      if ( pPlayer !is null && pPlayer.IsConnected() )
      {
        if(GetUniquePlayerId(pPlayer)==UniquePlayerId)
        {
          break;
        }
        else
        {
          @pPlayer=null;
        }
      }
    }
    return pPlayer;
  }
}

EccoPlayerInventory e_PlayerInventory;