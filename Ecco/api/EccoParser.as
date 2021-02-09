class CEccoScriptItem{
    private string szName;
    private string szPath;
    private array<array<string>> aryExcuteBlock = {};
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

    bool opEquals(string _szPath){
        return szPath == _szPath;
    }

    bool IsEmpty(){
        return aryExcuteBlock.length() <= 0;
    }

    string Name{
        get {return szName;}
    }

    CEccoScriptItem(string _Path){
        this.szPath = szRootPath + "scripts/" + _Path + ".echo";
        this.szName = _Path;
        array<string> aryRandom = {};
        bool bIsReadingRandom = false;
        File @pFile = g_FileSystem.OpenFile(this.szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen()){
            string szLine;
            while (!pFile.EOFReached()){
                pFile.ReadLine(szLine);
                szLine.Trim();
                if(!szLine.IsEmpty()){
                    if(szLine.Find(":") != String::INVALID_INDEX){
                        uint iFirstSymbol = szLine.FindFirstOf(":", 0);
                        if(iFirstSymbol > 0 && iFirstSymbol < szLine.Length()){
                            string szInfoName = szLine.SubString(0, iFirstSymbol);
                            szInfoName.Trim();
                            string szInfoContent = szLine.SubString(iFirstSymbol + 1);
                            szInfoContent.Trim();
                            this.Set(szInfoName, szInfoContent);
                        }
                        continue;
                    }
                    if(szLine.StartsWith("{")){
                        bIsReadingRandom = true;
                        string szDetection = szLine.Replace("{", "");
                        szDetection.Trim();
                        if(!szDetection.IsEmpty())
                            aryRandom.insertLast(szDetection);
                        continue;
                    }
                    if(szLine.EndsWith("}")){
                        bIsReadingRandom = false;
                        string szDetection = szLine.Replace("}", "");
                        szDetection.Trim();
                        if(!szDetection.IsEmpty())
                            aryRandom.insertLast(szDetection);
                        aryExcuteBlock.insertLast(Utility::Select(aryRandom, function(string szLine){return !szLine.IsEmpty();}));
                        aryRandom = {};
                        continue;
                    }
                    if(bIsReadingRandom)
                        aryRandom.insertLast(szLine);
                    else
                        aryExcuteBlock.insertLast(array<string> = {szLine});
                }
            }
            pFile.Close();
        }
    }

    bool Excute(CBasePlayer@ pPlayer){
    	bool bFlag = true;
        for(uint i = 0; i < aryExcuteBlock.length(); i++){
            if(aryExcuteBlock[i].length() > 1)
                e_ScriptParser.RandomExecute(aryExcuteBlock[i], @pPlayer);
            else if(aryExcuteBlock[i].length() == 1)
                bFlag = bFlag && e_ScriptParser.ExecuteCommand(aryExcuteBlock[i][0], @pPlayer);
        }
        return bFlag;
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

    array<CEccoScriptItem@> aryItem = {};
    CEccoScriptItem@ GetItem(string szPath){
        for(uint i = 0; i < aryItem.length(); i++){
            if(aryItem[i] == szPath)
                return aryItem[i];
        }
        return null;
    }
    void BuildItemList(){
        array<string>@ aryScripts = IO::FileLineReader(szRootPath + "Scripts.txt");
        for(uint i = 0; i < aryScripts.length();i++){
            CEccoScriptItem@ pItem = CEccoScriptItem(aryScripts[i]);
            if(!pItem.IsEmpty())
                aryItem.insertLast(@pItem);
        }
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
                        Logger::Log("[ERROR - Ecco::Echo] No such macro called " + szName);
                        bSuccess = false;
                    }
                }
            }
        }
        return bSuccess;
    }

    void RandomExecute(array<string>@ aryRandom, CBasePlayer@ pPlayer){
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
        CEccoScriptItem@ pItem = GetItem(MacroPath);
        if(pItem !is null && !pItem.IsEmpty())
            return pItem.Excute(@pPlayer);
        else
            return false;
    }
}
CEccoScriptParser e_ScriptParser;