namespace EccoScoreBuffer{
  CScheduledFunction@ RefreshScore;
  dictionary PlayerScoreBuffer;

  void ResetPlayerBuffer(CBasePlayer@ pPlayer){
    PlayerScoreBuffer.set(e_PlayerInventory.GetUniquePlayerId(pPlayer), 0);
  }

  void RegisterTimer(){
    g_Scheduler.ClearTimerList();
    @RefreshScore = null;
    @RefreshScore = g_Scheduler.SetInterval("RefreshBuffer", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES);
  }

  void RefreshBuffer(){
    for(int i=0; i<g_Engine.maxClients; i++){
      CBasePlayer@ pPlayer =  g_PlayerFuncs.FindPlayerByIndex(i+1);
      if(pPlayer !is null){
        string PlayerUniqueId = e_PlayerInventory.GetUniquePlayerId(pPlayer);
        int ScoreChange = int(pPlayer.pev.frags) - int(PlayerScoreBuffer[PlayerUniqueId]);
        if(ScoreChange != 0){
          float ConfigMultiplier = atof(string(EccoConfig["ScoreToMoneyMultiplier"]));
          e_PlayerInventory.ChangeBalance(pPlayer, int(ScoreChange * ConfigMultiplier));
        }
        PlayerScoreBuffer[PlayerUniqueId] = int(pPlayer.pev.frags);
      }
    }
  }
}