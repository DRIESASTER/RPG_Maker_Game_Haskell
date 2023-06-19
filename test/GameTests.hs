import Test.Hspec
import DataStructures
import Game_Logic
import GameManager


layout1 :: [TegelRij]
layout1 = [(TegelRij [Muur, Muur, Muur, Muur, Muur]), (TegelRij[Muur, Vloer, Vloer, Vloer, Muur]), (TegelRij[Muur, Start, Vloer, Vloer, Einde]), (TegelRij[Muur, Muur, Muur, Muur, Muur])]

items1 :: [Item]
items1 = [Item {itemId = ID "key", itemPos = (0,0), itemName = "Deze sleutel kan een deur openen", itemdescr = "Sleutel", itemUse = Amount 1, itemActions = [Action {conditions = [Function {functionId = ID "not", functionArg = [ArgFunction (Function {functionId = ID "inventoryFull", functionArg = [ArgId (ID "")]})]}], action = Function {functionId = ID "retrieveItem", functionArg = [ArgId (ID "key")]}},Action {conditions = [], action = Function {functionId = ID "leave", functionArg = [ArgId (ID "")]}}], value = 0}]

initGame :: Game
initGame = Game [Level layout1 [] items1 (1,1) (1,4)] (Player 100 []) [] 0 Playing 0 ""

fullInventory :: Game
fullInventory = Game [Level layout1 [] items1 (1,1) (1,4)] (Player 100 fullInventory') [] 0 Playing 0 ""

fullInventory' :: [Item]
fullInventory' = take 6 (repeat (Item {itemId = ID "key", itemPos = (0,0), itemName = "Deze sleutel kan een deur openen", itemdescr = "Sleutel", itemUse = Amount 1, itemActions = [Action {conditions = [Function {functionId = ID "not", functionArg = [ArgFunction (Function {functionId = ID "inventoryFull", functionArg = [ArgId (ID "")]})]}], action = Function {functionId = ID "retrieveItem", functionArg = [ArgId (ID "key")]}},Action {conditions = [], action = Function {functionId = ID "leave", functionArg = [ArgId (ID "")]}}], value = 0}))

exitCheckGame :: Game
exitCheckGame = Game [Level layout1 [] items1 (4,1) (4,1)] (Player 100 []) [] 0 Playing 0 ""

enemyGame :: Game 
enemyGame = Game [Level layout1 [entityDevil] [] (2,2) (1,4)] (Player 100 []) [] 0 Playing 0 ""

entityDevil :: Entity
entityDevil = Entity {entityId = ID "devil", entityPos = (2,1), entityName = "Deze duivel kan je leven kosten", entitydescr = "Duivel", entityActions = [], entityHp = 100, entityValue = 30, entityDir = Omhoog}

main :: IO ()
main = hspec $ do
    --test playerMove system
    it "should return a moved player" $ do
        (playerPos((levels(movePlayer initGame (0,1) Omhoog))!!0)) `shouldBe` (1,2)
    it "should not move player" $ do
        (playerPos((levels(movePlayer initGame (0,-1) Omlaag))!!0)) `shouldBe` (1,1)
    it "should not move player" $ do
        (playerPos((levels(movePlayer initGame (-1,0) Links))!!0)) `shouldBe` (1,1)
    it "should return a moved player" $ do
        (playerPos((levels(movePlayer initGame (1,0) Rechts))!!0)) `shouldBe` (2,1)
    --test checkActions system
    it "should detect retrieveItem() and leave()" $ do
        gameActions(checkActions initGame)  `shouldBe` [Action {conditions = [Function {functionId = ID "not", functionArg = [ArgFunction (Function {functionId = ID "inventoryFull", functionArg = [ArgId (ID "")]})]}], action = Function {functionId = ID "retrieveItem", functionArg = [ArgId (ID "key")]}},Action {conditions = [], action = Function {functionId = ID "leave", functionArg = [ArgId (ID "")]}}]
        
    it "should detect inventoryFull() and not retrieveItem()" $ do
        gameActions(checkActions fullInventory)  `shouldBe` [Action {conditions = [], action = Function {functionId = ID "leave", functionArg = [ArgId (ID "")]}}]
    --test removeItem system
    it "should remove item from level" $ do
        (items((levels(removeItem initGame (items1!!0)))!!0)) `shouldBe` []
    --test exit check system
    it "should return a game with a new level" $ do
        (status(checkExit exitCheckGame)) `shouldBe` Won
    --test attack system (enemies)
    it "should lower player hp by entityValue" $ do
        (playerHp(player(attackEnemies enemyGame))) `shouldBe` 70
