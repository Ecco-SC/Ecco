namespace EccoConfig{
    class CBaseConfig{
        string BuyMenuName = "[Ecco]";
        string BuyMenuDescription = "[ Ecco - Supply Store ]";
        uint ShowMoneyHUD = 1;
        Vector2D HUDMainPostion(0.5, 0.9);
        Vector2D HUDValueChangePostion(0.5, 0.858);
        float ScoreToMoneyMultiplier=1.0;
        float RefreshTimer=0.3;
        string PluginsRootPath="scripts/plugins/Ecco/";
        string PluginsStorePath="scripts/plugins/store/Ecco/";
        string BanMapPath="config/BannedMaps.txt";
        string SmartPrecachePath="config/Precache.txt";
        string ScriptsPath="config/Scripts.txt";
        string MoneyIconPath="misc/dollar.spr";
        RGBA MoneyIconPositiveColor(100, 130, 200, 255);
        RGBA MoneyIconNegativeColor(255, 0, 0, 255);
        RGBA MoneyIconIncreaseColor(0, 255, 0, 255);
        RGBA MoneyIconDecreaseColor(255, 0, 0, 255);
        uint StorePlayerScore=1;
        int PlayerStartScore=0;
        uint SereisMapCheckMethod=2;
        float SereisMapLCSCheckRatio=0.65;
        int ClearMaintenanceTimeMax=43200;
        int ObtainMoneyPerMapMax=-1;
        uint SteamIDFormmat=0;
        bool SaveInKeyvalue=false;
        string SaveInKeyvalueKey="ecco_value";
    }
    class CBuyMenu{
        string RootNodeName="root";
        string OpenShopTrigger="buy";
        bool UseBlurMatchForArgs=true;
        bool AllowDeathPlayerBuy=true;
        bool ReOpenMenuAfterParamBuy=false;
        bool GenerateOwnedReplica=true;
        bool AllowBuyOwned=true;
    }
    class CLocaleSetting{
        string ItemDisplayFormat="%MENUNAME% - %COST%";
        string LocaleAlreadyHave=" [ - 已持有该物品 - ]";
        string LocaleNotAllowed=" [ - 此地图已禁用购物功能 - ]";
        string CannotAffordPrice="你的资金不够购买该物品,你只有$%BALANCE%.";
        string BackPreviousMenu="Back to Previous";
        string NullPointerMenu="无法找到菜单: ";
        string PluginReloaded=" [ - 插件已重载,将禁用购买功能,换图恢复 - ]";
        string EmptyBuyList=" [ - 购买列表为空 - ]";
        string ChatLogTitle="[Ecco菜单]";
        string RefuseDiedPlyaerBuy=" [ - 你已经是个死人了 - ]";
    }
    class CEcco{
        CBaseConfig BaseConfig;
        CBuyMenu BuyMenu;
        CLocaleSetting LocaleSetting;
    }
     INIPraser::CINI@ pINI = null;
     CEcco pConfig;

    void FillINIToConfig(){
        pConfig.BaseConfig.BuyMenuName = pINI["Ecco.BaseConfig", "BuyMenuName"].getString();
        pConfig.BaseConfig.BuyMenuDescription = pINI["Ecco.BaseConfig", "BuyMenuDescription"].getString();
        pConfig.BaseConfig.ShowMoneyHUD = pINI["Ecco.BaseConfig", "ShowMoneyHUD"].getInt();
        pConfig.BaseConfig.HUDMainPostion = pINI["Ecco.BaseConfig", "HUDMainPostion"].getVector2D();
        pConfig.BaseConfig.HUDValueChangePostion = pINI["Ecco.BaseConfig", "HUDValueChangePostion"].getVector2D();
        pConfig.BaseConfig.ScoreToMoneyMultiplier = pINI["Ecco.BaseConfig", "ScoreToMoneyMultiplier"].getFloat();
        pConfig.BaseConfig.RefreshTimer = pINI["Ecco.BaseConfig", "RefreshTimer"].getFloat();
        pConfig.BaseConfig.PluginsRootPath = pINI["Ecco.BaseConfig", "PluginsRootPath"].getString();
        pConfig.BaseConfig.PluginsStorePath = pINI["Ecco.BaseConfig", "PluginsStorePath"].getString();
        pConfig.BaseConfig.BanMapPath = pINI["Ecco.BaseConfig", "BanMapPath"].getString();
        pConfig.BaseConfig.SmartPrecachePath = pINI["Ecco.BaseConfig", "SmartPrecachePath"].getString();
        pConfig.BaseConfig.ScriptsPath = pINI["Ecco.BaseConfig", "ScriptsPath"].getString();
        pConfig.BaseConfig.MoneyIconPath = pINI["Ecco.BaseConfig", "MoneyIconPath"].getString();
        pConfig.BaseConfig.MoneyIconPositiveColor = pINI["Ecco.BaseConfig", "MoneyIconPositiveColor"].getRGBA();
        pConfig.BaseConfig.MoneyIconNegativeColor = pINI["Ecco.BaseConfig", "MoneyIconNegativeColor"].getRGBA();
        pConfig.BaseConfig.MoneyIconIncreaseColor = pINI["Ecco.BaseConfig", "MoneyIconIncreaseColor"].getRGBA();
        pConfig.BaseConfig.MoneyIconDecreaseColor = pINI["Ecco.BaseConfig", "MoneyIconDecreaseColor"].getRGBA();
        pConfig.BaseConfig.StorePlayerScore = pINI["Ecco.BaseConfig", "StorePlayerScore"].getInt();
        pConfig.BaseConfig.PlayerStartScore = pINI["Ecco.BaseConfig", "PlayerStartScore"].getInt();
        pConfig.BaseConfig.SereisMapCheckMethod = pINI["Ecco.BaseConfig", "SereisMapCheckMethod"].getInt();
        pConfig.BaseConfig.SereisMapLCSCheckRatio = pINI["Ecco.BaseConfig", "SereisMapLCSCheckRatio"].getFloat();
        pConfig.BaseConfig.ClearMaintenanceTimeMax = pINI["Ecco.BaseConfig", "ClearMaintenanceTimeMax"].getInt();
        pConfig.BaseConfig.ObtainMoneyPerMapMax = pINI["Ecco.BaseConfig", "ObtainMoneyPerMapMax"].getInt();
        pConfig.BaseConfig.SteamIDFormmat = pINI["Ecco.BaseConfig", "SteamIDFormmat"].getInt();
        pConfig.BaseConfig.SaveInKeyvalue = pINI["Ecco.BaseConfig", "SaveInKeyvalue"].getBool();
        pConfig.BaseConfig.SaveInKeyvalueKey = pINI["Ecco.BaseConfig", "SaveInKeyvalueKey"].getString();

        pConfig.BuyMenu.RootNodeName = pINI["Ecco.BuyMenu", "RootNodeName"].getString();
        pConfig.BuyMenu.OpenShopTrigger = pINI["Ecco.BuyMenu", "OpenShopTrigger"].getString();
        pConfig.BuyMenu.UseBlurMatchForArgs = pINI["Ecco.BuyMenu", "UseBlurMatchForArgs"].getBool();
        pConfig.BuyMenu.AllowDeathPlayerBuy = pINI["Ecco.BuyMenu", "AllowDeathPlayerBuy"].getBool();
        pConfig.BuyMenu.ReOpenMenuAfterParamBuy = pINI["Ecco.BuyMenu", "ReOpenMenuAfterParamBuy"].getBool();
        pConfig.BuyMenu.GenerateOwnedReplica = pINI["Ecco.BuyMenu", "GenerateOwnedReplica"].getBool();
        pConfig.BuyMenu.AllowBuyOwned = pINI["Ecco.BuyMenu", "AllowBuyOwned"].getBool();

        pConfig.LocaleSetting.ItemDisplayFormat = pINI["Ecco.LocaleSetting", "ItemDisplayFormat"].getString();
        pConfig.LocaleSetting.LocaleAlreadyHave = pINI["Ecco.LocaleSetting", "LocaleAlreadyHave"].getString();
        pConfig.LocaleSetting.LocaleNotAllowed = pINI["Ecco.LocaleSetting", "LocaleNotAllowed"].getString();
        pConfig.LocaleSetting.CannotAffordPrice = pINI["Ecco.LocaleSetting", "CannotAffordPrice"].getString();
        pConfig.LocaleSetting.BackPreviousMenu = pINI["Ecco.LocaleSetting", "BackPreviousMenu"].getString();
        pConfig.LocaleSetting.NullPointerMenu = pINI["Ecco.LocaleSetting", "NullPointerMenu"].getString();
        pConfig.LocaleSetting.PluginReloaded = pINI["Ecco.LocaleSetting", "PluginReloaded"].getString();
        pConfig.LocaleSetting.EmptyBuyList = pINI["Ecco.LocaleSetting", "EmptyBuyList"].getString();
        pConfig.LocaleSetting.ChatLogTitle = pINI["Ecco.LocaleSetting", "ChatLogTitle"].getString();
        pConfig.LocaleSetting.RefuseDiedPlyaerBuy = pINI["Ecco.LocaleSetting", "RefuseDiedPlyaerBuy"].getString();
    }

    bool RefreshEccoConfig(){
        File @pFile = g_FileSystem.OpenFile(szConfigPath + "Config.ini", OpenFile::READ);
        if(@pFile is null){
            Logger::Log("\n[CRITICAL]Cannot read the config file, check if it exists and SCDS has the permission to access it!\n
                \tReading path: " + szConfigPath + "Config.ini\n
                \tEcco aborted loading.");
            return false;
        }
        else{
            @pINI = INIPraser::CINI(szConfigPath + "Config.ini");
            try{
                FillINIToConfig();
            }
            catch{
                Logger::Log("\n[CRITICAL]Meet error when filling the config file! check the config file version and syntax!\n
                    \tReading path: " + szConfigPath + "Config.ini\n
                    \tPluginVersion: " + IO::FileTotalReader(szRootPath + "Version") + "
                    \tEcco aborted loading.");
                return false;
            }
        }
        return true;
    }
    string GetLocateMessage(string szMessage, CBasePlayer@ pPlayer){
            return @pPlayer is null ? "" : EccoProcessVar::ProcessVariables(szMessage, @pPlayer);
    }

    string GetLocateMessage(string szMessage, CBaseMenuItem@ pMenuItem){
            return @pMenuItem is null ? "" : EccoProcessVar::ProcessVariables(szMessage, @pMenuItem);
    }
}