import qualified Data.Map as Map
import System.Environment (getArgs)
import Data.List (foldl')
import System.Random
import TravelingSalesmanTool
import TspDataParser
import Util

type Node = (Float, Float)

_DEFAULT_N = 1000
_DEFAULT_C = 100
_DEFAULT_INI_T = 100
_DEFAULT_FIN_T = 0.8
_DEFAULT_FORMAT = "other"
_DEFAULT_DUMP = True
_DEFAULT_DUMP_RESULTS = _DEFAULT_DUMP
_DEFAULT_DUMP_PRMS = _DEFAULT_DUMP

getN = getwara _DEFAULT_N . Map.lookup "n"
getC = getwara _DEFAULT_C . Map.lookup "c"
getIniT = getwara _DEFAULT_INI_T . Map.lookup "ini_t"
getFinT = getwara _DEFAULT_FIN_T . Map.lookup "fin_t"
getAndSetStdGen = setGetOrGetStdGen . Map.lookup "seed"
getText = readFOrGetC . Map.lookup "file"
getNeedDumpR = getwara _DEFAULT_DUMP_RESULTS . Map.lookup "dump-results"
getNeedDumpP = getwara _DEFAULT_DUMP_PRMS . Map.lookup "dump-params"
getFormat = parse . Map.lookup "format"
  where parse Nothing = _DEFAULT_FORMAT
        parse (Just f) = f

main = do
  args <- fmap toMapFromArgs getArgs
  let n = getN args
  let c = getC args
  let iniT = getIniT args
  let finT = getFinT args

  let rate = (finT/iniT) ** (1 / fromIntegral c)
  let iterations = n * c

  gen1 <- getAndSetStdGen args
  gen2 <- newStdGen

  text <- getText args
  let (pParse, pShow) = if getFormat args == "json"
                        then (toNodesFromJson, toJson)
                        else (toNodes, ppNodes)

  let route = pParse text
  let swapList = take iterations $ mkRndPairs gen1 $ length route
  let tSchedule = take iterations $ buildTSchedule iniT n rate
  let randoms = take iterations $ randomRs (0.0, 1.0) gen2
  let list = zipWith (\s (t, r) -> (s,t,r)) swapList $ zip tSchedule randoms
  let (optimizedRoute, tds@(td:_)) = sa route list
  if getNeedDumpP args
  then do
    putStrLn $ "args: " ++ show args
    putStrLn $ "seed: " ++ show gen1
    putStrLn $ "n: " ++ show n
    putStrLn $ "c: " ++ show c
    putStrLn $ "iniz_t: " ++ show iniT
    putStrLn $ "fin_t: " ++ show finT
    putStrLn $ "rate: " ++ show rate
    putStrLn $ "iterations: " ++ show iterations
  else return ()
  if getNeedDumpR args
  then do
    print $ reverse tds
    print td
  else return ()
  print $ pShow optimizedRoute

