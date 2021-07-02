//https://developer.valvesoftware.com/wiki/SteamID
//https://github.com/DrAbcrealone/AngelScripts/blob/master/lib/SteamIDHelper.as
enum STEAMID_FLAG{
    SteamID_Invalid = -1,
    SteamID_32,
    SteamID_64,
    SteamID_Community
}
final class CSteamIDHelper{
    STEAMID_FLAG checkSteamID(string sz32){
        if(sz32.StartsWith("STEAM_0:"))
            return SteamID_32;
        if(sz32.StartsWith("[U:1:") && sz32.EndsWith("]"))
            return SteamID_Community;
        if(isalnum(sz32) && sz32.Length() == 17 && sz32.StartsWith("76561"))
            return SteamID_64;
        return SteamID_Invalid;
    }
    STEAMID_FLAG checkSteamID(int64 i64){
        return i64 > 0x0110000200000000 || i64 < 0x0110000100000000 ? SteamID_Invalid : SteamID_64;
    }
    int64 to64(string sz32){
        switch(this.checkSteamID(sz32)){
            case SteamID_Community: return atoi64(sz32.SubString(5, sz32.Length() - 6)) + 0x0110000100000000;
            case SteamID_32: return atoi64(sz32.SubString(10)) * 2 + atoi64(sz32.SubString(8,1) + 0x0110000100000000);
            case SteamID_64: return atoi64(sz32);
        }
        return -1;
    }
    string to32(int64 i64){
        return this.checkSteamID(i64) == SteamID_64 ? "STEAM_0:" + i64 % 2 + ":" + ((i64 - 0x0110000100000000) >> 1) : String::EMPTY_STRING;
    }
    string to32(string szIn){
        switch(this.checkSteamID(szIn)){
            case SteamID_Community: {
                int iTemp = atoi(szIn.SubString(5, szIn.Length() - 6));
                return "STEAM_0:" + (iTemp % 2) + ":" + int(iTemp / 2);
            }
            case SteamID_32: return szIn;
            case SteamID_64: return this.to32(atoi64(szIn));
        }
        return String::EMPTY_STRING;
    }
    string toCommunity(int64 i64){
        return this.checkSteamID(i64) != SteamID_64 ? String::EMPTY_STRING : "[U:1:" + (i64 - 0x0110000100000000) + "]";
    }
    string toCommunity(string sz32){
        switch(this.checkSteamID(sz32)){
            case SteamID_Community: return sz32;
            case SteamID_32: return "[U:1:" + string(atoi(sz32.SubString(10)) * 2 + atoi(sz32.SubString(8,1))) + "]";
            case SteamID_64: return this.toCommunity(atoi64(sz32));
        }
        return String::EMPTY_STRING;
    }
}
CSteamIDHelper g_SteamIDHelper;