class EccoPlayerInventory{
    CBasePlayer@ GetRandomPlayer(){
        if(g_PlayerFuncs.GetNumPlayers() > 0){
            CBasePlayer@ pPlayer = null;
            while(pPlayer is null){
                int Index = int(Math.RandomLong(1, g_Engine.maxClients));
                @pPlayer = g_PlayerFuncs.FindPlayerByIndex(Index);
            }
            return @pPlayer;
        }
        return null;
    }

    string GetRandomPlayerName(){
        CBasePlayer@ pPlayer = GetRandomPlayer();
        if(pPlayer !is null)
            return pPlayer.pev.netname;
        return "";
    }

    int GetBalance(CBasePlayer@ pPlayer){
        array<string>@ aryLine = IO::FileLineReader(szStorePath + GetUniquePlayerId(pPlayer) + ".txt");
        if(aryLine.length() > 0 && !aryLine[0].IsEmpty())
            return atoi(aryLine[0]);
        return 0;
    }

    array<string>@ GetInventory(CBasePlayer@ pPlayer){
        array<string>@ aryLine = IO::FileLineReader(szStorePath + GetUniquePlayerId(pPlayer) + ".txt");
        if(aryLine.length() > 0)
            aryLine.removeAt(0);
        return aryLine;
    }

    dictionary RetrieveInfo(CBasePlayer@ pPlayer){
        dictionary UserInfo = {};
        array<string>@ aryLine = Utility::Select(IO::FileLineReader(szStorePath + GetUniquePlayerId(pPlayer) + ".txt"), function(string szLine){return !szLine.IsEmpty();});
        for(uint i = 0; i < aryLine.length(); i++){
            string sLine = aryLine[i];
            int FirstSymbol = int(sLine.FindFirstOf(";", 0));
            if(FirstSymbol <= 0 || FirstSymbol == int(sLine.Length()))
                continue;
            else{
                string InfoName = sLine.SubString(0, FirstSymbol);
                InfoName.Trim();
                string InfoContent = sLine.SubString(FirstSymbol);
                InfoContent.Trim();
                UserInfo.set(InfoName, InfoContent);
            }
        }
        return UserInfo;
    }

    void SetBalance(CBasePlayer@ pPlayer, int Amount){
        bool bFlag = true;
        EccoHook::PreChangeBalance(pPlayer, Amount, bFlag);
        if(bFlag){
            WriteInData(pPlayer, Amount);
            if(pConfig.BaseConfig.SaveInKeyvalue)
                g_EngineFuncs.GetPhysicsKeyBuffer(pPlayer.edict()).kv.SetValue(pConfig.BaseConfig.SaveInKeyvalueKey, Amount);
            EccoHook::PostChangeBalance(pPlayer, Amount);
        }
    }
    int ChangeBalance(CBasePlayer@ pPlayer, int Amount){
        int iBalance = GetBalance(pPlayer) + Amount;
        SetBalance(@pPlayer, iBalance);
        ShowHUD(@pPlayer, Amount);
        return iBalance;
    }

    void SetInfo(CBasePlayer@ pPlayer, string Name, string Info){
        dictionary PlayerInfo = RetrieveInfo(pPlayer);
        PlayerInfo.set(Name, Info);
        WriteInData(pPlayer, PlayerInfo);
    }

    bool RemoveInventory(CBasePlayer@ pPlayer, string ItemName){
        bool HasRemoved = false;
        array<string>@ Inventory = GetInventory(pPlayer);
        int ItemPosition = Inventory.find(ItemName);
        if(ItemPosition >= 0){
            Inventory.removeAt(ItemPosition);
            HasRemoved = true;
        }
        WriteInData(pPlayer, Inventory);
        return HasRemoved;
    }

    bool AddInventory(CBasePlayer@ pPlayer, string ItemName){
        array<string> Inventory = GetInventory(pPlayer);
        if(Inventory.find(ItemName) >= 0){
            return false;
        }
        Inventory.insertLast(ItemName);
        WriteInData(pPlayer, Inventory);
        return true;
    }
    
