#include "bsConf"
string WeaponScripts = "";
void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
	g_Module.ScriptInfo.SetContactInfo("Please Don't.");
  ImportItems();
  ImportBanlist();
  File@ file = g_FileSystem.OpenFile("scripts/plugins/store/Scripts.txt", OpenFile::WRITE);
  if(file !is null && file.IsOpen()){
    file.Write(WeaponScripts);
    file.Close();
  }else{
    g_Game.AlertMessage(at_console, "[ERROR - EccoImporter] Cannot write in script file!\n");
  }
  g_Game.AlertMessage(at_console, "[EccoImporter] Mission Accomplished!\n[EccoImporter] Please check .echo files, BannedMaps.txt and Scripts.txt in [scripts/plugins/store/] and move them to [scripts/plugins/Ecco]!\n[EccoImporter] Good luck, and fair seas!\n");
}

void ImportItems(){
  for(int i=0; i<int(bsConf.length()); i++){
    // entity, name, price, category
    WeaponScripts += bsConf[i][0] + "\n";
    string Content = "name: " + bsConf[i][1] + "\n";
    Content += "cost: " + bsConf[i][2] + "\n";
    Content += "category: " + bsConf[i][3] + "\n";
    array<string> BlacklistMaps;
    for(int j=0; j<int(disallowedWeapons.length()); j++){
      int Index = disallowedWeapons[j].find(bsConf[i][1]);
      if(Index >= 1){
        BlacklistMaps.insertLast(disallowedWeapons[j][0]);
      }
    }
    if(int(BlacklistMaps.length()) > 0){
      Content += "blacklist:";
      for(int j=0; j<int(BlacklistMaps.length()); j++){
        Content += " " + BlacklistMaps[j];
      }
      Content += "\n";
    }
    Content += "give " + bsConf[i][0];
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/" + bsConf[i][0] + ".echo", OpenFile::WRITE);
    if(file !is null && file.IsOpen()){
      file.Write(Content);
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - EccoImporter] Cannot write in script file!\n");
    }
  }
}

void ImportBanlist(){
  string Content = "";
  for(int i=0; i<int(disallowedWeapons.length()); i++){
    if(disallowedWeapons[i].length() == 1){
      Content += disallowedWeapons[i][0] + "\n";
    }
  }
  File@ file = g_FileSystem.OpenFile("scripts/plugins/store/BannedMaps.txt", OpenFile::WRITE);
  if(file !is null && file.IsOpen()){
    file.Write(Content);
    file.Close();
  }else{
    g_Game.AlertMessage(at_console, "[ERROR - EccoImporter] Cannot write in banlist file!\n");
  }
}