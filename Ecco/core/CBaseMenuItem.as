enum MenuItemFlag{
    FLAG_NONE = 0,
    FLAG_HIDECOST = 1 << 0
}
class CBaseMenuItem{
    string Name;
    private CTextMenu@ pTextMenu;
    private CEccoRootBuyMenu@ pRootNode;

    int Cost;
    string ScriptName;
    string DisplayName;
    uint Page;
    uint Index;
    int Id;
    int Flags = FLAG_NONE;

    bool IsTerminal = false;

    //For other use
    CEccoScriptItem@ pInfo;

    CBaseMenuItem@ pParent;
    private array<CBaseMenuItem@> aryChildren = {};

    CBaseMenuItem(){}
    CBaseMenuItem(string szTitle, TextMenuPlayerSlotCallback@ pCallback){
        @pTextMenu = CTextMenu(@pCallback);
        pTextMenu.SetTitle(szTitle);
    }

    CBaseMenuItem@ opIndex(uint i){
        return aryChildren[i];
    }

    CBaseMenuItem@ opIndex(string szName){
        for(uint i = 0; i < aryChildren.length(); i++){
            if(aryChildren[i].DisplayName == szName)
                return aryChildren[i];
        }
        return null;
    }

    CBaseMenuItem@ opPostInc(){
        return uint(this.Id+1) >= pRootNode.aryMenuItemList.length() ? null : pRootNode.aryMenuItemList[uint(this.Id)+1];
    }

    uint length(){
        return aryChildren.length();
    }

    void Open(const int iDisplayTime, const uint page, CBasePlayer@ pPlayer){
        EccoHook::OpenBuyMenu(iDisplayTime, page, @pPlayer, this);
        pTextMenu.Open(iDisplayTime, page, @pPlayer);
    }

