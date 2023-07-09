namespace EccoAddon{
namespace EchoLang{
    dictionary dicLangs = {
        {"schinese", "cn"},
        {"tchinese", "cn"}
    };
    void PluginInit(){
        g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @EccoAddon::EchoLang::ClientPutInServer);
    }
    string GetAuthor(){
        return "Dr.Abc";
    }
    HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer){
        string id = EccoPlayerInventory::GetUniquePlayerId(@pPlayer);
        if(EccoBuyMenu::dicPlayerLocale.exists(id))
            return HOOK_CONTINUE;

        int iReqId = pPlayer.entindex() + 114514;
        NetworkMessage m( MSG_ONE, NetworkMessages::NetworkMessageType(58), pPlayer.edict() );
            m.WriteLong(iReqId);
            m.WriteString("cap_lang");
        m.End();
        g_EngineFuncs.SetQueryCvar2Callback(iReqId, function(CBasePlayer@ pPlayer, int requestId, string cvarName, string value){
            if(requestId == pPlayer.entindex() + 114514){
                string szLang = "en";
                if(dicLangs.exists(value))
                    szLang = string(dicLangs[value]);
                EccoBuyMenu::SetLanguage(@pPlayer, szLang);
                CustomKeyvalues@ pKv = @pPlayer.GetCustomKeyvalues();
                pKv.SetKeyvalue("$s_ecco_lang", value);
            }
        });
        return HOOK_CONTINUE;
    }
}
}
