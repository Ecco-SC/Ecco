#include "CClientCmd"
namespace Command{
    array<CClinetCmd@> aryCmdList = {};
    funcdef bool CmdCallback( CBasePlayer@, const CCommand@, const CClinetCmd@ , const bool);
    void Register( string _szName, string _szHelpInfo, string szDescribeInfo ,string szReturnInfo, CmdCallback@ pCallback, ConCommandFlags_t iAdminLevel = ConCommandFlag::None ){
        string szName = EccoConfig::pConfig.Command.CommandPrefix + _szName;
        string szHelpInfo = szName + " " + _szHelpInfo;
        
        CClinetCmd command;
            command.Name = szName;
            command.HelpInfo = szHelpInfo;
            command.DescribeInfo = szDescribeInfo;
            command.ReturnInfo = szReturnInfo;
            command.AdminLevel = iAdminLevel;
            @command.ClientCallback = pCallback;
            @command.ClientCommand = CClientCommand( szName, szHelpInfo, @HandelCallback, iAdminLevel);
        aryCmdList.insertLast(@command);
    }

    CClinetCmd@ GetCommand( string szName ){
        for(uint i = 0; i < aryCmdList.length(); i++){
            if(cast<CClinetCmd@>(aryCmdList[i]).Name == szName)
                return aryCmdList[i];
        }
        return null;
    }

    void HandelCallback( const CCommand@ Argments ){ 
        CClinetCmd@ pCmd = GetCommand(Argments[0].SubString(1));
        CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        if(pCmd is null)
            return;
        if(g_PlayerFuncs.AdminLevel(pPlayer) < int(pCmd.AdminLevel)){
            Logger::Console(EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.RefuseCommand, pPlayer));
            return;
        }
        
        Logger::Log(EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ExcutedLogCommand, pPlayer).Replace("%COMMAND%", Argments.GetCommandString()));
        if(pCmd.ClientCallback(pPlayer, Argments, pCmd, false)){
            Logger::Console(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.ExcutedCommand, pPlayer).Replace("%COMMAND%", pCmd.Name));
            if(pCmd.ReturnInfo != "")
                Logger::Console(pPlayer, pCmd.ReturnInfo);
        }
        else{
            Logger::Console(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.CanNotExcutedCommand, pPlayer).Replace("%COMMAND%", pCmd.Name));
            Logger::Console(pPlayer, EccoConfig::GetLocateMessage(EccoConfig::pConfig.LocaleSetting.HelpCommand, pPlayer).Replace("%HELPINFO%", pCmd.HelpInfo));
        }
    }
}