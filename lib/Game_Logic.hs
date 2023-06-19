module Game_Logic where


import Parser
import DataStructures
import Text.Parsec
import Text.Parsec.String (Parser)
import Game_maker
import Data.Maybe
import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Game
import Graphics.Gloss.Juicy
import GHC.IO
import Renderer
import Global_vars
import ExtraScreens (renderSelectScreen)

executeAction :: Game -> Action -> Game
executeAction game inputAction
    | idToString(functionId(action inputAction)) == "leave" = leave game
    | idToString(functionId(action inputAction)) == "retrieveItem" = retrieveItem game (argumentToString((functionArg(action inputAction)!!0)))
    | idToString(functionId(action inputAction)) == "increasePlayerHp" = increasePlayerHp game (argumentToString((functionArg(action inputAction)!!0)))
    | idToString(functionId(action inputAction)) == "decreaseHp" = decreaseHp game (argumentToString((functionArg(action inputAction)!!0))) (getItemValue (getInventoryItem (inventory (player game)) (argumentToString((functionArg(action inputAction)!!1)))))
    | idToString(functionId(action inputAction)) == "useItem" = useItem game (argumentToString((functionArg(action inputAction)!!0)))
    | otherwise = game

--leave 
leave :: Game -> Game
leave game
    | getPlayerPos (movePlayer game (0,1) Omhoog) /= getPlayerPos game = movePlayer game (0,1) Omhoog
    | getPlayerPos (movePlayer game (0,-1) Omlaag) /= getPlayerPos game = movePlayer game (0,-1) Omlaag
    | getPlayerPos (movePlayer game (1,0) Rechts) /= getPlayerPos game = movePlayer game (1,0) Rechts
    | getPlayerPos (movePlayer game (-1,0) Links) /= getPlayerPos game = movePlayer game (-1,0) Links
    | otherwise = game

--useItem, takes argument and then deletes entity
useItem :: Game -> String -> Game
useItem game itemId = (decreaseUseTimes game itemId){levels = [((levels game)!!0){entities = removeMaybeElFromList (entities (levels game !! 0)) (getEntityAt (levels game !! 0) (playerPos (head(levels game))))}] ++(drop 1 (levels game))}

--retrieveItem 
retrieveItem :: Game -> String -> Game
retrieveItem game itemId = addToInventory game (getItemAtwithID (items((levels game)!!0)) itemId (playerPos((levels game)!!0)))

addToInventory :: Game -> Maybe Item -> Game
addToInventory game Nothing = game
addToInventory game (Just item) = removeItem (game{player = (player game){inventory = (inventory (player game)) ++ [item]}}) item


