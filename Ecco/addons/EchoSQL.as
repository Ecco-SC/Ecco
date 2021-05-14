
namespace EccoAddon{
namespace EccoSQL{
    class CPlayerData{
        string UID = "0";
        int Ecco = 0;
        string Add = "";
    }

    dictionary dicPlayerData = {};

    void PluginInit(){
        g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
        g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
        g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
        EccoHook::RegisterHook(EccoHook::Economy::PostChangeBalance, @SQLPostHook);
    }

    string GetAuthor(){
      return "Dr.Abc";
    }

    string GetContactInfo(){
        return "No person of the name";
    }

    void SQLQuery(string szID){
        File@ file = g_FileSystem.OpenFile( szStorePath + "SQLInput.txt" , OpenFile::WRITE);
        if(file !is null && file.IsOpen()){
            file.Write(szID);
            file.Close();
        }
    }

    void SQLWrite(){
        File@ file = g_FileSystem.OpenFile( szStorePath + "SQLChangeput.txt", OpenFile::WRITE);
        if(file !is null && file.IsOpen()){
            array<string>@ balancekey = dicPlayerData.getKeys();
            string op = "";
            for(uint i = 0;i < balancekey.length();i++){
                CPlayerData@ data = cast<CPlayerData@>(dicPlayerData[balancekey[i]]);
                if(data.UID != "0")
                    op += balancekey[i] + "," + data.Ecco + "," + data.Add + "\n";
            }
            file.Write(op);
            file.Close();
        }
        @file = g_FileSystem.OpenFile(szStorePath + "SQLFinish", OpenFile::WRITE);
            file.Write("");
        file.Close();
    }

    void SQLDic( string szID ){
        File@ file = g_FileSystem.OpenFile( szStorePath + "SQLOutput.txt", OpenFile::READ);
        if(file !is null && file.IsOpen()){
            while(!file.EOFReached()) {
                string sLine;
                file.ReadLine(sLine);
                    array<string>@ aryline = sLine.Split(",");
                if(sLine != "" && aryline[1] == szID)
                {
                    CPlayerData data;
                        data.UID = aryline[0];
                        data.Ecco = atoi(aryline[2]);
                        data.Add = aryline[3];
                    dicPlayerData[szID] = data;
                    break;
                }
                else
                    continue;
            }
            file.Close();
        }
    }

    CPlayerData@ GetPlayerData(CBasePlayer@ pPlayer){
        return cast<CPlayerData@>(dicPlayerData[g_EngineFuncs.GetPlayerAuthId(pPlayer.edict())]);
    }

    bool Exists(CBasePlayer@ pPlayer){
        return dicPlayerData.exists(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()));
    }

    void BewareNotSync(EHandle ePlayer, int time){
        int iMaxTry = 30;
        if(ePlayer.IsValid()){
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(ePlayer.GetEntity());
            Logger::Chat(@pPlayer, "[ECCO SQL]未获得SQL消息，尝试重新同步SQL消息中..(" + time + "/" + iMaxTry + ")");

            CPlayerData@ data = GetPlayerData(@pPlayer);
            if(data !is null && data.UID != "0"){
                e_PlayerInventory.SetBalance(@pPlayer, data.Ecco);
                Logger::Chat(@pPlayer, "[ECCO SQL]已同步SQL消息！");
            }
            else if(time >= iMaxTry)
                Logger::Chat(@pPlayer, "[ECCO SQL]同步到SQL消息失败！请尝试重新进入服务器！");
            else
                g_Scheduler.SetTimeout( "BewareNotSync", 1, ePlayer, time + 1);
        }
    }

    HookReturnCode SQLPostHook(CBasePlayer@ pPlayer, int iAmount){
        CPlayerData@ pData = GetPlayerData(@pPlayer);
        if(@pData is null)
            Logger::Chat(pPlayer, "[ECCO SQL]你没有同步到SQL消息！请尝试重新进入游戏！");
        else
            pData.Ecco = iAmount;
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer){
        string PlayerId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        CPlayerData@ data = null;
        if(!dicPlayerData.exists(PlayerId)){
            SQLDic(PlayerId);
            @data = GetPlayerData(pPlayer);
        }
        else{
            @data = GetPlayerData(pPlayer);
            if(data is null)
                dicPlayerData.delete(PlayerId);
            if(data.UID == "0")
                g_Scheduler.SetTimeout("BewareNotSync", 1, EHandle(pPlayer), 0);
        }
        if(data !is null){
            e_PlayerInventory.SetBalance(@pPlayer, data.Ecco);
            EccoPlayerStorage::ResetPlayerBuffer(@pPlayer);
            EccoInventoryLoader::LoadPlayerInventory(@pPlayer);
            e_PlayerInventory.RefreshHUD(@pPlayer);
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientConnected(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason){
        string PlayerId = g_EngineFuncs.GetPlayerAuthId(pEntity);
        string PlayerName = szPlayerName;
        if(!dicPlayerData.exists(PlayerId))
            SQLQuery(PlayerId + "," + PlayerName.Replace(",",""));
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
        SQLWrite();
        return HOOK_CONTINUE;
    }
}
}