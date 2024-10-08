namespace EccoHook{
    namespace Economy{
        enum Code{
            PreChangeBalance = 0,
            PostChangeBalance = 1,
            OpenBuyMenu = 2,
            ExcuteBuyMenu = 3
        }
    }

    final class CHookPackage{
        int Code = -1;
        ref@ Hook = null;

        CHookPackage(int _Code, ref@ _Hook){
            Code = _Code;
            @Hook = @_Hook;
        }
    }

    array<CHookPackage@> aryHooks = {};
    bool RegisterBeforeCheck(int HookCode = -1, ref@ pFunc = null){
        switch(HookCode){
            case Economy::PreChangeBalance: return cast<FuncPreChangeBalanceHook@>(pFunc) !is null;
            case Economy::PostChangeBalance: return cast<FuncPostChangeBalanceHook@>(pFunc) !is null;
            case Economy::OpenBuyMenu: return cast<FuncOpenBuyMenuHook@>(pFunc) !is null;
            case Economy::ExcuteBuyMenu: return cast<FuncExcuteBuyMenuHook@>(pFunc) !is null;
            default: return false;
        }
    }

    void RegisterHook(int HookCode, ref@ pFunc){
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Hook is @pFunc){
                Logger::Log("Existed Hook!: " + HookCode);
                return;
            }
        }
        if(!RegisterBeforeCheck(HookCode, @pFunc)){
            Logger::Log("Mismatched code and reference types!: " + HookCode);
            return;
        }
        aryHooks.insertLast(CHookPackage(HookCode, @pFunc));
    }

    void UnregisterHook(ref@ pFunc){
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Hook is @pFunc){
                aryHooks.removeAt(i);
                return;
            }
        }
        Logger::Log("Hook not registed yet");
    }

    funcdef HookReturnCode FuncPreChangeBalanceHook(CBasePlayer@, int, bool&out);
    void PreChangeBalance(CBasePlayer@ pPlayer, int Amount, bool&out bOut){
        bool bFlag = true;
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Code == Economy::PreChangeBalance){
                bool bTemp = true;
                HookReturnCode flag = cast<FuncPreChangeBalanceHook@>(aryHooks[i].Hook)(pPlayer, Amount, bTemp);
                bFlag = bFlag && bTemp;
                if(flag == HOOK_HANDLED)
                    break;
            }
        }
        bOut = bFlag;
    }

    funcdef HookReturnCode FuncPostChangeBalanceHook(CBasePlayer@, int);
    void PostChangeBalance(CBasePlayer@ pPlayer, int Amount){
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Code == Economy::PostChangeBalance){
                HookReturnCode flag = cast<FuncPostChangeBalanceHook@>(aryHooks[i].Hook)(pPlayer, Amount);
                if(flag == HOOK_HANDLED)
                    break;
            }
        }
    }

    funcdef HookReturnCode FuncOpenBuyMenuHook(const int, const uint, CBasePlayer@, CBaseMenuItem@);
    void OpenBuyMenu(const int iDisplayTime, const uint page, CBasePlayer@ pPlayer, CBaseMenuItem@ pMenu){
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Code == Economy::OpenBuyMenu){
                HookReturnCode flag = cast<FuncOpenBuyMenuHook@>(aryHooks[i].Hook)(iDisplayTime, page, @pPlayer, @pMenu);
                if(flag == HOOK_HANDLED)
                    break;
            }
        }
    }

    funcdef HookReturnCode FuncExcuteBuyMenuHook(CBasePlayer@, uint, CBaseMenuItem@);
    void ExcuteBuyMenu(CBasePlayer@ pPlayer, uint iPage, CBaseMenuItem@ pMenu){
        for(uint i = 0; i < aryHooks.length(); i++){
            if(aryHooks[i].Code == Economy::ExcuteBuyMenu){
                HookReturnCode flag = cast<FuncExcuteBuyMenuHook@>(aryHooks[i].Hook)(@pPlayer, iPage, @pMenu);
                if(flag == HOOK_HANDLED)
                    break;
            }
        }
    }
}