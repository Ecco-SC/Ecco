/*
    Quick buy ammo item

    Commands:
    buy_ammo_item
    
*/
namespace EccoAddon{
namespace EchoAmmo{
    //Set Weapon-EccoScripts pair
    //DO NOT SET SCRIPTS WHICH CONTAIN buy_ammo_item COMMAND!
    //You'll be stuck in a DEAD circle
    const dictionary dicWeaponAmmoMap = {
        {"weapon_mp5", "itemexample"},
        {"weapon_pistol", "randomexample"}
    };
    void PluginInit(){
        EccoScriptParser::Register(CEccoMarco("buy_ammo_item", Macro_buy_ammo_item));
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
                CEccoScriptItem@ pItem = EccoScriptParser::GetItem(szRootPath + "scripts/" + string(dicWeaponAmmoMap[szKey]) + ".echo");
                if(@pItem !is null && !pItem.IsEmpty()){
                    if(pItem.Excute(@pPlayer)){
                        EccoPlayerInventory::ChangeBalance(pPlayer, -atoi(pItem.Get("cost")));
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
}