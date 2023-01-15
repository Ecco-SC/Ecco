final class CEccoScriptItem{
    private string szName;
    private string szPath;
    private array<array<string>@> aryExcuteBlock = {};
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
                EccoScriptParser::RandomExecute(aryExcuteBlock[i], @pPlayer);
            else if(aryExcuteBlock[i].length() == 1)
                bFlag = bFlag && EccoScriptParser::ExecuteCommand(aryExcuteBlock[i][0], @pPlayer);
        }
        return bFlag;
    }
}