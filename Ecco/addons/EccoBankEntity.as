namespace EccoAddon{
namespace EccoBankEntity{
    void MapInit(){
        g_CustomEntityFuncs.RegisterCustomEntity( "EccoAddon::EccoBankEntity::CEccoInfoEntity", "info_ecco_bank" );
    }

    void MapActivate(){
        g_EntityFuncs.Create("info_ecco_bank", g_vecZero, g_vecZero, false, null);
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
            self.pev.skin = 0;

            //output
            self.pev.targetname = "";
            self.pev.frags = 0;
        }

        CBasePlayer@ FindPlayer(){
            CBasePlayer@ pPlayer = null;
            switch(self.pev.spawnflags){
                case 1: {
                    @pPlayer = g_PlayerFuncs.FindPlayerByName(self.pev.targetname);
                    break;
                }
                case 0:
                default:{
                    @pPlayer = g_PlayerFuncs.FindPlayerByIndex(self.pev.skin);
                    break;
                }
            }
            return @pPlayer;
        }

        void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f){
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pActivator);
            if(@pPlayer is null)
                @pPlayer = this.FindPlayer();
            switch(useType){
                //input
                case USE_SET: {
                    if(@pPlayer !is null)
                        e_PlayerInventory.ChangeBalance(@pPlayer, int(flValue) - e_PlayerInventory.GetBalance(@pPlayer));
                    break;
                }
                //add
                case USE_TOGGLE:{
                    if(@pPlayer !is null)
                        e_PlayerInventory.ChangeBalance(@pPlayer, int(flValue));
                    break;
                }
                //output
                case USE_ON:
                default: {
                    if(@pPlayer !is null)
                        self.pev.frags = e_PlayerInventory.GetBalance(@pPlayer);
                    break;
                }
            }
        }
    }
}
}