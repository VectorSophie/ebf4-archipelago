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
   import flash.utils.ByteArray;
   
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
               AP_state.flush();
            }
            Main.log("[AP] session " + _loc2_.session + ", managing " + _loc2_.locations.length + " locations");
            AP_sendHello();
         }
         else if(_loc2_.type == "ping")
         {
            AP_send({"type":"pong"});
         }
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
         if(_loc1_.index >= AP_state.data.itemIndex)
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
         if(_loc2_.length > 0)
         {
            (maps.parent as MapMenu).showTreasure(_loc2_);
         }
      }

      public static function AP_chestOpened(param1:int, param2:int) : *
      {
         Main.log("[AP] chest opened: map " + param1 + " chest " + param2);
         AP_send({
            "type":"check",
            "location":"chest_" + param1 + "_" + param2
         });
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
            }
            else
            {
               Maps.foeData[MapData.mapNo][battleNo] = 3;
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

