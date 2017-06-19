-----------------------------------------------------------------------------
-- |
-- Module      :  TestSuite.Optimization.Combined
-- Copyright   :  (c) Levent Erkok
-- License     :  BSD3
-- Maintainer  :  erkokl@gmail.com
-- Stability   :  experimental
--
-- Test suite for optimization routines, combined objectives
-----------------------------------------------------------------------------

module TestSuite.Optimization.Combined(tests) where

import Data.SBV
import SBVTest

-- Test suite
tests :: TestTree
tests =
  testGroup "Optimization.Combined"
    [ goldenVsStringShow "combined1" (optimize combined1)
    , goldenVsStringShow "combined2" (optimize combined2)
    , goldenVsStringShow "pareto1"   (optimize pareto1)
    , goldenVsStringShow "pareto2"   (optimize pareto2)
    , goldenVsStringShow "boxed1"    (optimize boxed1)
    ]

combined1 :: Goal
combined1 = do x <- sInteger "x"
               y <- sInteger "y"
               z <- sInteger "z"

               constrain $ x .< z
               constrain $ y .< z
               constrain $ z .< 5
               constrain $ x ./= y

               tactic $ OptimizePriority Lexicographic

               maximize "max_x" x
               maximize "max_y" y

combined2 :: Goal
combined2 = do a <- sBool "a"
               b <- sBool "b"
               c <- sBool "c"

               assertSoft "soft_a" a (Penalty 1 (Just "A"))
               assertSoft "soft_b" b (Penalty 2 (Just "B"))
               assertSoft "soft_c" c (Penalty 3 (Just "A"))

               constrain $ a .== c
               constrain $ bnot (a &&& b)

               tactic $ OptimizePriority Lexicographic

pareto1 :: Goal
pareto1 = do x <- sInteger "x"
             y <- sInteger "y"

             constrain $ 5 .>= x
             constrain $ x .>= 0
             constrain $ 4 .>= y
             constrain $ y .>= 0

             tactic $ OptimizePriority (Pareto Nothing)

             minimize "min_x"            x
             maximize "max_x_plus_y"   $ x + y
             minimize "min_y"            y

pareto2 :: Goal
pareto2 = do x <- sInteger "x"
             y <- sInteger "y"

             constrain $ 5 .>= x
             constrain $ x .>= 0

             tactic $ OptimizePriority (Pareto (Just 20))

             minimize "min_x"            x
             maximize "max_y"            y
             minimize "max_x_plus_y"   $ x + y

boxed1 :: Goal
boxed1 = do x <- sReal "x"
            y <- sReal "y"

            constrain $ 5 .>= x-y
            constrain $ x .>= 0
            constrain $ 4 .>= y
            constrain $ y .> 0

            minimize "min_x"        x
            maximize "max_x_plus_y" (x + y)
            minimize "min_y"        y
            maximize "max_y"        y

            tactic $ OptimizePriority Independent

{-# ANN module ("HLint: ignore Reduce duplication" :: String) #-}
