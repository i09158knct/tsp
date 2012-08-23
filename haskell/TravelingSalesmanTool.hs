module TravelingSalesmanTool
( dis
, totalDis
, swap
, swapAt
, mkRndPairs
, hillclimb
, buildTSchedule
, sa
) where

import System.Random
import Data.List


type Node = (Float, Float)


sa :: [Node] -> [( (Int, Int), Float, Float )] -> ([Node], [Float])
sa route = foldl' anneal (route, [totalDis route])

anneal :: ([Node], [Float]) -> ( (Int, Int), Float, Float ) -> ([Node], [Float])
anneal (route, td:tds) (swpNs, t, r)
  | dTd <= 0 = (newRoute, newTd:td:tds)
  | otherwise = if exp (-dTd / t) > r
                then (newRoute, newTd:td:tds)
                else (route, td:td:tds)
  where newRoute = swapAt swpNs route
        newTd = totalDis newRoute
        dTd = newTd - td

buildTSchedule :: Float -> Int -> Float -> [Float]
buildTSchedule t0 n coolingRate = concat $ map (replicate n) (geo t0)
  where geo a0 = a0:geo (a0 * coolingRate)


hillclimb :: [Node] -> [(Int, Int)] -> ([Node], [Float])
hillclimb route = foldl' climb (route, [totalDis route])

climb :: ([Node], [Float]) -> (Int, Int) -> ([Node], [Float])
climb (route, td:tds) swpNs
  | newTd < td = (newRoute, newTd:td:tds)
  | otherwise = (route, td:td:tds)
  where newRoute = swapAt swpNs route
        newTd = totalDis newRoute


hillclimb_old :: [Node] -> [(Int, Int)] -> [Node]
hillclimb_old = foldl climb
  where climb route swpNs = let newRoute = swapAt swpNs route
                            in if totalDis newRoute < totalDis route
                               then newRoute
                               else route

hillclimb_old' :: [Node] -> [(Int, Int)] -> ([Node], Float)
hillclimb_old' route = foldl climb (route, totalDis route)
  where climb (route, td) swpNs = let newRoute = swapAt swpNs route
                                      newTd = totalDis newRoute
                                  in if newTd < td
                                     then (newRoute, newTd)
                                     else (route, td)

mkRndPairs :: StdGen -> Int -> [(Int, Int)]
mkRndPairs seed len = (v1, v2):mkRndPairs gen2 len
  where mkRnd = randomR (0, len-1)
        (v1, gen1) = mkRnd seed
        (v2, gen2) = mkRnd gen1


swapAt :: Eq a => (Int, Int) -> [a] -> [a]
swapAt (i1, i2) ns = swap (ns !! i1) (ns !! i2) ns



-- 指定したnodeのうちの片方しかnodesに無い場合、
--「有る方のnodeを無い方のnodeで置き換える」というややこしい動作ができてしまう
-- 正しい使い方は「nodesのn1とn2の位置を交換する」
swap :: Eq a => a -> a -> [a] -> [a]
swap _ _ [] = []
swap n1 n2 (n:ns)
  | n1==n = n2:swap n1 n2 ns
  | n2==n = n1:swap n1 n2 ns
  | otherwise = n:swap n1 n2 ns


totalDis :: [Node] -> Float
totalDis route = fst $ foldl f (0, last route) route
  where f (total, node1) node2 = ( dis node1 node2 + total, node2 )

dis :: Floating a => (a, a) -> (a, a) -> a
dis (x1, y1) (x2, y2) = sqrt ( (x1 - x2) ** 2 + (y1 - y2) ** 2 )

