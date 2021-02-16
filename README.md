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

    |Keyword|Result|
    |---|---|
    |%PLAYER%|Player netname|
    |%RANDOMPLAYER%|Random player name|
    |%BALANCE%|Player remain balance|
    |%SPACE%|Space (` `), deprecated keyword|
    |%COST%|Item cost balance|
    |%MENUNAME%|Item name|

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

    