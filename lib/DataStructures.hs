module DataStructures where

data JSON = Number Integer | String String | Object [Pair] | Array [JSON] | Actions [Action] | Layout [TegelRij] | Richting Richting | UseTimes UseTimes deriving (Show, Eq);

data ID = ID String  deriving (Show, Eq);
data Pair = Pair ID JSON deriving (Show, Eq);

data Function = Function {
    functionId :: ID,
    functionArg :: [Argument] 
} deriving (Show, Eq);

data Action = Action{
    conditions :: [Function],
    action :: Function
} deriving (Show, Eq);

data Argument = ArgId ID | ArgFunction Function deriving (Show, Eq);

data UseTimes = Amount Integer | Infinite deriving (Show, Eq);

data TegelRij = TegelRij [Tegel] deriving (Show, Eq);

data Tegel = Muur | Vloer | Start | Einde | Leeg 
    deriving (Show, Eq);

data Richting = Omhoog | Omlaag | Links | Rechts deriving (Show, Eq);

data Entity = Entity {
    entityId :: ID,
    entityPos :: (Integer, Integer),
    entityName :: String,
    entitydescr :: String,
    entityActions :: [Action],
    entityHp :: Integer,
    entityValue :: Integer,
    entityDir :: Richting
} deriving (Show, Eq);

--entities get initialized in level but are stored in game
data Game = Game {
    levels :: [Level],
    player :: Player,
    gameActions :: [Action],
    attackCounter :: Int,
    status :: GameStatus,
    selectorPos :: Integer,
    currentFile :: String
} deriving (Show, Eq);

data GameStatus = Playing | Won | Select | Lost deriving (Show, Eq);

data Player = Player {
    playerHp :: Integer,
    inventory :: [Item]
} deriving (Show, Eq);

data Level = Level {
    layout :: [TegelRij],
    entities :: [Entity],
    items :: [Item],
    playerPos :: (Int, Int),
    exit :: (Int, Int)
} deriving (Show, Eq);

data Item = Item {
    itemId :: ID,
    itemPos :: (Integer, Integer),
    itemName :: String,
    itemdescr :: String,
    itemUse :: UseTimes,
    itemActions :: [Action],
    value :: Integer
} deriving (Show, Eq);