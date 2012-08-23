module Util
( toMapFromArgs
, getwara
, getOne
, readFOrGetC
, readFOrGetC'
, setGetOrGetStdGen
, setGetOrGetStdGen'
) where

import System.Random
import qualified Data.Map as Map


toMapFromArgs :: [String] -> Map.Map String String
toMapFromArgs = Map.fromList . map (formatting . splitOnCln)
  where splitOnCln = break (==':')
        formatting (k, _:v) = (k, v)

orrrr :: (b->a) -> a -> Maybe b -> a
orrrr _ def Nothing = def
orrrr f _ (Just a) = f a

getwara :: Read a => a -> Maybe String -> a
getwara = orrrr read

setGetOrGetStdGen :: Maybe String -> IO StdGen
setGetOrGetStdGen = orrrr (setAndGetStdGen . read) getStdGen
  where setAndGetStdGen specifiedGen = do setStdGen specifiedGen
                                          return specifiedGen

readFOrGetC :: Maybe String -> IO String
readFOrGetC = orrrr readFile getContents





getOne :: Read a => a -> String -> a
getOne def "" = def
getOne _ s    = read s

readFOrGetC' :: String -> IO String
readFOrGetC' "" = getContents
readFOrGetC' f  = readFile f

setGetOrGetStdGen' :: String -> IO StdGen
setGetOrGetStdGen' "" = getStdGen
setGetOrGetStdGen' s  = do setStdGen specifiedGen
                           return specifiedGen
  where specifiedGen = read s


