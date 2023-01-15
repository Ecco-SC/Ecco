  ![img](https://github.com/Paranoid-AF/EccoWikiAssets/raw/master/article1.png)
A complete economy & buy menu plugin for Sven Co-op 5.x

----
- [Quick start](#quick-start)
- [Config](#config)
- [Write Echo script](#write-echo-script)
  - [Basic](#basic)
    - [Property](#property)
    - [Marco](#marco)
    - [Flags](#flags)
  - [Advance](#advance)
    - [Random excute block](#random-excute-block)
  - [Developer](#developer)
- [Default addon](#default-addon)
  - [EccoBankEntity](#eccobankentity)
  - [EccoSQL](#eccosql)
  - [EccoEntity](#eccoentity)
- [Q\&A](#qa)
----

# Quick start

1. Grab plugin in `Ecco` directory
2. Put `Ecco` directory into `svencoop_addon/scripts/plugins/`
3. Create directory `svencoop/scripts/plugins/store/Ecco` and ensure has write permission (Very important!)
4. Put `assets/dollar.spr` into `svencoop_addon/sprites/misc/dollar.spr`
5. Add these `.echo` file name into `svencoop_addon/scripts/plugins/Ecco/config/Scripts.txt` (without `.echo` extension)
6. Open `/svencoop/default_plugins.txt` with notepad or other software, add
 ```
"plugin"
	{
		"name" "Ecco"
		"script" "Ecco/Ecco"
	}
```
7. Start game


# Config
All config and comment here

[Config](Ecco/config/Config_English.ini)

# Write Echo script

## Basic
Here is an example script:

`Example.echo`

```
name: Heavy;;Big Fucking gun 9000
cost: 114514
flags: 1
give weapon_bfg900
broadcast OMG,%PLAYER% bought a BFG and was ready to kill!!!
```

the `Example.echo` added an weapon which shown as `Big Fucking gun 9000` under `Heavy` category. when a player Goofy brought this item, plugin will take his 114514 points from ecco bank, and give him a 

`weapon_bfg9000`, then, broadcast a line in chat message like this:

`[Ecco]: OMG,Goofy bought a BFG and was ready to kill!!!`

plugin will be parse sentence by sentence from beginning to end.

### Property

```
name: Heavy;;Big Fucking gun 9000
cost: 114514
flags: 1
```

Attributes that end with `: ` are called "Property" and they define some values of the script, and Ecco stores them as a string whether or not the property is used.

here is the default used properties

|Property|Default Value|Explain|
|---|---|---|
|name|""|Used for script identity, it is the display name when "displayname" empty|
|cost|0|Cost|
|flags|0|Flag for special behavior|
|displayname|""|Showed name|

As you can see from the example, `name` and `cost` is necessary properties for an echo script.

Ps : `flags` is a bit value, here are the currently available values represented by each bit

0 - None

1 - Hide Cost


### Marco

```
give weapon_bfg900
broadcast OMG,%PLAYER% bought a BFG and was ready to kill!!!
```

The part like Half-Life console commands are called "Marco", they are the specific commands that are executed when the script is executed, and the characters after each marco are treated as arguments, usually separated by spaces

here is the default marcos:

|Marco|Usage|
|---|---|
|include [Scripts name] (Playername)|execute another script (as the player or another player), you don't need to enter the. Echo extension, just the name. Like `weapon_shotgun_Perm.echo`, you just need to use |`include weapon_ shotgun_Perm`.|
|money [Number]|Increase or decrease one's balance
|addinv [Scripts name] (Playername)|Add the script to the player's inventory, which will be executed every time the player enters the game|
|delinv [Scripts name] (Playername)|Remove script from player's inventory|
|maxhealth [Number] (Playername)|Set the player's maximum HP|
|maxarmor [Number] (Playername)|Set the player's maximum AP|
|say [Text]|Add text to the player's chat bar|
|broadcast [Text]|Add text to all players' chat bars|
|give [Entity Classname] (PlayerName)|Give the weapon or item to a player|
|log [Text]|Log text to server log|
|hurt (Number) (PlayerName)|Kill (leave the first parameter blank) or hurt the player|
|heal (Number) (PlayreName)|Healall (leave the first parameter blank) or heal the player|
|armor (Number) (PlayreName)|Fullcharge (leave the first parameter blank) or charge the player|
|maxspeed [Float] (PlayreName)|Set the player's maximum movement speed (can't exceed the server setting)|
|gravity [Float]|Set the player's gravity|

And you can see that `%PLAYER%` is used as a placeholder for the player's name in the example

Here is the default placeholders:

|Placeholder|Result|Flag|
|---|---|---|
|%PLAYER%|Player netname|p|
|%RANDOMPLAYER%|Random player name|p|
|%BALANCE%|Player remain balance|p|
|%SPACE%|Space (` `), deprecated keyword|m,p|
|%COST%|Item cost balance|m,p|
|%MENUNAME%|Item name|m,p|
|%PLAYERHP%|Player Health|p|
|%PLAYERAP%|Player Armor|p|
|%PLAYERTEAM%|Player Team|p|

### Flags

m - only work in buy menu

p - only work in marco 

## Advance

### Random excute block

The echo script provides a random execution block that allows the script to execute randomly.

Example:
```
{

  50 say Thx pal

  29 broadcast %PLAYER% got nothing hahahahaha

  1 broadcast congratulate %PLAYER% got an excalibruh! && give weapon_crowbar

}
```

Where `{}` represents the start and end of the random execution block. After that, you can wrap lines or not, but it is recommended to wrap lines for beauty.

Then the first number on each line represents the probability that the command will be executed, followed by the command to be executed.

At the same time, multiple commands can be connected through `&&` without line feed, so as to achieve the effect of executing multiple commands at the same time.

## Developer

You may find that the basic instruction Library of echo may not meet all requirements. At this time, you can try to develop echo script extensions.

Create your own as file in `/Ecco/addons`, open it and add the following content:

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
            EccoScriptParser::Register(CEccoMarco("examplemarco", marco_example));
            EccoHook::RegisterHook(EccoHook::Economy::PreChangeBalance, @PreChangeBalance)
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
        bool marco_example(CBasePlayer@ pPlayer, array<string>@ args){
            return true;
        }

        HookReturnCode PreChangeBalance(CBasePlayer@ pPlayer, int Amount, bool&out bOut){
            //f you want to block the next function(ChangeBalance)
            //set bOut to False
            //or set it to true
            /*...do something....*/
        }
    }
}
```

You must create a new namespace `EccoExample` as the domain of your addon under `EccoAddon`, plugin will search all namespaces under `EccoAddon` and excute `GetAuthor` `GetContactInfo` `PluginInit` `MapInit` `MapActived` `MapStart` methods one by one

As you can see from exaple, add and new marco just simply call `EccoScriptParser::Register` method in `PluginInit`

When the return value of marco is `true`, money will be deducted, otherwise the purchase will be considered as failed and keep money.

After you complete the addon coding, simply add `#include "addons/EccoExample"` into `Include.as`

wala, addon activited.

### Communicate with Ecco's data

If you wanna communicate with ecco from other plugin, there's two way to do that:

1. Use `EccoBankEntity` addon (recommand)
2. Read `svencoop/scripts/plugins/store/Ecco`, and edit it by yourself.

# Default addon

## EccoBankEntity

As we all know, angelscripts plugins and plugins are in a completely isolated environment, and plugins cannot directly affect each other.

so `EccoBankEntity.as` add a interface entity for other plugins to set player's balacne in game.

For example:

```csharp
void GrabBankEntity(CBasePlayer@ pPlayer){
    CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname(@pEntity, "info_ecco_bank");
    //set player balance
    //indexmode
    pEntity.pev.spawnflags = 1;
    pEntity.pev.targetname = pPlayer.pev.netname;
    pEntity.Use(null, null, USE_ON);
    int iBalance = int(pEntity.pev.frags);
    g_PlayerFuncs.SayText(@pPlayer, "The balance on your account is $" + iBalance + "\n");
	//set player balance
    //indexmode
    pEntity.pev.spawnflags = 0;
    pEntity.pev.skin = pPlayer.entindex();
    pEntity.Use(null, null, USE_SET, 114514);
    //add player balance
    //direct mode
    pEntity.Use(@pPlayer, null, USE_TOGGLE, -114514);
}
```

Easy, now you try.

If you don't want this features, delete include in `Include.as`

## EccoSQL

It is a plugin used with CSAS-ODS program or other programs to use SQL or todo otherting

- Query formate
  - SteamID
- Write formate
  - SteamID
  - Ecco
  - Additional string
- Read formate
  - UID
  - SteamID
  - Ecco
  - Additional string

## EccoEntity

Buy an entity with Ecco

Ecco commands:

```
    add_friendly_ent_at_aim [entity name] (hp) (display name) (model) 
```

# Q&A

1. Q: Why are all my weapons displayed directly and the category is invalid?
   
   A: Because you only add one category, the plugin will ignore it.

2. Q: Are you crazy about string comparison in recursive loops?

    A: Yeah, i know, working on it.

3. Q: `Echo` script is too simple! I need logical judgment and circulation!

    A: Is building it into a kind of `TCL` script format, just gimme some time.

4. Q: Why plugin can not read the first line of configure?

    A: Some editor will add stupid BOM header for UTF8 file automatically.However, Ecco plugin does not recognize which files have BOMs and ignores them.  

    Please make sure that the file you saved is in the format `WITHOUT BOM`

5. Q: 
   ```
   [CRITICAL]Cannot read the config file, check if it exists and SCDS has the permission to access it!
        Reading path: scripts/plugins/Ecco/config/Config.ini
        Ecco aborted loading.
    ```

    Why? how can i change config file path?

    A: This is the only place where a fixed variable needs to be used in the whole plugin, If your `Ecco.as` is not installed in `scripts/plugins/Ecco/`,
    Please open `Ecco.as`, and edit this line:

    `const string szConfigPath = "scripts/plugins/Ecco/config/";`

6. Q: My menu is completely messed up! How can I set the order of menu items?

   A: The menu display order is based on the loading order of echo files in `Scripts.txt`, The plugin will load the `echo` file from beginning to end.

   Therefore, if you need to set the display order of the menu, you just need to modify the loading order of the `echo` file in the `Scripts.txt`.