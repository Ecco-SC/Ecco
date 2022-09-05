class CClinetCmd
{
    private string szName = "";
    private string szHelpInfo = "";
    private string szDescribeInfo = "";
    private string szReturnInfo = "";
    private ConCommandFlags_t levelConFlags = ConCommandFlag::None;
    private CClientCommand@ cmdClientcmd;
    private Command::CmdCallback@ cbkCallBack;
        
    string Name
    {
        get const{ return szName;}
        set{ szName = value;}
    }
            
    string HelpInfo
    {
        get const{ return szHelpInfo;}
        set { szHelpInfo = value; }
    }

    string DescribeInfo
    {
        get const{ return szDescribeInfo;}
        set { szDescribeInfo = value; }
    }
        
    string ReturnInfo
    {
        get const{ return szReturnInfo;}
        set { szReturnInfo = value; }
    }

    ConCommandFlags_t AdminLevel
    {
        get const{ return levelConFlags;}
        set { levelConFlags = value; }
    }
            
    CClientCommand@ ClientCommand
    {
        get{ return cmdClientcmd;}
        set{ @cmdClientcmd = @value;}
    }
        
    Command::CmdCallback@ ClientCallback
    {
        get{ return cbkCallBack;}
        set{ @cbkCallBack = @value;}
    }

    bool IsEmpty()
    {
        return @cmdClientcmd is null || cbkCallBack is null;
    }
}