package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol4459")]
   public class MapPlayer extends MovieClip
   {
      
      public var X:int = 6;
      
      public var Y:int = 8;
      
      public var center:MovieClip;
      
      public var busy:Boolean = false;
      
      public var facing:String = "";
      
      public var bubbles:MovieClip;
      
      public var bubble:MovieClip;
      
      public var shoes:int = 2;
      
      public var hat:int = 30;
      
      public var body:int = 50;
      
      public var player:int = 1;
      
      public var back:int = 2;
      
      public var hold:int = 2;
      
      public var emo:int = 1;
      
      public var hand:int = 1;
      
      public var race:int = 2;
      
      public var dye:int = 2;
      
      public var shownBubble:Boolean = false;
      
      public function MapPlayer(param1:*, param2:*)
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4,4,this.frame5,5,this.frame6,6,this.frame7,7,this.frame8,8,this.frame9,9,this.frame10,10,this.frame11,11,this.frame12,12,this.frame13,13,this.frame14,14,this.frame15,15,this.frame16,16,this.frame17,17,this.frame18,18,this.frame19,19,this.frame20,20,this.frame21,21,this.frame22,22,this.frame23,23,this.frame24,24,this.frame25,25,this.frame26,26,this.frame27,27,this.frame28,28,this.frame29,30,this.frame31,41,this.frame42,43,this.frame44,54,this.frame55,56,this.frame57,67,this.frame68,69,this.frame70,81,this.frame82,84,this.frame85,101,this.frame102,102,this.frame103,103,this.frame104,116,this.frame117);
         if(param1 != -1)
         {
            this.X = param1;
         }
         else
         {
            this.X = Constants.PLAYER_X;
         }
         if(param2 != -1)
         {
            this.Y = param2;
         }
         else
         {
            this.Y = Constants.PLAYER_Y;
         }
      }
      
      public function skin() : *
      {
         var _loc1_:Player = null;
         this.back = 2;
         this.hold = 2;
         if(this.player == 1)
         {
            _loc1_ = Players.player1;
            this.back = _loc1_.weapon.map[0];
            this.emo = 1;
         }
         if(this.player == 2)
         {
            _loc1_ = Players.player2;
            this.hold = _loc1_.weapon.map[0];
            this.emo = 24;
         }
         if(this.player == 3)
         {
            _loc1_ = Players.player3;
            this.back = _loc1_.weapon.map[0];
            this.emo = 43;
         }
         if(this.player == 4)
         {
            _loc1_ = Players.player4;
            this.back = _loc1_.weapon.map[0];
            this.emo = 55;
         }
         this.hat = _loc1_.hat.map[0];
         this.body = _loc1_.armor.map[0];
         this.shoes = _loc1_.armor.map[1];
         this.hand = _loc1_.armor.map[2];
         gotoAndStop("empty");
         gotoAndStop("right2");
         this.facing = Maps.RIGHT;
      }
      
      public function init() : *
      {
         if(MapMenu.tempMapVars)
         {
            this.X = MapMenu.tempMapVars[0];
            this.Y = MapMenu.tempMapVars[1];
         }
         this.player = (Game.party[0] as Player).playerNo;
         this.updatePosition();
         this.skin();
         parent.setChildIndex(this,parent.getChildIndex(parent["layer" + (this.Y + 1)]));
         if(Boolean(MapMenu.tempMapVars) && Boolean(MapMenu.tempMapVars[2]))
         {
            this.face(MapMenu.tempMapVars[2]);
         }
      }
      
      public function done() : *
      {
         this.busy = false;
         stop();
         if(Options.keyboard)
         {
            if(this.X < 0)
            {
               parent.moveMap = Maps.LEFT;
            }
            if(this.X > 13)
            {
               parent.moveMap = Maps.RIGHT;
            }
            if(this.Y < 0)
            {
               parent.moveMap = Maps.UP;
            }
            if(this.Y > 9)
            {
               parent.moveMap = Maps.DOWN;
            }
         }
         if(!parent)
         {
            return;
         }
         this.updatePosition();
         this.move();
         if((parent as Maps).grid[Maps.getTile(this.X,this.Y)] == 3 && !this.busy && !Options.keyboard)
         {
            gotoAndStop("up2");
         }
      }
      
      public function animate(param1:String) : *
      {
         this.busy = true;
         gotoAndPlay(param1);
      }
      
      public function setCave() : *
      {
         if((parent as Maps).grid[this.X + this.Y * 14] == 18)
         {
            if((parent as Maps).roof.alpha == 1)
            {
               (parent as Maps).roof.fader.gotoAndPlay("out");
               Maps.inCave = true;
            }
         }
         if((parent as Maps).grid[this.X + this.Y * 14] == 19)
         {
            if((parent as Maps).roof.alpha == 0)
            {
               (parent as Maps).roof.fader.gotoAndPlay("in");
               Maps.inCave = false;
            }
         }
      }
      
      public function updatePosition() : *
      {
         var p:Player = null;
         var o:Object = null;
         var mc:MovieClip = null;
         x = this.X * 50 - this.center.x + 30;
         y = this.Y * 40 - this.center.y + 40;
         this.setCave();
         if((parent as Maps).grid[this.X + this.Y * 14] == 11 && Items.thermalboots.quantity != 0)
         {
            this.bubbles.gotoAndPlay("burn");
            Medals.unlock(Medals.lava);
            for each(p in [Players.player1,Players.player2,Players.player3,Players.player4])
            {
               p.realHP -= p.maxHP / 50 * p.getResistance("elemental",Element.FIRE);
               if(p.realHP < 1)
               {
                  p.realHP = 1;
               }
               if(p.realHP > p.maxHP)
               {
                  p.realHP = p.maxHP;
               }
               (parent.parent as MapMenu).updatePlayerBars();
            }
         }
         ++SaveData.stepsWalked;
         if(SaveData.stepsWalked >= 10000)
         {
            Medals.unlock(Medals.marathon);
         }
         if(Debug.showCutscenes)
         {
            try
            {
               for each(o in (parent as Maps).objectData)
               {
                  mc = parent.getChildByName(o.mc);
                  if(o.type == Maps.SCENE && mc.X == this.X && this.Y == mc.Y)
                  {
                     if(!Maps.sceneData[MapData.mapNo][o.id])
                     {
                        ++parent.busy;
                        Maps.sceneData[MapData.mapNo][o.id] = true;
                        ((parent.parent as MapMenu).textbox as MapText).page = 0;
                        ((parent.parent as MapMenu).textbox as MapText).NpcData = null;
                        ((parent.parent as MapMenu).textbox as MapText).scene(o.data,o.slides);
                     }
                  }
                  else if(o.type == Maps.FOE2 && mc.X == this.X && this.Y == mc.Y)
                  {
                     if(mc.state == 0)
                     {
                        this.busy = true;
                        Game.battleNo = mc.name.substring(3);
                        (parent as Maps).interact = "";
                        (parent as Maps).startBattle();
                        mc.state = 1;
                        Game.mapNo = MapData.mapNo;
                     }
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         if(Maps.outOfGrid(this.X,this.Y) && (parent as Maps).moveMap != "")
         {
            parent.fader.gotoAndPlay((parent as Maps).moveMap);
         }
         else
         {
            try
            {
               parent.setChildIndex(this,parent.getChildIndex(parent["layer" + (this.Y + 1)]));
            }
            catch(errObject:Error)
            {
            }
         }
      }
      
      public function showBubble(param1:int) : *
      {
         if(!Options.keyboard || this.shownBubble)
         {
            return;
         }
         this.shownBubble = true;
         this.bubble.visible = true;
         this.bubble.f = param1;
         this.bubble.gotoAndPlay(2);
      }
      
      public function passiveHeal() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in [Players.player1,Players.player2,Players.player3,Players.player4])
         {
            _loc1_.realHP += Math.ceil(_loc1_.maxHP / 30);
            if(_loc1_.realHP > _loc1_.maxHP)
            {
               _loc1_.realHP = _loc1_.maxHP;
            }
            _loc1_.realMP += Math.ceil(_loc1_.maxMP / 120);
            if(_loc1_.realMP > _loc1_.maxMP)
            {
               _loc1_.realMP = _loc1_.maxMP;
            }
            try
            {
               (parent.parent as MapMenu).updatePlayerBars();
            }
            catch(e:Error)
            {
            }
            try
            {
               (parent.parent as MapMenu).initFood(false);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function move() : *
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:MovieClip = null;
         if(Options.keyboard && !this.busy && !(parent as Maps).busy)
         {
            (parent as Maps).handleKeys();
         }
         if(!Options.keyboard && !this.busy && !(parent as Maps).busy && Boolean((parent as Maps).path.length))
         {
            _loc1_ = int((parent as Maps).path.pop());
            this.busy = true;
            if(_loc1_ == Maps.getTile(this.X,this.Y) + 1)
            {
               this.moveRight();
            }
            if(_loc1_ == Maps.getTile(this.X,this.Y) - 1)
            {
               this.moveLeft();
            }
            if(_loc1_ == Maps.getTile(this.X,this.Y) - 14)
            {
               this.moveUp();
            }
            if(_loc1_ == Maps.getTile(this.X,this.Y) + 14)
            {
               this.moveDown();
            }
         }
         else if(!this.busy && !(parent as Maps).busy && (parent as Maps).moveMap != "")
         {
            this.busy = true;
            if((parent as Maps).moveMap == Maps.RIGHT)
            {
               this.moveRight();
            }
            if((parent as Maps).moveMap == Maps.LEFT)
            {
               this.moveLeft();
            }
            if((parent as Maps).moveMap == Maps.UP)
            {
               this.moveUp();
            }
            if((parent as Maps).moveMap == Maps.DOWN)
            {
               this.moveDown();
            }
         }
         else if(!Options.keyboard && !(parent as Maps).busy && !this.busy && !(parent as Maps).path.length)
         {
            if((parent as Maps).interact == Maps.RIGHT)
            {
               this.face(Maps.RIGHT);
            }
            if((parent as Maps).interact == Maps.LEFT)
            {
               this.face(Maps.LEFT);
            }
            if((parent as Maps).interact == Maps.UP)
            {
               this.face(Maps.UP);
            }
            if((parent as Maps).interact == Maps.DOWN)
            {
               this.face(Maps.DOWN);
            }
            if(parent)
            {
               this.interact();
            }
         }
         if(Options.keyboard)
         {
            for each(_loc2_ in (parent as Maps).objectData)
            {
               _loc3_ = parent.getChildByName(_loc2_.mc);
               if(_loc2_.type == Maps.SIGN && _loc3_.X + _loc3_.Y * 14 == this.X + this.Y * 14 && this.facing == Maps.UP && !(parent.parent as MapMenu).playerMenu.visible || _loc2_.type != Maps.SIGN && _loc2_.type != Maps.SCENE && _loc3_.X + _loc3_.Y * 14 == this.facingTile() && (parent as Maps).grid[_loc3_.X + _loc3_.Y * 14] != 0 && (parent as Maps).grid[_loc3_.X + _loc3_.Y * 14] != 1)
               {
                  this.showBubble(2);
               }
            }
         }
      }
      
      public function interact() : *
      {
         var _loc2_:Object = null;
         var _loc3_:MovieClip = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc1_:Boolean = false;
         for each(_loc2_ in (parent as Maps).objectData)
         {
            _loc3_ = parent.getChildByName(_loc2_.mc);
            if(_loc3_.X + _loc3_.Y * 14 == this.facingTile() && (parent as Maps).grid[_loc3_.X + _loc3_.Y * 14] != 0 && (parent as Maps).grid[_loc3_.X + _loc3_.Y * 14] != 1)
            {
               if(_loc2_.type == Maps.CHEST && Boolean((parent as Maps).interact))
               {
                  if(_loc3_.state == 0)
                  {
                     this.busy = true;
                     this.animate("open" + this.facing);
                     _loc3_.gotoAndPlay("open");
                     _loc3_.state = 1;
                     --Maps.treasures;
                     (parent.parent as MapMenu).showTreasure(_loc2_.data);
                     (parent as Maps).interact = "";
                  }
               }
               if(_loc2_.type == Maps.SHOP && Boolean((parent as Maps).interact))
               {
                  this.busy = true;
                  this.animate("open" + this.facing);
                  (parent.parent as MapMenu).showShop(_loc2_.data);
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.FOE && Boolean((parent as Maps).interact))
               {
                  if(_loc3_.state == 0)
                  {
                     if(!Debug.skipBattles)
                     {
                        this.busy = true;
                        this.animate("open" + this.facing);
                        Game.battleNo = _loc3_.name.substring(3);
                        (parent as Maps).interact = "";
                        (parent as Maps).startBattle();
                        _loc3_.state = 1;
                        Game.mapNo = MapData.mapNo;
                     }
                     else
                     {
                        Maps.foeData[MapData.mapNo][_loc3_.name.substring(3)] = 2;
                     }
                  }
               }
               if(_loc2_.type == Maps.TORCH && Boolean((parent as Maps).interact))
               {
                  if(Items.candle.quantity == 0)
                  {
                     _loc3_.gotoAndPlay("bubble");
                  }
                  else if(_loc3_.state == 0)
                  {
                     _loc3_.gotoAndPlay("open");
                     _loc3_.state = 1;
                  }
                  this.animate("open" + this.facing);
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.ROCK && Boolean((parent as Maps).interact))
               {
                  if(Items.hammer.quantity == 0)
                  {
                     _loc3_.gotoAndPlay("bubble");
                  }
                  else if(_loc3_.state == 0)
                  {
                     _loc3_.gotoAndPlay("open");
                     _loc3_.state = 1;
                     (parent.parent as MapMenu).rockTreasure();
                  }
                  this.animate("open" + this.facing);
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.LADDER && Boolean((parent as Maps).interact))
               {
                  if(Items.stepladder.quantity == 0)
                  {
                     _loc3_.gotoAndPlay("bubble");
                  }
                  else if(_loc3_.state == 0)
                  {
                     _loc3_.gotoAndPlay("open");
                     _loc3_.state = 1;
                  }
                  this.animate("open" + this.facing);
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.TREE && Boolean((parent as Maps).interact))
               {
                  if(Items.axe.quantity == 0)
                  {
                     _loc3_.gotoAndPlay("bubble");
                  }
                  else if(_loc3_.state == 0)
                  {
                     _loc3_.gotoAndPlay("open");
                     _loc3_.state = 1;
                     (parent.parent as MapMenu).treeTreasure();
                  }
                  this.animate("open" + this.facing);
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.SWITCH && Boolean((parent as Maps).interact))
               {
                  this.animate("open" + this.facing);
                  _loc3_.play();
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.PED && Boolean((parent as Maps).interact))
               {
                  this.animate("open" + this.facing);
                  if(_loc3_.state == 0 && _loc3_.item.quantity != 0)
                  {
                     Maps.switchData[_loc3_.id] = true;
                     _loc3_.gotoAndPlay("on");
                     _loc3_.state = 1;
                     --_loc3_.item.quantity;
                  }
                  else if(_loc3_.state == 1)
                  {
                     Maps.switchData[_loc3_.id] = false;
                     _loc3_.gotoAndPlay("off");
                     _loc3_.state = 0;
                     (parent.parent as MapMenu).showTreasure([_loc3_.item,1]);
                  }
                  else
                  {
                     _loc3_.gotoAndPlay("bubble");
                  }
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.KEY_BLOCK && Boolean((parent as Maps).interact))
               {
                  if(_loc3_.state == 0)
                  {
                     if(_loc3_.item.quantity > 0)
                     {
                        this.busy = true;
                        this.animate("open" + this.facing);
                        _loc3_.gotoAndPlay("open");
                        _loc3_.state = 1;
                        --_loc3_.item.quantity;
                     }
                     else
                     {
                        this.animate("open" + this.facing);
                        _loc3_.gotoAndPlay("nope");
                     }
                     (parent as Maps).interact = "";
                  }
               }
               if(_loc2_.type == Maps.PUSH_BLOCK && Boolean((parent as Maps).interact))
               {
                  _loc4_ = false;
                  this.busy = true;
                  this.animate("open" + this.facing);
                  if(!Maps.blockData[MapData.mapNo])
                  {
                     if(this.facing == Maps.RIGHT && (parent as Maps).grid[_loc3_.X + 1 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 5;
                        _loc3_.py = 0;
                        _loc4_ = true;
                     }
                     if(this.facing == Maps.LEFT && (parent as Maps).grid[_loc3_.X - 1 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = -5;
                        _loc3_.py = 0;
                        _loc4_ = true;
                     }
                     if(this.facing == Maps.UP && (parent as Maps).grid[_loc3_.X - 14 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 0;
                        _loc3_.py = -4;
                        _loc4_ = true;
                     }
                     if(this.facing == Maps.DOWN && (parent as Maps).grid[_loc3_.X + 14 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 0;
                        _loc3_.py = 4;
                        _loc4_ = true;
                     }
                     if(_loc4_)
                     {
                        _loc3_.gotoAndPlay("push");
                     }
                  }
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.ICE_BLOCK && Boolean((parent as Maps).interact))
               {
                  _loc4_ = false;
                  this.busy = true;
                  this.animate("open" + this.facing);
                  if(!Maps.blockData[MapData.mapNo])
                  {
                     if(this.facing == Maps.RIGHT && (parent as Maps).grid[_loc3_.X + 1 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 5;
                        _loc3_.py = 0;
                        _loc4_ = true;
                        SFX.playSound("ice");
                     }
                     if(this.facing == Maps.LEFT && (parent as Maps).grid[_loc3_.X - 1 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = -5;
                        _loc3_.py = 0;
                        _loc4_ = true;
                        SFX.playSound("ice");
                     }
                     if(this.facing == Maps.UP && (parent as Maps).grid[_loc3_.X - 14 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 0;
                        _loc3_.py = -4;
                        _loc4_ = true;
                        SFX.playSound("ice");
                     }
                     if(this.facing == Maps.DOWN && (parent as Maps).grid[_loc3_.X + 14 + _loc3_.Y * 14] == 4)
                     {
                        _loc3_.px = 0;
                        _loc3_.py = 4;
                        _loc4_ = true;
                        SFX.playSound("ice");
                     }
                     if(_loc4_)
                     {
                        _loc3_.gotoAndPlay("push");
                     }
                  }
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.BUNNY && Boolean((parent as Maps).interact))
               {
                  this.busy = true;
                  ++(parent as Maps).busy;
                  this.animate("open" + this.facing);
                  this.facing = Maps.DOWN;
                  _loc3_.gotoAndPlay("open");
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.WARP && Boolean((parent as Maps).interact))
               {
                  this.busy = true;
                  ++(parent as Maps).busy;
                  this.animate("open" + this.facing);
                  this.facing = Maps.DOWN;
                  _loc3_.gotoAndPlay("open");
                  (parent as Maps).interact = "";
               }
               if(_loc2_.type == Maps.ANIMAL && Boolean((parent as Maps).interact))
               {
                  this.busy = true;
                  this.animate("open" + this.facing);
                  _loc3_.gotoAndPlay("scare");
                  (parent as Maps).interact = "";
               }
               if((_loc2_.type == Maps.SIGN2 || _loc2_.type == Maps.NPCMC) && (parent as Maps).interact && !(parent.parent as MapMenu).playerMenu.visible)
               {
                  _loc1_ = true;
                  (parent as Maps).interact = "";
               }
            }
            if(_loc3_.X + _loc3_.Y * 14 == this.X + this.Y * 14 && !(parent.parent as MapMenu).playerMenu.visible && !(parent.parent as MapMenu).equipsMenu.visible && (!Options.keyboard || this.facing == Maps.UP) || _loc1_)
            {
               if(_loc2_.type == Maps.SIGN || _loc2_.type == Maps.SIGN2)
               {
                  (parent.parent as MapMenu).textbox.more = false;
                  if(_loc2_.data.length > 2)
                  {
                     (parent.parent as MapMenu).showText(_loc2_.data[this.player * 2 - 2],_loc2_.data[this.player * 2 - 1],this.player);
                  }
                  else
                  {
                     (parent.parent as MapMenu).showText(_loc2_.data[0],_loc2_.data[1],this.player);
                  }
               }
               if(_loc2_.type == Maps.NPCMC)
               {
                  if(this.facing == Maps.RIGHT)
                  {
                     _loc3_.Npc.animate(Maps.LEFT);
                  }
                  if(this.facing == Maps.LEFT)
                  {
                     _loc3_.Npc.animate(Maps.RIGHT);
                  }
                  if(this.facing == Maps.UP)
                  {
                     _loc3_.Npc.animate(Maps.DOWN);
                  }
                  if(this.facing == Maps.DOWN)
                  {
                     _loc3_.Npc.animate(Maps.UP);
                  }
                  _loc5_ = (parent.parent as MapMenu).textbox.NpcData != _loc3_.data as NPC || !(parent.parent as MapMenu).textbox.more;
                  (parent.parent as MapMenu).textbox.NpcData = _loc3_.data as NPC;
                  (parent.parent as MapMenu).textbox.NpcTalk(true);
               }
               _loc1_ = false;
               this.bubble.visible = false;
            }
         }
      }
      
      public function dark() : *
      {
         if(!parent)
         {
            return;
         }
         if((parent as Maps).darkness)
         {
            (parent as Maps).darkness.x = this.x + this.center.x * 0.9;
            (parent as Maps).darkness.y = this.y + this.center.y * 0.9 - 40;
         }
      }
      
      public function getHeal() : *
      {
         var _loc1_:Player = null;
         (parent.parent as MapMenu).textbox.type = MapText.BUNNY;
         (parent.parent as MapMenu).showText(Strings.SLIME_BUNNY,0);
         for each(_loc1_ in [Players.player1,Players.player2,Players.player3,Players.player4])
         {
            _loc1_.eatItem(Items.burger);
         }
         (parent.parent as MapMenu).updatePlayerBars();
         this.animate("heal");
      }
      
      public function getWarp() : *
      {
         this.animate("warp");
      }
      
      public function facingTile() : int
      {
         if(this.facing == Maps.LEFT)
         {
            return this.X + this.Y * 14 - 1;
         }
         if(this.facing == Maps.RIGHT)
         {
            return this.X + this.Y * 14 + 1;
         }
         if(this.facing == Maps.UP)
         {
            return this.X + this.Y * 14 - 14;
         }
         if(this.facing == Maps.DOWN)
         {
            return this.X + this.Y * 14 + 14;
         }
      }
      
      public function moveLeft() : *
      {
         this.animate(Maps.LEFT);
         this.facing = Maps.LEFT;
         --this.X;
      }
      
      public function moveRight() : *
      {
         this.animate(Maps.RIGHT);
         this.facing = Maps.RIGHT;
         ++this.X;
      }
      
      public function moveUp() : *
      {
         this.animate(Maps.UP);
         this.facing = Maps.UP;
         --this.Y;
      }
      
      public function moveDown() : *
      {
         this.animate(Maps.DOWN);
         this.facing = Maps.DOWN;
         ++this.Y;
      }
      
      public function face(param1:String) : Boolean
      {
         if(param1 == this.facing)
         {
            return false;
         }
         this.shownBubble = false;
         gotoAndStop(param1 + "2");
         this.facing = param1;
         return true;
      }
      
      internal function frame1() : *
      {
         stop();
         this.dark();
      }
      
      internal function frame2() : *
      {
         this.dark();
         this.bubble.visible = false;
      }
      
      internal function frame3() : *
      {
         this.dark();
      }
      
      internal function frame4() : *
      {
         this.dark();
      }
      
      internal function frame5() : *
      {
         this.dark();
      }
      
      internal function frame6() : *
      {
         this.dark();
      }
      
      internal function frame7() : *
      {
         this.bubble.visible = false;
         this.shownBubble = false;
         this.dark();
      }
      
      internal function frame8() : *
      {
         this.done();
         this.dark();
         if(Boolean(Maps.treasures) && Options.treasureFinder)
         {
            this.bubble.visible = true;
            this.bubble.gotoAndPlay(2);
         }
      }
      
      internal function frame9() : *
      {
         this.dark();
         this.bubble.visible = false;
      }
      
      internal function frame10() : *
      {
         this.dark();
      }
      
      internal function frame11() : *
      {
         this.dark();
      }
      
      internal function frame12() : *
      {
         this.dark();
      }
      
      internal function frame13() : *
      {
         this.dark();
      }
      
      internal function frame14() : *
      {
         this.bubble.visible = false;
         this.shownBubble = false;
         this.dark();
      }
      
      internal function frame15() : *
      {
         this.done();
         this.dark();
         if(Boolean(Maps.treasures) && Options.treasureFinder)
         {
            this.bubble.visible = true;
            this.bubble.gotoAndPlay(2);
         }
      }
      
      internal function frame16() : *
      {
         this.dark();
         this.bubble.visible = false;
      }
      
      internal function frame17() : *
      {
         this.dark();
      }
      
      internal function frame18() : *
      {
         this.dark();
      }
      
      internal function frame19() : *
      {
         this.dark();
      }
      
      internal function frame20() : *
      {
         this.dark();
      }
      
      internal function frame21() : *
      {
         this.bubble.visible = false;
         this.shownBubble = false;
         this.dark();
      }
      
      internal function frame22() : *
      {
         this.done();
         this.dark();
         if(Boolean(Maps.treasures) && Options.treasureFinder)
         {
            this.bubble.visible = true;
            this.bubble.gotoAndPlay(2);
         }
      }
      
      internal function frame23() : *
      {
         this.dark();
         this.bubble.visible = false;
      }
      
      internal function frame24() : *
      {
         this.dark();
      }
      
      internal function frame25() : *
      {
         this.dark();
      }
      
      internal function frame26() : *
      {
         this.dark();
      }
      
      internal function frame27() : *
      {
         this.dark();
      }
      
      internal function frame28() : *
      {
         this.bubble.visible = false;
         this.shownBubble = false;
         if(Debug.mappingMode2 || Debug.mappingMode)
         {
            visible = false;
         }
         this.dark();
      }
      
      internal function frame29() : *
      {
         this.done();
         this.dark();
         if(Boolean(Maps.treasures) && Options.treasureFinder)
         {
            this.bubble.visible = true;
            this.bubble.gotoAndPlay(2);
         }
      }
      
      internal function frame31() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame42() : *
      {
         gotoAndStop("left2");
      }
      
      internal function frame44() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame55() : *
      {
         gotoAndStop("right2");
      }
      
      internal function frame57() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame68() : *
      {
         gotoAndStop("up2");
      }
      
      internal function frame70() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame82() : *
      {
         gotoAndStop("down2");
      }
      
      internal function frame85() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame102() : *
      {
         stop();
         this.done();
      }
      
      internal function frame103() : *
      {
         this.dark();
      }
      
      internal function frame104() : *
      {
         this.bubble.visible = false;
      }
      
      internal function frame117() : *
      {
         stop();
         parent.warp();
         this.done();
         this.dark();
      }
   }
}

