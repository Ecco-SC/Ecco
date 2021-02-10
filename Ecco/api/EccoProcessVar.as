namespace EccoProcessVar{
    funcdef string ProcessVariableFunc(string, string, CBasePlayer@);
    class CProcessVariableItem{
        private string szName;
        private ProcessVariableFunc@ pFunc;
        CProcessVariableItem(string _szName, ProcessVariableFunc@ _pFunc){
            this.szName = _szName;
            @this.pFunc = @_pFunc;
        }

        string Execute(string szInput, CBasePlayer@ pPlayer){
            return szInput.Find(szName, 0) != String::INVALID_INDEX ? pFunc(szInput, szName, @pPlayer) : szInput;
        }
    }

    array<CProcessVariableItem@> aryItems = {};
    void Register(string szName, ProcessVariableFunc@ pFunc){
        aryItems.insertLast(CProcessVariableItem(szName, @pFunc));
    }

    string ProcessVariables(string szInput, CBasePlayer@ pPlayer){
        for(uint i  = 0; i < aryItems.length(); i++){
            szInput = aryItems[i].Execute(szInput, @pPlayer);
        }
        return szInput;
    }
}