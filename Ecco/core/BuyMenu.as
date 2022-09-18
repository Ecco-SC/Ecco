final class CEccoRootBuyMenu{
    private string ParserName = "name";
    private CBaseMenuItem@ pRoot;
    private int iIdIterator = 0;
    array<CBaseMenuItem@> aryMenuItemList = {};

    CEccoRootBuyMenu(string pn){
        this.ParserName = pn;
    }
    CBaseMenuItem@ GetRoot(){
        return pRoot;
    };
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
        iIdIterator = 0;
        aryMenuItemList.resize(0);
        if(@pRoot !is null)
            pRoot.TextMenuUnregiste();
        @pRoot = CBaseMenuItem(EccoConfig::pConfig.BaseConfig.BuyMenuName + "\n" + EccoConfig::pConfig.BaseConfig.BuyMenuDescription + "\n", 
            function(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
                if(mItem !is null && pPlayer !is null){
                    CEccoRootBuyMenu@ pRoot = EccoBuyMenu::GetRootForPlayer(@pPlayer);
                    CBaseMenuItem@ pItem = pRoot.GetBaseMenuItem(@mMenu, mItem.m_szName);
                    if(pItem !is null)
                        pItem.Excute(@pPlayer);
                }
            });
        pRoot.Name = EccoConfig::pConfig.BuyMenu.RootNodeName;
        for(uint i = 0; i < e_ScriptParser.aryItem.length(); i++){
            CEccoScriptItem@ pScriptInfo = e_ScriptParser.aryItem[i];
            array<string> MapBlackList;
            if(pScriptInfo.exists("blacklist")){
                string MapBlackListStr = pScriptInfo["blacklist"];
                MapBlackList = MapBlackListStr.Split(" ");
            }
            if(!pScriptInfo.exists("blacklist") || MapBlackList.find(g_Engine.mapname) < 0){
                if((pScriptInfo.exists(ParserName) || pScriptInfo.exists("name")) && pScriptInfo.exists("cost")){
                    string szKeyName = pScriptInfo.exists(ParserName) ? pScriptInfo[ParserName] : pScriptInfo["name"];
                    string szName = (pScriptInfo.exists("category") ? pScriptInfo["category"] + "🈹" : "") + szKeyName;
                    pRoot.AddChild(szName, @pScriptInfo, this);
                }
            }
        }
        pRoot.TextMenuRegister();
    }
}
namespace EccoBuyMenu{
    dictionary dicPlayerLocale = {};
    dictionary dicRoots = {
        {"en", CEccoRootBuyMenu("name")},
        {"cn", CEccoRootBuyMenu("name_cn")}
    };
    CEccoRootBuyMenu@ GetRootForPlayer(CBasePlayer@ pPlayer){
        string id = e_PlayerInventory.GetUniquePlayerId(@pPlayer);
        if(!dicPlayerLocale.exists(id))
            return cast<CEccoRootBuyMenu@>(dicRoots["en"]);
        else
            return cast<CEccoRootBuyMenu@>(dicRoots[string(dicPlayerLocale[id])]);
    }
    void BuildMenu(){
        array<string>@ aryKeys = dicRoots.getKeys();
        for(uint i = 0; i < aryKeys.length();i++){
            cast<CEccoRootBuyMenu@>(dicRoots[aryKeys[i]]).ReadScriptList();
        }
    }
    bool SetLanguage(CBasePlayer@ pPlayer, string szLang){
        if(!dicRoots.exists(szLang))
            return false;
        string id = e_PlayerInventory.GetUniquePlayerId(@pPlayer);
        dicPlayerLocale[id] = szLang;
        return true;
    }
}