    bool Excute(CBasePlayer@ pPlayer, uint iPage = 0, bool bReopen = true){
        EccoHook::ExcuteBuyMenu(@pPlayer, iPage, this);
        if(IsTerminal){
            if(bReopen)
                pParent.Excute(@pPlayer, Page);
            int PlayerBalance = e_PlayerInventory.GetBalance(pPlayer);
            if(PlayerBalance >= Cost){
                if(e_ScriptParser.ExecuteFile(szRootPath + "scripts/" + ScriptName + ".echo", pPlayer)){
                    e_PlayerInventory.ChangeBalance(pPlayer, -Cost);
                    return true;
                }
            }else
                Logger::Chat(pPlayer, 
                    EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ChatLogTitle, @pPlayer) + 
                    EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.CannotAffordPrice, @pPlayer));
            return false;
        }
        else{
            this.Open(0, iPage, pPlayer);
            return true;
        }
    }

    void AddChild(string szName, CEccoScriptItem@ pScriptInfo, CEccoRootBuyMenu@ pRoot){
        string _Cost = pScriptInfo["cost"];
        string _ScriptName = pScriptInfo.Name;
        string _Flags = pScriptInfo["flags"];
        string _DisplayName = pScriptInfo["displayname"];
        bool bTerminal = szName.FindFirstOf("🈹") == String::INVALID_INDEX;
        if(bTerminal){
            CBaseMenuItem pItem;
            pItem.IsTerminal = bTerminal;
            pItem.Name = szName;
            pItem.Cost = atoi(_Cost);
            pItem.ScriptName = _ScriptName;
            pItem.Flags = atoi(_Flags);
            @pItem.pParent = @this;
            @pItem.pInfo = @pScriptInfo;
            aryChildren.insertLast(pItem);
            pItem.DisplayName = _DisplayName == "" ? 
                            EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ItemDisplayFormat, @pItem) : 
                            _DisplayName;
        }
        else{
            uint index = szName.FindFirstOf("🈹");
            string _Name = szName.SubString(0, index);
            string _Next = szName.SubString(index + 1);
            CBaseMenuItem@ pItem = null;
            for(uint i = 0; i < aryChildren.length(); i++){
                if(aryChildren[i].Name == _Name){
                    @pItem = aryChildren[i];
                    break;
                }
            }
            if(@pItem is null){
                @pItem = CBaseMenuItem();
                pItem.DisplayName = pItem.Name = _Name;
                @pItem.pTextMenu = CTextMenu(function(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
                    if(mItem !is null && pPlayer !is null){
                        CEccoRootBuyMenu@ pRoot = EccoBuyMenu::GetRootForPlayer(@pPlayer);
                        if(mItem.m_szName == EccoConfig::pConfig.LocaleSetting.BackPreviousMenu)
                            pRoot.GetBaseMenuItem(@mMenu).pParent.Excute(@pPlayer);
                        else{
                            CBaseMenuItem@ pItem = pRoot.GetBaseMenuItem(mMenu, mItem.m_szName);
                            if(pItem !is null)
                                pItem.Excute(@pPlayer);
                        }
                    }
                });
                pItem.pTextMenu.SetTitle(EccoConfig::pConfig.BaseConfig.BuyMenuName + "\nViewing: " + _Name + "\n");
                @pItem.pParent = @this;
                aryChildren.insertLast(pItem);
            }
            pItem.AddChild(_Next, pScriptInfo, pRoot);
        }
    }

    CBaseMenuItem@ GetItem(CTextMenu@ _pTextMenu, string _DisplayName){
        if(@this.pParent !is null && @this.pParent.pTextMenu is @_pTextMenu && (
                (_DisplayName == this.DisplayName && 
                    !EccoConfig::pConfig.BuyMenu.UseBlurMatchForArgs) || 
                (this.DisplayName.Find(_DisplayName) != String::INVALID_INDEX && 
                    EccoConfig::pConfig.BuyMenu.UseBlurMatchForArgs)
            )
        )
            return @this;
        else{
            CBaseMenuItem@ pItem = null;
            for(uint i = 0; i < aryChildren.length(); i++){
                @pItem = aryChildren[i].GetItem(_pTextMenu, _DisplayName);
                if(@pItem !is null)
                    break;
            }
            return @pItem;
        }
    }

    CBaseMenuItem@ GetItem(CTextMenu@ _pTextMenu){
        if(@_pTextMenu is @this.pTextMenu)
            return @this;
        else{
            CBaseMenuItem@ pItem = null;
            for(uint i = 0; i < aryChildren.length(); i++){
                @pItem = aryChildren[i].GetItem(_pTextMenu);
                if(@pItem !is null)
                    break;
            }
            return @pItem;
        }
    }

    void TextMenuUnregiste(){
        if(!IsTerminal && this.pTextMenu !is null){
            this.pTextMenu.Unregister();
            for(uint i = 0; i < aryChildren.length();i++){
                aryChildren[i].TextMenuUnregiste();
            }
        }
    }

    void TextMenuRegister(){
        if(!IsTerminal && this.pTextMenu !is null){
            uint iPage = 0;
            uint iIndex = 0;
            for(uint i = 0; i < aryChildren.length();i++){
                if(aryChildren.length() > 9 && i % 6 == 0 && i != 0 && this.Name != EccoConfig::pConfig.BuyMenu.RootNodeName){
                    this.pTextMenu.AddItem(EccoConfig::pConfig.LocaleSetting.BackPreviousMenu, null);
                    iPage++;
                    iIndex = 0;
                }
                this.pTextMenu.AddItem(aryChildren[i].DisplayName, null);
                aryChildren[i].Page = iPage;
                aryChildren[i].Index = iIndex;
                iIndex++;
            }
            if(this.Name != EccoConfig::pConfig.BuyMenu.RootNodeName)
                this.pTextMenu.AddItem(EccoConfig::pConfig.LocaleSetting.BackPreviousMenu, null);
            this.pTextMenu.Register();
            for(uint i = 0; i < aryChildren.length();i++){
                aryChildren[i].TextMenuRegister();
            }
        }
    }

    bool IsEmpty(){
        return aryChildren.length() <= 0;
    }
}
