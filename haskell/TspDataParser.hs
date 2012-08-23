module TspDataParser
( toNode
, toNodes
, ppNode
, ppNodes'
, ppNodes
, toNodesFromJson
, toJson
) where

import Data.List

type Node = (Float, Float)


toJson :: [Node] -> String
toJson = show . map (\(x, y)->[x, y])

toNodesFromJson :: String -> [Node]
toNodesFromJson = map (\[x, y]->(x, y)) . read

ppNodes :: [Node] -> String
ppNodes =  intercalate "\n" . map ppNode

ppNodes' :: [Node] -> IO [()]
ppNodes' = mapM putStrLn . map ppNode

ppNode :: Node -> String
ppNode (x, y) = "- " ++ show x ++ " " ++ show y

toNodes :: String -> [Node]
toNodes = map toNode . lines

toNode :: String -> Node
toNode rowstr = (x, y)
  where [x, y] = map read . tail . words $ rowstr

