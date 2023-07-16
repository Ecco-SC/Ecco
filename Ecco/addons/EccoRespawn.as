namespace EccoAddon{
namespace EchoRespawn
{
    void PluginInit(){
        EccoScriptParser::Register(CEccoMarco("respawn_player", Marco_respawn));
    }

    string GetAuthor(){
        return "Dr.Abc";
    }

    string GetContactInfo(){
        return "https://github.com/Ecco-SC/Ecco";
    }

    bool Marco_respawn(CBasePlayer@ pPlayer, array<string>@ args)
    {
        if(pPlayer.IsAlive()){
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Ecco] 你不需要购买复活\n");
            return false;
        }
        int money = EccoPlayerInventory::GetBalance(@pPlayer);
        if(money < 0){
            int cost = int(Math.max(20.0f, money * 0.25f));
            EccoPlayerInventory::ChangeBalance(pPlayer, -cost);
            g_PlayerFuncs.RespawnPlayer(@pPlayer, true, true);
        }
        return false;
    }
}
}