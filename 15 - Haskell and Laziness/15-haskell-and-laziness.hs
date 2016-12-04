-- Hintroduction ----------------------------------------------------------------
{-
	- Use mod to test for divisibility.
	- Consider using infinite lists (e.g., [2..]), higher-order functions, and
		list comprehension.
	- You may find the takeWhile function to be useful.
	- To help you debug isPrimesFast, consider using the primes list (not the
		primesFast list).
	- Although it is not required, the functions isPrime and isPrimeFast can
		each be written with a single line of code. Can you figure out how? (If
			not, a more brute-force recursive implementation will work as well.)
	- Since isPrimeFast uses the list primesFast, and primesFast is generated
		using isPrimeFast, you have to seed it by explicitly including that 2
		is a prime number. This can be done as a special case of isPrimeFast or
		by starting the primesFast list as
			2:<the rest of your code to generate it>.
	- For the lcsLength function, you will need to use an array rather than
		lists so that you can have random access into the table. See the Haskell
		documentation for how to do this.
	- To access an element of a string, use the “!!” operator. For example,
			s1!!j
		returns the jth element of the string s1 (using zero-based indexing).
	- Here's some code for a simple function that returns the largest Int
		value smaller than the square root of another Int. It's pretty
		straightforward, but it does involve some type conversions that we want
		to spare you from having to figure out.
-}

import Prelude

-- Part 1: Primes ---------------------------------------------------------------

-- isPrime ----------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
isPrime :: Int -> Bool
isPrime a = null [b | b <- makePrimeCheckArray a, isMod0 a b]

-- Some helpers
makePrimeCheckArray :: Int -> [Int]
makePrimeCheckArray n = takeWhile (<= iSqrt n) [2.. ]

iSqrt :: Int -> Int
iSqrt n = floor(sqrt(fromIntegral n))

isMod0 :: Int -> Int -> Bool
isMod0 a b = if (a `mod` b) == 0
				then True
				else False

-- primes -----------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
primes :: [Int]
primes = [x | x <- [2.. ], isPrime x]

-- Useful helper functions - the first defined above, the second from Haskell libs
-- isPrime :: Int -> Bool
-- filter  :: (a -> Bool) -> [a] -> [a]

-- isPrimeFast ------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
isPrimeFast :: Int -> Bool
isPrimeFast 2 = True
isPrimeFast a = null [b | b <- (takeWhile (<= iSqrt a) primesFast), isMod0 a b]

-- primesFast -------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
primesFast :: [Int]
primesFast = [x | x <- [2..], isPrimeFast x]

-- Part 2: Longest Common Subsequence -------------------------------------------
-- Type Signature ---------------------------------------------------------------

lcsLength :: String -> String -> Int
lcsLength a b = length (lcs a b)

lcs :: String -> String -> String
lcs a b
	| ( (length a == 0) || (length b == 0) ) = ""
	| (last a == last b ) = (lcs (init a) (init b)) ++ [last a]
	| (last a /= last b ) = longest (lcs (init a) b) (lcs a (init b))
	
longest :: String -> String -> String
longest a b = if length a > length b
				then a
				else b