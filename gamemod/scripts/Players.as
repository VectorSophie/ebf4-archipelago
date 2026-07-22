package
{
   public class Players
   {
      
      public static var player1:Player;
      
      public static var player2:Player;
      
      public static var player3:Player;
      
      public static var player4:Player;
      
      public static var party:Array;
      
      public static var PLAYERS:Array;
      
      public static var standby:Player;
      
      public static var P1equips:Array = [2,2,4,2,2,2];
      
      public static var P2equips:Array = [2,3,8,2,2,2];
      
      public static var P3equips:Array = [4,15,10,2,2,2];
      
      public static var P4equips:Array = [2,9,4,2,2,2];
      
      public static var equips:Array = [0,P1equips,P2equips,P3equips,P4equips];
       
      
      public function Players()
      {
         super();
      }
      
      public static function init() : *
      {
         player1 = new Player1();
         player2 = new Player2();
         player3 = new Player3();
         player4 = new Player4();
         party = [player4];
         standby = null;
         PLAYERS = [player1,player2,player3,player4];
      }
      
      public static function getAverageLevel() : Number
      {
         var _loc3_:Player = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         for each(_loc3_ in [player1,player2,player3,player4])
         {
            if(_loc3_)
            {
               _loc1_ += _loc3_.level;
               _loc2_++;
            }
         }
         return _loc1_ / _loc2_;
      }
      
      public static function getMatt() : *
      {
         var _loc1_:Equip = null;
         if(!Game.AP_partyAllowed("matt"))   // AP party_shuffle: gated until item arrives
         {
            return;
         }
         if(Game.party.indexOf(player1) != -1)
         {
            return;
         }
         Game.party.push(player1);
         for each(_loc1_ in [Equips.captainhat,Equips.captainshirt,Equips.heavensgate,Equips.silverblade,Equips.casualcap,Equips.casualshirt])
         {
            _loc1_.owned = true;
         }
         Spells.scanbot.owned = true;
         Spells.flood.owned = true;
         Spells.geyser.owned = true;
         Spells.spark.owned = true;
         Spells.bigspark.owned = true;
         Spells.protect.owned = true;
         if(SaveData.questNo == 1)
         {
            Debug.setLevel(1,player1);
         }
      }
      
      public static function getNatalie() : *
      {
         var _loc1_:Equip = null;
         if(!Game.AP_partyAllowed("natalie"))   // AP party_shuffle: gated until item arrives
         {
            return;
         }
         if(Game.party.indexOf(player2) != -1)
         {
            return;
         }
         Game.party.push(player2);
         for each(_loc1_ in [Equips.reddress,Equips.redribbon,Equips.crystalstaff,Equips.catbadge,Equips.mysticwind])
         {
            _loc1_.owned = true;
         }
         Spells.catsword.owned = true;
         Spells.heal.owned = true;
         Spells.healmore.owned = true;
         Spells.revive.owned = true;
         Spells.purify.owned = true;
         if(SaveData.questNo == 1)
         {
            Debug.setLevel(5,player2);
         }
      }
      
      public static function getLance() : *
      {
         var _loc1_:Equip = null;
         if(!Game.AP_partyAllowed("lance"))   // AP party_shuffle: gated until item arrives
         {
            return;
         }
         if(Game.party.indexOf(player3) != -1)
         {
            return;
         }
         Game.party.push(player3);
         for each(_loc1_ in [Equips.officercoat,Equips.officerhat,Equips.shadowblaster,Equips.flamethrower])
         {
            _loc1_.owned = true;
         }
         Spells.lockon.owned = true;
         Spells.dispel.owned = true;
         Spells.sawblade.owned = true;
         Spells.sawblades.owned = true;
         Medals.unlock(Medals.fullparty);
         if(SaveData.questNo == 1)
         {
            Debug.setLevel(8,player3);
         }
      }
   }
}
