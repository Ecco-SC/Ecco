
namespace EccoAddon{
namespace EccoMapEnable{
    string GetAuthor(){
      return "Dr.Abc";
    }
    shared bool IsMapValid(){
        array<string>@ aryMaps = IO::FileLineReader(szRootPath + EccoConfig::pConfig.BaseConfig.BanMapPath, function(string szLine){ if(szLine != g_Engine.mapname){return "\n";}return g_Engine.mapname;});
        if(aryMaps.length() > 0 && aryMaps[aryMaps.length() - 1] == g_Engine.mapname)
            return false;
        return true;
    }
}
}