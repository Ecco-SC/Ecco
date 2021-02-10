namespace EccoBuyMenu{
    class CBaseMenuItem{
        string Name;
    }

    class CMenuItem: CBaseMenuItem{
        CCategoryItem@ pParent;
        int Cost;
        string ScriptName;
        string DisplayName;
        uint Page;
        uint Index;

        bool Excute(CBasePlayer@ pPlayer){
            int PlayerBalance = e_PlayerInventory.GetBalance(pPlayer);
            pParent.Open(@pPlayer, Page);
            if(PlayerBalance >= Cost){
                if(e_ScriptParser.ExecuteFile(szRootPath + "scripts/" + ScriptName + ".echo", pPlayer)){
                    e_PlayerInventory.ChangeBalance(pPlayer, -Cost);
                    return true;
                }
            }else
                Logger::Chat(pPlayer, 
                    string(EccoConfig["BuyMenuName"]) + 
                    " You don't have enough points to purchase this! You have only " + PlayerBalance + " point" +
                    (PlayerBalance >= -1 || PlayerBalance <= 1 ? "s" : "")  + ".");
            return false;
        }
    }

    class CCategoryItem: CBaseMenuItem{
        private CTextMenu@ pMenu;
        array<CMenuItem@> aryItem = {};
        CCategoryItem(string _Name, CTextMenu@ _pMenu){
            this.Name = _Name;
            @this.pMenu = _pMenu;
            this.pMenu.SetTitle(string(EccoConfig["BuyMenuName"])+"\nViewing: " + _Name + "\n");
        }
        void AddItem(CMenuItem@ pItem){
            aryItem.insertLast(pItem);
        }
        void Open(CBasePlayer@ pPlayer, uint iPage = 0){
            this.pMenu.Open(0, iPage, pPlayer);
        }
        void Unregiste(){
            this.pMenu.Unregister();
        }
        void Registe(){
            uint iPage = 0;
            uint iIndex = 0;
            for(uint i = 0; i < aryItem.length();i++){
                if(aryItem.length() > 9 && i % 6 == 0 && i != 0){
                    this.pMenu.AddItem("Back to Categories", null);
                    iPage++;
                    iIndex = 0;
                }
                this.pMenu.AddItem(aryItem[i].DisplayName, null);
                aryItem[i].Page = iPage;
                aryItem[i].Index = iIndex;
                iIndex++;
            }
            this.pMenu.AddItem("Back to Categories", null);
            this.pMenu.Register();
        }
    }
    array<CCategoryItem@> aryMenuItem = {};
    CTextMenu@ pCateMenu;
    CCategoryItem@ GetCategoryItem(string _Category){
        for(uint i = 0; i < aryMenuItem.length(); i++){
            if(aryMenuItem[i].Name == _Category)
                return @aryMenuItem[i];
        }
        return null;
    }
    CMenuItem@ GetMenuItemByDisplayName(string szDisplay){
        for(uint i = 0; i < aryMenuItem.length(); i++){
            for(uint j = 0; j < aryMenuItem[i].aryItem.length(); j++){
                if(aryMenuItem[i].aryItem[j].DisplayName == szDisplay)
                    return @aryMenuItem[i].aryItem[j];
            }
        }
        return null;
    }

    void Add(string _Name, string _Cost, string _Category, string _ScriptName){
        CCategoryItem@ pCategory = GetCategoryItem(_Category);
        if(pCategory is null){
            @pCategory = CCategoryItem(_Category, CTextMenu(ItemMenuRespond));
            pCateMenu.AddItem(_Category, null);
            aryMenuItem.insertLast(@pCategory);
        }

        CMenuItem pItem;
        pItem.Name = _Name;
        pItem.Cost = atoi(_Cost);
        pItem.ScriptName = _ScriptName;
        pItem.DisplayName = string(EccoConfig["ItemDisplayFormat"]).Replace("%NAME%", _Name).Replace("%COST%", _Cost);
        @pItem.pParent = @pCategory;
        pCategory.AddItem(@pItem);
    }

    bool IsEmpty(){
        return aryMenuItem.length() <= 0;
    }

    
    void OpenBuyMenu(CBasePlayer@ pPlayer){
        pCateMenu.Open(0, 0, pPlayer);
    }
    
    void ReadScriptList(){
        if(@pCateMenu !is null)
            pCateMenu.Unregister();
        @pCateMenu = CTextMenu(CateMenuRespond);
        pCateMenu.SetTitle(string(EccoConfig["BuyMenuName"]) + "\n" + string(EccoConfig["BuyMenuDescription"]) + "\n");

        for(uint i = 0; i < aryMenuItem.length(); i++){
            aryMenuItem[i].Unregiste();
        }
        aryMenuItem = {};

        for(uint i = 0; i < e_ScriptParser.aryItem.length(); i++){
            CEccoScriptItem@ pScriptInfo = e_ScriptParser.aryItem[i];
            array<string> MapBlackList;
            if(pScriptInfo.exists("blacklist")){
                string MapBlackListStr = pScriptInfo["blacklist"];
                MapBlackList = MapBlackListStr.Split(" ");
            }
            
            if(!pScriptInfo.exists("blacklist") || MapBlackList.find(g_Engine.mapname) < 0){
                if(pScriptInfo.exists("name") && pScriptInfo.exists("cost") && pScriptInfo.exists("category"))
                    Add(pScriptInfo["name"], pScriptInfo["cost"], pScriptInfo["category"], pScriptInfo.Name);
            }
        }

        pCateMenu.Register();
        for(uint i = 0; i < aryMenuItem.length(); i++){
            aryMenuItem[i].Registe();
        }
    }

    void CateMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
        if(mItem !is null && pPlayer !is null){
            CCategoryItem@ pItem = GetCategoryItem(mItem.m_szName);
            if(pItem !is null)
                pItem.Open(@pPlayer);
        }
    }

    void ItemMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
        if(mItem !is null && pPlayer !is null){
            if(mItem.m_szName == "Back to Categories")
                pCateMenu.Open(0, 0, pPlayer);
            else{
                CMenuItem@ pItem = GetMenuItemByDisplayName(mItem.m_szName);
                if(pItem !is null){
                    pItem.Excute(@pPlayer);
                }
            }
        }
    }
}