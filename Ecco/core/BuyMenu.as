namespace EccoBuyMenu{
    dictionary ItemMenu; // indexes int
    array<CTextMenu@> Menus;
    CTextMenu@ CateMenu = CTextMenu(CateMenuRespond);
    dictionary MenuTextAndScriptName; // string
    dictionary ItemInfoData; // array<string>: name cost category
    dictionary CategoryData; // array<string>: [scripts]
    
    
    void OpenBuyMenu(CBasePlayer@ pPlayer){
        CateMenu.Open(0, 0, pPlayer);
    }
    
    void ReadScriptList(){
        CateMenu.Unregister();
        @CateMenu = CTextMenu(CateMenuRespond);
        CateMenu.SetTitle(string(EccoConfig["BuyMenuName"]) + "\n" + string(EccoConfig["BuyMenuDescription"]) + "\n");
    
        Menus.resize(0);
        ItemMenu.deleteAll();
        MenuTextAndScriptName.deleteAll();
        ItemInfoData.deleteAll();
        CategoryData.deleteAll();

        for(uint i = 0; i < e_ScriptParser.aryItem.length(); i++){
            CEccoScriptItem@ pScriptInfo = e_ScriptParser.aryItem[i];
            array<string> MapBlackList;
            if(pScriptInfo.exists("blacklist")){
                string MapBlackListStr = pScriptInfo["blacklist"];
                MapBlackList = MapBlackListStr.Split(" ");
            }
            
            if(!pScriptInfo.exists("blacklist") || MapBlackList.find(g_Engine.mapname) < 0){
                
                if(pScriptInfo.exists("name") && pScriptInfo.exists("cost")){
                    array<string> ItemInfoC;
                    if(pScriptInfo.exists("category")){
                        ItemInfoC.insertLast(pScriptInfo["name"]);
                        ItemInfoC.insertLast(pScriptInfo["cost"]);
                        ItemInfoC.insertLast(pScriptInfo["category"]);
                        
                        array<string> DictTemp;
                        if(CategoryData.exists(string(pScriptInfo["category"]))){
                            DictTemp = cast<array<string>>(CategoryData[pScriptInfo["category"]]);
                        }else{
                            CateMenu.AddItem(pScriptInfo["category"], null);
                        }
                        DictTemp.insertLast(pScriptInfo.Name);
                        CategoryData.set(pScriptInfo["category"], DictTemp);
                    }else{
                        ItemInfoC.insertLast(pScriptInfo["name"]);
                        ItemInfoC.insertLast(pScriptInfo["cost"]);
                    }
                    ItemInfoData.set(pScriptInfo.Name, ItemInfoC);
                    
                    string ItemFormat = string(EccoConfig["ItemDisplayFormat"]);
                    while(ItemFormat.Find("%NAME%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%NAME%", pScriptInfo["name"]);
                    }
                    while(ItemFormat.Find("%COST%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%COST%", pScriptInfo["cost"]);
                    }
                    MenuTextAndScriptName.set(ItemFormat, pScriptInfo.Name);
                }
            }
        }  
    }
    
    bool IsEmpty(){
        return ItemInfoData.isEmpty();
    }
    
    void InitializeBuyMenu(){
        if(ItemInfoData.isEmpty()){
            g_Game.AlertMessage(at_console, "[ERROR - Ecco] No existing item!\n");
        }else{
            array<string> DictKeys = CategoryData.getKeys();
            for(int i=0; i<int(DictKeys.length()); i++){
                CTextMenu@ SubMenu = CTextMenu(ItemMenuRespond);
                array<string> SubScripts = cast<array<string>>(CategoryData[DictKeys[i]]);
                for(int j=0; j<int(SubScripts.length()); j++){
                    if(SubScripts.length() != 7 && j != 0 && j % 6 == 0){
                        SubMenu.AddItem("Back to Categories", null);
                    }
                    string ItemFormat = string(EccoConfig["ItemDisplayFormat"]);
                    array<string> ItemDictInfo = cast<array<string>>(ItemInfoData[SubScripts[j]]);
                    while(ItemFormat.Find("%NAME%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%NAME%", ItemDictInfo[0]);
                    }
                    while(ItemFormat.Find("%COST%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%COST%", ItemDictInfo[1]);
                    }
                    SubMenu.AddItem(ItemFormat, null);
                    if(j == int(SubScripts.length()) - 1){
                        SubMenu.AddItem("Back to Categories", null);
                    }
                }
                SubMenu.SetTitle(string(EccoConfig["BuyMenuName"])+"\nViewing: " + DictKeys[i] + "\n");
                SubMenu.Register();
                Menus.insertLast(SubMenu);
                ItemMenu.set(DictKeys[i], Menus.length()-1);
            }
            DictKeys = ItemInfoData.getKeys();
            for(int i=0; i<int(DictKeys.length()); i++){
                array<string> ItemDictInfo = cast<array<string>>(ItemInfoData[DictKeys[i]]);
                if(ItemDictInfo.length() == 2){ // With no category
                    string ItemFormat = string(EccoConfig["ItemDisplayFormat"]);
                    while(ItemFormat.Find("%NAME%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%NAME%", ItemDictInfo[0]);
                    }
                    while(ItemFormat.Find("%COST%") != String::INVALID_INDEX){
                        ItemFormat.Replace("%COST%", ItemDictInfo[1]);
                    }
                    CateMenu.AddItem(ItemFormat, null);
                }
            }
            CateMenu.Register();
        }
    }

    void CateMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
        if(mItem !is null && pPlayer !is null){
            CTextMenu@ NextMenu = null;
            if(ItemMenu.exists(mItem.m_szName)){
                @NextMenu = Menus[int(ItemMenu[mItem.m_szName])];
            }
            if(NextMenu !is null){
                NextMenu.Open(0, 0, pPlayer);
            }else{
                if(MenuTextAndScriptName.exists(mItem.m_szName)){
                    ExecItem(pPlayer, string(MenuTextAndScriptName[mItem.m_szName]));
                    mMenu.Open(0, 0, pPlayer);
                }
            }
        }
    }

    void ItemMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
        if(mItem !is null && pPlayer !is null){
            if(mItem.m_szName == "Back to Categories"){
                CateMenu.Open(0, 0, pPlayer);
            }else{
                if(MenuTextAndScriptName.exists(mItem.m_szName)){
                    ExecItem(pPlayer, string(MenuTextAndScriptName[mItem.m_szName]));
                    mMenu.Open(0, 0, pPlayer);
                }
            }
        }
    }

    bool ExecItem(CBasePlayer@ pPlayer, string ScriptName){
        array<string> ItemInfoC = cast<array<string>>(ItemInfoData[ScriptName]);
        int PriceCost = atoi(ItemInfoC[1]);
        int PlayerBalance = e_PlayerInventory.GetBalance(pPlayer);
        if(PlayerBalance >= PriceCost){
            if(e_ScriptParser.ExecuteFile(szRootPath + "scripts/" + ScriptName + ".echo", pPlayer)){
                e_PlayerInventory.ChangeBalance(pPlayer, -PriceCost);
                return true;
            }
        }else{
            if(PlayerBalance == -1 || PlayerBalance == 0 || PlayerBalance == 1){
                Logger::Chat(pPlayer, string(EccoConfig["BuyMenuName"]) + " You don't have enough points to purchase this! You have only " + string(PlayerBalance) + " point.");
            }else{
                Logger::Chat(pPlayer, string(EccoConfig["BuyMenuName"]) + " You don't have enough points to purchase this! You have only " + string(PlayerBalance) + " points.");
            }
        }
        return false;
    }
}