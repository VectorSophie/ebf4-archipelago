package
{
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol4861")]
   public dynamic class Chest extends MovieClip
   {
      
      public var X:int;
      
      public var Y:int;
      
      public var secret:Boolean;
      
      public var state:int;
      
      public function Chest()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3,3,this.frame4,4,this.frame5,22,this.frame23,23,this.frame24,25,this.frame26,45,this.frame46);
      }
      
      internal function frame1() : *
      {
         cacheAsBitmap = false;
         this.secret = false;
         if(Debug.mappingMode2)
         {
            visible = false;
            stop();
         }
      }
      
      internal function frame2() : *
      {
         stop();
         if(!Maps.chestData[MapData.mapNo])
         {
            Maps.chestData[MapData.mapNo] = [];
         }
         if(Maps.chestData[MapData.mapNo][name.substring(5)] == 2)
         {
            gotoAndStop("opened");
            this.state = 1;
         }
         else if(this.state == -1 && !Maps.chestData[MapData.mapNo][name.substring(5)] == 1)
         {
            gotoAndStop("fall");
            this.X = 100;
            this.Y = 100;
            (parent as Maps).addTile(0,x,y - 15);
            Maps.playTreasureSound(name.substring(5));
         }
         else
         {
            this.state = 0;
            this.X = x / 50;
            this.Y = y / 40;
            (parent as Maps).addTile(5,x,y - 15);
            Maps.playTreasureSound(name.substring(5));
         }
         if(this.alpha == 0 && this.state == 0)
         {
            this.secret = true;
            alpha = 1;
            gotoAndStop(3);
         }
      }
      
      internal function frame3() : *
      {
      }
      
      internal function frame4() : *
      {
         if(this.secret)
         {
            ++SaveData.secretsFound;
            alpha = 0;
            if(SaveData.secretsFound >= Medals.keeneyes.value)
            {
               Medals.unlock(Medals.keeneyes);
            }
            if(SaveData.secretsFound >= Medals.eagleeyes.value)
            {
               Medals.unlock(Medals.eagleeyes);
            }
            SFX.playSound("secret");
            gotoAndPlay(6);
         }
         else
         {
            ++SaveData.chestsOpened;
            if(SaveData.chestsOpened >= Medals.treasurehunter.value)
            {
               Medals.unlock(Medals.treasurehunter);
            }
            if(SaveData.chestsOpened >= Medals.treasurethief.value)
            {
               Medals.unlock(Medals.treasurethief);
            }
            if(SaveData.chestsOpened >= Medals.treasurecollector.value)
            {
               Medals.unlock(Medals.treasurecollector);
            }
            gotoAndPlay(5);
         }
      }
      
      internal function frame5() : *
      {
         gotoAndPlay(7);
      }
      
      internal function frame23() : *
      {
         (parent as Maps).addTile(1,x,y - 15);
         Maps.chestData[MapData.mapNo][name.substring(5)] = 2;
      }
      
      internal function frame24() : *
      {
         stop();
      }
      
      internal function frame26() : *
      {
         ++parent.busy;
      }
      
      internal function frame46() : *
      {
         this.state = 0;
         gotoAndStop("normal");
         --parent.busy;
         Maps.chestData[MapData.mapNo][name.substring(5)] = 1;
      }
   }
}

