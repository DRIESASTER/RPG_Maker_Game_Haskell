module Global_vars where 

import DataStructures

--height of window
height :: Int
height = 800

--width of window
width :: Int
width = 800

fps :: Int
fps = 60

imageScale :: Float
imageScale = 3

margins :: Float
margins = 15.0

inventorySpacing :: Float
inventorySpacing = 55.0

heartSpacing :: Float
heartSpacing = 45.0

inventoryAlignment :: (Float, Float)
inventoryAlignment = (160.0, -40.0)

moveEverythingDownScale :: Float
moveEverythingDownScale = -100.0

windowPosition :: (Int, Int)
windowPosition = (200,200)

initGame :: Game
initGame = Game [] (Player 0 []) [] 0 Select 0 ""

idToString :: ID -> String
idToString (ID string) = string