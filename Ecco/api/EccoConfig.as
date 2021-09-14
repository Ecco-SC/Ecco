namespace EccoConfig{
    INIPraser::CINI@ pConfig = null;
    bool RefreshEccoConfig(){
        File @pFile = g_FileSystem.OpenFile(szConfigPath + "Config.ini", OpenFile::READ);
        if(@pFile is null){
            Logger::Log("[CRITICAL]Cannot read the config file, check if it exists and SCDS has the permission to access it!\n\tReading path: " + szConfigPath + "Config.ini\n\tEcco aborted loading.");
            return false;
        }
        else
            @pConfig = INIPraser::CINI(szConfigPath + "Config.ini");
        return true;
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