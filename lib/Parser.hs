module Parser where

import GHC.Generics (Par1)
import Text.Printf (HPrintfType)
import Text.Parsec
import Text.Parsec.String (Parser)
import DataStructures
--src https://www.adrians-blog.com/2020/12/08/building-a-json-parser-in-20-lines-of-code-haskell-parsec/
--ik heb een groot deel inspiratie van de bovenstaande bron opgedaan

--algemene parsers
parseJSON :: Parser JSON
parseJSON =parseNumber <|> parseString <|> parseArray <|> parseObject <|> parseActions <|> parseLayout <|> parseLevel <|> parseUsetimes

parseLevel :: Parser JSON
parseLevel = Object <$> (whitespace *> many1 parsePair <* whitespace)

parseObject :: Parser JSON
parseObject = Object <$> ( whitespace *> char '{' *> whitespace *> sepBy parsePair (char ',') <* whitespace <*char '}' <* whitespace)

parseObjID :: Parser ID
parseObjID = ID <$> (whitespace *> many1 letter <* whitespace)

parsePair :: Parser Pair
parsePair = do
    name <- parseObjID
    let parseValue = case name of
            ID "layout" -> parseLayout
            ID "actions" -> parseActions
            ID "direction" -> parseRichting
            ID "useTimes" -> parseUsetimes
            _ -> parseJSON
    Pair name <$> (whitespace >> char ':' >> whitespace >> parseValue <* whitespace)

parseNumber :: Parser JSON
parseNumber =  Number . read <$> many1 digit <* whitespace

parseString :: Parser JSON
parseString = String <$> (char '"' *> many1 (letter <|> space) <* char '"')

parseArray :: Parser JSON
parseArray = Array <$> (char '[' *> whitespace *> sepBy parseJSON (char ',') <* whitespace <* char ']')


--richting
parseRichting :: Parser JSON
parseRichting =  Richting <$> (Omhoog <$ try (string "up") <|> Omlaag <$ try (string "down") <|> Links <$ try (string "left") <|> Rechts <$ try (string "right"))

--actions
parseFunction :: Parser Function
parseFunction = whitespace *> parseObjID >>= \name -> Function name <$> (char '(' *> sepBy parseArg (char ',') <* char ')' <*whitespace)

parseArg :: Parser Argument
parseArg = try parseArgFunction <|> try parseArgId

parseArgFunction :: Parser Argument
parseArgFunction = ArgFunction <$> parseFunction

parseArgId :: Parser Argument
parseArgId = ArgId . ID <$> (whitespace *> many alphaNum <* whitespace)

parseAction :: Parser Action
parseAction = do 
        conditions <- whitespace *> char '[' *> sepBy parseFunction (char ',') <* char ']' <* whitespace
        Action conditions <$> (whitespace *>parseFunction <* whitespace)


parseActions :: Parser JSON
parseActions = do
        actions <- (whitespace *> char '{' *> whitespace *> sepBy parseAction (char ',') <* whitespace <* char '}' <* whitespace)
        return $ Actions actions


--usetimes
parseUsetimes :: Parser JSON
parseUsetimes = whitespace *>(parseAmount <|> parseUnlimited) <* whitespace

parseAmount :: Parser JSON
parseAmount = parseNumber

parseUnlimited :: Parser JSON
parseUnlimited = UseTimes <$> (whitespace *>( string "infinite" *> return Infinite) <* whitespace)


--layout
parseLayout :: Parser JSON
parseLayout = do
        layout <- (whitespace *> char '{' *> whitespace *> char '|' *> whitespace *> sepBy parseTegelRij (char '|') <* whitespace <* char '}' <* whitespace)
        return $ Layout layout


parseTegelRij :: Parser TegelRij
parseTegelRij = TegelRij <$> (whitespace *> sepBy parseTegel (char ' ') <* whitespace)

parseTegel :: Parser Tegel
parseTegel = do 
    tegel <- parseMuur <|> parseLeeg <|> parseVloer <|> parseStart <|> parseEinde
    return tegel

parseMuur :: Parser Tegel
parseMuur = char '*' *> return Muur

parseLeeg :: Parser Tegel
parseLeeg = char 'x' *> return Leeg

parseVloer :: Parser Tegel
parseVloer = char '.' *> return Vloer

parseStart :: Parser Tegel
parseStart = char 's' *> return Start

parseEinde :: Parser Tegel
parseEinde = char 'e' *> return Einde

--skip whitespace
whitespace :: Parser ()
whitespace = skipMany (oneOf " \t\n")