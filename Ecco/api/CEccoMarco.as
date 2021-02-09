funcdef bool CustomMacroFunc(CBasePlayer@, array<string>@);
interface IEccoMarco{
    string Command();
    bool Execute(CBasePlayer@ pPlayer, array<string>@ args);
    bool opEquals(string szName);
}

class CEccoMarco : IEccoMarco{
    private string _Command;
    private CustomMacroFunc@ _Marco;

    CEccoMarco(string _szCommand_, CustomMacroFunc@ _Marco_){
        this._Command = _szCommand_;
        @this._Marco = @_Marco_;
    }

    string Command(){
        return _Command;
    }

    bool Execute(CBasePlayer@ pPlayer, array<string>@ args){
        return _Marco(@pPlayer, @args);
    }

    bool opEquals(string szName){
        return this._Command == szName;
    }
}