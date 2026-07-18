package
{
   public class Battle
   {
      
      public static var stage:BattleStage;
      
      public static var menu:BattleMenu;
      
      public static var players:Array;
      
      public static var standbyPlayer:Player;
      
      public static var foeWaves:Array;
      
      public static var currentPlayer:Player;
      
      public static var swapPlayer:Player;
      
      public static var currentFoe:Foe;
      
      public static var selectedSkill:Object;
      
      public static var selectedTarget:Target;
      
      public static var targetType:String;
      
      public static var SP:int;
      
      public static var maxSP:int;
      
      public static var counterSkill:Spell;
      
      public static var foes:Array = [];
      
      public static var counterStack:Array = [];
      
      public static var goldPool:int = 0;
      
      public static var experiencePool:int = 0;
      
      public static var abilityPool:int = 0;
      
      public static var scorePool:int = 0;
      
      public static var dropPool:Array = [];
      
      public static var playerScore:int = 1;
      
      public static var foeScore:int = 1;
      
      public static var wave:int = 0;
      
      public static var end:Boolean = false;
      
      public static var turnPhase:int = 0;
      
      public static var soundStack:int = 0;
      
      public static var standbySwitch:Boolean = false;
      
      public static var counter:Boolean = false;
      
      public static var bonusSpellFlag:int = 0;
      
      public static var autoSpellFlag:Boolean = false;
      
      public static var speechFlag:Boolean = false;
      
      public static var autoSpellState:int = 0;
      
      public static var busy:Boolean = false;
      
      public static var foeCounter:Boolean = false;
      
      public static var rating:int = 1;
      
      public function Battle()
      {
         super();
      }
      
      public static function reset() : *
      {
         SP = 0;
         maxSP = Constants.spmStarting;
      }
      
      public static function init(param1:int) : *
      {
         stage = new BattleStage();
         Game.root.addChild(stage);
         menu = new BattleMenu();
         Game.root.addChild(menu);
         Backgrounds.createBackground(param1);
         if(Game.party.length < 4)
         {
            standbyPlayer = null;
            players = Game.party;
         }
         else
         {
            standbyPlayer = Game.party[3];
            players = Game.party.slice(0,3);
         }
         var _loc2_:int = 0;
         while(_loc2_ < players.length)
         {
            players[_loc2_].initBattle(_loc2_);
            _loc2_++;
         }
         currentPlayer = players[0];
      }
      
      public static function teardown() : *
      {
         var _loc1_:Player = null;
         if(Backgrounds.theBackground)
         {
            Backgrounds.theBackground.parent.removeChild(Backgrounds.theBackground);
            Backgrounds.theBackground = null;
         }
         selectedSkill = null;
         selectedTarget = null;
         targetType = null;
         goldPool = 0;
         experiencePool = 0;
         abilityPool = 0;
         scorePool = 0;
         dropPool = [];
         playerScore = 1;
         foeScore = 1;
         wave = 0;
         end = false;
         turnPhase = 0;
         soundStack = 0;
         standbySwitch = false;
         counter = false;
         counterSkill = null;
         bonusSpellFlag = 0;
         autoSpellFlag = false;
         speechFlag = false;
         autoSpellState = 0;
         busy = false;
         foeCounter = false;
         menu.tearDown();
         Game.root.removeChild(stage);
         stage = null;
         Game.root.removeChild(menu);
         menu = null;
         for each(_loc1_ in players)
         {
            _loc1_.clearBattleVars();
         }
         if(Game.party.length != 1)
         {
            if(Game.party.length < 4)
            {
               Game.party = players;
            }
            else
            {
               Game.party = players.concat([standbyPlayer]);
               standbyPlayer.clearBattleVars();
            }
         }
         players = null;
         standbyPlayer = null;
         foeWaves = null;
         foes = [];
         currentPlayer = null;
         swapPlayer = null;
         currentFoe = null;
         counterStack = [];
      }
      
      public static function addDrops(param1:Array) : *
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         var _loc4_:Array = null;
         for each(_loc2_ in param1)
         {
            if(_loc2_[1] / 100 > Math.random())
            {
               _loc3_ = false;
               for each(_loc4_ in dropPool)
               {
                  if(_loc4_[0] == _loc2_[0])
                  {
                     ++_loc4_[1];
                     _loc3_ = true;
                     break;
                  }
               }
               if(!_loc3_)
               {
                  dropPool.push([_loc2_[0],1]);
               }
            }
         }
      }
      
      public static function standby() : *
      {
         var _loc1_:int = 0;
         var _loc2_:Player = null;
         var _loc3_:int = 0;
         if(standbySwitch)
         {
            if(selectedTarget.dead)
            {
               Medals.unlock(Medals.stepoverthedead);
            }
            _loc1_ = int(players.indexOf(selectedTarget));
            _loc2_ = selectedTarget as Player;
            _loc3_ = _loc2_.graphic.parent.getChildIndex(_loc2_.graphic);
            selectedTarget.removeGraphic();
            standbySwitch = false;
            players[_loc1_] = standbyPlayer;
            standbyPlayer.initBattle(_loc1_,_loc3_);
            standbyPlayer = _loc2_;
            menu.updatePlayerBars();
         }
      }
      
      public static function gameover() : *
      {
         if(Boolean(standbyPlayer) && !standbyPlayer.dead)
         {
            standbySwitch = true;
            selectedTarget = players[1];
            standbyPlayer.turnTaken = true;
            Battle.selectedTarget.graphic.animate("dragout");
         }
         else
         {
            end = true;
            menu.transitions.gotoAndPlay("gameover");
         }
      }
      
      public static function nextWave() : *
      {
         var _loc1_:Player = null;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Class = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Foe = null;
         if(Options.surpriseAttack && wave != 0)
         {
            for each(_loc1_ in players)
            {
               _loc1_.turnTaken = true;
            }
         }
         if(Options.preemptiveStrike)
         {
            for each(_loc1_ in players)
            {
               _loc1_.turnTaken = false;
            }
         }
         foes = [];
         if(wave >= foeWaves.length && !Global.endlessBattle)
         {
            busy = false;
            winBattle();
         }
         else
         {
            counterStack = [];
            if(!Global.endlessBattle)
            {
               _loc2_ = foeWaves[wave];
            }
            else
            {
               _loc2_ = Battles.generateEndlessBattleWave(true);
            }
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_][0];
               _loc5_ = int(_loc2_[_loc3_][1]);
               _loc6_ = int(_loc2_[_loc3_][2]);
               _loc7_ = int(_loc2_[_loc3_][3]);
               if(_loc2_[_loc3_].length == 5)
               {
                  _loc8_ = int(_loc2_[_loc3_][4]);
               }
               else
               {
                  _loc8_ = 0;
               }
               _loc9_ = new _loc4_(_loc5_,_loc6_,_loc7_,_loc8_);
               foes.push(_loc9_);
               _loc3_++;
            }
            ++wave;
            menu.updateWave();
            menu.updateFoeBars();
         }
      }
      
      public static function calculateRating() : *
      {
         var _loc1_:Number = playerScore / foeScore;
         _loc1_ *= 0.5 + Options.getDifficulty() / 2;
         _loc1_ *= 1 + Players.getAverageLevel() / 30;
         if(_loc1_ > 20)
         {
            rating = 4;
         }
         else if(_loc1_ > 15)
         {
            rating = 3;
         }
         else if(_loc1_ > 10)
         {
            rating = 2;
         }
         else
         {
            rating = 1;
         }
      }
      
      public static function winBattle() : *
      {
         var _loc1_:Player = null;
         if(Debug.trailerMode)
         {
            menu.visible = true;
         }
         calculateRating();
         end = true;
         menu.showMochiAd();
         menu.awardDisplay.fader.gotoAndPlay("popin");
         menu.awardDisplay.init();
         menu.playerBars.gotoAndStop(2);
         for each(_loc1_ in players)
         {
            if(!_loc1_.dead && !_loc1_.status[Status.FREEZE] && !_loc1_.status[Status.SLIME])
            {
               _loc1_.graphic.animate("cheer");
            }
         }
      }
      
      public static function shake(param1:String = "small") : *
      {
         if(!Options.screenShake)
         {
            return;
         }
         if(Game.frame)
         {
            Game.frame.shake.gotoAndPlay(param1);
         }
      }
      
      public static function hidePlayers() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in players)
         {
            if(!_loc1_.dead && _loc1_.graphic.lastAnim != "jump")
            {
               _loc1_.graphic.animate("hide");
            }
            else if(_loc1_.graphic.lastAnim != "jump")
            {
               _loc1_.graphic.animate("dragout");
            }
         }
      }
      
      public static function showPlayers() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in players)
         {
            if(!_loc1_.dead && !_loc1_.slime)
            {
               _loc1_.graphic.animate("intro");
            }
            else if(!_loc1_.dead)
            {
               _loc1_.graphic.animate("intro2");
            }
            else
            {
               _loc1_.graphic.animate("dragin");
            }
         }
      }
      
      public static function invisiblePlayers() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in players)
         {
            _loc1_.graphic.visible = false;
            _loc1_.statusDisplay.alpha = 0;
         }
      }
      
      public static function visiblePlayers() : *
      {
         var _loc1_:Player = null;
         for each(_loc1_ in players)
         {
            _loc1_.graphic.visible = true;
            _loc1_.statusDisplay.alpha = 1;
         }
      }
      
      public static function invisibleFoes() : *
      {
         var _loc1_:Foe = null;
         for each(_loc1_ in foes)
         {
            _loc1_.graphic.visible = false;
            _loc1_.statusDisplay.alpha = 0;
         }
      }
      
      public static function visibleFoes() : *
      {
         var _loc1_:Foe = null;
         for each(_loc1_ in foes)
         {
            _loc1_.graphic.visible = true;
            _loc1_.statusDisplay.alpha = 1;
         }
      }
      
      public static function playerCount() : int
      {
         var _loc2_:Target = null;
         var _loc1_:int = 0;
         for each(_loc2_ in players)
         {
            if(!_loc2_.dead)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public static function foeCount() : int
      {
         var _loc2_:Target = null;
         var _loc1_:int = 0;
         for each(_loc2_ in foes)
         {
            if(!_loc2_.dead)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public static function runBattle() : *
      {
         var _loc1_:Foe = null;
         var _loc2_:Player = null;
         var _loc3_:Target = null;
         var _loc4_:int = 0;
         if(!menu.turnStarted && !end)
         {
            if(playersDead())
            {
               gameover();
            }
            else if(foesDead())
            {
               busy = true;
               for each(_loc1_ in foes)
               {
                  if(_loc1_ && _loc1_.gone && !_loc1_.unreplacable)
                  {
                     _loc1_.removeGraphic();
                  }
               }
               nextWave();
               busy = false;
            }
            else
            {
               currentPlayer = null;
               Spell.SUMMON = false;
               Spell.SUMMON2 = false;
               for each(_loc3_ in counterStack)
               {
                  if(_loc3_.isPlayer && (_loc3_.dead || _loc3_.lastAttacker.dead || !_loc3_.canMove() || _loc3_.lastAttacker && _loc3_.lastAttacker.dead))
                  {
                     counterStack.splice(counterStack.indexOf(_loc3_),1);
                  }
               }
               if(Boolean(counterStack.length) && Boolean(counterStack[counterStack.length - 1].isPlayer))
               {
                  counterSkill = counterStack[counterStack.length - 1].getCounterSkill();
                  currentPlayer = counterStack.pop();
                  counter = true;
               }
               else if(counterStack.length)
               {
                  currentFoe = counterStack.pop();
                  foeCounter = true;
               }
               else if(swapPlayer)
               {
                  currentPlayer = swapPlayer;
                  swapPlayer = null;
               }
               else
               {
                  for each(_loc2_ in players)
                  {
                     if(_loc2_.canTakeTurn())
                     {
                        currentPlayer = _loc2_;
                        break;
                     }
                  }
               }
               if(!speechFlag && !currentFoe)
               {
                  _loc4_ = autoSpellState;
                  while(_loc4_ < players.length)
                  {
                     autoSpellState = _loc4_ + 1;
                     if(players[_loc4_].autoSpell())
                     {
                        Skills.user = players[_loc4_];
                        currentPlayer = players[_loc4_];
                        autoSpellFlag = true;
                        break;
                     }
                     _loc4_++;
                  }
               }
               if(!currentPlayer && !foeCounter)
               {
                  currentPlayer = null;
                  for each(_loc2_ in players)
                  {
                     if((!_loc2_.status[Status.SLIME] && _loc2_.slime || !_loc2_.status[Status.FREEZE] && _loc2_.graphic.freeze && _loc2_.graphic.lastAnim != "stand") && !_loc2_.dead)
                     {
                        currentPlayer = _loc2_;
                        break;
                     }
                  }
                  if(currentPlayer)
                  {
                     if(currentPlayer.graphic.freeze)
                     {
                        currentPlayer.graphic.gotoAndStop("stand");
                        currentPlayer.graphic.lastAnim = "stand";
                        currentPlayer.graphic.k();
                     }
                     else if(!currentPlayer.status[Status.SLIME] && Boolean(currentPlayer.slime))
                     {
                        currentPlayer.unslimify();
                     }
                  }
                  else if(turnPhase == 0)
                  {
                     turnPhase = 1;
                     currentPlayer = null;
                     if(standbyPlayer)
                     {
                        standbyPlayer.negativeEffectsFade();
                     }
                     for each(_loc2_ in players)
                     {
                        _loc2_.negativeEffects();
                        _loc2_.turnTaken = true;
                     }
                     for each(_loc1_ in foes)
                     {
                        if(_loc1_)
                        {
                           _loc1_.positiveEffects();
                        }
                     }
                  }
                  else
                  {
                     currentFoe = null;
                     for each(_loc1_ in foes)
                     {
                        if(Boolean(_loc1_) && _loc1_.canTakeTurn())
                        {
                           _loc1_.takeTurn();
                           menu.turnStarted = false;
                           currentFoe = _loc1_;
                           break;
                        }
                     }
                     if(!currentFoe)
                     {
                        if(turnPhase == 1)
                        {
                           turnPhase = 2;
                           if(standbyPlayer)
                           {
                              standbyPlayer.positiveEffectsFade();
                           }
                           if(Boolean(standbyPlayer) && !standbyPlayer.dead)
                           {
                              standbyPlayer.outsideHeal(standbyPlayer.maxHP / 5);
                              standbyPlayer.outsideHealMP(standbyPlayer.maxMP / 10);
                           }
                           for each(_loc2_ in players)
                           {
                              _loc2_.positiveEffects();
                           }
                           for each(_loc1_ in foes)
                           {
                              if(_loc1_ && _loc1_.graphic.lastAnim == "freeze" && _loc1_.status[Status.FREEZE] == 1)
                              {
                                 _loc1_.graphic.gotoAndPlay("stand");
                              }
                              _loc1_.negativeEffects();
                              _loc1_.turnTaken = true;
                           }
                        }
                        else if(turnPhase == 2)
                        {
                           for each(_loc2_ in players)
                           {
                              _loc2_.autoStatus();
                              _loc2_.turnTaken = false;
                           }
                           Global.element = Element.NONE;
                           if(standbyPlayer)
                           {
                              standbyPlayer.turnTaken = false;
                           }
                           for each(_loc1_ in foes)
                           {
                              if(_loc1_)
                              {
                                 _loc1_.turnTaken = false;
                              }
                           }
                           turnPhase = 0;
                           selectedTarget = null;
                           autoSpellState = 0;
                        }
                     }
                  }
               }
               else if(counter)
               {
                  selectedTarget = currentPlayer.lastAttacker;
                  targetType = counterSkill.target;
                  currentPlayer.useSkill(counterSkill);
                  counter = false;
               }
               else if(speechFlag)
               {
                  speechFlag = false;
               }
               else if(foeCounter)
               {
                  Global.monster = currentFoe.monster;
                  selectedTarget = randomPlayer();
                  Skills.user = currentFoe;
                  targetType = Target.ONE_ENEMY;
                  currentFoe.counter2();
                  foeCounter = false;
               }
               else if(autoSpellFlag && !foeCounter)
               {
                  autoSpellFlag = false;
               }
               else if(currentPlayer.status[Status.BERSERK])
               {
                  selectedTarget = randomFoe();
                  targetType = Target.ONE_ENEMY;
                  if(currentPlayer.berserkSkill && currentPlayer.berserkSkill.level && Math.random() < 0.2)
                  {
                     currentPlayer.useSkill(currentPlayer.berserkSkill);
                  }
                  else
                  {
                     currentPlayer.useSkill(currentPlayer.skillsLimit[0]);
                  }
                  currentPlayer.turnTaken = true;
               }
               else
               {
                  menu.startTurn();
                  menu.turnStarted = true;
               }
            }
         }
      }
      
      public static function playersDead() : *
      {
         for each(p in players)
         {
            if(!p.dead)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function foesDead() : *
      {
         for each(f in foes)
         {
            if(Boolean(f) && !f.dead)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function flee() : *
      {
         hidePlayers();
         end = true;
         Game.win = false;
         menu.transitions.gotoAndPlay("fadeout");
      }
      
      public static function exit() : *
      {
         Game.win = true;
         menu.transitions.gotoAndPlay("fadeout");
      }
      
      public static function endBattle() : *
      {
      }
      
      public static function bonusSpell(param1:Number = 1) : *
      {
         if(currentPlayer)
         {
            currentPlayer.bonusSpell(param1);
         }
      }
      
      public static function randomPlayer() : Target
      {
         var _loc1_:Target = null;
         if(playersDead())
         {
            return players[0];
         }
         do
         {
            _loc1_ = players[Math.floor(Math.random() * players.length)];
         }
         while(_loc1_.dead);
         
         return _loc1_;
      }
      
      public static function randomFoe() : Target
      {
         var _loc1_:Target = null;
         if(foesDead())
         {
            return foes[0];
         }
         do
         {
            _loc1_ = foes[Math.floor(Math.random() * foes.length)];
         }
         while(!_loc1_ || _loc1_.dead);
         
         return _loc1_;
      }
   }
}

