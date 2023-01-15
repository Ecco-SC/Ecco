namespace EccoPlayerStorage{
    final class CPlayerStorageData{
        array<CPlayerStorageDataItem@> aryPlayerList = {};

        CPlayerStorageDataItem@ Get(string szSteamID){
            for(uint i = 0; i < aryPlayerList.length(); i++){
                if(aryPlayerList[i].szSteamID == szSteamID)
                    return aryPlayerList[i];
            }
            return null;
        }

        CPlayerStorageDataItem@ Get(CBasePlayer@ pPlayer){
            return Get(EccoPlayerInventory::GetUniquePlayerId(@pPlayer));
        }

        CPlayerStorageDataItem@ opIndex(string szSteamID){
            return Get(szSteamID);
        }

        CPlayerStorageDataItem@ opIndex(CBasePlayer@ pPlayer){
            return Get(pPlayer);
        }

        bool Exists(CBasePlayer@ pPlayer){
            return Get(@pPlayer) !is null;
        }

        void SetScore(CBasePlayer@ pPlayer, float flNew){
            Get(@pPlayer).flScore = flNew;
        }

        void Clear(){
            aryPlayerList = {};
        }

        void Add(CBasePlayer@ pPlayer){
            CPlayerStorageDataItem pItem;
                pItem.szSteamID = EccoPlayerInventory::GetUniquePlayerId(@pPlayer);
                pItem.flScore = 0;
                pItem.flObtained = 0;
                pItem.szLastPlayMap = g_Engine.mapname;
                pItem.pLastUpdateTime = DateTime();
            aryPlayerList.insertLast(pItem);
        }
    }
    final class CPlayerStorageDataItem{
        string szSteamID;
        EHandle pPlayer;
        float flScore;
        float flObtained;
        string szLastPlayMap;
        DateTime pLastUpdateTime;
    }
    CScheduledFunction@ RefreshScore;
    CPlayerStorageData pData;

    void ResetPlayerBuffer(CBasePlayer@ pPlayer){
        if(pData.Exists(@pPlayer))
            pData.SetScore(pPlayer, 0.0f);
        else
            pData.Add(pPlayer);
    }

    void ResetPlayerBuffer(){
        pData.Clear();
    }

    bool Exists(CBasePlayer@ pPlayer){
        return pData.Exists(pPlayer);
    }

    void RemoveTimer(){
        if(@RefreshScore !is null)
            g_Scheduler.RemoveTimer(@RefreshScore);
    }

    void RegisterTimer(){
        @RefreshScore = g_Scheduler.SetInterval("RefreshBuffer", EccoConfig::pConfig.BaseConfig.RefreshTimer, g_Scheduler.REPEAT_INFINITE_TIMES);
    }

    void RefreshBuffer(){
        float flConfigMultiplier = EccoConfig::pConfig.BaseConfig.ScoreToMoneyMultiplier;
        int iMaxLimitation = EccoConfig::pConfig.BaseConfig.ObtainMoneyPerMapMax;
        for(int i = 0; i <= g_Engine.maxClients; i++){
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
            if(pPlayer !is null){
                string szPlayerUniqueId = EccoPlayerInventory::GetUniquePlayerId(@pPlayer);
                if(!Exists(@pPlayer))
                    pData.Add(@pPlayer);
                
                CPlayerStorageDataItem@ pPlayerData = pData[szPlayerUniqueId];
                int iScoreChanged = int((int(pPlayer.pev.frags) - int(pPlayerData.flScore)) * flConfigMultiplier);
                if(iScoreChanged != 0 ){
                    if(iMaxLimitation > 0){
                        if(pPlayerData.flObtained + iScoreChanged < iMaxLimitation){
                            EccoPlayerInventory::ChangeBalance(pPlayer, iScoreChanged);
                            pPlayerData.flObtained += iScoreChanged;
                        }
                        else if(pPlayerData.flObtained < iMaxLimitation){
                            EccoPlayerInventory::ChangeBalance(pPlayer, int(iMaxLimitation - pPlayerData.flObtained));
                            pPlayerData.flObtained = iMaxLimitation;
                        }
                    }
                    else{
                        EccoPlayerInventory::ChangeBalance(pPlayer, iScoreChanged);
                        pPlayerData.flObtained += iScoreChanged;
                    }
                }
                pData.SetScore(pPlayer, pPlayer.pev.frags);
            }
        }
    }
}
