module GameManager where

import Parser
import DataStructures
import Text.Parsec
import Text.Parsec.String (Parser)
import Game_maker
import Graphics.Gloss.Interface.IO.Game
import GHC.IO
import Renderer
import Game_Logic
import ExtraScreens
import Global_vars
import Game_maker (startGame)
import DataStructures (Game)

enemyAttackTime :: Int
enemyAttackTime = 60

handleInput :: Event -> Game -> Game
handleInput ev game
    | status game == Playing = handleInputPlaying ev game
    | status game == Select = handleInputSelect ev game
    | status game == Lost = handleInputGameOverScreen ev game
    | otherwise = handleInputWinScreen ev game

handleInputPlaying :: Event -> Game -> Game
handleInputPlaying ev game
    | isKey KeyUp ev = nextGame (movePlayer game (0,1) Omhoog)
    | isKey KeyLeft ev = nextGame (movePlayer game (-1,0) Links)
    | isKey KeyRight ev = nextGame (movePlayer game (1,0) Rechts)
    | isKey KeyDown ev = nextGame (movePlayer game (0,-1) Omlaag)
    | isNumber ev && read (getNumber ev)<=length (gameActions  game) = nextGame (executeAction game ((gameActions game)!!((read (getNumber ev))-1)))
    | otherwise = game

handleInputSelect :: Event -> Game -> Game
handleInputSelect ev game
    | isKey KeyUp ev && (selectorPos game) > 0 = game{selectorPos = (selectorPos game)-1}
    | isKey KeyDown ev && (selectorPos game) + 1 < toInteger(length (levelFiles)) = game{selectorPos = (selectorPos game)+1}
    | isKey KeyEnter ev = playFile game (levelFiles!!(fromInteger (selectorPos game)))
    | otherwise = game

--handles input for game over or win screen
handleInputWinScreen :: Event -> Game -> Game
handleInputWinScreen ev game
    | isKey KeyEnter ev = game{status = Select}
    | otherwise = game

handleInputGameOverScreen :: Event -> Game -> Game
handleInputGameOverScreen ev game
    | isKey KeyEnter ev = playFile game (currentFile game)
    | otherwise = game


playFile :: Game -> String -> Game
playFile game file = checkActions ((unsafePerformIO(parseFile file)){status = Playing, currentFile = file})

-- Hulpfunctie die nagaat of een bepaalde toets is ingedrukt.
isKey :: SpecialKey -> Event -> Bool
isKey k1 (EventKey (SpecialKey k2) Down _ _) = k1 == k2
isKey _  _                                   = False

isCharKey :: Char -> Event -> Bool
isCharKey k1 (EventKey (Char k2) Down _ _) = k1 == k2
isCharKey _  _                                   = False

isNumber :: Event -> Bool
isNumber (EventKey (Char k) Down _ _) = k `elem` ['0'..'9']
isNumber _ = False

getNumber :: Event -> String
getNumber (EventKey (Char k) Down _ _) = [k]

getNumberInt :: Event -> Int
getNumberInt ev = read (getNumber ev)

step :: Float -> Game -> Game
step _ game
    | (status game) == Playing && playerHp (player game) <= 0 = game{status = Lost}
    | (attackCounter game) >= enemyAttackTime = attackEnemies game{attackCounter = 0}
    | otherwise = game{attackCounter = (attackCounter game)+1}

nextGame :: Game -> Game
nextGame game = checkExit (checkActions game)

--check voor exit
checkExit :: Game -> Game
checkExit game
    |exit ((levels game)!!0) == playerPos ((levels game)!!0) = nextLevel game
    |otherwise = game

--go to next level or end game
nextLevel :: Game -> Game
nextLevel game
    |(length (levels game)) == 1 = game{status = Won}
    |otherwise = game{levels = (drop 1 (levels game))}

--alle entities in de radius van de speler vallen de speler aan
attackEnemies :: Game -> Game
attackEnemies game = game{player = (player game){playerHp = (playerHp (player game)) - (sum [attack (getEntityAt ((levels game)!!0) pos)| pos <- positions])}} where positions = getRadius (playerPos ((levels game)!!0))

attack :: Maybe Entity -> Integer
attack Nothing = 0
attack (Just entity) = entityValue entity

getRadius :: (Int, Int) -> [(Int, Int)]
getRadius (x,y) = [(x+1,y),(x-1,y),(x,y+1),(x,y-1), (x,y)]

parseFile :: String -> IO Game
parseFile file = do
    file <- readFile file
    let json = parse parseJSON "" file
    case json of
        Left err -> do
            print err
            return initGame
        Right json -> do
            let game = startGame initGame json
            return game