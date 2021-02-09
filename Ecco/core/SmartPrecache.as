namespace SmartPrecache{
  void PrecacheByList(){
    File@ file = g_FileSystem.OpenFile(szRootPath + "Precache.txt", OpenFile::READ);
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        
        if(sLine != ""){
          if(sLine.Find("sound/", 0) == 0 || sLine.Find("media/", 0) == 0){
            string BareName = sLine.SubString(6);
            g_SoundSystem.PrecacheSound(BareName);
            g_Game.PrecacheGeneric(sLine);
          }else{
            if(sLine.Find("models/", 0) == 0){
              g_Game.PrecacheModel(sLine);
            }else{
              g_Game.PrecacheGeneric(sLine);
            }
          }
        }
      }
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - Ecco] Cannot read Precache.txt, check if it exists and SCDS has the permission to access it!\n");
    }
  }
}