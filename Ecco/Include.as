#include "api/CEccoMarco"
#include "api/CINI"
#include "api/CEccoScriptItem"

#include "api/EccoParser"
#include "api/EccoPlayers"
#include "api/EccoProcessVar"
#include "api/EccoConfig"
#include "api/EccoInclude"
#include "api/EccoUtility"

#include "api/IO"
#include "api/Logger"
#include "api/SteamIDHelper"

/*
    ADDON INCLUDE AREA
    Put your addons below to add them!
*/
#include "addons/EchoBase"
#include "addons/EccoBankEntity" //Delete this line if you don't need to exchange information with the outside world...
//#include "addons/EchoEntity" //If you need the summon some entity for you...
//#include "addons/EchoSQL" //If you need the CSAS-ODS program or other way use SQL...
//#include "addons/EchoAmmo" //If you need quick ammo buy..