module ImageManager where

import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Game
import Graphics.Gloss.Juicy
import GHC.IO
import Data.Maybe
import DataStructures


tegelToString :: Tegel -> String
tegelToString tegel = case tegel of
    Vloer -> "floor"
    Muur -> "wall"
    Einde -> "end"
    Start -> "floor"
    otherwise -> "floor"

--map voor memory leak te vermijden
pictureMap :: [(String,Picture)]
pictureMap = [((img),(loadPicture img))|img <- ["player", "wall", "floor", "player", "end","devil", "dagger", "sword", "potion", "key", "door", "inventory", "scroll", "heart", "winscreen", "gameover"]]

loadPicture :: String -> Picture
loadPicture string = fromMaybe Blank (unsafePerformIO (loadJuicyPNG ("lib/game_art/" ++ string ++ ".png")))

lookupPicture :: String -> Picture
lookupPicture string = Data.Maybe.fromJust (lookup string pictureMap)