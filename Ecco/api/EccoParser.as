funcdef bool CustomMacroFunc(CBasePlayer@, array<string>@);
class CustomMacro{
  CustomMacroFunc@ MacroFunc;
  CustomMacro(CustomMacroFunc@ NewCustomMacro){
    @MacroFunc = NewCustomMacro;
  }
};

class EccoScriptParser{
  private dictionary ScriptMacros;

  void Register(string CommandName, CustomMacro NewCustomMacro){
    ScriptMacros.set(CommandName, @NewCustomMacro);
  }

  dictionary RetrieveInfo(string MacroPath){
    dictionary ScriptInfo;
    File@ file = g_FileSystem.OpenFile(MacroPath, OpenFile::READ);
    string RandomScript = "";
    bool IsReadingRandom = false;
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        if(int(sLine.Length()) > 0){
          int FirstSymbol = int(sLine.FindFirstOf(":", 0));
          if(FirstSymbol <= 0 || FirstSymbol == int(sLine.Length())){
            continue;
          }else{
            string InfoName = sLine.SubString(0, FirstSymbol);
            InfoName.Replace(" ", "");
            string InfoContent = sLine.SubString(FirstSymbol);
            for(int i=1; i<int(InfoContent.Length()); i++){
              if(InfoContent[i] == " "){
                continue;
              }else{
                InfoContent = InfoContent.SubString(i);
                break;
              }
            }
            ScriptInfo.set(InfoName, InfoContent);
          }
        }
      }
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - Ecco::Echo] Cannot read such script file in " + MacroPath + ", check if it exists and SCDS has the permission to access it!\n");
    }
    return ScriptInfo;
  }

  bool ExecuteComm(string CommandLine, CBasePlayer@ pPlayer){
    array<string> CommandList = CommandLine.Split("&&");
    bool Success = true;
    
    for(int j=0; j<int(CommandList.length()); j++){
      array<string> args = CommandList[j].Split(" ");
      while(args[args.length()-1] == ""){
        args.removeAt(args.length()-1);
      }
      while(args[0] == ""){
        args.removeAt(0);
      }
      if(args.length() >= 1){
        string FuncName = args[0];
        args.removeAt(0);
        if(FuncName != "" && FuncName != "\n"){
          if(ScriptMacros.exists(FuncName)){
            CustomMacro@ Macro = cast<CustomMacro@>(ScriptMacros[FuncName]);
            for(int i=0; i<int(args.length()); i++){
              args[i] = ProcessVariables(args[i], pPlayer);
            }
            Success = Success && Macro.MacroFunc(pPlayer, args);
            if(!Success){
              break;
            }
          }else{
            g_Game.AlertMessage(at_console, "[ERROR - Ecco::Echo] No such macro called " + FuncName + "\n");
            Success = false;
          }
        }
      }
    }
    
    return Success;
  }

  bool ExecuteFile(string MacroPath, CBasePlayer@ pPlayer){
    bool Success = true;
    File@ file = g_FileSystem.OpenFile(MacroPath, OpenFile::READ);
    string RandomScript = "";
    bool IsReadingRandom = false;
    if(file !is null && file.IsOpen()){
      while(!file.EOFReached()){
        string sLine;
        file.ReadLine(sLine);
        if(int(sLine.Length()) > 0){
          if(int(sLine.FindFirstOf(":", 0)) >= 0){
            continue;
          }
          
          if(int(sLine.FindFirstOf("{", 0)) >= 0){
            sLine.Replace("{", "");
            string Detection = sLine;
            Detection.Trim(" ");
            if(Detection != ""){
              RandomScript = sLine + "\n";
            }
            IsReadingRandom = true;
            continue;
          }
          
          if(int(sLine.FindFirstOf("}", 0)) >= 0){
            sLine.Replace("}", "");
            string Detection = sLine;
            Detection.Trim(" ");
            if(Detection != ""){
              RandomScript += sLine;
            }
            RandomExecute(RandomScript, pPlayer);
            RandomScript = "";
            IsReadingRandom = false;
            continue;
          }
          
          if(IsReadingRandom){
            RandomScript += sLine + "\n";
          }else{
            string Detection = sLine;
            Detection.Trim(" ");
            if(Detection != ""){
              if(!ExecuteComm(sLine, pPlayer)){
                Success = false;
                break;
              }
            }
          }
        }
      }
      file.Close();
    }else{
      g_Game.AlertMessage(at_console, "[ERROR - Ecco::Echo] Cannot read such script file in " + MacroPath + ", check if it exists and SCDS has the permission to access it!\n");
      Success = false;
    }
    return Success;
  }

  private void RandomExecute(string RawLines, CBasePlayer@ pPlayer){
    dictionary RandomElements;
    RandomElements.deleteAll();
    array<string> ThisLine = RawLines.Split("\n");
    for(int i=0; i<int(ThisLine.length()); i++){
      if(ThisLine[i].Length() <= 0){
        ThisLine.removeAt(i);
        continue;
      }
      array<string> ThisArgs = ThisLine[i].Split(" ");
      while(ThisArgs[ThisArgs.length()-1] == ""){
        ThisArgs.removeAt(ThisArgs.length()-1);
      }
      while(ThisArgs[0] == ""){
        ThisArgs.removeAt(0);
      }
      int Possibility = atoi(ThisArgs[0]);
      if(Possibility > 0){
        ThisArgs.removeAt(0);
        ThisLine[i] = "";
        for(int j=0; j<int(ThisArgs.length()); j++){
          ThisLine[i] += ThisArgs[j];
          if(j != int(ThisArgs.length())-1){
            ThisLine[i] += " ";
          }
        }
        RandomElements.set(ThisLine[i], Possibility);
      }else{
        ThisLine.removeAt(i);
      }
    }
    
    array<string> dictKeys = RandomElements.getKeys();
    int randomSum = 0;
    for(int i=0; i<int(dictKeys.length()); i++){
      randomSum += int(RandomElements[dictKeys[i]]);
    }
    int randomNum = int(Math.RandomLong(0, randomSum));
    int thisRandom = 0;
    for(int i=0; i<int(dictKeys.length()); i++){
      thisRandom += int(RandomElements[dictKeys[i]]);
      if(thisRandom >= randomNum){
        if(dictKeys[i] != ""){
          ExecuteComm(dictKeys[i], pPlayer);
        }
        break;
      }
    }
  }
  
  private string ProcessVariables(string Input, CBasePlayer@ pPlayer){ // TODO
    if(Input.Find("%PLAYER%", 0) >= 0){
      Input.Replace("%PLAYER%", pPlayer.pev.netname);
    }
    if(Input.Find("%RANDOMPLAYER%", 0) >= 0){
      Input.Replace("%RANDOMPLAYER%", GetRandomPlayerName());
    }
    if(Input.Find("%BALANCE%", 0) >= 0){
      Input.Replace("%BALANCE%", string(e_PlayerInventory.GetBalance(pPlayer)));
    }
    return Input;
  }
  
  private string GetRandomPlayerName(){
    string Name = "";
    if(g_PlayerFuncs.GetNumPlayers() > 0){
      CBasePlayer@ pPlayer = null;
      while(pPlayer is null){
        int Index = int(Math.RandomLong(1, g_Engine.maxClients));
        @pPlayer = g_PlayerFuncs.FindPlayerByIndex(Index);
      }
      Name = pPlayer.pev.netname;
    }
    return Name;
  }
}
EccoScriptParser e_ScriptParser;
