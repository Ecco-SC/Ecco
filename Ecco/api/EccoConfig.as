namespace EccoConfig{
    INIPraser::CINI@ pConfig = null;
    void RefreshEccoConfig(){
        @pConfig = INIPraser::CINI(szConfigPath + "Config.ini");
        if(pConfig is null)
            Logger::Log("[ERROR - Ecco] Cannot read the config file, check if it exists and SCDS has the permission to access it!");
    }
    INIPraser::CINI@ GetConfig(){
        return pConfig;
    }

    string GetLocateMessage(string szKey, CBasePlayer@ pPlayer, string szSection = "Ecco.LocaleSetting"){
        INIPraser::CINIItem@ pItem = pConfig[szSection, szKey];
        if(pItem !is null){
            if(@pPlayer !is null)
                return EccoProcessVar::ProcessVariables(pItem.getString(), @pPlayer);
            else
                return pItem.getString();
        }
        return "";
    }

    string GetLocateMessage(string szKey, CBaseMenuItem@ pMenuItem, string szSection = "Ecco.LocaleSetting"){
        INIPraser::CINIItem@ pItem = pConfig[szSection, szKey];
        if(pItem !is null){
            if(@pMenuItem !is null)
                return EccoProcessVar::ProcessVariables(pItem.getString(), @pMenuItem);
            else
                return pItem.getString();
        }
        return "";
    }

    string GetLocateMessage(string szKey, string szSection = "Ecco.LocaleSetting"){
        INIPraser::CINIItem@ pItem = pConfig[szSection, szKey];
        if(pItem !is null)
            return pItem.getString();
        return "";
    }
}