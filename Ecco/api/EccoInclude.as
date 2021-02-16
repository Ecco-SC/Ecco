namespace EccoInclude{
    class CEccoAddonMethod{
        string Name;
        string Author;
        string ContactInfo;
        Reflection::Function@ PluginInit = null;
        Reflection::Function@ MapInit = null;
        Reflection::Function@ MapActivate = null;
        Reflection::Function@ MapStart = null;

        CEccoAddonMethod(string _Name){
            this.Name = _Name;
        }

        void ExcutePluginInit(){
            if(@this.PluginInit !is null)
                this.PluginInit.Call();
        }
        void ExcuteMapInit(){
            if(@this.MapInit !is null)
                this.MapInit.Call();
        }
        void ExcuteMapActivate(){
            if(@this.MapActivate !is null)
                this.MapActivate.Call();
        }
        void ExcuteMapStart(){
            if(@this.MapStart !is null)
                this.MapStart.Call();
        }
    }
    array<CEccoAddonMethod@> aryAddon = {};

    CEccoAddonMethod@ GetAddon(string szName){
        for(uint i = 0; i < aryAddon.length(); i++){
            if(aryAddon[i].Name == szName)
                return aryAddon[i];
        }
        return null;
    }

    string AddAddonInfo(string szIn){
        for(uint i = 0; i < aryAddon.length(); i++){
            if(!aryAddon[i].Author.IsEmpty()){
                szIn += "    Submodule:" + aryAddon[i].Name + "\n";
                szIn += "      Author:" + aryAddon[i].Author + "\n";
                szIn += "      ContactInfo:" + aryAddon[i].ContactInfo + "\n";
            }
        }
        return szIn;
    }

    void AddonListBuilder(){
        //Build Addon List
        Reflection::IReflectionGroup@ pModule = Reflection::g_Reflection.Module;

        for(uint i = 0; i < pModule.GetGlobalFunctionCount(); i++){
            Reflection::Function@ pFunction = pModule.GetGlobalFunctionByIndex(i);
            if(@pFunction !is null && pFunction.GetNamespace().StartsWith("EccoAddon::")){
                string szSpace = pFunction.GetNamespace().SubString(11);
                CEccoAddonMethod@ pAddon = GetAddon(szSpace);
                if(@pAddon is null){
                    @pAddon = CEccoAddonMethod(szSpace);
                    aryAddon.insertLast(@pAddon);
                }
                string szName = pFunction.GetName();
                if(szName == "PluginInit")
                    @pAddon.PluginInit = pFunction;
                else if(szName == "MapInit")
                    @pAddon.MapInit = pFunction;
                else if(szName == "MapActivate")
                    @pAddon.MapActivate = pFunction;
                else if(szName == "MapStart")
                    @pAddon.MapStart = pFunction;
                else if(szName == "GetAuthor")
                    pFunction.Call().ToAny().retrieve(pAddon.Author);
                else if(szName == "GetContactInfo")
                    pFunction.Call().ToAny().retrieve(pAddon.ContactInfo);
            }
        }
    }


    void PluginInit(){
        for(uint i = 0; i < aryAddon.length(); i++){
            aryAddon[i].ExcutePluginInit();
        }
    }

    void MapInit(){
        for(uint i = 0; i < aryAddon.length(); i++){
            aryAddon[i].ExcuteMapInit();
        }
    }

    void MapActivate(){
        for(uint i = 0; i < aryAddon.length(); i++){
            aryAddon[i].ExcuteMapActivate();
        }
    }
    
    void MapStart(){
        for(uint i = 0; i < aryAddon.length(); i++){
            aryAddon[i].ExcuteMapStart();
        }
    }
}