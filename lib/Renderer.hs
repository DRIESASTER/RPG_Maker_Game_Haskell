module Renderer where

import DataStructures
import Graphics.Gloss
import Graphics.Gloss.Juicy
import GHC.IO
import ExtraScreens
import Global_vars
import ImageManager


window :: Display
window = InWindow "RPG Maker" (width, height) windowPosition

render :: Game -> Picture
render game
    | status game == Playing = translate (0.0) moveEverythingDownScale (Pictures[renderLevel (levels game !! 0), renderInventory (player game), renderActions (gameActions game)])
    | status game == Won = renderWinScreen
    | status game == Lost = renderLoseScreen
    | status game == Select = (renderSelectScreen game)

renderInventory :: Player -> Picture
renderInventory player = Pictures[renderHp (playerHp player), renderActionBar, renderInventoryBar, Pictures[renderInventoryItem ((inventory player)!!x) x | x <- [0..(((length (inventory player)))-1)]]]

renderHp :: Integer -> Picture
renderHp hp = Pictures[renderHeart x | x <- [0..(div hp 10)]]

renderHeart :: Integer -> Picture
renderHeart x = (translate (-320.0+(heartSpacing * (fromInteger x))) (330.0) (lookupPicture ("heart")))

renderActionBar :: Picture
renderActionBar = (translate (-200.0) (100.0) (lookupPicture ("scroll")))

renderInventoryBar :: Picture
renderInventoryBar = (translate (fst inventoryAlignment) (snd inventoryAlignment) (lookupPicture ("inventory")))

renderInventoryItem :: Item -> Int -> Picture
renderInventoryItem item x =  (translate ((margins+3.0) + (fromInteger (toInteger x)*(inventorySpacing))) ((snd inventoryAlignment)-22) (scale (2.0) (2.0) (lookupPicture (idToString (itemId item)))))

renderLevel :: Level -> Picture
renderLevel level = Pictures[renderLayout (layout level), renderEntities (entities level), renderItems (items level), renderPlayer (playerPos level)]

renderItems :: [Item] -> Picture
renderItems items = Pictures[renderItem item | item <- items]

renderItem :: Item -> Picture
renderItem item = convertLevel (lookupPicture (idToString (itemId item))) ((fromInteger $ fst(itemPos item))+1) ((fromInteger $ snd(itemPos item))+1)

renderEntities :: [Entity] -> Picture
renderEntities entities = Pictures[renderEntity entity | entity <- entities]

renderEntity :: Entity -> Picture
renderEntity entity =  convertLevel ((rotateImage (lookupPicture (idToString (entityId entity))) (entityDir entity))) ((fromInteger $ fst(entityPos entity))+1) ((fromInteger $ snd(entityPos entity))+1)

rotateImage :: Picture -> Richting -> Picture
rotateImage pic Omhoog = pic
rotateImage pic Omlaag = rotate 180 pic
rotateImage pic Links = rotate 90 pic
rotateImage pic Rechts = rotate 270 pic


renderActions :: [Action] -> Picture
renderActions [] = Pictures[]
renderActions actions = Pictures[renderAction (actions!!x) x | x <- [0..((length actions)-1)]]

renderAction :: Action -> Int -> Picture
renderAction act x = translate (-300.0) (225.0-fromInteger((toInteger x)*35)) (scale (0.12) (0.12) (text ( (show (x+1)) ++ ") " ++ idToString(functionId(action act)) ++ "(" ++ (init(argumentsToString (functionArg(action act)))) ++ ")")))

argumentsToString :: [Argument] -> String
argumentsToString [] = ""
argumentsToString (x:xs) = (argumentToString x) ++ "," ++ (argumentsToString xs)

argumentToString :: Argument -> String
argumentToString (ArgId id) = idToString id
argumentToString _ = ""

renderPlayer :: (Int, Int) -> Picture
renderPlayer (x,y) = convertLevel (lookupPicture "player") x y

renderLayout :: [TegelRij] -> Picture
renderLayout layout = Pictures[renderTegelRij (layout!!y) ((length layout)-1-y) |  y <- [0..(length layout)-1]]

renderTegelRij :: TegelRij -> Int -> Picture
renderTegelRij (TegelRij tegels) y = Pictures[renderTegel (tegels!!x) x y | x <- [0..(length tegels)-1]]

renderTegel :: Tegel -> Int -> Int -> Picture
renderTegel tegel x y = convertLevel (lookupPicture (tegelToString tegel)) x y

convertLevel :: Picture -> Int -> Int-> Picture
convertLevel picture x y = scale imageScale imageScale (translate (fromIntegral x*15) (fromIntegral y*15) picture)