    void RefreshHUD(CBasePlayer@ pPlayer){
        if(pPlayer !is null){
            switch(EccoConfig::pConfig.BaseConfig.ShowMoneyHUD){
                case 1:
                case 2:{
                    HUDNumDisplayParams params;
                    int iBalance = GetBalance(pPlayer);
                    params.spritename = EccoConfig::pConfig.BaseConfig.MoneyIconPath;
                    params.color1 = 
                        iBalance >= 0 ? EccoConfig::pConfig.BaseConfig.MoneyIconPositiveColor : 
                                        EccoConfig::pConfig.BaseConfig.MoneyIconNegativeColor;
                    params.value = iBalance;
                    params.channel = 3;
                    params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_NEGATIVE_NUMBERS ;
                    params.x = EccoConfig::pConfig.BaseConfig.HUDMainPostion.x;
                    params.y = EccoConfig::pConfig.BaseConfig.HUDMainPostion.y;
                    params.defdigits = 1;
                    params.maxdigits = 12;
                    g_PlayerFuncs.HudNumDisplay(pPlayer, params);
                }
                default:break;
            }
        }
    }
    
    string FormmatSteamID(string szID){
        switch(EccoConfig::pConfig.BaseConfig.SteamIDFormmat){
            case 1: return szID;
            case 2: return g_SteamIDHelper.toCommunity(szID);
            case 3: return szID.SubString(6).Replace(":", "");
        }
        return string(g_SteamIDHelper.to64(szID));
    }
    string GetUniquePlayerId(CBasePlayer@ pPlayer){
        string szPlayerId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        return szPlayerId == "STEAM_ID_LAN" ? string(pPlayer.pev.netname) : FormmatSteamID(szPlayerId);
    }

    string GetUniquePlayerId(edict_t@ pPlayer){
        string szPlayerId = g_EngineFuncs.GetPlayerAuthId(pPlayer);
        return szPlayerId == "STEAM_ID_LAN" ? string(pPlayer.vars.netname) : FormmatSteamID(szPlayerId);
    }

    private void WriteInData(CBasePlayer@ pPlayer, int Balance){
        WriteInData(pPlayer, Balance, GetInventory(pPlayer), RetrieveInfo(pPlayer));
    }

    private void WriteInData(CBasePlayer@ pPlayer, array<string>@ Inventory){
        WriteInData(pPlayer, GetBalance(pPlayer), Inventory, RetrieveInfo(pPlayer));
    }

    private void WriteInData(CBasePlayer@ pPlayer, dictionary PlayerInfo){
        WriteInData(pPlayer, GetBalance(pPlayer), GetInventory(pPlayer), PlayerInfo);
    }

    private void WriteInData(CBasePlayer@ pPlayer, int Balance, array<string>@ Inventory, dictionary PlayerInfo){
        string Content = string(Balance);
        for(uint i=0; i < Inventory.length(); i++){
            Content += "\n" + Inventory[i];
        }
        
        array<string> dictKeys = PlayerInfo.getKeys();
        for(uint i=0; i < dictKeys.length(); i++){
            Content += "\n" + dictKeys[i] + "; " +string(PlayerInfo[dictKeys[i]]);
        }
        IO::FileWriter(szStorePath + GetUniquePlayerId(pPlayer) + ".txt", Content);
    }

    void ShowHUD(CBasePlayer@ pPlayer, int amount){
        if(pPlayer !is null){
            switch(EccoConfig::pConfig.BaseConfig.ShowMoneyHUD){
                case 1:
                case 3:{
                    HUDNumDisplayParams params;
                    params.channel = 4;
                    params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA | HUD_NUM_PLUS_SIGN | HUD_NUM_NEGATIVE_NUMBERS;
                    params.value = amount;
                    params.fadeinTime = 0.15;
                    params.holdTime = 1;
                    params.fadeoutTime = 0.15;
                    params.x = EccoConfig::pConfig.BaseConfig.HUDValueChangePostion.x;
                    params.y = EccoConfig::pConfig.BaseConfig.HUDValueChangePostion.y;
                    params.defdigits = 1;
                    params.maxdigits = 8;
                    params.color1 = 
                        amount < 0 ? EccoConfig::pConfig.BaseConfig.MoneyIconDecreaseColor : 
                                    EccoConfig::pConfig.BaseConfig.MoneyIconIncreaseColor;
                    g_PlayerFuncs.HudNumDisplay(pPlayer, params);
                    RefreshHUD(pPlayer);
                }
                default:break;
            }
        }
    }

    CBasePlayer@ FindPlayerById(string UniquePlayerId){
        CBasePlayer@ pPlayer = null;
        for(int i = 1; i <= g_PlayerFuncs.GetNumPlayers(); i++){
            @pPlayer=g_PlayerFuncs.FindPlayerByIndex(i);
            if ( pPlayer !is null && pPlayer.IsConnected()){
                if(GetUniquePlayerId(pPlayer) == UniquePlayerId)
                    break;
            }
        }
        return pPlayer;
    }
}
EccoPlayerInventory e_PlayerInventory;