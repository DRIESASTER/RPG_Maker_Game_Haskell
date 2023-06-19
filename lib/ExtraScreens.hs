module ExtraScreens where

import DataStructures
import Text.Parsec
import Text.Parsec.String (Parser)
import Game_maker
import Data.Maybe
import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Game
import Graphics.Gloss.Juicy
import GHC.IO
import System.Directory
import Data.List(sort)
import ImageManager
import Global_vars


levelFolder :: String 
levelFolder = "levels"

levelFiles :: [String]
levelFiles = sort findLevelFiles

returnText :: Picture 
returnText = Color white (translate (-290.0) (-300.0) (scale 0.25 0.25 (text "Press enter to return to level select")))

restartText :: Picture 
restartText = Color white (translate (-250.0) (-300.0) (scale 0.25 0.25 (text "Press enter to restart the level")))

--makes sure that the possible levels are centered on the screen
centerScreenMargins :: Float
centerScreenMargins =  (fromInteger(toInteger(height)))/(fromInteger(toInteger(length levelFiles)+1))

renderSelectScreen ::Game -> Picture
renderSelectScreen game = Pictures ([renderLevelFile (levelFiles!!x) (toInteger x) | x <- [0..((length levelFiles)-1)]] ++ [renderSelector (selectorPos game)])

renderWinScreen :: Picture
renderWinScreen = Pictures [lookupPicture ("winscreen"), returnText]

renderLoseScreen :: Picture
renderLoseScreen = Pictures [lookupPicture ("gameover"), restartText]

renderLevelFile :: String -> Integer -> Picture
renderLevelFile levelFile x = Color white (translate (-70.0) (centerScreenMargins - (fromIntegral x * 80.0)) (scale 0.5 0.5 (text (getLevelName levelFile) )))

getLevelName :: String -> String
getLevelName [] = []
getLevelName level =  init $ fst (splitAt (findChar (snd(splitAt (findChar level '/') level)) '.') (snd(splitAt (findChar level '/') level)))

renderSelector :: Integer -> Picture
renderSelector x = Color white (translate (-140.0) (centerScreenMargins + 10 - (fromIntegral x * 80.0)) (scale 0.25 0.25 (text ">>")))

findChar :: String -> Char -> Int
findChar [] char = 0
findChar (x:xs) char
    | x == char = 1
    | otherwise = 1 + findChar xs char


findLevelFiles :: [String]
findLevelFiles = unsafePerformIO $ do
    levels <- (getDirectoryContents levelFolder)
    return $ map (\f -> levelFolder ++ "/" ++ f) $ filter (\x -> getExtension x == "txt") levels

getExtension :: String -> String
getExtension [] = []
getExtension (x:xs)
    | x == '.' = xs
    | otherwise = getExtension xs







