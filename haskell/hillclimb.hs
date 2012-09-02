import System.Environment
import System.Random
import TravelingSalesmanTool
import TspDataParser
import Util

type Node = (Float, Float)
_DEFAULT_ITERATIONS = 10000

main = do
  arg_f:arg_i:arg_stdGen:_ <- fmap (++ cycle [""]) getArgs
  let iterations = getOne _DEFAULT_ITERATIONS arg_i
  text <- readFOrGetC' arg_f
  gen <- setGetOrGetStdGen' arg_stdGen

  let route = toNodes text
  let swapList = take iterations $ mkRndPairs gen $ length route
  let (optimizedRoute, tds@(td:_)) = hillclimb route swapList

  print $ reverse tds
  print td
  print gen
  print $ toJson optimizedRoute

