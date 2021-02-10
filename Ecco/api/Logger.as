namespace Logger
{
    void WriteLine(CBasePlayer@ pPlayer, string szContent, bool bChat = false)
    {
        if(bChat)
            Chat(pPlayer, szContent);
        else
            Console(pPlayer, szContent);
    }
    void Log(string szContent)
    {
        g_Log.PrintF( "[" + g_Module.GetModuleName() + "] " + szContent + "\n");
    }
    void WriteLine(string szContent)
    {
        g_Game.AlertMessage(at_console, szContent + "\n");
    }
    void Say(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.SayText(pPlayer, szContent + "\n");
    }

    void Say(string szContent)
    {
        g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szContent + "\n");
    }

    void Chat(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, szContent + "\n");
    }

    void Chat(CBasePlayer@ pPlayer)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "\n");
    }

    void Console(CBasePlayer@ pPlayer, string szContent)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szContent + "\n");
    }

    void Console(CBasePlayer@ pPlayer, array<string> szContent)
    {
        for(uint i = 0; i < szContent.length(); i++)
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szContent[i] + "\n");
        }
    }

    void Console(CBasePlayer@ pPlayer)
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
    }

    void Console(string szContent)
    {
        g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, szContent + "\n");
    }
}