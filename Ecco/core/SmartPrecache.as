namespace SmartPrecache{
    void PrecacheByList(){
        array<string>@ aryList = IO::FileLineReader(szRootPath + "Precache.txt");
        if(aryList !is null && aryList.length() > 0){
            for(uint i = aryList.length();i++){
                string szLine = aryList[i];
                if(szLine != ""){
                    if(szLine.StartsWith("sound/") || szLine.StartsWith("media/")){
                        string BareName = szLine.SubString(6);
                        g_SoundSystem.PrecacheSound(BareName);
                        g_Game.PrecacheGeneric(szLine);
                    }
                    else{
                        if(szLine.StartsWith("models/") )
                            g_Game.PrecacheModel(szLine);
                        else
                            g_Game.PrecacheGeneric(szLine);
                    }
                }
            }
        }
        else
            Logger::Log("[ERROR - Ecco] Cannot read Precache.txt, check if it exists and SCDS has the permission to access it!");
    }
}