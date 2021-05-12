namespace EccoAddon{
namespace EccoBankEntity{
    void MapInit(){
        g_CustomEntityFuncs.RegisterCustomEntity( "EccoAddon::EccoBankEntity::CEccoInfoEntity", "info_ecco_bank" );
    }

    void MapActivate(){
        g_EntityFuncs.CreateEntity("info_ecco_bank");
    }

    string GetAuthor(){
        return "Dr.Abc";
    }

    string GetContactInfo(){
        return "The number you are dialing is empty";
    }

    class CEccoInfoEntity : ScriptBaseEntity{
        void Spawn(){
            //searchmode
            //0 index
            //1 name
            self.pev.spawnflags = 0;

            //input
            self.pev.netname = "";

            //output
            self.pev.targetname = "";
            self.pev.frags = 0;
        }

        CBasePlayer@ FindPlayer(string szMessage){
            CBasePlayer@ pPlayer = null;
            switch(self.pev.spawnflags){
                case 1: {
                    @pPlayer = g_PlayerFuncs.FindPlayerByName(szMessage);
                    break;
                }
                case 0:
                default:{
                    @pPlayer = g_PlayerFuncs.FindPlayerByIndex(atoi(szMessage));
                    break;
                }
            }
            return @pPlayer;
        }

        void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f){
            switch(useType){
                //input
                case USE_SET: {
                    CBasePlayer@ pPlayer = FindPlayer(self.pev.netname);
                    if(@pPlayer !is null)
                        e_PlayerInventory.SetBalance(@pPlayer, int(flValue));
                    break;
                }
                //output
                case USE_ON:
                default: {
                    CBasePlayer@ pPlayer = FindPlayer(self.pev.targetname);
                    if(@pPlayer !is null)
                        self.pev.frags = e_PlayerInventory.GetBalance(@pPlayer);
                    break;
                }
            }
        }
    }
}
}