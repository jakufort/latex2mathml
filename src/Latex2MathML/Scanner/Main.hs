module Latex2MathML.Scanner.Main (scan) where

import Data.Char (isDigit,isLetter)
import Data.List (elemIndex)
import Data.Maybe (fromJust)
import Latex2MathML.Utils.Definitions

scan :: String -> ([Token],String)
scan lst = tokenize (prepareInput lst "") '\n'

prepareInput :: String -> String -> String
prepareInput [] buffer = reverse buffer
prepareInput lst@(h:t) buffer
    | h == '%' = prepareInput (snd $ splitAt (fromJust (elemIndex '\n' lst) + 1) lst) buffer
--     | h == ' ' = prepareInput t buffer
    | null t = reverse ('\n':h:buffer)
    | otherwise = prepareInput t (h:buffer)

tokenize :: String -> Char -> ([Token],String)
tokenize [] _ = ([],[])
tokenize lst@(h:t) stopSign
    | h == stopSign = ([],t)
    | h == '\\' = iterateOver readCommand t stopSign
    | h == ' ' || h == '\n' = tokenize t stopSign
    | h == '^' = iterateOver readSup t stopSign
    | h == '_' = iterateOver readSub t stopSign
    | isDigit h = iterateOver readNumber lst stopSign
    | h `elem` operators =
        let tmp = tokenize t stopSign
        in (Operator h : fst tmp,snd tmp)
    | isLetter h = iterateOver readString lst stopSign
    | otherwise = ([],lst)

iterateOver :: (t -> String -> (Token,String)) -> t -> Char -> ([Token],String)
iterateOver function lst stopSign
    | fst tmp == ComplexEnd = ([],snd tmp)
    | otherwise = (fst tmp : fst tmp2,snd tmp2)
    where tmp = function lst ""
          tmp2 = tokenize (snd tmp) stopSign

readString :: String -> String -> (Token,String)
readString [] [] = (End,[])
readString [] buffer = (MyStr $ reverse buffer,[])
readString (h:t) ""
    | h `elem` "ABEZHIKMNOoTX" = (CommandBodyless [h],t)
readString lst@(h:t) buffer
    | h `elem` "ABEZHIKMNOoTX" = (MyStr $ reverse buffer,lst)
    | isLetter h = readString t (h:buffer)
    | otherwise = (MyStr $ reverse buffer,lst)

readNumber :: String -> String -> (Token,String)
readNumber [] [] = (End,[])
readNumber [] buffer = (MyNum $ reverse buffer,[])
readNumber lst@(h:t) buffer
    | isDigit h || h == '.' = readNumber t (h:buffer)
    | otherwise = (MyNum $ reverse buffer,lst)

readCommand :: String -> String -> (Token,String)
readCommand [] [] = (End,[])
readCommand [] buffer = (CommandBodyless $ reverse buffer,[])
readCommand (h:t) ""
    | h `elem` "{[" = (Operator h,t)
    | h == '\\' = (Operator '\n',t)
    | otherwise = readCommand t [h]
readCommand lst@(h:t) buffer
    | null lst || (h `elem` " }()_^\\" && buffer /= "") = (CommandBodyless $ reverse buffer,lst)
    | (h == '{' || h == '[') && ("begin" == reverse buffer) = readComplexCommand lst
    | h == '{' && ("end" == reverse buffer) = (ComplexEnd,snd $ splitAt (fromJust (elemIndex '}' lst)+1) lst)
    | h == '{' || h == '[' = readInlineCommand (reverse buffer) lst
    | otherwise = readCommand t (h:buffer)

readCommandBody :: String -> ([[Token]],String)
readCommandBody ('{':t) =
    let tmp = tokenize t '}'
        tmp2 = readCommandBody (snd tmp)
    in (fst tmp : fst tmp2,snd tmp2)
readCommandBody lst = ([],lst)

readInlineCommand :: String -> String -> (Token,String)
readInlineCommand name lst =
    let par = readParameters lst
        body = readCommandBody (snd par)
    in (InlineCommand name (fst par) (fst body),snd body)

readParameters :: String -> ([Token],String)
readParameters ('[':t) = tokenize t ']'
readParameters lst = ([],lst)

readComplexCommand :: String -> (Token,String)
readComplexCommand [] = (End,[])
readComplexCommand lst
    | isComplexCommand commName =
        let par = readParameters rest
            tmp = tokenize (snd par) '}'
        in (ComplexCommand commName (fst par) (fst tmp),snd tmp)
    where ([[MyStr commName]],rest) = readCommandBody lst

isComplexCommand :: String -> Bool
isComplexCommand comm = comm `elem` ["matrix","table","array"]

readSup :: String -> String -> (Token,String)
readSup lst _ = readSupOrSub lst Sup

readSub :: String -> String -> (Token,String)
readSub lst _ = readSupOrSub lst Sub

readSupOrSub lst@(h:t) type'
    | h == '{' = runTokenizer t '}' [] type'
    | h == '\\' = runTokenizer lst ' ' [] type'
    | otherwise = runTokenizer [h] ' ' t type'

runTokenizer :: String -> Char -> String -> ([Token] -> Token) -> (Token,String)
runTokenizer lst stopSign [] type' =
    let tmp = tokenize lst stopSign
    in (type' (fst tmp),snd tmp)
runTokenizer lst stopSign returnList type' =
    let tmp = tokenize lst stopSign
    in (type' (fst tmp),returnList)

operators :: String
operators = "+-*/=!():<>|[]&\n,.'"