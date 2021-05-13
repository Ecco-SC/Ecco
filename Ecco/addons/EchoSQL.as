
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

    HookReturnCode SQLPostHook(CBasePlayer@ pPlayer, int iAmount){
        CPlayerData@ pData = GetPlayerData(@pPlayer);
        if(@pData is null)
            Logger::Chat(pPlayer, "[ECCO SQL]你没有同步到SQL消息！请尝试重新进入游戏！");
        else
            pData.Ecco = iAmount;
        return HOOK_CONTINUE;
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
        return cast<CPlayerData@>(dicPlayerData[e_PlayerInventory.GetUniquePlayerId(@pPlayer)]);
    }

    bool Exists(CBasePlayer@ pPlayer){
        return dicPlayerData.exists(e_PlayerInventory.GetUniquePlayerId(@pPlayer));
    }

    void BewareNotSync(EHandle pPlayer){
        if(pPlayer.IsValid()){
            Logger::Chat(cast<CBasePlayer@>(pPlayer.GetEntity()), "[ECCO SQL]你没有同步到SQL消息！请尝试重新进入游戏！");
            g_Scheduler.SetTimeout( "BewareNotSync", 1, pPlayer);
        }
    }

    HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer){
        string PlayerId = e_PlayerInventory.GetUniquePlayerId(@pPlayer);
        if(!dicPlayerData.exists(PlayerId))
            SQLDic(PlayerId);
        else{
            CPlayerData@ data = GetPlayerData(pPlayer);
            if(data is null)
                dicPlayerData.delete(PlayerId);
            if(data.UID != "0")
                g_Scheduler.SetTimeout("BewareNotSync", 1, EHandle(pPlayer));
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientConnected(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason){
        string PlayerId = e_PlayerInventory.GetUniquePlayerId(@pEntity);
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