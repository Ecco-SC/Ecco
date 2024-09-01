namespace EccoUtility{
    string GetNextMap(){
        string nextMap = g_EngineFuncs.CVarGetString("mp_nextmap");
        if(nextMap == "")
            nextMap = g_EngineFuncs.CVarGetString("mp_survival_nextmap");
        return nextMap;
    }

    float GetLCS( string&in str1, string&in str2)
    {
        if( str1 == "" || str2 == "")
            return 0.0;
        array<array<int>> aryMatrix (str1.Length(), array<int>( str2.Length(), 0));
        int index = 0;
        int length = 0;
        for(uint i = 0; i < str1.Length(); i++){
            for(uint j = 0; j < str2.Length(); j++){
                int n = int(i)-1 >= 0 && int(j)-1 >= 0 ? aryMatrix[i-1][j-1] : 0;
                aryMatrix[i][j] = str1[i] == str2[j] ? n+1 : 0;
                if( aryMatrix[i][j] > length ){
                    length = aryMatrix[i][j];
                    index = i;
                }
            }
        }
        return float(length)/float( str2.Length() > str1.Length() ? str2.Length() : str1.Length() );
    }
    bool CanOpenShop(string arg){
        if(EccoConfig::pConfig.BuyMenu.AllowIgnoreBuyPrefix && EccoConfig::pConfig.BuyMenu.OpenShopTrigger.find(arg) > -1)
            return true;
        else if((arg.StartsWith("!") || arg.StartsWith("/") || arg.StartsWith("\\") || arg.StartsWith("$")) && 
            EccoConfig::pConfig.BuyMenu.OpenShopTrigger.find(arg.SubString(1)) > -1)
            return true;
        return false;
    }
    string PadSpace(uint uiLength, string&in inStr, string ptrChar = " "){
        string szTemp = inStr;
        for(uint i = inStr.Length(); i < uiLength; i++){
            szTemp += ptrChar;
        }
        return szTemp;
    }
    string GetAdminLevelString(ConCommandFlags_t flag){
        switch(int(flag)){
            case 0: return "None";
            case 1: return "Admin";
            case 2: return "Cheat/Server";
            default: return "Forbidden";
        }
    }
}