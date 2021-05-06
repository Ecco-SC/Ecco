namespace INIPraser{
//实数
Regex::Regex@ pRegex = Regex::Regex("^(-?\\d+)(\\.\\d+)?$");
//整数
Regex::Regex@ fRegex = Regex::Regex("^-?[0-9]\\d*$");
//向量
Regex::Regex@ vRegex = Regex::Regex("^[+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)?$");
//二维向量
Regex::Regex@ v2Regex = Regex::Regex("^[+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)?$");
//颜色
Regex::Regex@ cRegex = Regex::Regex("^[+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)? [+-]?\\d+(\\.\\d+)?$");


enum INI_VALUE_TYPE
{
    INI_INT=0,
    INI_FLOAT,
    INI_BOOL,
    INI_STRING,
    INI_VECTOR,
    INI_VECTOR2D,
    INI_RGBA
}

int getStringType(string sz)
{
    //布尔型
    string temp = sz;
    if(sz.ToLowercase() == "true" || sz.ToLowercase() == "false")
        return INI_BOOL;
    //整数型
    else if(Regex::Match(temp, @fRegex))
        return INI_INT;
    //实数型
    else if(Regex::Match(temp, @pRegex))
        return INI_FLOAT;
    //二维向量型
    else if(Regex::Match(temp, @v2Regex))
        return INI_VECTOR2D;
    //向量型
    else if(Regex::Match(temp, @vRegex))
        return INI_VECTOR;
    //颜色型
    else if(Regex::Match(temp, @cRegex))
        return INI_RGBA;
    else
        return INI_STRING;
}

class CINI{
    private array<CINISection@> arySection = {};

    CINI(){}
    CINI(string szFilePath){
        File @pFile = g_FileSystem.OpenFile(szFilePath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen()){
            string szLine;
            string szNowSection = String::EMPTY_STRING;
            while (!pFile.EOFReached()){
                pFile.ReadLine(szLine);
                szLine.Trim();
                //comment
                if(szLine.StartsWith(";"))
                    continue;
                if(szLine.StartsWith("[") || szLine.EndsWith("]")){
                    szNowSection = szLine.Replace("[", "").Replace("]", "");
                    szNowSection.Trim();
                    continue;
                }
                uint iCut = szLine.Find("=");
                if(iCut != String::INVALID_INDEX && !szNowSection.IsEmpty()){
                    string szKey = szLine.SubString(0, iCut);
                    string szVal = szLine.SubString(iCut + 1);
                    szKey.Trim();
                    szVal.Trim();
                    array<string> aryTemp;
                    switch(getStringType(szVal))
                    {
                        case INI_BOOL: SetKeyValue(szNowSection, szKey, CINIItem(szKey, szVal.ToLowercase() == "true" ? true : false));break;
                        case INI_INT: SetKeyValue(szNowSection, szKey, CINIItem(szKey, atoi(szVal)));break;
                        case INI_FLOAT: SetKeyValue(szNowSection, szKey, CINIItem(szKey, atof(szVal)));break;
                        case INI_VECTOR2D: {
                            aryTemp = szVal.Split(" ");
                            SetKeyValue(szNowSection, szKey, CINIItem(szKey, aryTemp[0], aryTemp[1]));
                            break;
                        }
                        case INI_VECTOR: {
                            aryTemp = szVal.Split(" ");
                            SetKeyValue(szNowSection, szKey, CINIItem(szKey, aryTemp[0], aryTemp[1], aryTemp[2]));
                            break;
                        }
                        case INI_RGBA: {
                            aryTemp = szVal.Split(" ");
                            SetKeyValue(szNowSection, szKey, CINIItem(szKey, aryTemp[0], aryTemp[1], aryTemp[2], aryTemp[3]));
                            break;
                        }
                        case INI_STRING:
                        default: {
                            szVal.Trim("\""); 
                            SetKeyValue(szNowSection, szKey, CINIItem(szKey, szVal.Replace("\\n", "\n")));
                            break;
                        }
                    }
                }
            }
            pFile.Close();
        }
    }

    CINIItem@ GetItem(string szNode, string szKey){
        CINISection@ pNode = GetSection(szNode);
        if(@pNode !is null)
            return pNode[szKey];
        return null;
    }
    CINISection@ GetSection(string szNode){
        for(uint i = 0; i < arySection.length(); i++){
            if(arySection[i] == szNode)
                return arySection[i];
        }
        return null;
    }

    CINIItem@ opIndex(string szSection, string szKey){
        return GetItem(szSection, szKey);
    }

    CINISection@ opIndex(string szSection){
        return GetSection(szSection);
    }

    void SetKeyValue(string szNode, string szKey, CINIItem@ _pItem){
        CINISection@ pNode = GetSection(szNode);
        if(pNode !is null){
            CINIItem@ pItem = pNode[szKey];
            if(pItem !is null)
                @pItem = @_pItem;
            else
                pNode.insertLast(@_pItem);
        }
        else
            arySection.insertLast(CINISection(szNode, @_pItem));
    }
}

class CINISection{
    string szName;
    private array<CINIItem@> aryChildren = {};

    CINISection(string _szName){
        szName = _szName;
    }
    CINISection(string _szName, CINIItem@ pItem){
        szName = _szName;
        aryChildren.insertLast(@pItem);
    }

    uint length(){
        return aryChildren.length();
    }

    void insertLast(CINIItem@ pItem){
        aryChildren.insertLast(@pItem);
    }

    bool opEquals(string szTemp){
        return this.szName == szTemp;
    }

    CINIItem@ Get(string szName){
        for(uint i = 0; i < aryChildren.length(); i++){
            if(aryChildren[i].szKey == szName)
                return aryChildren[i];
        }
        return null;
    }

    CINIItem@ opIndex(uint uiIndex){
        return aryChildren[uiIndex];
    }

    CINIItem@ opIndex(string szKey){
        return Get(szKey);
    }
}
class CINIItem{
    string szKey;

    private any@ pStored = any();
    CINIItem(string _Key){ 
        szKey = _Key;
    }
    CINIItem(string _Key, int _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, float _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, bool _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, string _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, string _Type1, string _Type2, string _Type3, string _Type4){
        set(_Key, RGBA(atoui(_Type1), atoui(_Type2), atoui(_Type3), atoui(_Type4)));
    }
    CINIItem(string _Key, string _Type1, string _Type2, string _Type3){
        set(_Key, Vector(atof(_Type1), atof(_Type2), atof(_Type3)));
    }
    CINIItem(string _Key, string _Type1, string _Type2){
        set(_Key, Vector2D(atof(_Type1), atof(_Type2)));
    }
    CINIItem(string _Key, RGBA _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, Vector _Type){
        set(_Key, _Type);
    }
    CINIItem(string _Key, Vector2D _Type){
        set(_Key, _Type);
    }
    
    void set(string _Key, int _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, float _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, bool _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, string _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, Vector _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, Vector2D _Type){
        szKey = _Key;
        pStored.store(_Type);
    }
    void set(string _Key, RGBA _Type){
        szKey = _Key;
        pStored.store(_Type);
    }

    int getInt(){
        int a;
        pStored.retrieve(a);
        return a;
    }
    float getFloat(){
        float a;
        pStored.retrieve(a);
        return a;
    }
    bool getBool(){
        bool a;
        pStored.retrieve(a);
        return a;
    }
    string getString(){
        string a;
        pStored.retrieve(a);
        return a;
    }
    Vector getVector(){
        Vector a;
        pStored.retrieve(a);
        return a;
    }
    Vector2D getVector2D(){
        Vector2D a;
        pStored.retrieve(a);
        return a;
    }
    RGBA getRGBA(){
        RGBA a;
        pStored.retrieve(a);
        return a;
    }

    any@ get(){
        return @pStored;
    }
}
}