package
{
   import Playtomic.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.SharedObject;
   import flash.net.Socket;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class Game
   {
      
      public static var root:Main;
      
      public static var frame:MovieClip;
      
      public static var battle:Battle;
      
      public static var maps:Maps;
      
      public static var mode:String;
      
      public static var party:Array;
      
      public static var skipAutosave:Boolean = false;
      
      public static var BATTLE:String = "battle";
      
      public static var MAP:String = "map";
      
      public static var MAIN_MENU:String = "main menu";
      
      public static var onDeath:Function = null;
      
      public static var onDeath2:Function = null;
      
      public static var onDeathList:Array = [];
      
      public static var fleeable:Boolean = true;
      
      public static var boobCount:int = 0;
      
      public static var background:int = 1;
      
      public static var foes:Array = null;
      
      public static var battleNo:int = 0;
      
      public static var mapNo:int = 0;
      
      public static var tempSave:Array = [];
      
      public static var win:Boolean = false;
      
      public static var gameOver:Boolean = false;
      
      public static var respawnable:Boolean = false;
      
      public function Game()
      {
         super();
      }
      
      public static function init() : *
      {
         party = [Players.player4];
         try
         {
            AP_init();
         }
         catch(e:Error)
         {
            Main.log("[AP] init failed: " + e);
         }
      }

      // ===== Archipelago mod (EBF4-AP) =====
      // ponytail: all AP code lives in Game.as because FFDec CLI cannot add new classes.

      public static var AP_socket:Socket = null;

      public static var AP_connected:Boolean = false;

      public static var AP_state:SharedObject = null;

      public static var AP_queue:Array = [];

      public static var AP_buf:ByteArray = null;

      public static var AP_msgLen:uint = 0;

      public static var AP_waiting:Boolean = true;

      public static var AP_retryTicks:int = 0;

      public static var AP_HOST:String = "127.0.0.1";

      public static var AP_PORT:int = 26510;

      public static var AP_managed:Object = null;

      public static var AP_toastField:TextField = null;

      public static var AP_toastQueue:Array = [];

      public static var AP_toastTimer:int = 0;

      public static var AP_deathQueued:String = null;

      public static var AP_deathSuppress:Boolean = false;

      public static var AP_deathShown:Boolean = false;

      public static var AP_activeTraps:Array = [];

      public static var AP_battleFoes:Object = {};

      public static function AP_init() : *
      {
         if(AP_socket != null)
         {
            return;
         }
         AP_state = SharedObject.getLocal("EBF4AP");
         if(!AP_state.data.hasOwnProperty("itemIndex") || AP_state.data.itemIndex == null)
         {
            AP_state.data.itemIndex = 0;
         }
         AP_buf = new ByteArray();
         AP_socket = new Socket();
         AP_socket.addEventListener(Event.CONNECT,AP_onConnect);
         AP_socket.addEventListener(Event.CLOSE,AP_onClose);
         AP_socket.addEventListener(IOErrorEvent.IO_ERROR,AP_onIOError);
         AP_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,AP_onSecurityError);
         AP_socket.addEventListener(ProgressEvent.SOCKET_DATA,AP_onData);
         Main.log("[AP] mod loaded, itemIndex=" + AP_state.data.itemIndex);
         AP_connect();
      }

      public static function AP_connect() : *
      {
         if(AP_connected || AP_socket == null || AP_socket.connected)
         {
            return;
         }
         try
         {
            AP_socket.connect(AP_HOST,AP_PORT);
         }
         catch(e:Error)
         {
            Main.log("[AP] connect error: " + e);
         }
      }

      public static function AP_onConnect(param1:Event) : *
      {
         AP_connected = true;
         Main.log("[AP] connected to bridge at " + AP_HOST + ":" + AP_PORT);
         AP_sendHello();
      }

      public static function AP_sendHello() : *
      {
         AP_send({
            "type":"hello",
            "game":"EBF4",
            "protocol":2,
            "itemIndex":AP_state.data.itemIndex,
            "session":AP_state.data.session is String ? AP_state.data.session : ""
         });
      }

      public static function AP_onClose(param1:Event) : *
      {
         AP_connected = false;
         AP_waiting = true;
         Main.log("[AP] disconnected from bridge");
      }

      public static function AP_onIOError(param1:IOErrorEvent) : *
      {
         AP_connected = false;
         AP_waiting = true;
      }

      public static function AP_onSecurityError(param1:SecurityErrorEvent) : *
      {
         AP_connected = false;
         Main.log("[AP] socket security error: " + param1.text);
      }

      public static function AP_send(param1:Object) : *
      {
         if(!AP_connected)
         {
            return;
         }
         try
         {
            var _loc2_:String = JSON.stringify(param1);
            var _loc3_:ByteArray = new ByteArray();
            _loc3_.writeUTFBytes(_loc2_);
            AP_socket.writeUnsignedInt(_loc3_.length);
            AP_socket.writeUTFBytes(_loc2_);
            AP_socket.flush();
         }
         catch(e:Error)
         {
            Main.log("[AP] send error: " + e);
         }
      }

      public static function AP_onData(param1:ProgressEvent) : *
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         while(AP_socket.bytesAvailable > 0)
         {
            if(AP_waiting)
            {
               if(AP_socket.bytesAvailable < 4)
               {
                  return;
               }
               AP_msgLen = AP_socket.readUnsignedInt();
               AP_buf.clear();
               AP_waiting = false;
            }
            _loc2_ = AP_msgLen - AP_buf.length;
            _loc3_ = Math.min(AP_socket.bytesAvailable,_loc2_);
            AP_socket.readBytes(AP_buf,AP_buf.length,_loc3_);
            if(AP_buf.length == AP_msgLen)
            {
               AP_buf.position = 0;
               _loc4_ = AP_buf.readUTFBytes(AP_buf.length);
               AP_waiting = true;
               AP_buf.clear();
               AP_handleMessage(_loc4_);
            }
         }
      }

      public static function AP_handleMessage(param1:String) : *
      {
         var _loc2_:Object = null;
         try
         {
            _loc2_ = JSON.parse(param1);
         }
         catch(e:Error)
         {
            Main.log("[AP] bad message: " + param1);
            return;
         }
         if(_loc2_.type == "item")
         {
            AP_queue.push(_loc2_);
         }
         else if(_loc2_.type == "grant")
         {
            // out-of-band /tool failsafe: apply once, bypassing item-index dedup
            _loc2_.force = true;
            AP_queue.push(_loc2_);
         }
         else if(_loc2_.type == "session")
         {
            AP_managed = {};
            for each(var _loc3_:String in _loc2_.locations)
            {
               AP_managed[_loc3_] = true;
            }
            if(AP_state.data.session != _loc2_.session)
            {
               Main.log("[AP] new session " + _loc2_.session + ", resetting item index");
               AP_state.data.session = _loc2_.session;
               AP_state.data.itemIndex = 0;
               AP_state.data.checks = [];
               AP_state.data.party = {};   // new seed: re-earn allies (grants replay from index 0)
               AP_state.flush();
               AP_sendHello();
            }
            if(_loc2_.difficulty is String && _loc2_.difficulty.length > 0)
            {
               Options.difficulty = _loc2_.difficulty;
            }
            AP_state.data.partyShuffle = _loc2_.partyShuffle == true;
            AP_state.flush();
            Main.log("[AP] session " + _loc2_.session + ", managing " + _loc2_.locations.length + " locations");
            AP_resendChecks();
         }
         else if(_loc2_.type == "spendGold")
         {
            AP_spendGold(int(_loc2_.amount));
         }
         else if(_loc2_.type == "msg")
         {
            AP_toast(_loc2_.text);
         }
         else if(_loc2_.type == "deathlink")
         {
            AP_deathQueued = _loc2_.source is String ? _loc2_.source : "someone";
         }
         else if(_loc2_.type == "ping")
         {
            AP_send({"type":"pong"});
         }
      }

      public static function AP_toast(param1:String) : *
      {
         AP_toastQueue.push(param1);
      }

      public static function AP_toastTick() : *
      {
         var _loc1_:TextFormat = null;
         if(AP_toastTimer > 0)
         {
            --AP_toastTimer;
            if(AP_toastTimer == 0 && AP_toastField != null)
            {
               AP_toastField.visible = false;
            }
            else if(AP_toastTimer < 20 && AP_toastField != null)
            {
               AP_toastField.alpha = AP_toastTimer / 20;
            }
            return;
         }
         if(AP_toastQueue.length == 0 || root == null || root.stage == null)
         {
            return;
         }
         if(AP_toastField == null)
         {
            AP_toastField = new TextField();
            _loc1_ = new TextFormat("Verdana",14,0xFFFFFF,true);
            _loc1_.align = "center";
            AP_toastField.defaultTextFormat = _loc1_;
            AP_toastField.background = true;
            AP_toastField.backgroundColor = 0x1B1B4B;
            AP_toastField.border = true;
            AP_toastField.borderColor = 0x88AAFF;
            AP_toastField.selectable = false;
            AP_toastField.mouseEnabled = false;
            AP_toastField.width = 560;
            AP_toastField.height = 26;
            AP_toastField.x = (root.stage.stageWidth - 560) / 2;
            AP_toastField.y = 8;
         }
         AP_toastField.text = String(AP_toastQueue.shift());
         AP_toastField.alpha = 0.9;
         AP_toastField.visible = true;
         root.stage.addChild(AP_toastField);
         AP_toastTimer = 130;
      }

      public static function AP_partyWiped() : *
      {
         if(AP_deathSuppress)
         {
            AP_deathSuppress = false;
            return;
         }
         if(AP_connected)
         {
            AP_send({"type":"death"});
         }
      }

      public static function AP_deathTick() : *
      {
         var _loc1_:Object = null;
         if(AP_deathQueued == null)
         {
            return;
         }
         // outside battle: kill the party's map HP so they lose the next fight,
         // and show it immediately.
         if(mode != BATTLE)
         {
            AP_toast("DeathLink: " + AP_deathQueued + " has died.");
            for each(_loc1_ in party)
            {
               _loc1_.realHP = 0;
            }
            AP_deathQueued = null;
            return;
         }
         if(Battle.players == null || Battle.end || Battle.menu == null || !Battle.menu.visible)
         {
            return; // wait for a stable player-turn state so wave-init can't revive us
         }
         if(!AP_deathShown)
         {
            AP_toast("DeathLink: " + AP_deathQueued + " has died, and so do you.");
            AP_deathShown = true;
         }
         AP_deathSuppress = true;
         for each(_loc1_ in Battle.players)
         {
            _loc1_.realHP = 0;
            _loc1_.dead = true;
         }
         AP_deathQueued = null;
         AP_deathShown = false;
         Battle.gameover();
      }

      public static function AP_isManaged(param1:int, param2:int) : Boolean
      {
         if(AP_managed == null)
         {
            return false;
         }
         return AP_managed["chest_" + param1 + "_" + param2] == true;
      }

      public static function AP_tick() : *
      {
         var _loc1_:Object = null;
         if(AP_queue.length == 0)
         {
            return;
         }
         if(!SaveData.inGame || mode != MAP || maps == null)
         {
            return;
         }
         if((maps.parent as MapMenu).treasurebox.visible)
         {
            return;
         }
         _loc1_ = AP_queue.shift();
         if(_loc1_.force == true)
         {
            // manual /tool grant: apply once, no index bookkeeping/dedup
            AP_applyItem(_loc1_);
         }
         else if(_loc1_.index >= AP_state.data.itemIndex)
         {
            AP_applyItem(_loc1_);
            AP_state.data.itemIndex = _loc1_.index + 1;
            AP_state.flush();
         }
         else
         {
            Main.log("[AP] skipping already-applied item index " + _loc1_.index);
         }
      }

      public static function AP_applyItem(param1:Object) : *
      {
         var _loc2_:Array = [];
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         // legacy test-bridge form: {"item":"money","amount":N}
         if(param1.item == "money")
         {
            SaveData.money += int(param1.amount);
            if(SaveData.money > SaveData.moneyMax)
            {
               SaveData.money = SaveData.moneyMax;
            }
            Main.log("[AP] received item " + param1.index + ": " + param1.amount + " gold");
            return;
         }
         // AP form: {"grant":[["i","turnip",3],["e","cloverpin",1],["s","rain",0],["money","",100]]}
         for each(_loc3_ in param1.grant)
         {
            if(_loc3_[0] == "money")
            {
               SaveData.money += int(_loc3_[2]);
               if(SaveData.money > SaveData.moneyMax)
               {
                  SaveData.money = SaveData.moneyMax;
               }
               continue;
            }
            if(_loc3_[0] == "party")
            {
               AP_grantParty(String(_loc3_[1]));
               continue;
            }
            if(_loc3_[0] == "trap")
            {
               AP_applyTrap(String(_loc3_[1]));
               continue;
            }
            _loc4_ = null;
            if(_loc3_[0] == "i")
            {
               _loc4_ = Items[_loc3_[1]];
            }
            else if(_loc3_[0] == "e")
            {
               _loc4_ = Equips[_loc3_[1]];
            }
            else if(_loc3_[0] == "s")
            {
               _loc4_ = Spells[_loc3_[1]];
            }
            if(_loc4_ == null)
            {
               Main.log("[AP] unknown grant object: " + _loc3_[0] + ":" + _loc3_[1]);
               continue;
            }
            _loc2_.push(_loc4_);
            _loc2_.push(int(_loc3_[2]));
         }
         Main.log("[AP] received item " + param1.index + ": " + param1.name);
         if(param1.text is String)
         {
            AP_toast(param1.text);
         }
         if(_loc2_.length > 0)
         {
            (maps.parent as MapMenu).showTreasure(_loc2_);
         }
      }

      // Party shuffle: when active (from slot_data via the "session" msg), the
      // three recruitable allies (Matt/Natalie/Lance) no longer auto-join at
      // their story maps — Players.getX early-returns via AP_partyAllowed until
      // the AP item arrives. Anna is the free starting character. The unlocked
      // set persists in EBF4AP.sol so gating survives reloads.
      // EnergyLink deposit: remove up to `amount` gold and tell the client how
      // much we actually had, so it deposits exactly that to the shared pool.
      public static function AP_spendGold(param1:int) : *
      {
         var _loc2_:int = param1;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         if(_loc2_ > SaveData.money)
         {
            _loc2_ = SaveData.money;
         }
         SaveData.money -= _loc2_;
         if(_loc2_ > 0)
         {
            AP_toast("Deposited " + _loc2_ + " gold");
         }
         AP_send({
            "type":"goldSpent",
            "amount":_loc2_
         });
      }

      public static function AP_partyAllowed(param1:String) : Boolean
      {
         if(AP_state == null || AP_state.data.partyShuffle != true)
         {
            return true;
         }
         return AP_state.data.party != null && AP_state.data.party[param1] == true;
      }

      public static function AP_grantParty(param1:String) : *
      {
         if(!(AP_state.data.party is Object) || AP_state.data.party == null)
         {
            AP_state.data.party = {};
         }
         AP_state.data.party[param1] = true;
         AP_state.flush();
         AP_joinParty(param1);
      }

      public static function AP_joinParty(param1:String) : *
      {
         try
         {
            if(param1 == "matt")
            {
               Players.getMatt();
            }
            else if(param1 == "natalie")
            {
               Players.getNatalie();
            }
            else if(param1 == "lance")
            {
               Players.getLance();
            }
         }
         catch(e:Error)
         {
            Main.log("[AP] party join failed for " + param1 + ": " + e);
         }
      }

      // Traps map onto EBF4's own foe-difficulty toggles so they are safe and
      // self-limiting: a flag is set here, then cleared after the next battle
      // (AP_clearTraps in endBattle). goldloss is a one-shot money hit.
      public static function AP_applyTrap(param1:String) : *
      {
         if(param1 == "goldloss")
         {
            SaveData.money = Math.max(0,SaveData.money - 500);
            AP_toast("Gold Loss Trap! -500 gold");
            return;
         }
         if(param1 == "poison")
         {
            Options.offensiveFoes = true;
            AP_pushTrap("offensiveFoes");
            AP_toast("Poison Trap! Foes hit harder next battle");
         }
         else if(param1 == "statdown")
         {
            Options.bulkyFoes = true;
            AP_pushTrap("bulkyFoes");
            AP_toast("Stat Down Trap! Foes are tankier next battle");
         }
         else if(param1 == "encounter")
         {
            Options.surpriseAttack = true;
            AP_pushTrap("surpriseAttack");
            AP_toast("Encounter Trap! Ambushed next battle");
         }
      }

      public static function AP_pushTrap(param1:String) : *
      {
         if(AP_activeTraps.indexOf(param1) < 0)
         {
            AP_activeTraps.push(param1);
         }
      }

      public static function AP_clearTraps() : *
      {
         var _loc1_:String = null;
         for each(_loc1_ in AP_activeTraps)
         {
            if(_loc1_ == "offensiveFoes")
            {
               Options.offensiveFoes = false;
            }
            else if(_loc1_ == "bulkyFoes")
            {
               Options.bulkyFoes = false;
            }
            else if(_loc1_ == "surpriseAttack")
            {
               Options.surpriseAttack = false;
            }
         }
         AP_activeTraps = [];
      }

      public static function AP_chestOpened(param1:int, param2:int) : *
      {
         var _loc3_:String = "chest_" + param1 + "_" + param2;
         Main.log("[AP] chest opened: " + _loc3_);
         if(!(AP_state.data.checks is Array))
         {
            AP_state.data.checks = [];
         }
         if(AP_state.data.checks.indexOf(_loc3_) < 0)
         {
            AP_state.data.checks.push(_loc3_);
            AP_state.flush();
         }
         AP_send({
            "type":"check",
            "location":_loc3_
         });
      }

      public static function AP_battleWon(param1:int, param2:int) : *
      {
         var _loc3_:String = "battle_" + param1 + "_" + param2;
         if(AP_managed == null || AP_managed[_loc3_] != true)
         {
            return;
         }
         Main.log("[AP] battle won: " + _loc3_);
         if(!(AP_state.data.checks is Array))
         {
            AP_state.data.checks = [];
         }
         if(AP_state.data.checks.indexOf(_loc3_) < 0)
         {
            AP_state.data.checks.push(_loc3_);
            AP_state.flush();
         }
         AP_send({
            "type":"check",
            "location":_loc3_
         });
      }

      public static function AP_medalUnlocked(param1:String) : *
      {
         var _loc2_:String = "medal_" + param1;
         if(AP_managed == null || AP_managed[_loc2_] != true)
         {
            return;
         }
         if(!(AP_state.data.checks is Array))
         {
            AP_state.data.checks = [];
         }
         if(AP_state.data.checks.indexOf(_loc2_) < 0)
         {
            AP_state.data.checks.push(_loc2_);
            AP_state.flush();
         }
         AP_send({
            "type":"check",
            "location":_loc2_
         });
      }

      // Bestiary: a foe defeated for the first time is a check. Foes are recorded
      // as each wave spawns (AP_foeSpawned from Battle.nextWave) so multi-wave
      // battles count every wave, then flushed on a win (all waves cleared = all
      // those foes defeated). Reset per battle in startBattle.
      public static function AP_foeSpawned(param1:*) : *
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         try
         {
            _loc2_ = getQualifiedClassName(param1);
            _loc3_ = _loc2_.indexOf("::");
            if(_loc3_ >= 0)
            {
               _loc2_ = _loc2_.substring(_loc3_ + 2);
            }
            AP_battleFoes[_loc2_.toLowerCase()] = true;
         }
         catch(e:Error)
         {
         }
      }

      public static function AP_flushFoes() : *
      {
         var _loc1_:String = null;
         for(_loc1_ in AP_battleFoes)
         {
            AP_foeDefeated(_loc1_);
         }
         AP_battleFoes = {};
      }

      public static function AP_foeDefeated(param1:String) : *
      {
         var _loc2_:String = "foe_" + param1;
         if(AP_managed == null || AP_managed[_loc2_] != true)
         {
            return;
         }
         if(!(AP_state.data.checks is Array))
         {
            AP_state.data.checks = [];
         }
         if(AP_state.data.checks.indexOf(_loc2_) < 0)
         {
            AP_state.data.checks.push(_loc2_);
            AP_state.flush();
         }
         AP_send({
            "type":"check",
            "location":_loc2_
         });
      }

      public static function AP_resendChecks() : *
      {
         var _loc1_:String = null;
         if(!(AP_state.data.checks is Array))
         {
            return;
         }
         for each(_loc1_ in AP_state.data.checks)
         {
            AP_send({
               "type":"check",
               "location":_loc1_
            });
         }
      }

      public static function AP_retry() : *
      {
         if(AP_connected || AP_socket == null)
         {
            return;
         }
         ++AP_retryTicks;
         if(AP_retryTicks >= 15)
         {
            AP_retryTicks = 0;
            AP_connect();
         }
      }

      // ===== end Archipelago mod =====
      
      public static function listChildren(param1:MovieClip) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc2_++;
         }
      }
      
      public static function startBattle() : *
      {
         AP_battleFoes = {};
         onDeathList = [];
         fleeable = true;
         onDeath = null;
         skipAutosave = true;
         Maps.keyIsDown = [];
         onDeath = function():*
         {
            var _loc1_:Object = null;
            for each(_loc1_ in onDeathList)
            {
               Medals.unlock(_loc1_);
            }
         };
         tempSave[0] = Maps.mapX;
         tempSave[1] = Maps.mapY;
         tempSave[2] = Game.maps.player.X;
         tempSave[3] = Game.maps.player.Y;
         tempSave[4] = MapData.mapNo;
         (maps.parent as MapMenu).teardown();
         if(MapData.battleBG.length == 1)
         {
            background = MapData.battleBG[0];
         }
         else
         {
            background = MapData.battleBG[battleNo];
         }
         if(MapData.battleBGM.length == 1)
         {
            BGM.play(MapData.battleBGM[0]);
         }
         else
         {
            BGM.play(MapData.battleBGM[battleNo]);
         }
         respawnable = MapData.respawn[battleNo];
         foes = MapData.battles[battleNo];
         if(foes == Battles.endlessMarathon)
         {
            Global.endlessBattle = true;
            Global.endlessBattleWave = 0;
         }
         mode = BATTLE;
         Battle.init(background);
         Battle.foeWaves = foes;
         Battle.nextWave();
         Game.frame = new Frame();
         Game.root.addChild(Game.frame);
      }
      
      public static function endBattle() : *
      {
         var _loc2_:Player = null;
         var _loc3_:Equip = null;
         var _loc4_:MapMenu = null;
         BGM.randomize = true;
         Global.slime = false;
         Global.endlessBattle = false;
         try
         {
            AP_clearTraps();
         }
         catch(apErr:Error)
         {
         }
         if(onDeath != null && win)
         {
            onDeath();
            Medals.saveMisc();
         }
         onDeath = null;
         if(onDeath2 != null && win)
         {
            onDeath2();
            Medals.saveMisc();
         }
         onDeath2 = null;
         var _loc1_:String = "M" + mapNo + "_B" + battleNo;
         if(win)
         {
            if(!respawnable)
            {
               Maps.foeData[MapData.mapNo][battleNo] = 2;
               try
               {
                  AP_battleWon(MapData.mapNo,battleNo);
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               Maps.foeData[MapData.mapNo][battleNo] = 3;
            }
            try
            {
               AP_flushFoes();
            }
            catch(apFoeErr:Error)
            {
            }
            for each(_loc2_ in Battle.players)
            {
               for each(_loc3_ in _loc2_.equips)
               {
                  ++_loc3_.uses;
               }
            }
         }
         fleeable = true;
         foes = null;
         Battle.teardown();
         if(Boolean(Game.frame) && Boolean(Game.frame.parent))
         {
            Game.root.removeChild(Game.frame);
         }
         if(!gameOver)
         {
            _loc4_ = new MapMenu();
            Game.root.addChild(_loc4_);
            Game.maps = _loc4_.maps;
         }
         else
         {
            Log.CustomMetric(_loc1_,"Lose");
            gameOver = false;
         }
         Options.trackOptions();
         Game.root.setChildIndex(Game.root.medalBox,Game.root.numChildren - 1);
      }
      
      public static function mainLoop(param1:Event) : *
      {
         try
         {
            AP_tick();
            AP_toastTick();
            AP_deathTick();
         }
         catch(e:Error)
         {
         }
         if(!Debug.noMusic)
         {
            BGM.loop();
         }
         try
         {
            if(frame)
            {
               Debug.display();
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public static function timer(param1:TimerEvent) : *
      {
         try
         {
            AP_retry();
         }
         catch(e:Error)
         {
         }
         if(SaveData.inGame && Game.mode != Game.MAIN_MENU)
         {
            ++SaveData.playTime;
         }
      }
   }
}

