# monopoly-sim
This is a fairly basic monopoly simulator, built with the purpose of finding the most landed on spaces. Intuitively, all spaces should
be about as frequent, which is the assumption that all other analyses I have found online have worked from. However, this is not the case,
since the most common outcome of rolling two dice is a 7. It is also non-trivial, since the standard 40-space monopoly board is not evenly divisible by 7.
Since we are not concerned with money, or even with multiple players, this simulator simply plays a "game" of 250 dice rolls, keeping
track of where the player ends each roll. It then plays through 500_000 of these "games" and aggregates the landing counts across all
runs, outputting the results.
Of note, this simulator _does_ implement the logic of the community chest and chance cards that move the player, as well as the go to jail
space, and the rolling-three-doubles-in-a-row landing you in jail rule. However, since the number of turns it takes to escape jail does
not matter for our purposes, and since money doesn't either, this simulator does not implement any details related to either of those.

Of interest results-wise: The top few properties according to this simulation are very consistently:
1. Illinois Avenue
2. New York Avenue
3. B. & O. Railroad
4. Tennessee Avenue
5. Pennsylvania Railroad
