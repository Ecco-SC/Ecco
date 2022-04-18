/*
    Echo scripts 

    Commands:
    buy_ammo_item
    
*/
namespace EccoAddon{
namespace EchoAmmo{
    //Set Weapon-EccoScripts pair
    const dictionary dicWeaponAmmoMap = {
        {"weapon_mp5", "itemexample"},
        {"weapon_pistol", "randomexample"}
    };
    void PluginInit(){
        e_ScriptParser.Register(CEccoMarco("buy_ammo_item", Macro_buy_ammo_item));
    }
    string GetAuthor(){
        return "Dr.Abc";
    }
    string GetContactInfo(){
        return "https://github.com/Ecco-SC/Ecco";
    }
    bool Macro_buy_ammo_item(CBasePlayer@ pPlayer, array<string>@ args){
        if(pPlayer.m_hActiveItem.IsValid()){
            string szKey = pPlayer.m_hActiveItem.GetEntity().pev.classname;
            if(dicWeaponAmmoMap.exists(szKey)){
                CEccoScriptItem@ pItem = e_ScriptParser.GetItem(szRootPath + "scripts/" + string(dicWeaponAmmoMap[szKey]) + ".echo");
                if(@pItem !is null && !pItem.IsEmpty()){
                    if(pItem.Excute(@pPlayer)){
                        e_PlayerInventory.ChangeBalance(pPlayer, -atoi(pItem.Get("cost")));
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
}