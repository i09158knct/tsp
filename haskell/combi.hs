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
  --let route = [(37,52),(49,49),(52,64),(20,26),(40,30),(21,47),(17,63),(31,62),(52,33),(51,21),(42,41),(31,32),(5,25),(12,42),(36,16),(52,41),(27,23),(17,33),(13,13),(57,58),(62,42),(42,57),(16,57),(8,52),(7,38),(27,68),(30,48),(43,67),(58,48),(58,27),(37,69),(38,46),(46,10),(61,33),(62,63),(63,69),(32,22),(45,35),(59,15),(5,6),(10,17),(21,10),(5,64),(30,15),(39,10),(32,39),(25,32),(25,55),(48,28),(56,37),(30,40)]

  let swapList = take iterations $ mkRndPairs gen1 $ length route
  let tSchedule = take iterations $ buildTSchedule iniT n rate
  let randoms = take iterations $ randomRs (0.0, 1.0) gen2
  let list = zipWith (\s (t, r) -> (s,t,r)) swapList $ zip tSchedule randoms
  let (optimizedRoute, totalDsts@(totalDst:_)) = sa' route list
  let (optimizedRoute', totalDsts'@(totalDst':_)) = hillclimb optimizedRoute $ take 5000 swapList
  if getNeedDumpP args
  then do
    putStrLn $ "args: " ++ show args
    putStrLn $ "seed: " ++ show gen1
    putStrLn $ "n: " ++ show n
    putStrLn $ "c: " ++ show c
    putStrLn $ "ini_t: " ++ show iniT
    putStrLn $ "fin_t: " ++ show finT
    putStrLn $ "rate: " ++ show rate
    putStrLn $ "iterations: " ++ show iterations
  else return ()
  if getNeedDumpR args
  then do
    print $ reverse $ totalDsts' ++ totalDsts
    print totalDst
    print totalDst'
    print gen1
  else return ()

  if True
  then do putStrLn $ pShow optimizedRoute'
  else do main

sa' :: [Node] -> [( (Int, Int), Float, Float )] -> ([Node], [Float])
sa' route = foldl' anneal' (route, [totalDis route])

anneal' :: ([Node], [Float]) -> ( (Int, Int), Float, Float ) -> ([Node], [Float])
anneal' (route, td:tds) (swpNs, t, r) =
  if shouldBeChanged (newTd-td) t r
    then (newRoute, newTd:td:tds)
    else (route, td:td:tds)
  where newRoute = reverseBetween_51 swpNs route
        newTd = totalDis newRoute

shouldBeChanged d t r =
  if exp (-d / t) > r
    then True
    else False

shouldBeChanged' d t r
  | d <= 0 = True
  | otherwise = if exp (-d / t) > r
                then True
                else False

--reverseBetween_51 = reverseBetween 51
-- インライン化
reverseBetween_51 (i1, i2) ns
  | i2'==i1' || i2'-i1' == 1 || i1'-i2' == 50 = swapAt (i1', i2') ns
  | otherwise = reverseBetween_51 (i1'+1,i2'-1) $ swapAt (i1',i2') ns
  where i1' = i1 `mod` 51
        i2' = i2 `mod` 51

reverseBetween len (i1, i2) ns
  | i2'==i1' || i2'-i1' == 1 || i1'-i2' == len - 1 = swapAt (i1', i2') ns
  | otherwise = reverseBetween len (i1'+1,i2'-1) $ swapAt (i1',i2') ns
  where i1' = i1 `mod` len
        i2' = i2 `mod` len


