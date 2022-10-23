**This repository is currently maintained by [DrAbc](https://github.com/DrAbcrealone).**

# What is Ecco

![img](https://github.com/Paranoid-AF/EccoWikiAssets/raw/master/article1.png)

A complete economy & buy menu plugin for Sven Co-op 5.x

## [Plugin document](Guidance.md)

## [Q&A](Guidance.md#qa)

## [For more information on forked new features](#forked-new-features)

## Quick start
1. Grab plugin in Ecco directory
2. Put Ecco directory into svencoop_addon/scripts/plugins/
3. Create directory svencoop/scripts/plugins/store/Ecco and ensure has write permission (***Very important!***)
4. Put assets/dollar.spr into svencoop_addon/sprites/misc/dollar.spr
5. Add these .echo file name into svencoop_addon/scripts/plugins/Ecco/config/Scripts.txt (without .echo extension)
6. Open /svencoop/default_plugins.txt with notepad or other software, add

```
"plugin"
   {
   	"name" "Ecco"
   	"script" "Ecco/Ecco"
   }
 ```
 
7. Start game

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

-----

## Forked New Features

1. Plugin performance optimization

2. Can be used `;;` as a separator to add multi-level submenu in the echo script `name` keyvalue.
   
   Example:

        in test.echo, you could write:
            name: a;;b;;c;;d;;e;;f;;g;;h;;i;;j;;k;;l;;m;;n;;o;;p;;q;;r;;s;;t;;u;;v;;w;;x;;y;;z;;9mm Ammobox
            cost: 3
            give ammo_9mmbox
    
    this name will add a~z multi-level submenu

    `category` is no longer necessary, it's a deprecated key in echo scripts, but if a scripts contain `category` key, plugin will combine `category` keyvalue and `name` keyvalue;

    Example:

            name: aaa;;bbb;;ccc;;9mm
            category: 1337
            cost: 3
            give ammo_9mmbox
    
    The plugin will combine two keyvalue to `1337;;aaa;;bbb;;ccc;;9mm` for parsing.

    ### What? ;;? Why?
    1. Because `.` is actually a very common character (e.g: 5.56 ammo) and I didn't want to mess with something as ugly as an escape character. Also, if the control characters in the Asiic code are used, it will be very difficult for the user to read or edit them. As for emoji, it is very difficult to manipulate utf8 emoji of variable length because the string type's support for multi-byte characters is a disaster, so changing to double characters was the most logical option in my opinion.
    2. If you need to upgrade from an old . You can use a tool like `visual studio code` to batch replace.

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

    More info please check [here](Guidance.md#basic)

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

    More info please check [here](Guidance.md#developer)

7. flexible balance storage strategy

    Plugin provides build in storage options in `Config.ini`

    More info please check [here](Guidance.md#config)
    
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

    More info please check [here](Guidance.md#eccobankentity)

   If you don't want this features, delete include in `Include.as`
    
