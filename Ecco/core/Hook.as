namespace Hook{
HookReturnCode ClientSay(SayParameters@ pParams){
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ pCommand = pParams.GetArguments();
    string arg = pCommand[0].ToLowercase();
    arg.Trim();
    if(pPlayer !is null && EccoUtility::CanOpenShop(arg)){
        pParams.ShouldHide = true;
        if(!IsMapAllowed){
            Logger::Chat(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ChatLogTitle, @pPlayer) + " " + 
            EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.LocaleNotAllowed, @pPlayer));
            return HOOK_CONTINUE;
        }

        CEccoRootBuyMenu@ pRootItem = EccoBuyMenu::GetRootForPlayer(pPlayer);
        if(pRootItem.IsEmpty()){
            Logger::Chat(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ChatLogTitle, @pPlayer) + " " + 
            EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.EmptyBuyList, @pPlayer));
            return HOOK_CONTINUE;
        }
        if(!EccoConfig::pConfig.BuyMenu.AllowDeathPlayerBuy && !pPlayer.IsAlive()){
            Logger::Chat(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ChatLogTitle, @pPlayer) + " " + 
            EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.RefuseDiedPlyaerBuy, @pPlayer));
            return HOOK_CONTINUE;
        }
        if(pCommand.ArgC() <= 1)
            pRootItem.OpenBuyMenu(pPlayer);
        else{
            CBaseMenuItem@ pItem = pRootItem.GetRoot();
            string szPointer = "";
            if(atoi(pCommand[1]) > 0){
                for(int i = 1; i < pCommand.ArgC();i++){
                @pItem = pItem[Math.clamp(0, pItem.length() - 1 ,atoi(pCommand[i]) - 1)];
                    szPointer = pCommand[i];
                    if(pItem.IsTerminal)
                        break;
                }
            }
            else{
                for(int i = 1; i < pCommand.ArgC();i++){
                    @pItem = pItem[pCommand[i]];
                    szPointer = pCommand[i];
                    if(@pItem is null|| pItem.IsTerminal)
                        break;
                }
            }
            if(@pItem !is null)
                pItem.Excute(@pPlayer, 0, EccoConfig::pConfig.BuyMenu.ReOpenMenuAfterParamBuy);
            else
                Logger::Chat(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ChatLogTitle, @pPlayer) + 
                    " " + EccoConfig::pConfig.LocaleSetting.NullPointerMenu + szPointer);
        }
        return HOOK_HANDLED;
    }
    return HOOK_CONTINUE;
}
HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer){
    if(IsMapAllowed){
        switch(EccoConfig::pConfig.BaseConfig.StorePlayerScore){
            case 2: break;
            case 1: if(bShouldCleanScore == false){break;}
            case 0: {
                if(EccoPlayerStorage::Exists(@pPlayer)){
                    EccoPlayerStorage::CPlayerStorageDataItem@ pItem = EccoPlayerStorage::pData.Get(@pPlayer);
                    DateTime pNow;
                    if(pItem.szLastPlayMap == g_Engine.mapname && (pNow - pItem.pLastUpdateTime).GetSeconds() < EccoConfig::pConfig.BaseConfig.ClearMaintenanceTimeMax)
                        break;
                    else{
                        pItem.szLastPlayMap = g_Engine.mapname;
                        pItem.pLastUpdateTime = pNow;
                    }
                }
            }
            default: EccoPlayerInventory::SetBalance(@pPlayer, EccoConfig::pConfig.BaseConfig.PlayerStartScore);break;
        }
        EccoPlayerStorage::ResetPlayerBuffer(@pPlayer);
        EccoPlayerInventory::RefreshHUD(@pPlayer);
    }
    return HOOK_HANDLED;
}
}