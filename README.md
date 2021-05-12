# What is Ecco

![img](https://github.com/Paranoid-AF/EccoWikiAssets/raw/master/article1.png)
A complete economy & buy menu plugin for Sven Co-op 5.x

#### [For more information on how to use this plugin, click here!](https://github.com/Paranoid-AF/Ecco/wiki)

## Basically an Economy Plugin

Ecco saves players' scores permanently, adding them to players' balance, and allows other plugins to interact with the data. Like, a buy menu plugin could deduct the currency, and a game mode plugin could also add currency to players' balance, as a reward. In the long run, it encourages players to keep on playing.

## Wait, that's it?

Definitely not. Ecco also includes a script system, pretty similar to Half-Life's `.cfg` files. All you need to do is to 

scrabble up a script out of all the commands supported, which are capable of expansion. There are some considerable commands built-in, but you could also use addons to expand them. Also, it provides a random function, which allows you to execute commands randomly.

So how should we deal with the script system? Well, it provides a easier but more powerful way to expand the customization of plugins. For example, if a buy menu plugin has included this system, players could buy more than just weapons. Like loot boxes (with the random execution function introduced), speed up, healing and even randomly killing other players.

Also, Ecco introduces a permanent inventory system, which stores the scripts that should get running when a player joins the game. So you could make a weapon permanent for some players, set a very high max health or so. And yes, this is also expandable.

## So...what can I do with it?

If you're a server operator, you could make full use of the script system and plugins with Ecco support.

If you're an advanced server operator, you could even write an addon yourself, to expand the commands of the script system.

And if you're a plugin developer, you could try to communicate with Ecco's data and invoke the script system within your plugin.

>  ** NOTE **: This is not an open-source software, since I hold the full rights to this project. With that being said, I'm always glad with people using this plugin as long as it's not for commercial use. (Like, donation to your server is fine, but you're not supposed to add their in-game balance / items that may break the experience of gameplay for this.)

-----

## Forked New Features

1. Plugin performance optimization
   
2. Can be used `.` as a separator to add multi-level submenu in the echo script `name` keyvalue.
   
   Example:

        in test.echo, you could write:
            name: a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.9mm Ammobox
            cost: 3
            give ammo_9mmbox
    
    this name will add a~z multi-level submenu

    `category` is no longer necessary, it's a deprecated key in echo scripts, but if a scripts contain `category` key, plugin will combine `category` keyvalue and `name` keyvalue;

    Example:

            name: aaa.bbb.ccc.9mm
            category: 1337
            cost: 3
            give ammo_9mmbox
    
    The plugin will combine two keyvalue to `1337.aaa.bbb.ccc.9mm` for parsing.

3. INI file for config
4. Localization Message Keyword replacement
 
   Example:

    ```ini
    [Ecco.LocaleSetting]
    ;MenuItem Formmat
    ItemDisplayFormat="%MENUNAME% - %COST%"
    ```
    this sentence will replace to `WeaponName - Price`, example as `9mm Box - 3`

    Similarly, like the original Ecco, you can also use these keywords in echo, but please note that only statements involving players can be driven by player type keywords, and different kinds of keywords cannot coexist in the same sentence

    |Keyword|Result|
    |---|---|
    |%PLAYER%|Player netname|
    |%RANDOMPLAYER%|Random player name|
    |%BALANCE%|Player remain balance|
    |%SPACE%|Space (` `), deprecated keyword|
    |%COST%|Item cost balance|
    |%MENUNAME%|Item name|
    |%PLAYERHP%|Player Health|
    |%PLAYERAP%|Player Armor|
    |%PLAYERTEAM%|Player Team|

    will add more keyword soon...

5. Buy Arguments

    You can buy a item via arguments

    Example:
    
    You have a item display name is: 9mm Ammbox-2

        Menu looks like:
            Root
            |-Ammo
            |    |-9mm Ammbox-2
            |-Other

    You could buy 9mm Ammbox via command `!buy 1 1` or `!buy "Ammo" "9mm Ammbox-2"`

6. Addon init via Reflection Method

    I don't know when Angelscripts can use the same namespace in different files, so now Addon can be loaded by reflection method

    To do that, you just need put your Addon namespace under the namespace `EccoAddon`, the write `PluginInit`, `MapInit`, `MapActivate` and `MapStart` functions as entry points just like normal plugins

    And you need add two Funcions to provide your name and contact info, otherwise your info won't shown in `as_listplugins`. you don't like that, right?

    For a example:

    ```csharp
    namespace EccoAddon{
        //You have to create a new namespace for your addon scripts
        //The name of the namespace will be used as the name of the extension
        namespace EccoExample{
            //Provide your info for as_listplugins
            string GetAuthor(){
                return "Your name";
            }
            //If you don't like to tell others your contact information, 
            //you can choose not to implement this function,
            // so your contact information will be left blank
            string GetContactInfo(){
                return "Your info";
            }

            //You have not to provide all of these functions.
            //In fact, You can implement none of these functions, 
            //but that means your extension will not work anymore;
            void PluginInit(){
                //Todo something
            }

            void MapInit(){
                //Todo something
            }

            void MapActived(){
                //Todo something
            }

            void MapStart(){
                //Todo something
            }
            //Todo something
        }
    }
    ```

    Then just add `#include` anywhere to link your extensions and plugins
    I highly recommanded you put your `#include` into `Include.as`

    For more info, please check `Addon/EccoBase.as`

7. flexible balance storage strategy

    Forked plugin provides build in storage options in `Config.ini`
    ```ini
    ;Store balance or not
    ;0 don't store
    ;1 only store in series maps
    ;2 permanent storage
    StorePlayerScore=1
    ;If the balance isn't stored, how much is the starting balance
    PlayerStartScore=0
    ;Determination method of Series Map
    ;0 by CVAR
    ;   check mp_nextmap and mp_survival_nextmap
    ;   if map dosen't set these, this method won't work
    ;1 by LCS
    ;   check two maps name by LCS
    ;   If the similarity is greater than the ratio, 
    ;   it is considered as series maps
    SereisMapCheckMethod=1
    ;LCS check ratio
    SereisMapLCSCheckRatio=0.65
    ```
8. Hookable behavior

    Added Hook Function for interior behavior

    for example

    ```csharp
        void PluginInit(){
            EccoHook::RegisterHook(EccoHook::Economy::PreChangeBalance, @PreChangeBalance)
        }

        HookReturnCode PreChangeBalance(CBasePlayer@ pPlayer, int Amount, bool&out bOut){
            //f you want to block the next function(ChangeBalance)
            //set bOut to False
            //or set it to true
            /*...do something....*/
        }
    ```

    At present, only `SetBalance`  hooks has been added

    will add more hook in future.

    for more info, please cheack `EccoHook.as` and `EchoSQL.as`

9.  Exchangable info entity for other plugins

    As we all know, angelscripts plugins and plugins are in a completely isolated environment, and plug-ins cannot directly affect each other.

    so `EccoBankEntity.as` add a interface entity for other plugins to set player's balacne in game.

    for example
    
    ```csharp
    void GrabBankEntity(CBasePlayer@ pPlayer){
        CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname(@pEntity, "info_ecco_bank");

        //set player balance
        //indexmode
        pEntity.pev.spawnflag = 0;
        pEntity.pev.netname = pPlayer.entindex();
        pEntity.Use(null, null, USE_SET, 114514);
        //get player balance
        //namemode
        pEntity.pev.spawnflag = 1;
        pEntity.pev.targetname = pPlayer.pev.netname;
        pEntity.Use(null, null, USE_ON);
        int iBalance = pEntity.pev.frags;
        g_PlayerFuncs.SayText(@pPlayer, "The balance on your account is $" + iBalance + "\n");
    }
    ```

    Easy, now you try.

    If you don't want this features, delete include in `Include.as`
    