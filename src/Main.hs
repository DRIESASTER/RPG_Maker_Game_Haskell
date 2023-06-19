import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Game
import Graphics.Gloss.Juicy
import GHC.IO
import Renderer
import Global_vars
import GameManager
import Parser

main :: IO ()
main = do play window black fps initGame render handleInput step