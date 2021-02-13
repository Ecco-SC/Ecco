namespace EccoBuyMenu{
    CBaseMenuItem@ pRoot;

    CBaseMenuItem@ GetBaseMenuItem(CTextMenu@ _pTextMenu){
        return pRoot.GetItem(_pTextMenu);
    }

    CBaseMenuItem@ GetBaseMenuItem(CTextMenu@ _pTextMenu, string _DisplayName){
        return pRoot.GetItem(_pTextMenu, _DisplayName);
    }

    bool IsEmpty(){
        return @pRoot is null || pRoot.IsEmpty();
    }

    
    void OpenBuyMenu(CBasePlayer@ pPlayer){
        pRoot.Excute(pPlayer);
    }
    
    void ReadScriptList(){
        if(@pRoot !is null)
            pRoot.TextMenuUnregiste();
        @pRoot = CBaseMenuItem();
        pRoot.Name = "root";
        @pRoot.pTextMenu = CTextMenu(function(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
            if(mItem !is null && pPlayer !is null){
                CBaseMenuItem@ pItem = GetBaseMenuItem(@mMenu, mItem.m_szName);
                if(pItem !is null)
                    pItem.Excute(@pPlayer);
            }
        });
        pRoot.pTextMenu.SetTitle(string(EccoConfig["BuyMenuName"]) + "\n" + string(EccoConfig["BuyMenuDescription"]) + "\n");

        for(uint i = 0; i < e_ScriptParser.aryItem.length(); i++){
            CEccoScriptItem@ pScriptInfo = e_ScriptParser.aryItem[i];
            array<string> MapBlackList;
            if(pScriptInfo.exists("blacklist")){
                string MapBlackListStr = pScriptInfo["blacklist"];
                MapBlackList = MapBlackListStr.Split(" ");
            }
            
            if(!pScriptInfo.exists("blacklist") || MapBlackList.find(g_Engine.mapname) < 0){
                if(pScriptInfo.exists("name") && pScriptInfo.exists("cost"))
                    pRoot.AddChild((pScriptInfo.exists("category") ? pScriptInfo["category"] + "." : "") + pScriptInfo["name"], pScriptInfo["cost"], pScriptInfo.Name);
            }
        }

        pRoot.TextMenuRegister();
    }
}