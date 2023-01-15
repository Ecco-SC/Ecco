namespace EccoScriptParser{
    array<IEccoMarco@> aryMarco = {};
    void Register(IEccoMarco@ Marco){
        aryMarco.insertLast(@Marco);
    }
    IEccoMarco@ GetMarco(string szName){
        for(uint i = 0; i < aryMarco.length(); i++){
            if(aryMarco[i] == szName)
                return aryMarco[i];
        }
        return null;
    }

    array<CEccoScriptItem@> aryItem = {};
    CEccoScriptItem@ GetItem(string szPath){
        for(uint i = 0; i < aryItem.length(); i++){
            if(aryItem[i] == szPath)
                return aryItem[i];
        }
        return null;
    }
    void BuildItemList(){
        array<string>@ aryScripts = IO::FileLineReader(szRootPath + EccoConfig::pConfig.BaseConfig.ScriptsPath);
        for(uint i = 0; i < aryScripts.length();i++){
            CEccoScriptItem@ pItem = CEccoScriptItem(aryScripts[i]);
            if(!pItem.IsEmpty())
                aryItem.insertLast(@pItem);
        }
    }

    bool ExecuteCommand(string szCommandLine, CBasePlayer@ pPlayer){
        array<string>@ aryCommandList = szCommandLine.Split("&&");
        bool bSuccess = true;
        for(uint j=0; j < aryCommandList.length(); j++){
            array<string>@ args = Utility::Select(aryCommandList[j].Split(" "), function(string szLine){ return !szLine.IsEmpty(); });
            if(args.length() > 0){
                string szName = args[0];
                if(!szName.IsEmpty() && szName != "\n"){
                    args.removeAt(0);
                    IEccoMarco@ pMarco = GetMarco(szName);
                    if(pMarco !is null){
                        for(uint i = 0; i < args.length(); i++){
                            args[i] = EccoProcessVar::ProcessVariables(args[i], @pPlayer);
                        }
                        bSuccess = bSuccess && pMarco.Execute(@pPlayer, args);
                        if(!bSuccess)
                            break;
                    }else{
                        Logger::Log("[ERROR - Ecco::Echo] No such macro called " + szName);
                        bSuccess = false;
                    }
                }
            }
        }
        return bSuccess;
    }

    void RandomExecute(array<string>@ aryRandom, CBasePlayer@ pPlayer){
        array<int> aryPossible(aryRandom.length());
        int iPossible = 0;
        for(uint i = 0; i< aryRandom.length(); i++){
            string szLine = aryRandom[i];
            szLine.Trim(" ");
            szLine.Trim("\t");
            iPossible += atoi(szLine.SubString(0, szLine.FindFirstOf(" ")));
            aryPossible[i] = iPossible;
        }
        
        int iRandom = Math.RandomLong(0, iPossible);
        for(uint i = 0; i< aryPossible.length(); i++){
            if(aryPossible[i] >= iRandom){
                string szLine = aryRandom[i];
                szLine.Trim(" ");
                szLine.Trim("\t");
                ExecuteCommand(szLine.SubString(szLine.FindFirstOf(" ")), pPlayer);
                break;
            }
        }
    }

    bool ExecuteFile(string MacroPath, CBasePlayer@ pPlayer){
        CEccoScriptItem@ pItem = GetItem(MacroPath);
        if(pItem !is null && !pItem.IsEmpty())
            return pItem.Excute(@pPlayer);
        else
            return false;
    }
}