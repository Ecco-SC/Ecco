namespace EccoUtility{
    string GetNextMap(){
        string nextMap = g_EngineFuncs.CVarGetString("mp_nextmap");
        if(nextMap == "")
            nextMap = g_EngineFuncs.CVarGetString("mp_survival_nextmap");
        return nextMap;
    }
}