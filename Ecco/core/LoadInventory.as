namespace EccoInventoryLoader{
  void LoadPlayerInventory(CBasePlayer@ pPlayer){
    array<string> Inventory = e_PlayerInventory.GetInventory(pPlayer);
    for(int i=0; i<int(Inventory.length()); i++){
      e_ScriptParser.ExecuteFile(szRootPath + "scripts/"+Inventory[i]+".echo", pPlayer);
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[INFO - Ecco] Loaded " + Inventory[i] + " from your inventory...\n");
    }
  }
}