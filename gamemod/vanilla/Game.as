package
{
   import Playtomic.*;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   
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
      }
      
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
         if(SaveData.inGame && Game.mode != Game.MAIN_MENU)
         {
            ++SaveData.playTime;
         }
      }
   }
}

