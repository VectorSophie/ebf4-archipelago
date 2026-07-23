package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   
   [Embed(source="/_assets/assets.swf", symbol="BattleMenu")]
   public class BattleMenu extends MovieClip
   {
      
      public static var adCount:int = 2;
       
      
      public var playerBars:MovieClip;
      
      public var awardDisplay:MovieClip;
      
      public var commandMenu:MovieClip;
      
      public var skillMenuSmall:MovieClip;
      
      public var skillMenuBig:MovieClip;
      
      public var skillMenuHuge:MovieClip;
      
      public var equipMenu:MovieClip;
      
      public var equipMenu2:MovieClip;
      
      public var equipMenu3:MovieClip;
      
      public var transitions:MovieClip;
      
      public var speechBox:MovieClip;
      
      public var stats:MovieClip;
      
      public var foeStats:MovieClip;
      
      public var pointer:MovieClip;
      
      public var pointer2:MovieClip;
      
      public var foeBars:MovieClip;
      
      public var playerArrow:MovieClip;
      
      public var debugButton:SimpleButton;
      
      public var adScreen:MovieClip;
      
      public var crosshairs:Array;
      
      public var bubbles:Array;
      
      public var selectedSkill:Object;
      
      public var currentMenu:String = "";
      
      public var turnStarted:Boolean = false;
      
      public var cursor:Icon;
      
      public var newEquips:Array;
      
      public var equipPos:int;
      
      private var equipFlag:Boolean = false;
      
      public function BattleMenu()
      {
         this.crosshairs = [];
         this.bubbles = [];
         this.newEquips = [];
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function showMochiAd() : *
      {
      }
      
      public function init() : *
      {
         Game.root.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.onRightClick);
         this.cursor = GUI.createIcon(this,null,null,true,Icon.CURSOR);
         this.cursor.icon.gotoAndStop(140);
         Game.root.mouseFunction = this.moveCursor;
         this.cursor.visible = false;
         Game.mode = Game.BATTLE;
         this.commandMenu.visible = false;
         this.playerArrow.mouseEnabled = false;
         this.awardDisplay.visible = false;
         this.updatePlayerBars();
         this.updateFoeBars();
         this.hideSkillMenus();
         this.pointer2.y = 1000;
      }
      
      public function tearDown() : *
      {
         Game.root.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,this.onRightClick);
      }
      
      public function onRightClick(param1:MouseEvent = null) : *
      {
         if(this.stats.visible)
         {
            this.stats.visible = false;
         }
         if(this.equipMenu3.visible || this.equipMenu2.visible)
         {
            this.cancelEquipSelection();
         }
         else if(this.currentMenu && this.commandMenu.visible && this.commandMenu.currentFrame == 1)
         {
            this.hideSkillMenus();
            this.currentMenu = "";
            this.openRecentMenu();
         }
         if(this.commandMenu.currentFrame == 2 && this.commandMenu.visible)
         {
            this.cancelSelection();
         }
         if(this.speechBox.visible)
         {
            this.speechBox.nextText();
         }
      }
      
      public function moveCursor() : *
      {
         this.cursor.x = mouseX;
         this.cursor.y = mouseY;
      }
      
      public function showSwapCrosshairs() : *
      {
         var _loc1_:Player = null;
         var _loc2_:MovieClip = null;
         for each(_loc1_ in Battle.players)
         {
            if(_loc1_.canTakeTurn() && Battle.currentPlayer != _loc1_)
            {
               _loc2_ = new Crosshair3();
               addChild(_loc2_);
               _loc2_.x += _loc1_.graphic.getX(3) - 5;
               _loc2_.y += _loc1_.graphic.getY(3) + 15;
               this.crosshairs.push(_loc2_);
               _loc2_.scaleX = 1.2;
               _loc2_.scaleY = 1.2;
               _loc2_.target = _loc1_;
               this.setChildIndex(_loc2_,0);
            }
         }
      }
      
      public function startTurn() : *
      {
         if(Debug.trailerMode)
         {
            this.visible = true;
         }
         this.showSwapCrosshairs();
         this.selectedSkill = null;
         this.newEquips = [null,null,null,null,null,null];
         this.equipFlag = false;
         this.showInfoBubbles();
         this.commandMenu.visible = true;
         this.commandMenu.fader.gotoAndPlay(1);
         this.commandMenu.gotoAndStop(1);
         if(Battle.currentPlayer.limit != 100 || !Battle.currentPlayer.hasLimitSkill())
         {
            this.commandMenu.limit.visible = false;
         }
         else
         {
            this.commandMenu.limit.visible = true;
         }
         this.commandMenu.icon.gotoAndStop(Battle.currentPlayer.playerNo);
         Skills.user = Battle.currentPlayer;
         Battle.currentPlayer.startTurn();
         this.openRecentMenu();
         if(Boolean(this.commandMenu) && Boolean(this.commandMenu.icons2))
         {
            this.commandMenu.icons2.gotoAndStop(Battle.currentPlayer.playerNo + 1);
         }
         if(!Battle.currentPlayer.slime)
         {
            this.setPlayerArrow();
         }
         if(Battle.currentPlayer == Battle.players[0])
         {
            this.pointer2.y = 368;
         }
         if(Battle.currentPlayer == Battle.players[1])
         {
            this.pointer2.y = 398;
         }
         if(Battle.currentPlayer == Battle.players[2])
         {
            this.pointer2.y = 428;
         }
      }
      
      public function showInfoBubbles() : *
      {
         var _loc1_:Target = null;
         var _loc2_:MovieClip = null;
         for each(_loc1_ in Battle.foes)
         {
            if(_loc1_ && !_loc1_.dead && (Foes.isScanned(_loc1_) || Boolean(Debug.bestiary) || Options.autoScan))
            {
               _loc2_ = new Bubble(_loc1_,this.showFoeStats);
               addChild(_loc2_);
               _loc2_.x = _loc1_.graphic.getX(4) + 35;
               _loc2_.y = _loc1_.graphic.getY(4) + 25;
               this.bubbles.push(_loc2_);
               this.setChildIndex(_loc2_,0);
            }
         }
      }
      
      public function hideInfoBubbles() : *
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.bubbles)
         {
            if(Boolean(_loc1_) && Boolean(_loc1_.parent))
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
      }
      
      public function setPlayerArrow() : *
      {
         this.playerArrow.gotoAndPlay("intro");
         this.playerArrow.x = Battle.currentPlayer.graphic.getX(4) - 5;
         this.playerArrow.y = Battle.currentPlayer.graphic.getY(4) - 40;
      }
      
      public function selectSkill(param1:Object) : *
      {
         this.removeCrosshairs();
         this.cursor.icon.gotoAndStop(param1.icon);
         this.cursor.visible = true;
         this.hideSkillMenus();
         this.commandMenu.gotoAndStop(2);
         this.selectedSkill = param1;
         this.showCrosshairs(param1.target);
         setChildIndex(this.cursor,numChildren - 1);
      }
      
      public function selectTarget(param1:Target) : *
      {
         if(Debug.trailerMode)
         {
            this.visible = false;
         }
         this.cursor.icon.gotoAndStop(140);
         this.cursor.visible = false;
         Global.element = Battle.currentPlayer.weapon.element;
         this.hideInfoBubbles();
         Battle.selectedTarget = param1;
         Battle.currentPlayer.turnTaken = true;
         if(this.selectedSkill == Spells.defend)
         {
            Battle.currentPlayer.graphic.animate("defend");
            ++Battle.currentPlayer.status[Status.DEFEND];
            this.addToRecent(Spells.defend);
         }
         else if(this.selectedSkill == Spells.skip)
         {
            this.addToRecent(Spells.skip);
         }
         else if(this.selectedSkill == Spells.swap)
         {
            Battle.currentPlayer.turnTaken = false;
            Battle.swapPlayer = Battle.selectedTarget;
         }
         else if(this.selectedSkill == Spells.standby)
         {
            Battle.currentPlayer.turnTaken = false;
            Battle.standbySwitch = true;
            if(!Battle.selectedTarget.dead)
            {
               Battle.selectedTarget.graphic.animate("hide");
            }
            else
            {
               Battle.selectedTarget.graphic.animate("dragout");
            }
         }
         else if(this.selectedSkill == Spells.flee)
         {
            Battle.flee();
         }
         else if(this.currentMenu == "item")
         {
            Battle.currentPlayer.useItem(this.selectedSkill);
            --(this.selectedSkill as Item).quantity;
         }
         else if(this.currentMenu == "equip")
         {
            Battle.currentPlayer.graphic.animate("equip");
         }
         else if(this.currentMenu == "summon")
         {
            Battle.currentPlayer.useSkill(this.selectedSkill);
            Battle.SP -= this.selectedSkill.getStats().MP;
            try
            {
               Game.AP_summonUsed(this.selectedSkill);
            }
            catch(apSummonErr:Error)
            {
            }
         }
         else
         {
            Battle.currentPlayer.useSkill(this.selectedSkill);
            Battle.currentPlayer.realMP -= this.selectedSkill.getStats().MP;
            this.addToRecent(this.selectedSkill);
         }
         this.removeCrosshairs();
         this.commandMenu.visible = false;
         this.turnStarted = false;
         this.playerArrow.gotoAndPlay("outro");
         this.pointer2.y = 1000;
         this.updatePlayerBars();
      }
      
      public function quickSwapPlayer(param1:Player) : *
      {
         this.cursor.icon.gotoAndStop(140);
         this.cursor.visible = false;
         Battle.currentPlayer.turnTaken = false;
         Battle.selectedTarget = param1;
         Battle.swapPlayer = Battle.selectedTarget;
         this.removeCrosshairs();
         this.hideSkillMenus();
         this.hideInfoBubbles();
         this.commandMenu.visible = false;
         this.turnStarted = false;
         this.playerArrow.gotoAndPlay("outro");
         this.pointer2.y = 1000;
         this.commandMenu.icons2.gotoAndStop(Battle.selectedTarget.playerNo + 1);
         this.updatePlayerBars();
      }
      
      public function addToRecent(param1:Object) : *
      {
         var _loc3_:Object = null;
         if(param1.MP[0] == 0 && param1.name != "Normal Attack")
         {
            return;
         }
         var _loc2_:Array = Battle.currentPlayer.recentSkills;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_ == param1)
            {
               _loc2_.splice(_loc2_.indexOf(_loc3_),1);
            }
         }
         _loc2_.unshift(param1);
         if(Battle.currentPlayer.recentSkills.length > 6)
         {
            Battle.currentPlayer.recentSkills.pop();
         }
      }
      
      public function showCrosshairs(param1:String) : *
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Target = null;
         if(param1 == Target.AUTO)
         {
            this.selectTarget(Battle.currentPlayer);
         }
         if(param1 == Target.ONE_ENEMY || param1 == Target.CENTER_ENEMY || param1 == Target.ONE_ANY)
         {
            for each(_loc3_ in Battle.foes)
            {
               this.showCrosshair(_loc3_);
            }
         }
         if(param1 == Target.ALL_ENEMY)
         {
            _loc2_ = new Crosshair();
            addChild(_loc2_);
            _loc2_.x = 550;
            _loc2_.y = 230;
            _loc2_.scaleX = 3;
            _loc2_.scaleY = 3;
            this.crosshairs.push(_loc2_);
            this.setChildIndex(_loc2_,0);
         }
         if(param1 == Target.ONE_ALLY || param1 == Target.ONE_ANY || param1 == Target.ANY_ALLY)
         {
            for each(_loc3_ in Battle.players)
            {
               if(!_loc3_.dead)
               {
                  this.showCrosshair(_loc3_);
               }
            }
         }
         if(param1 == Target.READY_ALLY)
         {
            for each(_loc3_ in Battle.players)
            {
               if(_loc3_.canTakeTurn())
               {
                  this.showCrosshair(_loc3_);
               }
            }
         }
         if(param1 == Target.SWAPABLE_ALLY)
         {
            for each(_loc3_ in Battle.players)
            {
               if(!_loc3_.turnTaken && !_loc3_.status[Status.FREEZE] && !_loc3_.status[Status.SLIME])
               {
                  this.showCrosshair(_loc3_,true);
               }
            }
         }
         if(param1 == Target.DEAD_ALLY || param1 == Target.ANY_ALLY)
         {
            for each(_loc3_ in Battle.players)
            {
               if(_loc3_.dead)
               {
                  this.showCrosshair(_loc3_,true);
               }
            }
         }
         if(param1 == Target.ALL_ALLY)
         {
            _loc2_ = new Crosshair();
            addChild(_loc2_);
            _loc2_.x = 150;
            _loc2_.y = 200;
            _loc2_.scaleX = 3;
            _loc2_.scaleY = 3;
            this.crosshairs.push(_loc2_);
            this.setChildIndex(_loc2_,0);
         }
         if(param1 == Target.ALL)
         {
            _loc2_ = new Crosshair();
            addChild(_loc2_);
            _loc2_.x = 350;
            _loc2_.y = 240;
            _loc2_.scaleX = 4.5;
            _loc2_.scaleY = 4.5;
            this.crosshairs.push(_loc2_);
            this.setChildIndex(_loc2_,0);
         }
      }
      
      public function showCrosshair(param1:Target, param2:Boolean = false) : *
      {
         var _loc3_:MovieClip = null;
         if(!param1.dead || param2)
         {
            _loc3_ = new Crosshair();
            addChild(_loc3_);
            _loc3_.x += param1.graphic.getX(3);
            _loc3_.y += param1.graphic.getY(3);
            this.crosshairs.push(_loc3_);
            _loc3_.scaleX = 1.2;
            _loc3_.scaleY = 1.2;
            _loc3_.target = param1;
         }
      }
      
      public function removeCrosshairs() : *
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.crosshairs)
         {
            if(Boolean(_loc1_) && Boolean(_loc1_.parent))
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
      }
      
      public function hideSkillMenus() : *
      {
         if(this.currentMenu != "equip")
         {
            this.newEquips = [null,null,null,null,null,null];
            this.equipFlag = false;
         }
         this.skillMenuSmall.visible = false;
         this.skillMenuBig.visible = false;
         this.skillMenuHuge.visible = false;
         this.equipMenu.visible = false;
         this.equipMenu2.visible = false;
         this.equipMenu3.visible = false;
         GUI.removeIcons();
         this.pointer.y = 1000;
      }
      
      public function cancelSelection() : *
      {
         Spell.SUMMON = false;
         this.cursor.icon.gotoAndStop(140);
         this.cursor.visible = false;
         this.commandMenu.gotoAndStop(1);
         this.removeCrosshairs();
         this.showSwapCrosshairs();
         this.openRecentMenu();
      }
      
      public function stretchSkillMenu(param1:MovieClip, param2:int) : *
      {
         param1.visible = true;
         param1.fader.gotoAndPlay(1);
         param1.top.y = GUI.activeIcons[0].y;
         param1.bottom.y = GUI.activeIcons[GUI.activeIcons.length - 1].y + 50;
         param1.middle.y = param1.top.y;
         var _loc3_:int = Math.floor((GUI.activeIcons.length - 1) / param2) * 1 + 1;
         param1.middle.scaleY = _loc3_;
         if(this.currentMenu == "summon")
         {
            param1.y = 445 - _loc3_ * 42.7;
         }
         else
         {
            param1.y = 445 - _loc3_ * 44;
         }
         if(Boolean(param1.recent) && this.currentMenu != "recent")
         {
            param1.recent.visible = false;
         }
         if(Boolean(param1.recent) && this.currentMenu == "recent")
         {
            param1.recent.visible = true;
         }
         if(_loc3_ <= 2)
         {
            if(this.currentMenu == "attack")
            {
               param1.y = 380 - _loc3_ * 22 - 15;
            }
            if(this.currentMenu == "tactics")
            {
               param1.y = 400 - _loc3_ * 25;
            }
            if(this.currentMenu == "skill")
            {
               param1.y = 420 - _loc3_ * 22 - 60;
            }
            if(this.currentMenu == "special")
            {
               param1.y = 440 - _loc3_ * 22 - 50;
            }
            if(this.currentMenu == "summon")
            {
               param1.y = 430 - _loc3_ * 25;
            }
         }
      }
      
      public function openRecentMenu() : *
      {
         this.hideSkillMenus();
         this.currentMenu = "recent";
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < Battle.currentPlayer.recentSkills.length)
         {
            _loc1_.push(GUI.createIcon(this.skillMenuBig,Battle.currentPlayer.recentSkills[_loc2_],this.selectSkill,Battle.currentPlayer.realMP >= Battle.currentPlayer.recentSkills[_loc2_].getStats().MP && !Battle.currentPlayer.status[Status.SYPHON],Icon.SKILL));
            _loc2_++;
         }
         if(_loc1_.length != 0)
         {
            GUI.createIconMatrix(_loc1_,3,0,0,1);
            this.stretchSkillMenu(this.skillMenuBig,3);
            this.pointer.y = 900;
         }
      }
      
      public function openAttackMenu() : *
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         this.hideSkillMenus();
         if(this.currentMenu == "attack")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "attack";
         this.pointer.y = 365 - 74;
         if(Battle.currentPlayer.limit == 100 && Battle.currentPlayer.hasLimitSkill())
         {
            _loc1_ = [];
            _loc2_ = 0;
            while(_loc2_ < Battle.currentPlayer.skillsLimit.length)
            {
               if(Battle.currentPlayer.skillsLimit[_loc2_] && Battle.currentPlayer.skillsLimit[_loc2_].level != 0 && Boolean(Battle.currentPlayer.skillsLimit[_loc2_].owned))
               {
                  _loc1_.push(GUI.createIcon(this.skillMenuSmall,Battle.currentPlayer.skillsLimit[_loc2_],this.selectSkill,true,Icon.SKILL));
               }
               _loc2_++;
            }
            GUI.createIconMatrix(_loc1_,2,0,-60,1);
            this.stretchSkillMenu(this.skillMenuSmall,2);
         }
         else
         {
            this.selectSkill(Battle.currentPlayer.skillsLimit[0]);
         }
      }
      
      public function openTacticsMenu() : *
      {
         this.hideSkillMenus();
         if(this.currentMenu == "tactics")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "tactics";
         this.pointer.y = 384 - 62;
         var _loc1_:Array = [];
         var _loc2_:Array = [Spells.defend,Spells.skip,Spells.swap,Spells.standby,Spells.flee];
         var _loc3_:Array = [true,true,true,true,true];
         if(!Battle.standbyPlayer)
         {
            _loc3_[3] = false;
         }
         if(Battle.players.length == 1)
         {
            _loc3_[3] = false;
         }
         if(!Game.fleeable)
         {
            _loc3_[4] = false;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc1_.push(GUI.createIcon(this.skillMenuSmall,_loc2_[_loc4_],this.selectSkill,_loc3_[_loc4_],Icon.TACTIC));
            _loc4_++;
         }
         GUI.createIconMatrix(_loc1_,2,0,-50,1);
         this.stretchSkillMenu(this.skillMenuSmall,2);
      }
      
      public function openSkillMenu() : *
      {
         this.hideSkillMenus();
         if(this.currentMenu == "skill")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "skill";
         this.pointer.y = 403 - 50;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < Battle.currentPlayer.skillsMain.length)
         {
            if(Battle.currentPlayer.skillsMain[_loc2_].level != 0)
            {
               _loc1_.push(GUI.createIcon(this.skillMenuBig,Battle.currentPlayer.skillsMain[_loc2_],this.selectSkill,Battle.currentPlayer.realMP >= Battle.currentPlayer.skillsMain[_loc2_].getStats().MP && !Battle.currentPlayer.status[Status.SYPHON],Icon.SKILL));
            }
            _loc2_++;
         }
         GUI.createIconMatrix(_loc1_,3,0,0,1);
         this.stretchSkillMenu(this.skillMenuBig,3);
      }
      
      public function openSpecialMenu() : *
      {
         this.hideSkillMenus();
         if(this.currentMenu == "special")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "special";
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < Battle.currentPlayer.skillsSub.length)
         {
            if(Boolean(Battle.currentPlayer.skillsSub[_loc2_]) && Battle.currentPlayer.skillsSub[_loc2_].level != 0)
            {
               _loc1_.push(GUI.createIcon(this.skillMenuBig,Battle.currentPlayer.skillsSub[_loc2_],this.selectSkill,Battle.currentPlayer.realMP >= Battle.currentPlayer.skillsSub[_loc2_].getStats().MP && !Battle.currentPlayer.status[Status.SYPHON],Icon.SKILL));
            }
            _loc2_++;
         }
         if(_loc1_.length != 0)
         {
            GUI.createIconMatrix(_loc1_,3,0,0,1);
            this.stretchSkillMenu(this.skillMenuBig,3);
            this.pointer.y = 422 - 39;
         }
      }
      
      public function openSummonMenu() : *
      {
         this.hideSkillMenus();
         if(this.currentMenu == "summon")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "summon";
         this.skillMenuBig.visible = true;
         this.pointer.y = 441 - 26;
         Spell.SUMMON = true;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < Spells.summons.length)
         {
            if((Spells.summons[_loc2_] as Spell).owned)
            {
               _loc1_.push(GUI.createIcon(this.skillMenuBig,Spells.summons[_loc2_],this.selectSkill,Battle.SP >= Spells.summons[_loc2_].getStats().MP,Icon.SUMMON));
            }
            _loc2_++;
         }
         GUI.createIconMatrix(_loc1_,3,0,0,1,-1);
         this.stretchSkillMenu(this.skillMenuBig,3);
      }
      
      public function openEquipMenu() : *
      {
         this.hideSkillMenus();
         this.currentMenu = "equip";
         this.equipMenu.visible = true;
         this.equipMenu.fader.gotoAndPlay(1);
         this.pointer.y = 460 - 16;
         var _loc1_:Array = [];
         var _loc2_:Player = Battle.currentPlayer;
         if(this.newEquips[0])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[0],this.selectEquip,true,Icon.EQUIP,0,0,0,0));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.weapon,this.selectEquip,true,Icon.EQUIP,0,0,0,0));
         }
         if(this.newEquips[1])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[1],this.selectEquip,true,Icon.EQUIP,0,0,0,1));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.flair1,this.selectEquip,true,Icon.EQUIP,0,0,0,1));
         }
         if(this.newEquips[2])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[2],this.selectEquip,true,Icon.EQUIP,0,0,0,2));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.hat,this.selectEquip,true,Icon.EQUIP,0,0,0,2));
         }
         if(this.newEquips[3])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[3],this.selectEquip,true,Icon.EQUIP,0,0,0,3));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.flair2,this.selectEquip,true,Icon.EQUIP,0,0,0,3));
         }
         if(this.newEquips[4])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[4],this.selectEquip,true,Icon.EQUIP,0,0,0,4));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.armor,this.selectEquip,true,Icon.EQUIP,0,0,0,4));
         }
         if(this.newEquips[5])
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,this.newEquips[5],this.selectEquip,true,Icon.EQUIP,0,0,0,5));
         }
         else
         {
            _loc1_.push(GUI.createIcon(this.equipMenu,_loc2_.flair3,this.selectEquip,true,Icon.EQUIP,0,0,0,5));
         }
         GUI.createIconMatrix(_loc1_,2,0,0,1);
      }
      
      public function selectEquip(param1:Object) : *
      {
         var _loc4_:int = 0;
         var _loc5_:Icon = null;
         this.hideSkillMenus();
         var _loc2_:Array = [];
         if(param1.type == Equip.FLAIR)
         {
            _loc2_ = Equips.FLAIRS;
         }
         if(param1.type == Equip.SWORD)
         {
            _loc2_ = Equips.SWORDS;
         }
         if(param1.type == Equip.STAFF)
         {
            _loc2_ = Equips.STALVES;
         }
         if(param1.type == Equip.GUN)
         {
            _loc2_ = Equips.GUNS;
         }
         if(param1.type == Equip.BOW)
         {
            _loc2_ = Equips.BOWS;
         }
         if(param1.type == Equip.HAT_MALE)
         {
            _loc2_ = Equips.MALE_HATS;
         }
         if(param1.type == Equip.ARMOR_MALE)
         {
            _loc2_ = Equips.MALE_ARMOR;
         }
         if(param1.type == Equip.HAT_FEMALE)
         {
            _loc2_ = Equips.FEMALE_HATS;
         }
         if(param1.type == Equip.ARMOR_FEMALE)
         {
            _loc2_ = Equips.FEMALE_ARMOR;
         }
         var _loc3_:Array = [];
         if(param1.type != Equip.FLAIR)
         {
            this.equipMenu2.visible = true;
            this.equipMenu2.fader.gotoAndPlay(1);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(Boolean(_loc2_[_loc4_]) && (_loc2_[_loc4_] as Equip).owned)
               {
                  _loc5_ = GUI.createIcon(this.equipMenu2,_loc2_[_loc4_],this.selectEquip2,!_loc2_[_loc4_].equipped2(this.newEquips,Battle.currentPlayer),Icon.EQUIP);
                  MapMenu.showPlayerIconOnEquip(_loc5_);
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc3_.push(null);
               }
               _loc4_++;
            }
            GUI.createIconMatrix(_loc3_,5,0,0,1);
         }
         else
         {
            this.equipMenu3.visible = true;
            this.equipMenu3.fader.gotoAndPlay(1);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(Boolean(_loc2_[_loc4_]) && (_loc2_[_loc4_] as Equip).owned)
               {
                  _loc5_ = GUI.createIcon(this.equipMenu3,_loc2_[_loc4_],this.selectEquip2,!_loc2_[_loc4_].equipped2(this.newEquips,Battle.currentPlayer),Icon.EQUIP);
                  MapMenu.showPlayerIconOnEquip(_loc5_);
                  _loc3_.push(_loc5_);
               }
               else
               {
                  _loc3_.push(null);
               }
               _loc4_++;
            }
            GUI.createIconMatrix(_loc3_,8,0,0,1);
         }
      }
      
      public function selectEquip2(param1:Object) : *
      {
         this.equipFlag = true;
         this.newEquips[this.equipPos] = param1;
         this.openEquipMenu();
      }
      
      public function cancelEquipSelection() : *
      {
         this.openEquipMenu();
      }
      
      public function removeFlair() : *
      {
         this.equipFlag = true;
         this.newEquips[this.equipPos] = Equips.empty;
         this.openEquipMenu();
      }
      
      public function acceptEquips() : *
      {
         this.selectedSkill = null;
         if(this.equipFlag)
         {
            this.hideSkillMenus();
            this.selectTarget(Battle.currentPlayer);
            if(this.newEquips[0])
            {
               Battle.currentPlayer.weapon = this.newEquips[0];
            }
            if(this.newEquips[2])
            {
               Battle.currentPlayer.hat = this.newEquips[2];
            }
            if(this.newEquips[4])
            {
               Battle.currentPlayer.armor = this.newEquips[4];
            }
            if(this.newEquips[1])
            {
               Battle.currentPlayer.flair1 = this.newEquips[1];
            }
            if(this.newEquips[3])
            {
               Battle.currentPlayer.flair2 = this.newEquips[3];
            }
            if(this.newEquips[5])
            {
               Battle.currentPlayer.flair3 = this.newEquips[5];
            }
            MapMenu.tipCompleteFlag[6] = true;
            Battle.currentPlayer.buffHP();
            Battle.currentPlayer.buffMP();
         }
      }
      
      public function openItemMenu() : *
      {
         this.hideSkillMenus();
         if(this.currentMenu == "item")
         {
            this.openRecentMenu();
            return;
         }
         this.currentMenu = "item";
         var _loc1_:Boolean = true;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < Items.FOOD_LIST.length)
         {
            if(Options.noRareFood && (Items.FOOD_LIST[_loc3_] == Items.pizza || Items.FOOD_LIST[_loc3_] == Items.sauce || Items.FOOD_LIST[_loc3_] == Items.burger || Items.FOOD_LIST[_loc3_] == Items.orangejuice))
            {
               _loc1_ = false;
            }
            else
            {
               _loc1_ = true;
            }
            if(Items.FOOD_LIST[_loc3_].quantity)
            {
               _loc2_.push(GUI.createIcon(this.skillMenuHuge,Items.FOOD_LIST[_loc3_],this.selectSkill,_loc1_,Icon.ITEM));
            }
            else
            {
               _loc2_.push(null);
            }
            _loc3_++;
         }
         if(_loc2_.length != 0)
         {
            GUI.createIconMatrix(_loc2_,4,0,0,1);
         }
         this.skillMenuHuge.visible = true;
         this.skillMenuHuge.fader.gotoAndPlay(1);
         this.pointer.y = 479 - 3;
      }
      
      public function showStats(param1:int) : *
      {
         this.stats.visible = true;
         this.stats.fader.gotoAndPlay(1);
         if(param1 == 4)
         {
            this.stats.display(Battle.standbyPlayer);
         }
         else
         {
            this.stats.display(Battle.players[param1 - 1]);
         }
      }
      
      public function showFoeStats(param1:Foe) : *
      {
         this.foeStats.visible = true;
         this.foeStats.fader.gotoAndPlay(1);
         this.foeStats.display(param1);
      }
      
      public function hideFoeStats() : *
      {
         this.foeStats.visible = false;
      }
      
      public function updateFoeBars() : *
      {
         if(Options.noFoeHPbars)
         {
            this.foeBars.foeBar0.gotoAndStop(106);
            this.foeBars.foeBar1.gotoAndStop(106);
            this.foeBars.foeBar2.gotoAndStop(106);
            this.foeBars.foeBar3.gotoAndStop(106);
            this.foeBars.foeBar4.gotoAndStop(106);
         }
         else
         {
            if(Battle.foes[0])
            {
               this.foeBars.foeBar0.gotoAndStop(Battle.foes[0].getHpPercent());
            }
            if(Battle.foes[1])
            {
               this.foeBars.foeBar1.gotoAndStop(Battle.foes[1].getHpPercent());
            }
            if(Battle.foes[2])
            {
               this.foeBars.foeBar2.gotoAndStop(Battle.foes[2].getHpPercent());
            }
            if(Battle.foes[3])
            {
               this.foeBars.foeBar3.gotoAndStop(Battle.foes[3].getHpPercent());
            }
            if(Battle.foes[4])
            {
               this.foeBars.foeBar4.gotoAndStop(Battle.foes[4].getHpPercent());
            }
         }
      }
      
      public function updateWave() : *
      {
         if(Global.endlessBattle)
         {
            this.foeBars.waveBox.text = "" + Global.endlessBattleWave;
         }
         else
         {
            this.foeBars.waveBox.text = "" + Battle.wave + "/" + Battle.foeWaves.length;
         }
         this.foeBars.waveBox.setTextFormat(GUI.boldText);
      }
      
      public function updatePlayerBars() : *
      {
         var p:int;
         var players:Array = null;
         try
         {
            players = [Battle.players[0],Battle.players[1],Battle.players[2],Battle.standbyPlayer];
         }
         catch(e:Error)
         {
            return;
         }
         p = 0;
         while(p < 4)
         {
            if(players[p])
            {
               this.playerBars["hpBar" + p].visible = true;
               this.playerBars["mpBar" + p].visible = true;
               this.playerBars["limitBar" + p].visible = true;
               this.playerBars["hpBar" + p].gotoAndStop(players[p].getHpPercent());
               this.playerBars["mpBar" + p].gotoAndStop(players[p].getMpPercent());
               this.playerBars["limitBar" + p].gotoAndStop(players[p].getLimitPercent());
               this.playerBars["hpBox" + p].text = players[p].getHp();
               this.playerBars["mpBox" + p].text = players[p].getMp();
               this.playerBars["icon" + p].gotoAndStop(players[p].playerNo);
               this.playerBars["section" + p].visible = true;
            }
            else
            {
               this.playerBars["hpBar" + p].visible = false;
               this.playerBars["mpBar" + p].visible = false;
               this.playerBars["limitBar" + p].visible = false;
               this.playerBars["hpBox" + p].text = "";
               this.playerBars["mpBox" + p].text = "";
               this.playerBars["icon" + p].gotoAndStop(5);
               this.playerBars["section" + p].visible = false;
            }
            p++;
         }
         this.playerBars.spBox.text = "" + Battle.SP + "/" + Battle.maxSP;
         this.playerBars.spBar.gotoAndStop(Math.floor(Battle.SP / Battle.maxSP * 100));
      }
      
      internal function frame1() : *
      {
         this.init();
         this.debugButton.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):*
         {
            Debug.debug();
         });
      }
   }
}
