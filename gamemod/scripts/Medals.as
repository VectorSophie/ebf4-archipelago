package
{
   import Playtomic.*;
   import com.newgrounds.*;
   import flash.net.*;
   
   public class Medals
   {
      
      public static var current:Object;
      
      public static var stats:Object = {
         "notHit":false,
         "kills":0
      };
      
      public static var resistance:Object = {
         "id":"resistance",
         "name":["Mega Resistance","Mega Resistencia","Mega Resistência","Mega-Resistenz","Mega Résistance"],
         "description":["Absorb some elemental damage.","Absorbe un poco de daño elemental.","Absorva um pouco de dano elemental.","Absorbiere elementaren Schaden.","Absorbe des dégâts élémentaux."],
         "icon":613
      };
      
      public static var skillfound:Object = {
         "id":"skillfound",
         "name":["New Skill Found","Habilidad Descubierta","Habilidade Descoberta","Neue Fähigkeit gefunden","Compétence Trouvée"],
         "description":["Find a new special skill. You can find them in chests or get them from quests.","Encuentra una habilidad especial nueva. Las puedes encontrar en cofres o misiones.","Encontre uma nova habilidade especial. Você pode as encontrar em baús ou adquiri-las em quests.","Finde eine neue Spezialfähigkeit. Du kannst sie in Schatztruhen finden oder durch Quests bekommen.","Trouve une nouvelle compétence spéciale. Trouvables dans des trésors ou en terminant des quêtes."],
         "icon":610
      };
      
      public static var statboost:Object = {
         "id":"statboost",
         "name":["Permanent Stat Boost","Aumento de Stats","Melhoria Permanente","Dauerhafte Statsteigerung","Boost de Stat"],
         "description":["Eat a stat-boosting snack and boost your stats permanently. Protip: Don\'t give them all to one character.","Come un aperitivo y aumenta stats permanentemente. Consejo: No se los des todos a un solo personaje.","Coma um lanche que melhore seus status permanentemente. Não os dê para apenas um só personagem.","Iss einen Snack, der deine Statuswerte dauerhaft steigert. Pro-Tipp: Gib sie nicht alle nur einem Charakter.","Mange un aliment qui augmente les stats en permanence. Astuce: Ne les réserve pas à un personnage."],
         "icon":679
      };
      
      public static var skilllearnt:Object = {
         "id":"skilllearnt",
         "name":["New Skill Learnt","Habilidad Aprendida","Nova Habilidade Aprendida","Neue Fähigkeit erlernt","Compétence apprise"],
         "description":["Learn the first of many new skills.","Aprende la primera de muchas nuevas habilidades.","Aprenda a primeira de muitas novas habilidades.","Lerne die erste von vielen neuen Fähigkeiten.","Apprends une toute première compétence."],
         "icon":611
      };
      
      public static var powerup:Object = {
         "id":"powerup",
         "name":["Power On","Activado","Ligado","Strom an","Portes Ouvertes"],
         "description":["Power up a set of factory doors, and open the next area.","Activa un grupo de puertas de fábrica, y abre el siguiente área.","Ligue um grupo de portas de fábrica, e ganhe acesso a próxima área.","Aktiviere eine Reihe von Türen in der Anlage und leg den nächsten Bereich frei.","Alimente un ensemble de portes de l’usine et ouvre la prochaine région."],
         "icon":614
      };
      
      public static var fullparty:Object = {
         "id":"fullparty",
         "name":["The Gang\'s All Here","La Banda Está Aquí","A Turma toda Presente","Die Fantastischen Vier","Tout Le Monde Est Là"],
         "description":["Find all of your missing party members.","Encuentra a todos tus compañeros de grupo.","Encontre todos os integrantes perdidos do grupo.","Finde alle deiner fehlenden Mitstreiter.","Trouve tous les membres du groupe manquants."],
         "icon":612
      };
      
      public static var millionaire:Object = {
         "id":"millionaire",
         "name":["Millionaire","Millonario","Milionário","Millionär","Millionnaire"],
         "description":["Save up 1,000,000 chocolate coins.","Guarda 1,000,000 de monedas de chocolate.","Economize até 1,000,000 de moedas de chocolate","Spare 1.000.000 Schokoladenmünzen.","Économise 1,000,000 de pièces en chocolat."],
         "icon":625
      };
      
      public static var zoostudent:Object = {
         "id":"zoostudent",
         "name":["Zoology Student","Estudiante de Zoología","Estudante de Zoologia","Zoologie-Student","Étudiant en Zoologie"],
         "description":["Scan a foe and begin filling in the bestiary.","Escanea un enemigo y comienza a llenar el bestiario.","Escaneie um inimigo e comece a preencher o bestiário","Scanne einen Gegner und fang an das Bestiarium zu füllen.","Scanne un ennemi et commence à remplir le bestiaire."],
         "icon":624
      };
      
      public static var zooexpert:Object = {
         "id":"zooexpert",
         "name":["Zoology Expert","Zoólogo Experto","Expert em Zoologia","Zoologie-Experte","Expert Zoologue"],
         "description":["Scan all foes and complete the bestiary.","Escanea a todos los enemigos y completa el bestiario.","Escaneie todos os inimigos e complete o bestiário.","Scanne alle Gegner und vervollständige das Bestiarium.","Scanne tous les ennemis et remplis le bestiaire."],
         "icon":623
      };
      
      public static var treasurehunter:Object = {
         "id":"treasurehunter",
         "name":["Treasure Hunter","Cazador de Tesoros","Caçador de Recompensas","Schatzsucher","Chercheur de Trésors"],
         "description":["Collect 333 treasure chests. There\'s more, but getting all of them could be frustrating.","Abre 333 cofres de tesoro. Hay más, pero conseguirlos todos puede ser frustrante.","Abra 333 baús de tesouro. Existem mais deles, mas pegar todos poderá ser um pouco frustrante.","Öffne 333 Schatztruhen. Es gibt mehr, aber sie alle zu finden könnte frustrierend werden.","Collecte 333 coffres au trésor. Il y en a plus, mais tous les obtenir pourrait être frustrant."],
         "icon":703,
         "value":333
      };
      
      public static var beastmaster:Object = {
         "id":"beastmaster",
         "name":["Beastmaster","Adiestrador","Adestrador","Meister der Bestien","Maître des Bêtes"],
         "description":["Unlock all summon creatures.","Desbloquea a las 24 criaturas invocables.","Desbloqueie todas as 24 criaturas invocáveis.","Schalte alle 24 beschwörbaren Monster frei.","Débloque chacune des 24 invocations."],
         "icon":621
      };
      
      public static var quest1:Object = {
         "id":"quest1",
         "name":["The World is Saved","El Mundo está a Salvo","O mundo está à Salvo","Die Welt ist gerettet","Le Monde Est Sauvé"],
         "description":["Beat the game and save the world.","Termina el juego y salva al mundo.","Termine o jogo e salve o mundo.","Spiel das Spiel durch und rette die Welt.","Termine le jeu et sauve le monde."],
         "icon":619
      };
      
      public static var quest2:Object = {
         "id":"quest2",
         "name":["Second Quest","Segunda Aventura","Segunda Aventura","Zweites Abenteuer","Deuxième Quête"],
         "description":["Beat the game a second time, continuing from a completed file.","Termina el juego por segunda vez, continuando desde un archivo completado.","Complete o jogo pela segunda vez, continuando-o de um save anterior.","Mach mit einem beendeten Spielstand weiter und spiel das Spiel ein zweites Mal durch.","Termine le jeu une seconde fois, à partir d’un fichier déjà complété."],
         "icon":618
      };
      
      public static var quest3:Object = {
         "id":"quest3",
         "name":["Final Chapter","Capítulo Final","Último Capítulo","Letztes Kapitel","Dernier Chapitre"],
         "description":["Beat the game a third and final time.","Termina el juego por tercera y última vez.","Complete o jogo pela terceira e última vez.","Spiel das Spiel ein drittes und letztes Mal durch.","Termine le jeu une troisième et dernière fois."],
         "icon":617
      };
      
      public static var NPChelper:Object = {
         "id":"NPChelper",
         "name":["NPC Helper","Ayudante de NPC","Ajudante de NPC","NPC-Helfer","Aide de PNJ"],
         "description":["Complete 10 quests for NPCs. They can\'t do anything by themselves.","Completa 10 misiones para NPCs. Ellos no pueden hacer nada por sí solos.","Complete 10 missões para os NPCs. Eles não conseguem fazer nada sozinhos.","Erledige 10 Quests für NPCs. Ohne Hilfe kriegen sie nichts hin.","Complète 10 quêtes pour des PNJ. Ils ne peuvent rien faire par eux-mêmes."],
         "icon":608
      };
      
      public static var NPCservant:Object = {
         "id":"NPCservant",
         "name":["NPC Servant","Sirviente de NPC","Servo de um NPC","NPC-Diener","Serviteur des PNJ"],
         "description":["Complete 20 quests for NPCs. Saving the world can wait.","Completa 20 misiones para NPCs. Salvar al mundo puede esperar.","Complete 20 missões para NPCs. O mundo pode esperar para ser salvo.","Erledige 20 Quests für NPCs. Die Rettung der Welt kann warten.","Complète 20 quêtes pour des PNJ. Sauver le monde peut attendre."],
         "icon":672
      };
      
      public static var NPCslave:Object = {
         "id":"NPCslave",
         "name":["NPC Slave","Esclavo de NPC","Escravizado por um NPC","NPC-Sklave","Esclave des PNJ"],
         "description":["Complete 30 quests for NPCs. They own you now.","Completa 30 misiones para NPCs. Ahora les perteneces.","Complete 30 missões para NPCs. Agora você os pertence.","Erledige 30 Quests für NPCs. Jetzt gehörst du ihnen.","Complète 30 quêtes pour des PNJ. Tu leur appartiens maintenant."],
         "icon":607
      };
      
      public static var art:Object = {
         "id":"art",
         "name":["Art Appreciator","Apreciador de Arte","Crítico de Arte","Kunstliebhaber","Amateur d’Art"],
         "description":["Check out some of the art galleries.","Echa un vistazo a la galería de arte.","Dê uma olhada na galeria de Arte.","Schau dir die Bildergalerien an.","Jette un œil aux galeries d’art."],
         "icon":616
      };
      
      public static var slimysituation:Object = {
         "id":"slimysituation",
         "name":["Slimy Situation","Situación Babosa","Situação Viscosa","Schleimige Situation","Situation Gluante"],
         "description":["Get turned into a slime. Some people have a fetish for that sort of thing.","Conviértete en una baba. Algunas personas tienen un fetichismo por ese tipo de cosas","Seja transformado em uma Gosma. Algumas pessoas têm fetiche por esse tipo de coisa.","Verwandele dich in einen Schleim. Manche Leute haben einen Fetisch für so Sachen.","Sois transformé en gluant. Certaines personnes ont un fétiche pour ce genre de choses."],
         "icon":615
      };
      
      public static var chicken:Object = {
         "id":"chicken",
         "name":["Chicken Molester","Abusador de Gallinas","Molestador de Galinhas","Hühnchenschänder","Agresseur de Poulets"],
         "description":["Seriously stress out a chicken. Just don\'t stab it.","Estresa a una gallina seriamente. Solo no la apuñales.","Deixe a galinha realmente estressada. Só não a ataque.","Stresse ein Hühnchen bis zum Gehtnichtmehr. Du darfst bloß nicht auf es einstechen.","Stresse sérieusement un poulet. Ne les attaque pas par contre."],
         "icon":620
      };
      
      public static var deathpenalty:Object = {
         "id":"deathpenalty",
         "name":["Death Penalty","Pena de Muerte","Pena de Morte","Todesstrafe","Peine de mort"],
         "description":["Kill a foe with an instant-death attack.","Mata a un enemigo con un ataque de muerte instantánea.","Derrote um inimigo com um ataque de morte instantânea.","Erledige einen Gegner mit einer Attacke, die direkt zum Tod führen kann.","Tue un ennemi avec une attaque de mort intantanée."],
         "icon":654
      };
      
      public static var survivedeath:Object = {
         "id":"survivedeath",
         "name":["Extra Lives","Vidas Extra","Vidas Extras","Extra-Leben","Vies Bonus"],
         "description":["Survive death: Be killed, but do not die.","Sobrevive a la muerte: Se asesinado, pero no mueras.","Sobreviva a morte: Seja assassinado, mas não morra.","Überlebe den Tod: Werde umgebracht, aber stirb nicht.","Survis à la mort: Sois tué, mais ne meurs pas."],
         "icon":656
      };
      
      public static var powerofcourage:Object = {
         "id":"powerofcourage",
         "name":["Power of Courage","Poder del Coraje","Poder da Coragem","Macht des Mutes","Puissance du Courage"],
         "description":["Survive a powerful attack with 1HP.","Sobrevive un poderoso ataque con 1HP.","Sobreviva a um ataque poderoso com 1HP.","Überlebe eine mächtige Attacke mit 1 HP.","Survis à une puissante attaque avec 1HP."],
         "icon":650
      };
      
      public static var monsterhunter:Object = {
         "id":"monsterhunter",
         "name":["Monster Hunter","Cazador de Monstruos","Caçador de Monstros","Monsterjäger","Chasseur de Monstres"],
         "description":["Defeat 100 foes in total, and develop a taste for their flesh.","Derrota 100 monstruos en total, y desarrolla un gusto por su carne.","Derrote 100 monstros no total e desenvolva um gosto por sua carne.","Besiege insgesamt 100 Gegner und komm auf den Geschmack ihres Fleisches.","Bats 100 ennemis au total et développe un goût pour leur chair."],
         "icon":648
      };
      
      public static var extinctionevent:Object = {
         "id":"extinctionevent",
         "name":["Extinction Event","Evento de Extinción","Evento de Extinção","Massensterben","Extinction"],
         "description":["Defeat 1,000 foes in total, and become a serious threat to the ecosystem.","Derrota 1,000 enemigos en total, y conviértete en una seria amenaza para el ecosistema.","Derrote 1,000 inimigos no total e se torne uma séria ameaça para o ecosistema.","Besiege insgesamt 1.000 Gegner und werde zu einer ernsthaften Gefahr für das Ökosystem.","Bats 1,000 ennemis au total et deviens une menace sérieuse pour l’écosystème."],
         "icon":647
      };
      
      public static var starthegame:Object = {
         "id":"starthegame",
         "name":["Start the Game Already","Comienza el Juego Ya","Começe o jogo de uma vez","Fang endlich mit dem Spiel an","Allez, Commence le Jeu"],
         "description":["Smash 100 Idols on the loading screen, because clicking randomly makes the game load faster.","Destruye 100 Ídolos en la pantalla de carga, porque hacer click al azar hace que el juego cargue más rápido.","Destrua 100 Ídolos na tela de carregamento, porque clicar aleatoriamente faz o jogo carregar mais rapidamente.","Zerstöre 100 Götzen auf dem Ladebildschirm, weil wildes Herumgeklicke das Spiel schneller laden lässt.","Détruis 100 Idoles dans l’écran de chargement, parce que cliquer n’importe où rend le jeu plus rapide à charger."],
         "icon":649
      };
      
      public static var overpriced:Object = {
         "id":"overpriced",
         "name":["Overpriced Snacks","Bocadillos Caros","Aperitivos de Ouro","Überteuerte Snacks","Goûter Hors de Prix"],
         "description":["Destroy the economy by buying rare food.","Destruye la economía comprando comida rara.","Destrua a economia comprando um alimento raro.","Zerstöre die Wirtschaft, indem du seltene Lebensmittel kaufst.","Détruis l’économie en achetant des aliments rares."],
         "icon":641
      };
      
      public static var bestcustomer:Object = {
         "id":"bestcustomer",
         "name":["Best Customer","El Mejor Cliente","Cliente número um","Bester Kunde","Le Meilleur Client"],
         "description":["Completely buy-out an equipment shop.","Agota completamente una tienda de equipamiento.","Esgote o estoque da loja de equipamentos.","Kauf einen Ausrüstungsladen komplett leer.","Dévalise un magasin d’équipement."],
         "icon":640
      };
      
      public static var keeneyes:Object = {
         "id":"keeneyes",
         "name":["Keen Eye","Vista Lince","Olhos de Águia","Adlerauge","Œil de Lynx"],
         "description":["Discover 30 secrets. There\'s actually way more than that though.","Descubre 30 secretos. Aunque en realidad hay mucho más que eso.","Descubra 30 segredos. Aliás, existem muito mais do qeu isso.","Entdecke 30 Geheimnisse. Es gibt allerdings weitaus mehr von ihnen.","Découvre 30 secrets. Il y en a bien plus que ça par contre."],
         "icon":626,
         "value":30
      };
      
      public static var blacksmith:Object = {
         "id":"blacksmith",
         "name":["Blacksmith","Herrero","Ferreiro","Schmied","Forgeron"],
         "description":["Fully upgrade any item of equipment.","Mejora por completo cualquier pieza de equipo.","Refine ao máximo qualquer peça de equipamento.","Rüste irgendeinen beliebigen Ausrüstungsgegenstand komplett auf.","Améliore complètement un équipement."],
         "icon":639
      };
      
      public static var equipmentcollector:Object = {
         "id":"equipmentcollector",
         "name":["Equipment Collector","Coleccionista de Equipos","Colecionador de Equipamentos","Ausrüstungssammler","Collectionneur"],
         "description":["Collect 145 pieces of equipment.","Adquiere 145 piezas de equipo.","Colete 145 peças de equipamento.","Sammle 145 Ausrüstungsgegenstände.","Obtiens 145 pièces d’équipement."],
         "icon":638
      };
      
      public static var firstcasualty:Object = {
         "id":"firstcasualty",
         "name":["First Casualty","Primera Pérdida","Primeira Vítima","Erstes Todesopfer","Première Victime"],
         "description":["Watch a player die, as you do nothing to help.","Observa a un jugador morir, mientras no haces nada para evitarlo.","Observe um jogador morrer enquanto você não pode fazer nada para ajudá-lo.","Sieh zu, wie ein Spieler stirbt, während du nichts tust, um ihm zu helfen.","Regarde un joueur mourir, pendant que tu ne fais rien pour aider."],
         "icon":637
      };
      
      public static var stepoverthedead:Object = {
         "id":"stepoverthedead",
         "name":["Step Over the Dead","Camina Sobre los Muertos","Caminhe sobre os Mortos","Weg über Leichen","Marche sur les Morts"],
         "description":["Clear away a player\'s rotting corpse.","Deshazte del cadáver podrido de un jugador.","Se desfaça do cadáver apodrecido de um jogador.","Entsorge die rottende Leiche eines Spielers.","Dégage le corps d’un joueur."],
         "icon":636
      };
      
      public static var suicidalattack:Object = {
         "id":"suicidalattack",
         "name":["Kamikaze","Kamikaze","Kamikaze","Kamikaze","Kamikaze"],
         "description":["Kill yourself with a spell or summon.","Eliminate a tí mismo con un hechizo o invocación.","Se mate com uma magia ou uma invocação.","Bring dich selbst mit einem Zauber oder einer Beschwörung um.","Suicide-toi avec un sort ou une invocation."],
         "icon":635
      };
      
      public static var invadersfromspace:Object = {
         "id":"invadersfromspace",
         "name":["Invaders from Space","Invasores del Espacio","Invasores do Espaço","Angreifer aus dem All","Envahisseurs de l’Espace"],
         "description":["Summon the most powerful creature to obliterate your enemies.","Invoca la criatura más poderosa para arrasar con tus enemigos.","Invoque a criatura mais poderosa para poder obliterar seus inimigos.","Beschwöre die allermächtigste Kreatur, um deine Gegner dem Erdboden gleich zu machen.","Invoque la plus puissante créature pour oblitérer tes ennemis."],
         "icon":634
      };
      
      public static var unkownpowerlevel:Object = {
         "id":"unkownpowerlevel",
         "name":["Unknown Power Level","Nivel de Poder Oculto","Poder de Luta Desconhecido","Unbekannte Kampfkraft","Puissance Inconnue"],
         "description":["Find an unscannable secret foe.","Encuentra un enemigo secreto no-escaneable.","Encontre um inimigo secreto impossível de se escanear.","Finde einen nicht scannbaren geheimen Gegner.","Trouve un ennemi secret qui ne peut pas être scanné."],
         "icon":632
      };
      
      public static var d300:Object = {
         "id":"d300",
         "name":["300 Damage","300 de Daño","300 de Dano","300 Schaden","300 Dégâts"],
         "description":["Deal 300 damage with a single hit.","Causa 300 de daño con un solo golpe.","Cause 300 de dano em um só golpe.","Füge mit einem einzigen Schlag 300 Schaden zu.","Inflige 300 dégâts en un seul coup."],
         "icon":631
      };
      
      public static var d3k:Object = {
         "id":"d3k",
         "name":["3K Damage","3K de Daño","3K de Dano","3K Schaden","3K Dégâts"],
         "description":["Deal 3,000 damage with a single hit.","Causa 3,000 de daño con un solo golpe.","Cause 3,000 de dano em um só golpe.","Füge mit einem einzigen Schlag 3.000 Schaden zu.","Inflige 3,000 dégâts en un seul coup."],
         "icon":630
      };
      
      public static var d30k:Object = {
         "id":"d30k",
         "name":["30K Damage","30K de Daño","30K de Dano","30K Schaden","30K Dégâts"],
         "description":["Deal 30,000 damage with a single hit.","Causa 30,000 de daño con un solo golpe.","Cause 30,000 de dano com um só golpe.","Füge mit einem einzigen Schlag 30.000 Schaden zu.","Inflige 30,000 dégâts en un seul coup."],
         "icon":629
      };
      
      public static var d300k:Object = {
         "id":"d300k",
         "name":["300K Damage","300K de Daño","300K de Dano","300K Schaden","300K Dégâts"],
         "description":["Deal 300,000 damage with a single hit.","Causa 300,000 de daño con un solo golpe.","Cause 300,000 de dano em um só golpe.","Füge mit einem einzigen Schlag 300.000 Schaden zu.","Inflige 300,000 dégâts en un seul coup."],
         "icon":628
      };
      
      public static var d3m:Object = {
         "id":"d3m",
         "name":["3M Damage","3M de Daño","3M de Dano","3M Schaden","3M Dégâts"],
         "description":["Deal 3,000,000 damage with a single hit. That\'s a lot!","Causa 3,000,000 de daño con un solo golpe. ¡Eso es mucho!","Cause 3,000,000 de dano em um só golpe. Isso é muito!","Füge mit einem einzigen Schlag 3.000.000 Schaden zu. Das ist \'ne ganz schöne Menge!","Inflige 3,000,000 dégâts en un seul coup. C’est beaucoup!"],
         "icon":627
      };
      
      public static var level11:Object = {
         "id":"level11",
         "name":["Level 10","Nivel 10","Nível 10","Level 10","Niveau 10"],
         "description":["Reach level 10. That\'s a good start, but there\'s still a long way to go.","Alcanza el nivel 10. Es un buen inicio, pero aún queda un largo camino por recorrer","Alcance o nível 10. É um bom começo, mas ainda se tem uma boa estrada a se percorrer.","Erreiche Level 10. Das ist ein guter Anfang, aber du hast noch einen langen Weg vor dir.","Atteins le niveau 10. C’est un bon départ, mais la route est encore longue."],
         "icon":601
      };
      
      public static var level22:Object = {
         "id":"level22",
         "name":["Level 20","Nivel 20","Nível 20","Level 20","Niveau 20"],
         "description":["Reach level 20. Getting well into the game now.","Alcanza el nivel 20. Ahora te estás metiendo en el juego.","Alcance o nível 20. Agora sim o jogo está começando.","Erreiche Level 20. So langsam kommst du voran.","Atteins le niveau 20. Pas mal avancé dans le jeu maintenant."],
         "icon":602
      };
      
      public static var level33:Object = {
         "id":"level33",
         "name":["Level 30","Nivel 30","Nível 30","Level 30","Niveau 30"],
         "description":["Reach level 30. Should be strong enough to take on the final boss. Almost.","Alcanza el nivel 30. Deberías ser lo suficientemente fuerte para enfrentar al jefe final.","Alcance o nível 30. Já deve ser o suficiente para derrotar o último chefe.","Erreiche Level 30. Das sollte genügen, um dir den Endboss vorzuknöpfen.","Atteins le niveau 30. Tu devrais être assez puissant pour battre le boss final."],
         "icon":603
      };
      
      public static var level44:Object = {
         "id":"level44",
         "name":["Level 40","Nivel 40","Nível 40","Level 40","Niveau 40"],
         "description":["Reach level 40. Well, if you don\'t have anything better to do, you might as well go even further.","Alcanza el nivel 40. Bueno, si no tienes nada mejor que hacer, podrías ir incluso más allá.","Alcance o nível 40. Bem, se você não tiver mais nada pra fazer, pode tentar ir até mais para frente.","Erreiche Level 40. Nun, wenn du nichts Besseres zu tun hast, kannst du einfach noch weiter gehen.","Atteins le niveau 40. Bon, si tu n’as rien d’autre à faire, autant continuer encore plus loin."],
         "icon":604
      };
      
      public static var limitbreak:Object = {
         "id":"limitbreak",
         "name":["Limits Were Broken","Rompe los Límites","Quebrando o Limite","Grenzensprenger","Dépasser les Limites"],
         "description":["Use an awesome limit break for the first time.","Usa un increíble limit break por primera vez.","Use um incrível limit break pela primeira vez.","Verwende zum ersten Mal einen fantastischen Limit Break.","Utilise un incroyable limit break pour la première fois. "],
         "icon":655
      };
      
      public static var winteriscoming:Object = {
         "id":"winteriscoming",
         "name":["Winter is Coming","Se Acerca el Invierno","O Inverno está Chegando","Der Winter naht","L’Hiver s’en Vient"],
         "description":["Freeze a foe, and then hit them again for massive damage.","Congela un enemigo, y luego golpéalo de nuevo para un daño masivo.","Congele um inimigo e então o ataque novamente para um dano massivo.","Friere einen Gegner ein. Triff ihn dann erneut, um massiven Schaden zu verursachen.","Gèle un ennemi, puis frappe-le encore pour des dégâts massifs."],
         "icon":651
      };
      
      public static var burnbabyburn:Object = {
         "id":"burnbabyburn",
         "name":["Burn Baby Burn","Arde Nena Arde","Queime querido Queime","Brenn, Baby, brenn","Burn Baby Burn"],
         "description":["Set a foe on fire, and watch them burn.","Quema un enemigo, y obsérvalo arder.","Coloque um inimigo em chamas e o veja queimar.","Setze einen Gegner in Brand und sieh ihm beim Brennen zu.","Mets le feu à un ennemi puis regarde-le brûler."],
         "icon":652
      };
      
      public static var waterconducts:Object = {
         "id":"waterconducts",
         "name":["Water Conducts","Agua Conductora","Água Condutora","Wasser leitet","Conduite d’Eau"],
         "description":["Shock a wet foe with a thunder attack (or ice, if you prefer).","Ataca a un enemigo mojado con un ataque tipo trueno (o hielo, si lo prefieres).","Eletrocute um inimigo molhado com um ataque do tipo Raio (ou gelo, o que você preferir)","Greif einen nassen Gegner mit einer Blitz- oder, wenn dir das lieber ist, Eisattacke an.","Frappe un ennemi mouillé avec une attaque de type foudre (ou glace, si tu préfères)."],
         "icon":653
      };
      
      public static var overkill:Object = {
         "id":"overkill",
         "name":["Overkill","Overkill","Overkill","Overkill","Overkill"],
         "description":["Completely obliterate a feeble enemy. The cute ones deserve it.","Arrasa completamente con un enemigo débil. Los adorables se lo merecen.","Oblitere um inimigo inofensivo. Os fofinhos merecem.","Lösche einen mickrigen Gegner vollständig aus. Die Niedlichen verdienen es.","Oblitère complètement un ennemi faible. Ceux qui sont mignons ne méritent pas mieux."],
         "icon":660
      };
      
      public static var firstkill:Object = {
         "id":"firstkill",
         "name":["First Blood","Primera Muerte","Primeira Morte","Erstes Blut","Premier Sang"],
         "description":["Defeat your first foe, and become a hardened killer.","Derrota tu primer enemigo, y conviértete en un asesino preparado.","Derrote seu primeiro inimigo e se torne um assassino preparado.","Besiege deinen ersten Gegner und werde zu einem hartgesottenen Killer.","Bats ton premier ennemi et deviens un tueur endurci."],
         "icon":661
      };
      
      public static var lostruins:Object = {
         "id":"lostruins",
         "name":["Lost Ruins","Ruinas Perdidas","Ruínas Perdidas","Verlorene Ruinen","Ruines Perdues"],
         "description":["Find the hidden ruins in the jungle.","Encuentra la ruinas escondidas en la jungla.","Encontre as ruínas perdidas na floresta.","Finde die versteckten Ruinen im Dschungel.","Trouve les ruines cachées dans la jungle."],
         "icon":659
      };
      
      public static var lunchtime:Object = {
         "id":"lunchtime",
         "name":["Lunchtime","Hora de Almorzar","Hora do Almoço","Mittagspause","Pause Déjeuner"],
         "description":["Take a break and have something to eat outside of battle.","Tomate un descanso y come algo fuera de la batalla.","Descanse um pouco e pegue algo para comer fora da batalha.","Gönn dir eine Pause und iss etwas außerhalb eines Kampfes.","Fais une pause et mange quelque chose hors d’un combat."],
         "icon":658
      };
      
      public static var tastepain:Object = {
         "id":"tastepain",
         "name":["Taste Pain","Saborea el Dolor","Saboreie a Dor","Schmecke den Schmerz","Savoure la Douleur"],
         "description":["Drink a whole bottle of Chilli Sauce, and eat the actual bottle too.","Toma toda una botella de Salsa Picante, y también comete la botella.","Tome uma garrafa inteira de Molho Picante, aproveite e coma a garrafa também.","Trink eine ganze Flasche Chilisoße und iss die Flasche gleich mit.","Bois une bouteille complète de Sauce Chili et mange la bouteille aussi."],
         "icon":657
      };
      
      public static var marathon:Object = {
         "id":"marathon",
         "name":["Marathon Runner","Maratonista","Maratonista","Marathonläufer","Coureur de Marathon"],
         "description":["Take 10,000 steps. Fun.","Camina 10,000 pasos. Divertido.","Dê 10,000 passos. Divertido.","Geh 10.000 Schritte. Was für ein Spaß.","Marche 10,000 pas. Amusant."],
         "icon":671
      };
      
      public static var keys:Object = {
         "id":"keys",
         "name":["Keys Unlock Stuff","Las Llaves Abren Cosas","Chaves Destravam Coisas.","Schlüssel zum Glück","Clés Débloquent Trucs"],
         "description":["Use a key to access new treasures, but you should have figured that out on your own.","Usa una llave para acceder a nuevos tesoros, pero ya tendrías que saber eso ","Use a chave para acessar novos tesouros, mas você deveria ter aprendido isso sozinho.","Verwende einen Schlüssel, um an neue Schätze zu kommen, aber das solltest du bereits selbst herausgefunden haben.","Utilise une clé pour accéder à de nouveaux trésors, mais tu devrais déjà l’avoir compris par toi-même."],
         "icon":669
      };
      
      public static var lava:Object = {
         "id":"lava",
         "name":["Lava Burns","La Lava Quema","A Lava Queima.","Lava brennt","La Lave Brûle"],
         "description":["Walk on lava and get hurt, because that\'s not smart.","Camina por lava y quémate, porque eso no es astuto.","Ande na lava e se queime por que isso não é muito esperto.","Laufe auf Lava und verletze dich dabei, weil das nicht gerade intelligent ist.","Marche sur la lave et fais-toi blesser, parce que ce n’était pas intelligent."],
         "icon":664
      };
      
      public static var slimecatking:Object = {
         "id":"slimecatking",
         "name":["Slime Cat King","Rey Gato de Baba","Rei Gato de Gosma","Schleimkatzenkönig","Roi des Chats Gluants."],
         "description":["Find all the Slime Cats, and rule the world map.","Encuentra a todos los Gatos de Baba, y gobierna el mapa del mundo.","Encontre todos os Gatos de Gosma e domine o mapa do mundo.","Finde alle Schleimkatzen und sei Herrscher der Weltkarte.","Trouve tous les Chats Gluants et gouverne la carte du monde."],
         "icon":663
      };
      
      public static var slimecat:Object = {
         "id":"slimecat",
         "name":["Slime Cat","Gato de Baba","Gato de Gosma","Schleimkatze","Chat Gluant"],
         "description":["Find a Slime Cat and discover the Warp Zone.","Encuentra a un Gato de Baba y descubre la Zona de Transporte.","Encontre um Gato de Gosma e descubra uma Zona de Teletransporte.","Finde eine Schleimkatze und entdecke die Warpzone.","Trouve un Chat Gluant et découvre la Zone de Téléportation."],
         "icon":662
      };
      
      public static var strength:Object = {
         "id":"strength",
         "name":["Used Strength","Usó Fuerza","Usou Força","VM Stärke","Utilise Force"],
         "description":["Push an unwanted block out of the way. It will not be missed.","Empuja un bloque inoportuno fuera del camino. Nadie lo extrañará.","Empurre um bloco para fora do caminho. Ele não fará falta.","Schieb einen störenden Block zur Seite. Niemand wird ihn vermissen.","Pousse un bloc indésirable hors du chemin. Il ne va pas nous manquer."],
         "icon":665
      };
      
      public static var flash:Object = {
         "id":"flash",
         "name":["Used Flash","Usó Destello","Usou Flash","VM Blitz","Utilise Flash"],
         "description":["Light a torch with your candle. Fire magic doesn\'t work for some reason.","Prende una antorcha con tu vela. La magia de fuego no funciona por alguna razón.","Acenda uma tocha com sua vela. Magias de fogo não funcionam por algum motivo.","Zünde mit der Kerze eine Fackel an. Aus irgendeinem Grund klappt Feuermagie nicht.","Allume une torche avec ta bougie. La magie de feu ne fonctionne pas pour une raison quelconque."],
         "icon":670
      };
      
      public static var cut:Object = {
         "id":"cut",
         "name":["Used Cut","Usó Corte","Usou Cortar","VM Zerschneider","Utilise Coupe"],
         "description":["Cut down a dangerous path-blocking bush. Don\'t worry, they don\'t have feelings.","Corta un peligroso arbusto entrometido. No te preocupes, no tienen sentimientos.","Corte um perigoso arbusto que está em seu caminho. Não se preocupe, eles não têm sentimentos.","Fälle ein gefährliches und im Weg stehendes Bäumchen. Keine Sorge, sie können nichts fühlen.","Coupe un dangereux buisson bloquant le passage. Ne t’inquiète pas, ils ne ressentent rien."],
         "icon":667
      };
      
      public static var rocksmash:Object = {
         "id":"rocksmash",
         "name":["Used Rock Smash","Usó Golpe Roca","Usou Quebrar Rocha","VM Zertrümmerer","Utilise Éclate-Roc"],
         "description":["Smash a nice boulder. You could even find some diamond inside.","Rompe una linda piedra. Hasta podrías encontrar algún diamante adentro.","Quebre uma linda pedra. Você poderá até encontrar um diamante dentro.","Zertrümmere einen hübschen Felsen. Du könntest darin sogar einen Diamanten finden.","Casse une belle pierre. Tu pourrais même trouver des diamants à l’intérieur."],
         "icon":668
      };
      
      public static var ladder:Object = {
         "id":"ladder",
         "name":["Used... Ladder?","Usó... ¿Escalera?","Usou... Escada?","VM... Leiter?","Utilise... Escabeau?"],
         "description":["Bridge a gap, with the power of ladders.","Arma un puente, con el poder de las escaleras.","Preencha um buraco com o poder das escadas.","Überbrücke einen Spalt mit der Macht der Leiter.","Surmonte un trou, avec le pouvoir des escabeaux."],
         "icon":666
      };
      
      public static var pantythief:Object = {
         "id":"pantythief",
         "name":["Panty Thief","Ladrón de Bragas.","Ladrão de Calcinhas","Höschendieb","Voleur de Culottes"],
         "description":["Steal some underwear. Perverts pay good money for stuff like this.","Roba ropa interior. Los pervertidos pagan buen dinero por cosas como esta.","Roube umas roupas íntimas. Pervertidos pagarão um bom dinheiro por coisas deste tipo.","Stiehl etwas Unterwäsche. Perverse zahlen viel Geld für sowas.","Vole des sous-vêtements. Les pervers paient bien pour ce genre de choses."],
         "icon":605
      };
      
      public static var pervert:Object = {
         "id":"pervert",
         "name":["Pervert","Pervertido","Pervertido","Perversling","Pervers"],
         "description":["Please don\'t leave 100,000 comments about this. Seriously.","No dejen 100,000 comentarios sobre esto de nuevo por favor. En serio, enfermos.","Por favor não façam 100,000 comentários sobre isso de novo. Sério, seus loucos.","Bitte hinterlasst nicht schon wieder 100.000 Kommentare deswegen. Ernsthaft, ihr Freaks.","S’il vous plaît, ne me récrivez 100,000 commentaires à propos de ça. Sérieusement, bande de malades."],
         "icon":609
      };
      
      public static var lumberjack:Object = {
         "id":"lumberjack",
         "epic":true,
         "name":["Lumberjack","Leñador","Lenhador","Holzfäller","Bûcheron"],
         "description":["Defeat Mighty Oak on Epic difficulty.","Derrota al Gran Roble en dificultad Épica.","Derrote o Grande Carvalho na dificuldade Épica.","Besiege die Mächtige Eiche auf dem Schwierigkeitsgrad \"Epic\".","Bats le Grand Chêne en difficulté Épique."],
         "icon":646
      };
      
      public static var rockminer:Object = {
         "id":"rockminer",
         "epic":true,
         "name":["Rock Miner","Minero de Roca","Mineirador de Rochas","Bergarbeiter","Mineur de Roche"],
         "description":["Defeat Crystal Golem on Epic difficulty.","Derrota al Golem de Cristal en dificultad Épica.","Derrote o Golem de Cristal na dificuldade Épica.","Besiege den Kristallgolem auf dem Schwierigkeitsgrad \"Epic\".","Bats le Golem de Crystal en difficulté Épique."],
         "icon":645
      };
      
      public static var electricalengineer:Object = {
         "id":"electricalengineer",
         "epic":true,
         "name":["Electrical Engineer","Ingeniero Eléctrico","Engenheiro Elétrico","Elektrotechniker","Ingénieur Électricien"],
         "description":["Defeat Praetorian on Epic difficulty.","Derrota al Pretoriano en dificultad Épica.","Derrote o Pretoriano na dificuldade Épica","Besiege den Prätorianer auf dem Schwierigkeitsgrad \"Epic\".","Bats le Prétorien en difficulté Épique."],
         "icon":644
      };
      
      public static var extremegardener:Object = {
         "id":"extremegardener",
         "epic":true,
         "name":["Extreme Gardener","Jardinero Extremo","Jardineiro Radical","Extremgärtner","Jardinage Extrême"],
         "description":["Defeat Rafflesia on Epic difficulty.","Derrota a Rafflesia en dificultad Épica.","Derrote a Raflésia na dificuldade Épica","Besiege die Rafflesie auf dem Schwierigkeitsgrad \"Epic\".","Bats Rafflesia en difficulté Épique."],
         "icon":643
      };
      
      public static var leethacker:Object = {
         "id":"leethacker",
         "acable":true,
         "name":["Leet Hacker","Hacker Élite","Hacker de Elite","Leet-Hacker","Hacker d’Él33t"],
         "description":["Defeat the glitch on any difficulty.","Derrota al glitch en cualquier dificultad.","Derrote o glitch em qualquer dificuldade.","Besiege den Glitch auf einem beliebigen Schwierigkeitsgrad.","Bats le Bug avec n’importe quelle difficulté."],
         "icon":633
      };
      
      public static var catperson:Object = {
         "id":"catperson",
         "epic":true,
         "name":["Cat Person","Persona Gatuna","Pessoa de Gatos","Katzenmensch","Personne à Chat"],
         "description":["Defeat Godcat on Epic difficulty.","Derrota a Diosgato en dificultad Épica.","Derrote o Deusgato na dificuldade Épica","Besiege die Götterkatze auf dem Schwierigkeitsgrad \"Epic\".","Bats Déesse Féline en difficulté Épique."],
         "icon":642
      };
      
      public static var enterashwood:Object = {
         "id":"enterashwood",
         "name":["Deforestation Problem","Problema de Deforestación","Problemas de Desmatamento","Waldzerstörungsproblem","Déforestation Difficile"],
         "description":["Enter Ashwood Forest for the first time.","Entra a Bosque Ceniza por primera vez.","Entre na Floresta de Freixos pela primeira vez.","Betrete zum ersten Mal den Holzaschenwald.","Entre dans la Forêt de Boiscendré pour la première fois."],
         "icon":674
      };
      
      public static var entercaverns:Object = {
         "id":"entercaverns",
         "name":["Digging Too Deep","Excavar Muy Profundo","Cavando Profundo Demais","Zu tief gegraben","Creuser Trop Profond"],
         "description":["Enter the Crystal Caverns for the first time.","Entra a las Cavernas Cristal por primera vez.","Entre na Caverna de Cristal pela primeira vez.","Betrete zum ersten Mal die Kristallhöhlen.","Entre dans les Cavernes de Cristal pour la première fois."],
         "icon":676
      };
      
      public static var entergraveyard:Object = {
         "id":"entergraveyard",
         "name":["I See Dead People","Veo Gente Muerta","Vejo Pessoas Mortas","Ich sehe tote Menschen","Je Vois des Morts"],
         "description":["Enter Graybone Graveyard for the first time.","Entra a Cementerio Huesogris por primera vez.","Entre no Cemitério Osso Cinzento pela primeira vez.","Betrete zum ersten Mal den Grauknochenfriedhof.","Entre dans le Cimetière d’Osgris pour la première fois."],
         "icon":675
      };
      
      public static var enterplant:Object = {
         "id":"enterplant",
         "name":["Realm of Robots","Reino de Robots","O Reino dos Robôs","Reich der Roboter","Domaine des Robots"],
         "description":["Enter the Waste Disposal Plant for the first time.","Entra a la Planta de Desechos por primera vez.","Entre na Estação de Esgoto pela primeira vez. ","Betrete zum ersten Mal die Abfallbeseitigungsanlage.","Entre dans l’Usine Chimique pour la première fois."],
         "icon":673
      };
      
      public static var enterjungle:Object = {
         "id":"enterjungle",
         "name":["Plants Eat You","Las Plantas te Comen","As Plantas comem Você","Pflanzen fressen dich","Les Plantes te Mangent"],
         "description":["Enter Lankyroot Jungle for the first time.","Entra a Jungla Raizlarga por primera vez.","Entre na Selva Raíz Delgada pela primeira vez.","Betrete zum ersten Mal den Schmalwurzdschungel.","Entre dans la Jungle de Rachitiracine pour la première fois."],
         "icon":677
      };
      
      public static var entertemple:Object = {
         "id":"entertemple",
         "name":["Ancient Civilization","Civilización antigua","Civilização Anciã","Uralte Zivilisation","Civilisation Ancienne"],
         "description":["Enter the Temple of Godcat for the first time.","Entra al Templo de Diosgato por primera vez.","Entre no Templo da Deusgato pela primeira vez.","Betrete zum ersten Mal den Tempel der Götterkatze.","Entre dans le temple de Déesse Féline pour la première fois."],
         "icon":678
      };
      
      public static var treasurethief:Object = {
         "id":"treasurethief",
         "name":["Treasure Thief","Ladrón de Tesoros","Ladrão de Tesouros","Schatzräuber","Voleur de Trésors"],
         "description":["Collect 111 treasure chests. Those chests aren\'t left out there for you, but you seem to take them anyway.","Abre 111 cofres de tesoro. Esos cofres no están allí para que los tomes, pero parece que lo haces de todos modos.","Abra 111 baús de tesouro. Esses baús não foram espalhados por aí para você, mas você parece pegá-los de qualquer maneira.","Öffne 111 Schatztruhen. Diese Truhen sind nicht für dich bestimmt, aber du scheinst sie dir trotzdem einfach zu nehmen.","Collecte 111 coffres au trésor. Ces coffre ne sont pas laissés là pour toi mais tu sembles les prendre quand même."],
         "icon":709,
         "value":111
      };
      
      public static var treasurecollector:Object = {
         "id":"treasurecollector",
         "name":["Treasure Collector","Coleccionista de Tesoros","Colecionador de Tesouros","Schatzsammler","Collectionneur de trésor"],
         "description":["Collect 222 treasure chests. That\'s more chests than original Pok*mon!","Abre 222 cofres de tesoro. ¡Esos son más cofres que Pok*mon originales!","Abra 222 baús de tesouro. Isso são mais baús do que o Pok*mon original!","Öffne 222 Schatztruhen. Das sind mehr Truhen als es ursprünglich mal Pok*mon gab!","Collecte 222 coffres au trésor. Il y en a plus qu’il y a de Pok*mon dans la première série!"],
         "icon":708,
         "value":222
      };
      
      public static var eagleeyes:Object = {
         "id":"eagleeyes",
         "name":["Eagle Eye","Vista Águila","Visão de Águia","Adlerauge Plus","Œil d’Aigle"],
         "description":["Discover 60 secrets. There may be a few more, but we won\'t force you to find them all.","Descubre 60 secretos. Puede que haya algunos más, pero no te obligaremos a que los encuentres todos.","Descubra 60 segredos. Devem haver um pouco mais, mas não iremos te forçar a encontrar todos eles.","Entdecke 60 Geheimnisse. Vielleicht gibt es noch ein paar mehr, aber wir werden euch nicht dazu zwingen, alle zu finden.","Découvre 60 secrets. Il peut y en avoir un peu plus mais on va pas te forcer à tous les trouver."],
         "icon":710,
         "value":60
      };
      
      public static var d30m:Object = {
         "id":"d30m",
         "name":["30M Damage","30M de Daño","30M de Dano","30M Schaden","30M Dégâts"],
         "description":["Deal 30,000,000 damage with a single hit. Is that even possible?!","Causa 30,000,000 de daño con un solo golpe. ¡¿Es eso siquiera posible?!","Cause 30,000,000 de dano em um só golpe. ...","Füge mit einem einzigen Schlag 30.000.000 Schaden zu. Ist das überhaupt möglich?!","Inflige 30,000,000 dégâts en un seul coup. Est-ce même possible?!"],
         "icon":692
      };
      
      public static var dressupgame:Object = {
         "id":"dressupgame",
         "name":["Dress Up Game","Juego de Vestir","Jogo de Moda","Dress-Up-Spiel","Vestiaire"],
         "description":["Fully upgrade 30 hats or armors. You\'ll need plenty of different armor for the hardest battles!","Mejora 30 sombreros o armaduras por completo. ¡Necesitarás de todo para las batallas difíciles!","Aprimore completamente 30 chapéus ou armaduras. Você precisará de diversas armaduras diferentes para as batalhas mais complicadas!","Bring 30 Hüte oder Rüstungen auf die höchste Stufe. Für die härtesten Kämpfe wirst du \'ne Menge verschiedene Rüstungen brauchen!","Améliore complètement 30 armures ou chapeaux. Tu aura besoin de plein d’armures différentes pour les batailles les plus difficiles."],
         "icon":711,
         "value":30
      };
      
      public static var masterblacksmith:Object = {
         "id":"masterblacksmith",
         "name":["Master Blacksmith","Herrero Maestro","Mestre Ferreiro","Meisterschmied","Maître Forgeron"],
         "description":["Fully upgrade 30 weapons. Don\'t just use the same weapons all the time, that\'s boring!","Mejora 30 armas por completo. No uses las mismas armas todo el tiempo ¡Eso es aburrido!","Aprimore completamente 30 armas. Não utilize a mesma arma o tempo inteiro, isso é entediante!","Bring 30 Waffen auf die höchste Stufe. Benutz nicht ständig dieselben Waffen - das ist langweilig!","Améliore complètement 30 armes. Utilise pas toujours la même arme, c’est ennuyeux!"],
         "icon":681,
         "value":30
      };
      
      public static var treewar:Object = {
         "id":"treewar",
         "epic":true,
         "name":["Trees Go To War","Árboles de Guerra","Árvores de Guerra","Bäume auf Kriegsfuß","Arbres de Guerre"],
         "description":["Defeat the stronger version of Mighty Oak, on Epic difficulty.","Derrota la versión mejorada del Gran Roble, en dificultad Épica.","Derrote a versão aprimorada do Grande Carvalho, na dificuldade Épica.","Besiege die stärkere Version der Mächtigen Eiche auf dem Schwierigkeitsgrad \"Epic\".","Bats la version plus forte du Grand Chêne, en difficulté Épique."],
         "icon":696
      };
      
      public static var diamonds:Object = {
         "id":"diamonds",
         "epic":true,
         "name":["Die For Diamonds","Muero por Diamantes","Morra por Diamantes","Blut gegen Diamanten","Les Diamants ou la Vie"],
         "description":["Defeat the stronger version of Crystal Golem, on Epic difficulty.","Derrota la versión mejorada del Golem de Cristal, en dificultad Épica.","Derrote a vesão aprimorada do Golem de Cristal, na dificuldade Épica.","Besiege die stärkere Version des Kristallgolems auf dem Schwierigkeitsgrad \"Epic\".","Bats la version plus forte du Golem de Cristal, en difficulté Épique."],
         "icon":695
      };
      
      public static var hardwareupgrade:Object = {
         "id":"hardwareupgrade",
         "epic":true,
         "name":["Hardware Upgrade","Hardware Actualizado","Hardware Atualizado","Hardware-Upgrade","Mise à jour du matériel"],
         "description":["Defeat the stronger version of Praetorian, on Epic difficulty.","Derrota la versión mejorada del Pretoriano, en dificultad Épica.","Derrote a versão aprimorada do Pretoriano, na dificuldade Épica.","Besiege die stärkere Version des Prätorianers auf dem Schwierigkeitsgrad \"Epic\".","Bats la version plus forte du Prétorien, en difficulté Épique."],
         "icon":694
      };
      
      public static var endoftherainbow:Object = {
         "id":"endoftherainbow",
         "epic":true,
         "name":["End Of The Rainbow","Final del Arcoiris","Fim do Arco-Íris","Das Ende des Regenbogens","Bout de l’Arc-en-Ciel"],
         "description":["Defeat the stronger version of Rafflesia, on Epic difficulty.","Derrota la versión mejorada de Rafflesia, en dificultad Épica.","Derrote a versão aprimorada da Raflésia, na dificuldade Épica.","Besiege die stärkere Version der Rafflesie auf dem Schwierigkeitsgrad \"Epic\".","Bats la version plus forte de Rafflesia, en difficulté Épique."],
         "icon":693
      };
      
      public static var bossrush1:Object = {
         "id":"bossrush1",
         "epic":true,
         "name":["Miniboss Rush","Fiebre de Mini-Jefes","Conquista dos Mini-Chefes","Miniboss Rush","Rush de Miniboss"],
         "description":["Beat the first boss marathon, on Epic difficulty.","Completa la primer maratón de jefes, en dificultad Épica.","Complete a primeira maratona de chefes, na dificuldade Épica.","Beende den ersten Boss-Marathon auf dem Schwierigkeitsgrad \"Epic\".","Bats le premier marathon de boss, en difficulté Épique."],
         "icon":707
      };
      
      public static var bossrush2:Object = {
         "id":"bossrush2",
         "epic":true,
         "name":["Boss Rush","Fiebre de Jefes","Conquista dos Chefes","Boss Rush","Rush de Boss"],
         "description":["Beat the second boss marathon, on Epic difficulty.","Completa la segunda maratón de jefes, en dificultad Épica.","Complete a segunda maratona de chefes, na dificuldade Épica.","Beende den zweiten Boss-Marathon auf dem Schwierigkeitsgrad \"Epic\".","Bats le second marathon de boss, en difficulté épique."],
         "icon":706
      };
      
      public static var bossrush3:Object = {
         "id":"bossrush3",
         "epic":true,
         "name":["Mega Boss Rush","Mega Fiebre de Jefes","Conquista dos Mega-Chefes","Mega Boss Rush","Rush de Méga Boss"],
         "description":["Beat the third boss marathon, on Epic difficulty.","Completa la tercer maratón de jefes, en dificultad Épica.","Complete a terceira maratona de chefes, na dificuldade Épica.","Beende den dritten Boss-Marathon auf dem Schwierigkeitsgrad \"Epic\".","Bats le troisième marathon de boss, en difficulté Épique"],
         "icon":705
      };
      
      public static var bossrush4:Object = {
         "id":"bossrush4",
         "epic":true,
         "name":["Dark Boss Rush","Fiebre de Necro-Jefes","Conquista dos Chefes das Trevas","Zombie Boss Rush","Rush de Nécro-Boss"],
         "description":["Beat the fourth boss marathon, on Epic difficulty.","Completa la cuarta maratón de jefes, en dificultad Épica.","Complete a quarta maratona dos chefes, na dificuldade Épica.","Beende den dritten Boss-Marathon auf dem Schwierigkeitsgrad \"Epic\".","Bats le quatrième marathon de boss, en difficulté Épique."],
         "icon":704
      };
      
      public static var foerush:Object = {
         "id":"foerush",
         "epic":true,
         "name":["Foe Rush","Fiebre de Enemigos","Conquista dos Monstros","Monster Rush","Rush d’Ennemis"],
         "description":["Beat the monster marathon, on Epic difficulty.","Completa la maratón de monstruos, en dificultad Épica.","Complete a maratona dos monstros, na dificuldade Épica.","Beende den Monster-Marathon auf dem Schwierigkeitsgrad \"Epic\".","Bats le marathon de monstres, en difficulté Épique."],
         "icon":683
      };
      
      public static var endlessbattles1:Object = {
         "id":"endlessbattles1",
         "acable":true,
         "name":["Mighty Fighters","Peleadores Potentes","Grande Guerreiros","Mächtige Krieger","Formidables Guerriers"],
         "description":["Defeat 10 waves of enemies in Endless Battles. That\'s a good start.","Derrota 10 grupos de enemigos en Peleas sin Fin. Es un buen comienzo.","Derrote 10 grupos de inimigos na Batalha sem Fim. É um bom começo.","Besiege 10 Gegnerwellen in der Endlosen Schlacht. Ein guter Start.","Bats 10 vagues d’ennemis dans la Bataille Sans Fin. C’est un bon début."],
         "icon":687,
         "value":10
      };
      
      public static var endlessbattles2:Object = {
         "id":"endlessbattles2",
         "acable":true,
         "name":["Epic Crusaders","Cruzados Épicos","Cruzada Épica","Sagenumwobene Kreuzritter","Champions épiques"],
         "description":["Defeat 20 waves of enemies in Endless Battles. Time to start getting serious.","Derrota 20 grupos de enemigos en Peleas sin Fin. La situación se torna seria.","Derrote 20 grupos de inimigos na batalha sem Fim. A coisa ficou séria.","Besiege 20 Gegnerwellen in der Endlosen Schlacht. So langsam wird\'s ernst.","Bats 20 vagues d’ennemis dans la Bataille Sans Fin. Ça commence à être sérieux."],
         "icon":686,
         "value":20
      };
      
      public static var endlessbattles3:Object = {
         "id":"endlessbattles3",
         "acable":true,
         "name":["Legendary Heroes","Héroes Legendarios","Heróis Lendários","Legendäre Helden","Héros Légendaires"],
         "description":["Defeat 30 waves of enemies in Endless Battles. This should be quite the challenge!","Derrota 30 grupos de enemigos en Peleas sin Fin. ¡Esto debería ser un gran desafío!","Derrote 30 grupos de inimigos na Batalha sem Fim. Isso deve ser bem desafiador!","Besiege 30 Gegnerwellen in der Endlosen Schlacht. Das sollte eine ziemliche Herausforderung sein!","Bats 30 vagues d’ennemis dans la Bataille Sans Fin. Ça devrait être tout un défi!"],
         "icon":682,
         "value":30
      };
      
      public static var endlessbattles4:Object = {
         "id":"endlessbattles4",
         "name":["Legendary Heroes","","","",""],
         "description":["Defeat 60 waves of enemies in Endless Battles. This should be quite the challenge!","","","",""],
         "icon":682
      };
      
      public static var smashingpumpkins:Object = {
         "id":"smashingpumpkins",
         "epic":true,
         "name":["Smashing Pumpkins","Rompiendo Calabazas","Esmagando Abóboras","Kürbiszerschmetterer","Éclater la Citrouille"],
         "description":["Defeat Jack on Epic difficulty.","Derrota a Jack en dificultad Épica.","Derrote o Jack na dificuldade Épica.","Besiege Jack auf dem Schwierigkeitsgrad \"Epic\".","Bats Jack en difficulté Épique"],
         "icon":700
      };
      
      public static var mammothfeast:Object = {
         "id":"mammothfeast",
         "epic":true,
         "name":["Mammoth Feast","Banquete de Mamut","Banquete de Mamute","Mammutgelage","Festin de Mammouth"],
         "description":["Defeat Wooly Mammoth on Epic difficulty.","Derrota al Mamut Lanudo en dificultad Épica.","Derrote o Mamute Lanoso na dificuldade Épica.","Besiege das Wollige Mammut auf dem Schwierigkeitsgrad \"Epic\".","Bats le Mammouth Laineux en difficulté Épique."],
         "icon":699
      };
      
      public static var wormcontrol:Object = {
         "id":"wormcontrol",
         "epic":true,
         "name":["Worm Control","Control de Plagas","Controle de Pragas","Wurmbekämpfung","Extermination de vers"],
         "description":["Defeat Sand Worm on Epic difficulty.","Derrota a la Lombriz Arenera en dificultad Épica.","Derrote a Minhoca de Areia na dificuldade Épica.","Besiege den Sandwurm auf dem Schwierigkeitsgrad \"Epic\".","Bats le Vers des Sable en difficulté Épique."],
         "icon":698
      };
      
      public static var loandbehold:Object = {
         "id":"loandbehold",
         "epic":true,
         "name":["Lo And Behold","Mirad y Aprended","Veja e Aprenda","Sieh an, sieh an!","Vois et Observe"],
         "description":["Defeat Beholder on Epic difficulty.","Derrota al Espectador en dificultad Épica.","Derrote o Espectador na dificuldade Épica.","Besiege den Betrachter auf dem Schwierigkeitsgrad \"Epic\".","Bats le Spectateur en difficulté Épique."],
         "icon":697
      };
      
      public static var dragonslayer:Object = {
         "id":"dragonslayer",
         "epic":true,
         "name":["Dragon Slayer","Mata Dragones","Matador de Dragões","Drachentöter","Tueur de Dragons"],
         "description":["Defeat Zombie Hydra on Epic difficulty.","Derrota a la Hidra Zombi en dificultad Épica.","Derrote a Hydra Zumbi na dificuldade Épica.","Besiege die Zombie-Hydra auf dem Schwierigkeitsgrad \"Epic\".","Bats l’Hydre zombie en difficulté Épique."],
         "icon":702
      };
      
      public static var unprotected:Object = {
         "id":"unprotected",
         "epic":true,
         "name":["Unprotected","Desprotegido","Desprotegido","Ungeschützt","Non Protégé"],
         "description":["Defeat Protector on Epic difficulty.","Derrota al Protector en dificultad Épica.","Derrote o Protetor na dificuldade Épica.","Besiege den Beschützer auf dem Schwierigkeitsgrad \"Epic\".","Bats le Protecteur en difficulté Épique."],
         "icon":701
      };
      
      public static var darkanna:Object = {
         "id":"darkanna",
         "epic":true,
         "name":["Shadow Huntress","Cazadora Sombría","Caçadora Sombria","Schattenjägerin","Chasseuse de l’Ombre"],
         "description":["Defeat a ranger of the night on Epic difficulty.","Derrota una exploradora de la noche en dificultad Épica.","Derrote uma exploradora da noite na dificuldade Épica.","Besiege eine Waldläuferin der Nacht auf dem Schwierigkeitsgrad \"Epic\".","Bats un ranger de la nuit un difficulté Épique."],
         "icon":691
      };
      
      public static var darkmatt:Object = {
         "id":"darkmatt",
         "epic":true,
         "name":["Captain Of Death","Capitán de la Muerte","Capitão da Morte","Kapitän des Todes","Capitaine de la Mort"],
         "description":["Defeat an undead pirate on Epic difficulty.","Derrota un pirata no-muerto en dificultad Épica.","Derrote um pirata zumbi na dificuldade Épica.","Besiege einen untoten Piraten auf dem Schwierigkeitsgrad \"Epic\".","Bats un pirate revenu des morts en difficulté Épique."],
         "icon":690
      };
      
      public static var darknatalie:Object = {
         "id":"darknatalie",
         "epic":true,
         "name":["Dark Seductress","Seductora Oscura","Sedutora Obscura","Dunkle Verführerin","Sombre Séductrice"],
         "description":["Defeat a busty succubus on Epic difficulty.","Derrota una voluptuosa súcubo en dificultad Épica.","Derrote uma súcubus bem dotada na dificuldade Épica.","Besiege einen vollbusigen Sukkubus auf dem Schwierigkeitsgrad \"Epic\".","Bats un succube bien équipé en difficulté Épique."],
         "icon":689
      };
      
      public static var darklance:Object = {
         "id":"darklance",
         "epic":true,
         "name":["Fallen Comrade","Camarada Caído","Camarada Caído","Gefallener Kamerad","Tombé au Combat"],
         "description":["Defeat a zombie soldier on Epic difficulty.","Derrota un soldado zombi en dificultad Épica.","Derrote um soldado zumbi na dificuldade Épica.","Besiege einen Zombiesoldaten auf dem Schwierigkeitsgrad \"Epic\".","Bats un soldat zombi en difficulté Épique."],
         "icon":688
      };
      
      public static var t:Object = {
         "name":["","","","",""],
         "description":["","","","",""],
         "icon":0
      };
      
      public static var MEDALS:Array = [firstkill,monsterhunter,extinctionevent,starthegame,overkill,firstcasualty,stepoverthedead,lunchtime,tastepain,limitbreak,slimecat,slimecatking,lostruins,strength,cut,flash,rocksmash,ladder,pantythief,marathon,lava,powerup,keys,winteriscoming,burnbabyburn,waterconducts,deathpenalty,survivedeath,powerofcourage,bestcustomer,overpriced,statboost,blacksmith,equipmentcollector,suicidalattack,invadersfromspace,beastmaster,treasurehunter,keeneyes,millionaire,unkownpowerlevel,zoostudent,zooexpert,NPChelper,NPCservant,NPCslave,art,chicken,slimysituation,resistance,skilllearnt,skillfound,lumberjack,rockminer,electricalengineer,extremegardener,leethacker,catperson,pervert,enterashwood,entercaverns,entergraveyard,enterplant,enterjungle,entertemple,d300,d3k,d30k,d300k,d3m,fullparty,level11,level22,level33,level44,quest1,quest2,quest3,treasurethief,treasurecollector,eagleeyes,d30m,dressupgame,masterblacksmith,treewar,diamonds,hardwareupgrade,endoftherainbow,bossrush1,bossrush2,bossrush3,bossrush4,foerush,endlessbattles1,endlessbattles2,endlessbattles3,endlessbattles4,smashingpumpkins,mammothfeast,wormcontrol,loandbehold,dragonslayer,unprotected,darkanna,darknatalie,darkmatt,darklance];
      
      public static var MEDALS_DISPLAY:Array = [firstkill,monsterhunter,extinctionevent,starthegame,overkill,firstcasualty,stepoverthedead,lunchtime,tastepain,limitbreak,slimecat,slimecatking,lostruins,strength,cut,flash,rocksmash,ladder,pantythief,marathon,lava,powerup,keys,winteriscoming,burnbabyburn,waterconducts,deathpenalty,survivedeath,powerofcourage,bestcustomer,overpriced,statboost,blacksmith,dressupgame,masterblacksmith,equipmentcollector,suicidalattack,invadersfromspace,beastmaster,treasurethief,treasurecollector,treasurehunter,keeneyes,eagleeyes,millionaire,unkownpowerlevel,zoostudent,zooexpert,NPChelper,NPCservant,NPCslave,art,chicken,slimysituation,resistance,skilllearnt,skillfound,pervert,enterashwood,entercaverns,entergraveyard,enterplant,enterjungle,entertemple,d300,d3k,d30k,d300k,d3m,d30m,fullparty,level11,level22,level33,level44,quest1,quest2,quest3,wormcontrol,loandbehold,unprotected,dragonslayer,lumberjack,rockminer,electricalengineer,extremegardener,treewar,diamonds,hardwareupgrade,endoftherainbow,leethacker,darkanna,darknatalie,darkmatt,darklance,catperson,foerush,bossrush1,bossrush2,bossrush3,bossrush4,endlessbattles1,endlessbattles2,endlessbattles3];
       
      
      public function Medals()
      {
         super();
      }
      
      public static function saveMisc() : *
      {
         var a:Array;
         var b:Array;
         var i:int;
         var so:SharedObject = null;
         var data:Object = {};
         if(Options.enableSols)
         {
            so = SharedObject.getLocal("EBF4misc");
            data = so.data;
         }
         a = [];
         b = [];
         i = 0;
         while(i < MEDALS.length)
         {
            a[i] = MEDALS[i].unlocked;
            b[i] = MEDALS[i].aced;
            i++;
         }
         data.medals = a;
         data.aces = b;
         data.gallery = MainMenu.gallery;
         data.score = SaveData.endlessBattlesScore;
         data.title = MainMenu.title;
         if(Options.applicationFeatures && Main.messagesEnabled)
         {
            SaveData.exeSave = "medals";
            SaveData.convertDataToJSON(data,true,false,true);
         }
         try
         {
            if(Options.enableSols)
            {
               so.flush();
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public static function submitDataCallback(param1:Object) : void
      {
         if(!param1.success)
         {
         }
      }
      
      public static function loadOnlineMedals() : *
      {
      }
      
      public static function recieveDataCallback(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(Boolean(param1.success) && Boolean(param1.data))
         {
            _loc2_ = 0;
            while(_loc2_ < MEDALS.length)
            {
               MEDALS[_loc2_].unlocked = param1.data[_loc2_];
               _loc2_++;
            }
         }
      }
      
      public static function sendMedals() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         while(_loc2_ < MEDALS.length)
         {
            _loc1_[_loc2_] = MEDALS[_loc2_].unlocked;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function recieveMedals(param1:Array) : *
      {
         var _loc2_:int = 0;
         while(_loc2_ < MEDALS.length)
         {
            MEDALS[_loc2_].unlocked = param1[_loc2_];
            _loc2_++;
         }
      }
      
      public static function loadMisc(param1:Object = null) : *
      {
         var _loc2_:SharedObject = null;
         var _loc3_:Object = null;
         if(!param1)
         {
            _loc2_ = SharedObject.getLocal("EBF4misc");
         }
         if(param1)
         {
            _loc3_ = param1;
         }
         else
         {
            _loc3_ = _loc2_.data;
         }
         if(!_loc3_.medals)
         {
            MainMenu.gallery = false;
            MainMenu.title = 1;
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < MEDALS.length)
         {
            if(_loc3_.medals[_loc4_])
            {
               MEDALS[_loc4_].unlocked = true;
            }
            _loc4_++;
         }
         if(_loc3_.aces)
         {
            _loc4_ = 0;
            while(_loc4_ < MEDALS.length)
            {
               MEDALS[_loc4_].aced = _loc3_.aces[_loc4_];
               _loc4_++;
            }
         }
         MainMenu.gallery = _loc3_.gallery;
         SaveData.endlessBattlesScore = _loc3_.score;
         MainMenu.title = _loc3_.title;
      }
      
      public static function isAce() : Boolean
      {
         return !Options.cheatsOn() && Options.difficulty == Options.EPIC && Options.allChallenges();
      }
      
      public static function unlock(param1:Object) : *
      {
         if(Debug.trailerMode)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(Boolean(param1.epic) || Boolean(param1.acable))
         {
            if(isAce())
            {
               param1.aced = true;
               _loc2_ = true;
            }
         }
         if(!(Boolean(param1.unlocked) || param1.epic && Options.cheatsOn()))
         {
            param1.unlocked = true;
            try
            {
               Game.AP_medalUnlocked(param1.id);
            }
            catch(apErr:Error)
            {
            }
            Main.sendMessage("unlockMedal",param1.id);
            sendArmorMedals(param1);
            current = param1;
            Game.root.medalBox.gotoAndPlay(100);
            Game.root.medalBox.gotoAndPlay(2);
            Game.root.setChildIndex(Game.root.medalBox,Game.root.numChildren - 1);
            countMedals();
            _loc2_ = true;
         }
         if(_loc2_)
         {
            saveMisc();
         }
      }
      
      public static function strReplace(param1:String, param2:String, param3:String) : String
      {
         return param1.split(param2).join(param3);
      }
      
      public static function sendArmorMedals(param1:Object) : *
      {
         var med:Object = null;
         var medalName:String = null;
         var medal:Object = param1;
         if(Debug.armorGames)
         {
            try
            {
               for each(med in [chicken,fullparty,deathpenalty,blacksmith,NPChelper,keeneyes,level33,lostruins,treasurehunter,d3m,quest1,leethacker])
               {
                  if(medal == med)
                  {
                     medalName = strReplace(medal.name[0]," ","_");
                     medalName = strReplace(medalName,"\'","");
                     Main.armorQuests.achievements.submit({"key":medalName});
                     break;
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function countMedals() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 1;
         while(_loc2_ <= MEDALS.length)
         {
            if(MEDALS[_loc2_ - 1].unlocked)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function resetMedals() : *
      {
         var _loc2_:SharedObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < MEDALS.length)
         {
            MEDALS[_loc1_].unlocked = false;
            MEDALS[_loc1_].aced = false;
            _loc1_++;
         }
         try
         {
            _loc2_ = SharedObject.getLocal("EBF4misc");
            _loc2_.clear();
         }
         catch(e:Error)
         {
         }
         saveMisc();
      }
   }
}
