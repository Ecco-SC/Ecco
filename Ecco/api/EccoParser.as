class CEccoScriptInfo{
    private dictionary dicInfo = {};
    void Set(string szKey, string szVal){
        dicInfo.set(szKey, szVal);
    }
    string Get(string szKey){
        return string(dicInfo[szKey]);
    }
    string opIndex(string szKey){
        return Get(szKey);
    }
    bool exists(string szKey){
        return dicInfo.exists(szKey);
    }
}

class CEccoScriptParser{
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

    CEccoScriptInfo@ RetrieveInfo(string MacroPath){
        CEccoScriptInfo pInfo;
        File @pFile = g_FileSystem.OpenFile(MacroPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen()){
            string szLine;
            while (!pFile.EOFReached()){
                pFile.ReadLine(szLine);
                szLine.Trim();
                if(!szLine.IsEmpty()){
                    uint iFirstSymbol = szLine.FindFirstOf(":", 0);
                    if(iFirstSymbol > 0 && iFirstSymbol < szLine.Length()){
                        string szInfoName = szLine.SubString(0, iFirstSymbol);
                        szInfoName.Trim();
                        string szInfoContent = szLine.SubString(iFirstSymbol);
                        szInfoContent.Trim();
                        pInfo.Set(szInfoName, szInfoContent);
                    }
                }
                continue;
            }
            pFile.Close();
        }
        return @pInfo;
    }

    bool ExecuteCommand(string szCommandLine, CBasePlayer@ pPlayer){
        array<string> aryCommandList = szCommandLine.Split("&&");
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
                            args[i] = EccoProcessVar::ProcessVariables(args[i], pPlayer);
                        }
                        bSuccess = bSuccess && pMarco.Execute(@pPlayer, args);
                        if(!bSuccess)
                            break;
                    }else{
                        g_Game.AlertMessage(at_console, "[ERROR - Ecco::Echo] No such macro called " + szName + "\n");
                        bSuccess = false;
                    }
                }
            }
        }
        return bSuccess;
    }

    private void RandomExecute(array<string>@ aryRandom, CBasePlayer@ pPlayer){
        dictionary dicRandomElements = {};
        for(uint i = 0; i< aryRandom.length(); i++){
            array<string>@ aryThisArgs = Utility::Select(aryRandom[i].Split(" "), function(string szLine){return !szLine.IsEmpty();});
            int iPossibility = atoi(aryThisArgs[0]);
            if(iPossibility > 0){
                aryThisArgs.removeAt(0);
                aryRandom[i] = "";
                for(uint j = 0; j < aryThisArgs.length(); j++){
                    aryRandom[i] += aryThisArgs[j];
                    if( j != aryThisArgs.length() - 1 )
                        aryRandom[i] += " ";
                }
                dicRandomElements.set(aryRandom[i], iPossibility);
            }else
                aryRandom.removeAt(i);
        }
        
        array<string>@ dictKeys = dicRandomElements.getKeys();
        int randomSum = 0;
        for(uint i = 0; i < dictKeys.length(); i++){
            randomSum += int(dicRandomElements[dictKeys[i]]);
        }
        int randomNum = int(Math.RandomLong(0, randomSum));
        int thisRandom = 0;
        for(uint i=0; i < dictKeys.length(); i++){
            thisRandom += int(dicRandomElements[dictKeys[i]]);
            if(thisRandom >= randomNum){
                if(dictKeys[i] != "")
                    ExecuteCommand(dictKeys[i], pPlayer);
                break;
            }
        }
    }

    bool ExecuteFile(string MacroPath, CBasePlayer@ pPlayer){
        bool bSuccess = true;
        array<string> aryRandom = {};
        bool bIsReadingRandom = false;
        File @pFile = g_FileSystem.OpenFile(MacroPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen()){
            string szLine;
            while (!pFile.EOFReached()){
                pFile.ReadLine(szLine);
                szLine.Trim();
                if(!szLine.IsEmpty()){
                    if(szLine.Compare(":") != 0)
                        continue;
                    if(szLine.StartsWith("{")){
                        bIsReadingRandom = true;
                        string szDetection = szLine.Replace("{", "");
                        szDetection.Trim();
                        if(!szDetection.IsEmpty())
                            aryRandom.insertLast(szDetection);
                        continue;;
                    }
                    if(szLine.EndsWith("}")){
                        bIsReadingRandom = false;
                        string szDetection = szLine.Replace("}", "");
                        szDetection.Trim();
                        if(!szDetection.IsEmpty())
                            aryRandom.insertLast(szDetection);
                        RandomExecute(@Utility::Select(aryRandom, function(string szLine){ return !szLine.IsEmpty(); }), @pPlayer);
                        aryRandom = {};
                        continue;
                    }
                    if(bIsReadingRandom)
                        aryRandom.insertLast(szLine);
                    else{
                        string szDetection = szLine;
                        szDetection.Trim();
                        if(!szDetection.IsEmpty()){
                            if(!ExecuteCommand(szLine, pPlayer)){
                                bSuccess = false;
                                break;
                            }
                        }
                    }
                }
                continue;
            }
            pFile.Close();
        }
        return bSuccess;
    }
}
CEccoScriptParser e_ScriptParser;