namespace EccoProcessVar{
    funcdef string ProcessVariablePlayerFunc(string, string, CBasePlayer@);
    funcdef string ProcessVariableMenuFunc(string, string, CBaseMenuItem@);
    class CProcessVariableItem{
        private string szName;
        private ProcessVariablePlayerFunc@ pFunc;
        private ProcessVariableMenuFunc@ pMenuFunc;
        CProcessVariableItem(string _szName, ProcessVariablePlayerFunc@ _pFunc){
            this.szName = _szName;
            @this.pFunc = @_pFunc;
        }

        CProcessVariableItem(string _szName, ProcessVariableMenuFunc@ _pFunc){
            this.szName = _szName;
            @this.pMenuFunc = @_pFunc;
        }

        string Execute(string szInput, CBasePlayer@ pPlayer){
            if(@pFunc !is null)
                return szInput.Find(szName, 0) != String::INVALID_INDEX ? pFunc(szInput, szName, @pPlayer) : szInput;
            return szInput;
        }

        string Execute(string szInput, CBaseMenuItem@ pMenu){
            if(@pMenuFunc !is null)
                return szInput.Find(szName, 0) != String::INVALID_INDEX ? pMenuFunc(szInput, szName, @pMenu) : szInput;
            return szInput;
        }
    }

    array<CProcessVariableItem@> aryItems = {};
    void Register(string szName, ProcessVariablePlayerFunc@ pFunc){
        aryItems.insertLast(CProcessVariableItem(szName, @pFunc));
    }

    void Register(string szName, ProcessVariableMenuFunc@ pFunc){
        aryItems.insertLast(CProcessVariableItem(szName, @pFunc));
    }

    string ProcessVariables(string szInput, CBasePlayer@ pPlayer){
        for(uint i  = 0; i < aryItems.length(); i++){
            if(@pPlayer !is null)
                szInput = aryItems[i].Execute(szInput, @pPlayer);
        }
        return szInput;
    }

    string ProcessVariables(string szInput, CBaseMenuItem@ pMenuItem){
        for(uint i  = 0; i < aryItems.length(); i++){
            if(@pMenuItem !is null)
                szInput = aryItems[i].Execute(szInput, @pMenuItem);
        }
        return szInput;
    }
}