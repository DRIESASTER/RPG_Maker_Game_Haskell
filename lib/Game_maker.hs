module Game_maker where

import Parser
import DataStructures
import Text.Parsec
import Text.Parsec.String (Parser)
import Global_vars

findMaybePair :: ID -> [Pair] -> Maybe Pair
findMaybePair _ [] = Nothing
findMaybePair id ((Pair id2 json):xs)
    | id == id2 = Just (Pair id2 json)
    | otherwise = findMaybePair id xs

findPair :: ID -> [Pair] -> Pair
findPair id pairs = fromJust (findMaybePair id pairs)

fromJust :: Maybe Pair -> Pair
fromJust (Just pair) = pair
fromJust Nothing = Pair (ID "") (Object [])


fstPair :: Pair -> ID
fstPair (Pair id json) = id

sndPair :: Pair -> JSON
sndPair (Pair id json) = json

jsonToArray :: JSON -> [JSON]
jsonToArray (Array jsons) = jsons
jsonToArray _ = []

jsonToPair :: JSON -> [Pair]
jsonToPair (Object pairs) = pairs
jsonToPair _ = []


startGame :: Game -> JSON -> Game
startGame game (Object pairs) = game{levels = (createLevels pairs), player = (createPlayer (sndPair(findPair (ID "player") pairs)))}

createLevels :: [Pair] -> [Level]
createLevels pairs = do
    [createLevel level | level <- jsonToArray(sndPair(findPair (ID "levels") pairs))]

createLevel :: JSON -> Level
createLevel (Object pairs) = Level layout entities items (findTegel layout ((length layout)-1) Start) (findTegel layout ((length layout)-1) Einde)
    where layout = getLayout(sndPair(findPair (ID "layout") pairs))
          items = createItems(sndPair(findPair (ID "items") pairs))
          entities = createEnties(sndPair(findPair (ID "entities") pairs))

createPlayer :: JSON -> Player
createPlayer (Object pairs) = Player hp inventory 
    where hp = (jsonToInteger(sndPair(findPair (ID "hp") pairs)))
          inventory = createItems(sndPair(findPair (ID "inventory") pairs))


findTegel :: [TegelRij] -> Int -> Tegel -> (Int, Int)
findTegel layout y tegel
    | y == 0 = (0, 0)
    | (fst(containsTegel (layout!!y) 0 tegel)) == True = (snd(containsTegel (layout!!y) 0 tegel), ((length layout)-1-y))
    | otherwise = findTegel layout (y-1) tegel

containsTegel :: TegelRij -> Int -> Tegel -> (Bool, Int)
containsTegel (TegelRij tegels) x tegel
    | length tegels == x = (False, 0)
    | (tegels!!x) == tegel = (True, x)
    | otherwise = containsTegel (TegelRij tegels) (x+1) tegel


createItems :: JSON -> [Item]
createItems (Array items) = [createItem item | item <- items]

createItem :: JSON -> Item
createItem (Object pairs) = Item id pos descr name useTimes actions value
    where id = jsonToID(sndPair(findPair (ID "id") pairs))
          pos = (jsonToInteger((sndPair(findPair (ID "x") pairs))), jsonToInteger((sndPair(findPair (ID "y") pairs))))
          descr = jsonToString(sndPair(findPair (ID "description") pairs))
          name = jsonToString(sndPair(findPair (ID "name") pairs))
          useTimes = jsonToUseTimes(sndPair(findPair (ID "useTimes") pairs))
          value = jsonToInteger(sndPair(findPair (ID "value") pairs))
          actions = jsonToActions(sndPair(findPair (ID "actions") pairs))

createEnties :: JSON -> [Entity]
createEnties (Array entities) = [createEntity entity | entity <- entities]

createEntity :: JSON -> Entity
createEntity (Object pairs) = Entity id pos name descr actions hp value dir
    where id = jsonToID(sndPair(findPair (ID "id") pairs))
          pos = (jsonToInteger((sndPair(findPair (ID "x") pairs))), jsonToInteger((sndPair(findPair (ID "y") pairs))))
          descr = jsonToString(sndPair(findPair (ID "description") pairs))
          name = jsonToString(sndPair(findPair (ID "name") pairs))
          hp = jsonToInteger(sndPair(findPair (ID "hp") pairs))
          value = jsonToInteger(sndPair(findPair (ID "value") pairs))
          actions = jsonToActions(sndPair(findPair (ID "actions") pairs))
          dir = jsonToDir(sndPair(findPair (ID "direction") pairs))


jsonToActions :: JSON -> [Action]
jsonToActions (Actions actions) = actions

jsonToID :: JSON -> ID
jsonToID (String id) = ID id
jsonToIdD _ = ID ""

jsonToString :: JSON -> String
jsonToString (String string) = string
jsonToString _ = ""

jsonToInteger :: JSON -> Integer
jsonToInteger (Number integer) = integer
jsonToInteger _ = 0

-- jsonToDir :: JSON -> Richting
-- jsonToDir (String string)
--     | string == "Omlaag" = Omlaag
--     | string == "left" = Links
--     | string == "right" = Rechts
--     | otherwise = Links
jsonToDir (Richting richting)
    | richting == Omlaag = Omlaag
    | richting == Links = Links
    | richting == Rechts = Rechts
    | otherwise = Omhoog
jsonToDir _ = Omhoog

jsonToUseTimes :: JSON -> UseTimes
jsonToUseTimes (Number integer) = Amount integer
jsonToUseTimes (String string)
    | string == "infinite" = Infinite
    | otherwise = Amount 0
jsonToUseTimes _ = Amount 0


getLayout :: JSON -> [TegelRij]
getLayout (Layout layout) = layout
getLayout _ = []
