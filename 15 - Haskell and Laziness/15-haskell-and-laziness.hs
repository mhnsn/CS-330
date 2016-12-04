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

main = primeChecker 7

iSqrt :: Int -> Int
iSqrt n = floor(sqrt(fromIntegral n))

primeChecker :: Int -> IO()
primeChecker s = if isPrime s
					then putStrLn $ "Yes!"
					else putStrLn $ "No!"

-- Part 1: Primes ---------------------------------------------------------------

isMod0 a b = if (a mod b) == 0
				then True
				else False

-- isPrime ----------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
isPrime :: Int -> Bool
isPrime n = foldl (\a n -> (a mod n) == 0) False [1...sqrt(n)]
		--  foldl (bool -> int  -> bool) 				-> bool -> [int]   	-> bool
		--  foldl (a 	-> b 	-> a) 	 				-> a 	-> [b] 		-> a

		
foldl (bool -> bool  -> bool)	-> bool -> [bool]   	-> bool

isDivisibleBy :: Int		


-- primes -----------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
primes :: [Int]
primes = [0]

-- Useful helper functions - the first defined above, the second from Haskell libs
-- isPrime :: Int -> Bool
-- filter  :: (a -> Bool) -> [a] -> [a]

-- isPrimeFast ------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
isPrimeFast :: Int -> Bool
isPrimeFast n = if(isPrime n)
				then True
				else False

-- primesFast -------------------------------------------------------------------
-- Type Signature ---------------------------------------------------------------
primesFast :: [Int]
primesFast = [2]

-- Part 2: Longest Common Subsequence -------------------------------------------
-- Type Signature ---------------------------------------------------------------
lcsLength :: String -> String -> Int
lcsLength = 0