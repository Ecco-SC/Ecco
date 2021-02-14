dictionary PlayerJoined;
string LastNextMap = "";
const string szStorePath = "scripts/plugins/store/Ecco/";

void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
    g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
}

void MapInit(){
    if(LastNextMap != g_Engine.mapname){
        PlayerJoined.deleteAll();
    }
    LastNextMap = GetNextMap();
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
    if(pPlayer !is null){
        if(!PlayerJoined.exists(GetUniquePlayerId(pPlayer))){
            File @pFile = g_FileSystem.OpenFile(szStorePath + "Ecco-" + GetUniquePlayerId(pPlayer) + ".txt", OpenFile::WRITE);
            if (pFile !is null && pFile.IsOpen()){
                pFile.Write("0");
                pFile.Close();
            }
        }
        PlayerJoined.set(GetUniquePlayerId(pPlayer), true);
    }
    return HOOK_HANDLED;
}

string GetNextMap(){
    string nextMap = g_EngineFuncs.CVarGetString("mp_nextmap");
    if(nextMap == ""){
        nextMap = g_EngineFuncs.CVarGetString("mp_survival_nextmap");
    }
    return nextMap;
}

string GetUniquePlayerId(CBasePlayer@ pPlayer){
    string PlayerId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    if(PlayerId == "STEAM_ID_LAN"){
        PlayerId = pPlayer.pev.netname;
    }else{
        PlayerId.Replace("STEAM_", "");
        PlayerId.Replace(":", "");
    }
    return PlayerId;
}