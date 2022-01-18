class CBaseMenuItem{
    string Name;
    private CTextMenu@ pTextMenu;

    int Cost;
    string ScriptName;
    string DisplayName;
    uint Page;
    uint Index;
    int Id;

    bool IsTerminal = false;

    CBaseMenuItem@ pParent;
    private array<CBaseMenuItem@> aryChildren = {};

    CBaseMenuItem(){
        GetId();
    }

    CBaseMenuItem(string szTitle, TextMenuPlayerSlotCallback@ pCallback){
        GetId();

        @pTextMenu = CTextMenu(@pCallback);
        pTextMenu.SetTitle(szTitle);
    }

    void GetId(){
        this.Id = EccoBuyMenu::iGloabaBaseMenuItemlIdIterator;
        EccoBuyMenu::iGloabaBaseMenuItemlIdIterator++;
        EccoBuyMenu::aryMenuItemList.insertLast(this);
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
        return uint(this.Id+1) >= EccoBuyMenu::aryMenuItemList.length() ? EccoBuyMenu::aryMenuItemList[uint(this.Id)+1] : null;
    }

    uint length(){
        return aryChildren.length();
    }

    void Open(const int iDisplayTime, const uint page, CBasePlayer@ pPlayer){
        EccoHook::OpenBuyMenu(iDisplayTime, page, @pPlayer, this);
        pTextMenu.Open(iDisplayTime, page, @pPlayer);
    }

    bool Excute(CBasePlayer@ pPlayer, uint iPage = 0){
        EccoHook::ExcuteBuyMenu(@pPlayer, iPage, this);
        if(IsTerminal){
            int PlayerBalance = e_PlayerInventory.GetBalance(pPlayer);
            pParent.Excute(@pPlayer, Page);
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

    void AddChild(string szName, string _Cost, string _ScriptName){
        bool bTerminal = szName.FindFirstOf(".") == String::INVALID_INDEX;
        if(bTerminal){
            CBaseMenuItem pItem;
            pItem.IsTerminal = bTerminal;
            pItem.Name = szName;
            pItem.Cost = atoi(_Cost);
            pItem.ScriptName = _ScriptName;
            @pItem.pParent = @this;
            aryChildren.insertLast(pItem);
            pItem.DisplayName = EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ItemDisplayFormat, @pItem);
        }
        else{
            uint index = szName.FindFirstOf(".");
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
                        if(mItem.m_szName == EccoConfig::pConfig.LocaleSetting.BackPreviousMenu)
                            EccoBuyMenu::GetBaseMenuItem(@mMenu).pParent.Excute(@pPlayer);
                        else{
                            CBaseMenuItem@ pItem = EccoBuyMenu::GetBaseMenuItem(mMenu, mItem.m_szName);
                            if(pItem !is null)
                                pItem.Excute(@pPlayer);
                        }
                    }
                });
                pItem.pTextMenu.SetTitle(EccoConfig::pConfig.BaseConfig.BuyMenuName + "\nViewing: " + _Name + "\n");
                @pItem.pParent = @this;
                aryChildren.insertLast(pItem);
            }
            pItem.AddChild(_Next, _Cost, _ScriptName);
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