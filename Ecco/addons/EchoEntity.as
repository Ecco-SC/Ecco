/*

    Useful Variables:
    %PLAYER%     %RANDOMPLAYER%     %BALANCE%     %SPACE% 
    
    Commands:
    add_friendly_ent_at_aim [entity name] (hp) (display name) (model) 
    
*/
namespace EccoAddon{
namespace EchoEntity
{
    const string szNPCMaxError = "你所请求的NPC队友数量已达上限!";
    const string szNPCNarrowError = "你召唤的位置空间太狭窄！";
    void PluginInit()
    {
        e_ScriptParser.Register(CEccoMarco("add_friendly_ent_at_aim", Macro_add_friendly_ent_at_aim));
    }

    string GetAuthor(){
        return "Paranoid_AF|Dr.Abc";
    }

    string GetContactInfo(){
        return "Please don't";
    }

    class CEchoEntityHandle
    {
        string szName;
        array<EHandle> aryMonsters = {};
        CEchoEntityHandle(CBasePlayer@ pPlayer)
        {
            this.szName = e_PlayerInventory.GetUniquePlayerId(pPlayer);
        }

        CEchoEntityHandle@ Init()
        {
            aryPlayerMonster.insertLast(this);
            return @this;
        }

        bool opEquals(CEchoEntityHandle@ pOther)
        {
            return this.szName == pOther.szName;
        }

        bool Check()
        {
            for(uint i = 0; i < aryMonsters.length(); i++)
            {
                if(!aryMonsters[i].IsValid() || !aryMonsters[i].GetEntity().IsAlive())
                    aryMonsters.removeAt(i);
            }
            return aryMonsters.length() < MaxNPC;
        }

        void Add(CBaseEntity@ pEntity)
        {
            aryMonsters.insertLast(EHandle(pEntity));
        }
    }

    const int MaxNPC = 5;
    array<CEchoEntityHandle@> aryPlayerMonster = {};
    bool Macro_add_friendly_ent_at_aim(CBasePlayer@ pPlayer, array<string>@ args)
    {
        TraceResult tr;
        Vector vecSrc = pPlayer.GetGunPosition();
        Vector vecAiming = pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);
        Vector vecEnd = vecSrc + vecAiming * 4096;
        g_Utility.TraceHull(vecSrc, vecEnd, dont_ignore_monsters, human_hull, pPlayer.edict(), tr);

        int index = aryPlayerMonster.find(CEchoEntityHandle(@pPlayer));
        CEchoEntityHandle@ pHandle = index >= 0 ? aryPlayerMonster[index] : CEchoEntityHandle(@pPlayer).Init();
        
        if(!pHandle.Check())
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Ecco Entity] " + szNPCMaxError + " ["+string(MaxNPC)+"/"+string(MaxNPC)+"] "+"\n");
            return false;
        }
 
        if(args.length() > 0)
        {
            CBaseEntity@ pEntity = g_EntityFuncs.Create(args[0], g_vecZero, g_vecZero, true);
            CBaseEntity@ pHit = g_EntityFuncs.Instance(tr.pHit);
            while(@pHit !is null && pHit.IsMonster())
            {
                g_Utility.TraceHull(tr.vecEndPos, tr.vecEndPos + Vector(0, 0, pHit.pev.size.z), dont_ignore_monsters, human_hull, pHit.edict(), tr);
                @pHit = g_EntityFuncs.Instance(tr.pHit);
            }

            if(tr.flFraction > 0.95)
            {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Ecco Entity] " + szNPCNarrowError + "\n");
                return false;
            }

            pEntity.pev.origin = tr.vecEndPos;
            pEntity.pev.origin.z += pEntity.pev.size.z / 2;
            @pEntity.pev.owner = pPlayer.edict();
            switch(args.length())
            {
                case 5:g_EntityFuncs.SetModel(pEntity, "models/"+args[4]);
                case 4:pEntity.KeyValue("displayname", args[3]);
                case 3:pEntity.pev.weapons = atoi(args[2]);
                case 2:pEntity.pev.max_health = atoi(args[1]);pEntity.pev.health = atoi(args[1]);
                case 1:
                {
                    if(pEntity.IRelationship(pPlayer) > R_NO)
                    {
                        pEntity.SetClassification(11);
                        pEntity.SetPlayerAlly(true);
                        pEntity.KeyValue("m_flCustomRespawnTime", "-1");
                    }
                    pHandle.Add(@pEntity);
                }
                default:g_EntityFuncs.DispatchSpawn(pEntity.edict());break;
            }
            return true;
        }
        return false;
    }
}
}