--removes item from the playing field
removeItem :: Game -> Item -> Game
removeItem game item = game{levels = [removeItem' ((levels game)!!0) (itemPos item) (itemId item)] ++ (drop 1 (levels game))}

removeItem' :: Level -> (Integer, Integer) -> ID -> Level
removeItem' level (x,y) itemId  = level{items = removeItem'' (items level) (x,y) itemId 0}

removeItem'' :: [Item] -> (Integer, Integer) -> ID -> Int -> [Item]
removeItem'' [] _ _ _ = []
removeItem'' items (x1,y1) id index
    | itemPos (items!!index) == (x1,y1) && (itemId(items!!index)) == id = (take (index) items) ++ (drop (index+1) items)
    | otherwise = removeItem'' items (x1,y1) id (index+1)


--decreaseHp : attack entity
decreaseHp :: Game -> String -> Int -> Game
decreaseHp game enemyId dmg = decreaseHp' (getEntityAt (levels game !! 0) (playerPos (head(levels game)))) dmg game

decreaseHp' :: Maybe Entity -> Int -> Game -> Game
decreaseHp' (Just entity) dmg game 
    | not(entityIsDead entity) = game{levels = [(levels game !! 0){entities = [(decreaseEntityHp entity dmg)] ++ removeElFromList (entities (levels game !! 0)) (entity)}]}
    | otherwise = game{levels = [(levels game !! 0){entities = removeElFromList (entities (levels game !! 0)) (entity)}]}
decreaseHp' Nothing dmg game = game

decreaseEntityHp :: Entity -> Int -> Entity
decreaseEntityHp entity dmg = entity{entityHp = (entityHp entity) - (toInteger dmg)}

--checks if entity is dead
entityIsDead :: Entity -> Bool
entityIsDead entity = (entityHp entity) <= 0

--inceases player health via potion
increasePlayerHp :: Game -> String -> Game 
increasePlayerHp game potionId = decreaseUseTimes (increasePlayerHp' (getInventoryItem (inventory(player game)) potionId) game) potionId

increasePlayerHp' :: Maybe Item -> Game -> Game
increasePlayerHp' (Just item) game = game{player = (player game){playerHp = (playerHp (player game)) + (value item)}}
increasePlayerHp' Nothing game = game


--gets value of item from Maybe item
getItemValue :: Maybe Item -> Int
getItemValue (Just item) = fromInteger (value item)
getItemValue Nothing = 0

--gets entity at position (x,y)
getEntityAt :: Level -> (Int, Int) -> Maybe Entity
getEntityAt level (x,y) = getEntityAt' (entities level) (x,y)

getEntityAt' :: [Entity] -> (Int, Int) -> Maybe Entity
getEntityAt' [] _ = Nothing
getEntityAt' (x:xs) (x1,y1)
    | (x1-1) == fromInteger(fst (entityPos x)) && (y1-1) == fromInteger(snd (entityPos x)) = Just x
    | otherwise = getEntityAt' xs (x1,y1)

--decreaes useTimes from item in inventory with name itemId
decreaseUseTimes :: Game -> String -> Game
decreaseUseTimes game itemId = decreaseUseTimes' (getInventoryItem (inventory(player game)) itemId) game

decreaseUseTimes' :: Maybe Item -> Game -> Game
decreaseUseTimes' (Just item) game = game{player = (player game){inventory = (decreaseUseTimes'' (inventory(player game)) (item) 0)}}
decreaseUseTimes' Nothing game = game

decreaseUseTimes'' :: [Item] -> Item -> Int -> [Item]
decreaseUseTimes'' items item index
    | itemUsedUp (itemUse item) = removeItemFromInventory items 0 (idToString (itemId item))
    | otherwise = (removeItemFromInventory items 0 (idToString (itemId item))) ++ [item{itemUse = decreaseUseTimes''' (itemUse item)}]

decreaseUseTimes''' :: UseTimes -> UseTimes
decreaseUseTimes''' (Amount x) = Amount (x-1)
decreaseUseTimes''' (Infinite) = Infinite

--checks if item is used up
itemUsedUp :: UseTimes -> Bool
itemUsedUp (Amount 1) = True
itemUsedUp _ = False


--moves the player if possible
movePlayer :: Game -> (Int, Int) -> Richting -> Game
movePlayer game (x,y) dir = game{levels = [movePlayer' ((levels game)!!0) ((fst (playerPos((levels game)!!0)))+x) ((snd (playerPos((levels game)!!0)))+y) dir ] ++ (drop 1 (levels game))}


movePlayer' :: Level -> Int -> Int -> Richting -> Level
movePlayer' level x y dir
    | (canMove ((layout level)!!((length (layout level))-y-1)) x) && not(isDoor (entities level)  dir (playerPos level)) = level{playerPos = (x,y)}
    | otherwise = level

canMove :: TegelRij -> Int -> Bool
canMove (TegelRij rij) x
    | (rij!!x == Muur) = False
    | otherwise = True

isDoor :: [Entity] -> Richting -> (Int, Int) -> Bool
isDoor [] _ _ = False
isDoor (x:xs)  dir (ogX, ogY)
    | ((ogX-1) == fromInteger (fst (entityPos x))) && ((ogY-1) == fromInteger (snd (entityPos x))) && (idToString(entityId x) == "door") && (convertDoorDir(entityDir x)) == dir  = True
    | otherwise = isDoor xs dir (ogX, ogY)

--is needed because door art dir is different from player walking direction
convertDoorDir :: Richting -> Richting
convertDoorDir Omhoog = Omhoog
convertDoorDir Omlaag = Omlaag
convertDoorDir Links = Rechts
convertDoorDir Rechts = Links

--refreshes all possible actions
checkActions :: Game -> Game
checkActions game = game{gameActions = checkMetConditions((getEntityActions (getEntityAt ((levels game)!!0) (playerPos((levels game)!!0)))) ++ (getItemActions (getItemAt (items((levels game)!!0)) (playerPos((levels game)!!0))))) (inventory (player game)) 0}

getEntityActions :: Maybe Entity -> [Action]
getEntityActions Nothing = []
getEntityActions (Just entity) = entityActions entity

getItemActions :: Maybe Item -> [Action]
getItemActions Nothing = []
getItemActions (Just item) = itemActions item

getInventoryActions :: [Item] -> [Action]
getInventoryActions items = mergeActions [itemActions item | item <- items]

checkMetConditions :: [Action] -> [Item] -> Int -> [Action]
checkMetConditions actions inventory index
    | index == length actions = actions
    | (checkConditions (conditions(actions!!index)) inventory) = checkMetConditions actions inventory (index+1)
    | otherwise = checkMetConditions (((take (index) actions) ++ (drop (index+1) actions))) inventory index

checkConditions :: [Function] -> [Item] -> Bool
checkConditions [] _ = True
checkConditions (x:xs) inventory
    | checkCondition x inventory = checkConditions xs inventory
    | otherwise = False

checkCondition :: Function -> [Item] -> Bool
checkCondition (Function id args) inventory
    | idToString(id) == "not" = not (checkConditions [argumentToFunction arg | arg <- args] inventory)
    | idToString(id) == "inventoryFull" = (length inventory) > 5
    | idToString(id) == "inventoryContains" = inventoryContains (args!!0) inventory
    | otherwise = True

mergeActions :: [[Action]] -> [Action]
mergeActions [] = []
mergeActions (x:xs) = x ++ mergeActions xs


--gets item from inventory
getInventoryItem :: [Item] -> String -> Maybe Item
getInventoryItem [] _ = Nothing
getInventoryItem (x:xs) id
    | idToString(itemId x) == id = Just x
    | otherwise = getInventoryItem xs id


inventoryContains :: Argument -> [Item] -> Bool
inventoryContains (ArgId id) inventory = inventoryContains' (idToString(id)) inventory
inventoryContains (ArgFunction function) inventory = False

inventoryContains' :: String -> [Item] -> Bool
inventoryContains' _ [] = False
inventoryContains' id (x:xs)
    | idToString(itemId x) == id = True
    | otherwise = inventoryContains' id xs


argumentToFunction :: Argument -> Function
argumentToFunction (ArgId id) = Function id []
argumentToFunction (ArgFunction function) = function

removeItemFromInventory :: [Item] -> Int -> String -> [Item]
removeItemFromInventory [] _ _ = []
removeItemFromInventory inventory index id
    | idToString(itemId(inventory!!index)) == id = (take (index) inventory) ++ (drop (index+1) inventory)
    | otherwise = removeItemFromInventory inventory (index+1) id

--removes element from list
removeElFromList :: Eq a => [a] -> a -> [a]
removeElFromList [] _ = []
removeElFromList (x:xs) el
    | x == el = xs
    | otherwise = x : removeElFromList xs el

removeMaybeElFromList :: Eq a => [a] -> Maybe a -> [a]
removeMaybeElFromList [] _ = []
removeMaybeElFromList (x:xs) Nothing = x:xs
removeMaybeElFromList (x:xs) (Just el) = removeElFromList (x:xs) el


getItemAtwithID :: [Item] -> String -> (Int, Int) -> Maybe Item
getItemAtwithID [] _ _ = Nothing
getItemAtwithID (x:xs) id (x1,y1)
    | ((x1-1) == fromInteger (fst (itemPos x))) && ((y1-1) == fromInteger (snd (itemPos x))) && idToString(itemId x) == id = Just x
    | otherwise = getItemAtwithID xs id (x1,y1)

getItemAt [] _ = Nothing
getItemAt (x:xs) (x1,y1)
    | ((x1-1) == fromInteger (fst (itemPos x))) && ((y1-1) == fromInteger (snd (itemPos x))) = Just x
    | otherwise = getItemAt xs (x1,y1)

getPlayerPos :: Game -> (Int, Int)
getPlayerPos game = playerPos (head(levels game))