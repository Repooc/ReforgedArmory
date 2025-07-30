# LibGearScore-1.0
World of Warcraft Wrath (Classic) embeddable GearScore calculation library.  
Formulas from original GearScore/Lite by Mirrikat45.

## Usage/API
0. If not using it standalone but embedded then in your addon .toc file or embeds.xml / libs.xml whatever is used to reference libraries.
 ```
 <path_to>\LibStub.lua
 <path_to>\CallbackHandler-1.0.xml
 <path_to>\LibGearScore.lua
 ```

1. Get a reference to the library
 ```lua
 local LibGearScore = LibStub:GetLibrary("LibGearScore.1000",true)
 ```

2. Call the public :GetScore() method passing a unitid or unitguid to get back GearScore data
 ```lua
 local guid, gearScore = LibGearScore:GetScore("player")
 ```

 Player has to have been inspected during the play session. 
 History of scores is not retained beyond the current session by this library.
 If data retention is required it has to be implemented downstream by the addon embedding or referencing the library.
 
 `gearScore`members
 ```lua
 {
  TimeStamp = YYYYMMDDhhmmss, -- string (eg. 20221025134532) for easy string sortable comparisons
  PlayerName = PlayerName, -- string
  PlayerRealm = PlayerRealm, -- string:Normalized Realm Name
  GearScore = N, -- Number
  AvgItemLevel = N, -- Number
  RawTime = xxxxxxxxxx, -- number/nilable: unixtime (can feed to date(fmt,RawTime) to get back human readable datetime)
  Color = colorobject, -- ColorMixin/nilable -- can call colorobject:WrapTextInColorCode(text) for example
  Description = qualitydescription -- nilable: String
 }
 ```
 ```lua
 if gearScore.PlayerName == _G.UNKNOWNOBJECT or gearScore.GearScore == 0 then
   -- we don't have data for this unit
 end
 ```
3. call the public GetItemScore() method passing itemid, itemstring or itemlink to get the base Score for a single item
 
 ```lua
 local itemID, itemScore = LibGearScore:GetItemScore(item)
 ```
 `itemScore`members
 ```lua
 {
  ItemScore=ItemScore, -- Number
  ItemLevel=ItemLevel, -- Number
  Red=r, -- 0-1
  Green=g, -- 0-1
  Blue=b, -- 0-1
  Description=qualitydescription, -- String
 }
 ```
 ```lua
 if itemScore.Description == _G.UNKNOWNOBJECT then
  -- invalid item
 end
 if itemScore.Description == _G.PENDING_INVITE then
  -- item is not in local cache, see callbacks below
 end
 ```
 
 4.  Callbacks: 
  "LibGearScore_Update", "LibGearScore_ItemScore", "LibGearScore_ItemPending" events are sent by the library to addons registering for them.
  (requires LibStub) 
  
  In addon code: (_addon is your addon object_)
  ```lua
  LibGearScore.RegisterCallback(addon, "LibGearScore_Update")
  function addon:LibGearScore_Update(guid, gearScore) -- see (2a) for `gearScore` members
    -- do something with gearScore for player guid
  end
  --
  LibGearScore.RegisterCallback(addon, "LibGearScore_ItemScore")
  function addon:LibGearScore_ItemScore(itemid, itemScore) -- see (3a) for `itemScore` members
    -- do something with itemScore for itemid
  end
  LibGearScore.RegisterCallback(addon, "LibGearScore_ItemPending")
  function addon:LibGearScore_ItemPending(itemid)
    -- can for example monitor for the LibGearScore_ItemScore callback to have final item data
  end
  ```
5. Testing 
  
  `/lib_gs` with a player targetted in-game.

## Notes
  **LibGearScore-1.0** does not initiate Inspects.  
  It passively caches and provides GearScore results from Inspections started by the player manually or by other addons (including the addon embedding it)
