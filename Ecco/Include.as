#include "api/EccoParser"
#include "api/EccoPlayers"
#include "api/IO"
#include "api/Logger"
#include "api/EccoProcessVar"
#include "api/CEccoMarco"

/*
                    ADDON INCLUDE AREA
                Put your addons below to add them!
*/
#include "addons/EchoBase"

dictionary EccoConfig;

void InitEcco(){
  EccoConfig = EccoUtils::RefreshEccoConfig();

  /*
                    ADDON REGISTER AREA
                Put your addons below to activate them!
  */
  EccoBase::Activate();
}

namespace EccoUtils{
  dictionary RefreshEccoConfig(){
    dictionary TempConfig;
    string ConfigPath = szRootPath + "Config.txt";
    File@ file = g_FileSystem.OpenFile(ConfigPath, OpenFile::READ);
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        
        
        array<string> ConfigFields = sLine.Split("	");
        if(ConfigFields.length() >= 2){
          TempConfig.set(ConfigFields[0], ConfigFields[1]);
        }else{
          g_Game.AlertMessage(at_console, "[ERROR - Ecco] Config format error!\n");
        }
        
        
      }
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - Ecco] Cannot read the config file, check if it exists and SCDS has the permission to access it!\n");
    }
    return TempConfig;
  }
}