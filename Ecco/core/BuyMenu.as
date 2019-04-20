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
    Menus.resize(0);
    ItemMenu.deleteAll();
    MenuTextAndScriptName.deleteAll();
    ItemInfoData.deleteAll();
    CategoryData.deleteAll();
    string ConfigPath = "scripts/plugins/Ecco/Scripts.txt";
    File@ file = g_FileSystem.OpenFile(ConfigPath, OpenFile::READ);
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        
        if(sLine != ""){
          dictionary ScriptInfo = e_ScriptParser.RetrieveInfo("scripts/plugins/Ecco/scripts/" + sLine);
          array<string> MapBlackList;
          if(ScriptInfo.exists("blacklist")){
            string MapBlackListStr = string(ScriptInfo["blacklist"]);
            MapBlackList = MapBlackListStr.Split(" ");
          }
          
          if(!ScriptInfo.exists("blacklist") || MapBlackList.find(g_Engine.mapname) < 0){
            
            if(ScriptInfo.exists("name") && ScriptInfo.exists("cost")){
              array<string> ItemInfoC;
              if(ScriptInfo.exists("category")){
                ItemInfoC.insertLast(string(ScriptInfo["name"]));
                ItemInfoC.insertLast(string(ScriptInfo["cost"]));
                ItemInfoC.insertLast(string(ScriptInfo["category"]));
                
                array<string> DictTemp;
                if(CategoryData.exists(string(ScriptInfo["category"]))){
                  DictTemp = cast<array<string>>(CategoryData[string(ScriptInfo["category"])]);
                }
                DictTemp.insertLast(sLine);
                CategoryData.set(string(ScriptInfo["category"]), DictTemp);
              }else{
                ItemInfoC.insertLast(string(ScriptInfo["name"]));
                ItemInfoC.insertLast(string(ScriptInfo["cost"]));
              }
              ItemInfoData.set(sLine, ItemInfoC);
              
              
              string ItemFormat = string(EccoConfig["ItemDisplayFormat"]);
              while(ItemFormat.Find("%NAME%") != String::INVALID_INDEX){
                ItemFormat.Replace("%NAME%", string(ScriptInfo["name"]));
              }
              while(ItemFormat.Find("%COST%") != String::INVALID_INDEX){
                ItemFormat.Replace("%COST%", string(ScriptInfo["cost"]));
              }
              
              MenuTextAndScriptName.set(ItemFormat, sLine);
              
            }
            
          }
          
        }
        
      }
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - Ecco] Cannot read the config file, check if it exists and SCDS has the permission to access it!\n");
    }
  }
  
  bool IsEmpty(){
    return ItemInfoData.isEmpty();
  }
  
  void InitializeBuyMenu(){
    if(ItemInfoData.isEmpty()){
      g_Game.AlertMessage(at_console, "[ERROR - Ecco] No existing item!\n");
    }else{
      CateMenu.Unregister();
      @CateMenu = CTextMenu(CateMenuRespond);
      CateMenu.SetTitle(string(EccoConfig["BuyMenuName"]) + "\n" + string(EccoConfig["BuyMenuDescription"]) + "\n");
      array<string> DictKeys = CategoryData.getKeys();
      for(int i=0; i<int(DictKeys.length()); i++){
        CateMenu.AddItem(DictKeys[i], null);
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
      if(e_ScriptParser.ExecuteFile("scripts/plugins/Ecco/scripts/" + ScriptName, pPlayer)){
        e_PlayerInventory.ChangeBalance(pPlayer, -PriceCost);
        return true;
      }
    }else{
      if(PlayerBalance == -1 || PlayerBalance == 0 || PlayerBalance == 1){
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, string(EccoConfig["BuyMenuName"]) + " You don't have enough points to purchase this! You have only " + string(PlayerBalance) + " point.\n");
      }else{
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, string(EccoConfig["BuyMenuName"]) + " You don't have enough points to purchase this! You have only " + string(PlayerBalance) + " points.\n");
      }
    }
    return false;
  }
}