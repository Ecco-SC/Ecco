namespace IO
{
    funcdef string IOMarcoFunc(string);
    array<string> FileLineReader(string szPath, IOMarcoFunc@ pMarco = null)
    {
        array<string> szTemp = {};
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                if(pMarco !is null)
                    szLine = pMarco(szLine);
                if(szLine == "\nbreak")
                    break;
                else if(szLine == "\n")
                    continue;
                szTemp.insertLast(szLine);
            }
            pFile.Close();
        }
        return szTemp;
    }

    string FileCharReader(string szPath, IOMarcoFunc@ pMarco = null)
    {
        string szTemp = "";
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szChar = "";
            while (!pFile.EOFReached())
            {
                szChar = pFile.ReadCharacter();
                if(pMarco !is null)
                    szChar = pMarco(szChar);
                if(!szChar.IsEmpty())
                    szTemp += szChar;
            }
            pFile.Close();
        }
        return szTemp;
    }

    string FileTotalReader(string szPath)
    {
        string szTemp = "";
        File @pFile = g_FileSystem.OpenFile(szPath, OpenFile::READ);
        if (pFile !is null && pFile.IsOpen())
        {
            string szLine;
            while (!pFile.EOFReached())
            {
                pFile.ReadLine(szLine);
                szTemp += szLine + "\n";
            }
            pFile.Close();
        }
        return szTemp;
    }

    bool FileWriter(string szPath, string szContent, OpenFileFlags_t flag = OpenFile::WRITE)
    {
        File @pFile = g_FileSystem.OpenFile( szPath , flag );
        if ( pFile !is null && pFile.IsOpen())
        {
            pFile.Write( szContent );
            pFile.Close();	
            return true;
        }
        else
            return false;
    }

    bool FileWriter(string szPath, array<string> aryContent, OpenFileFlags_t flag = OpenFile::WRITE)
    {
        File @pFile = g_FileSystem.OpenFile( szPath , flag );
        if ( pFile !is null && pFile.IsOpen())
        {
            for(uint i = 0; i < aryContent.length(); i++)
            {
                pFile.Write( aryContent[i] + "\n" );
            }
            pFile.Close();	
            return true;
        }
        else   
            return false;
    }
}

namespace Utility
{
    funcdef bool SelectMarcoFunc(string);
    array<string>@ Select(array<string>@&in aryIn, SelectMarcoFunc@ pMarco)
    {
        array<string> aryTemp = {};
        for(uint i = 0; i < aryIn.length(); i++)
        {
            if(pMarco(aryIn[i]))
                aryTemp.insertLast(aryIn[i]);
        }
        return @aryTemp;
    }
}