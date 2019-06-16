=begin
This is a (fairly) basic monopoly simulator, built with the purpose of finding the most landed on spaces. Intuitively, all spaces should
be about as frequent, which is the assumption that all other analyses I have found online have worked from. However, this is not the case,
since the most common outcome of rolling two dice is a 7.
Since we are not concerned with money, or even with multiple players, this simulator simply plays a "game" of 250 dice rolls, keeping
track of the most frequently landed on spaces in each game. It then plays through 500_000 of these "games" and keeps a count of the most
popular space in each one, outputting the results.
Of note, this simulator does implement the logic of the community chest and chance cards that move the player, as well as the go to jail
space, and the rolling-three-doubles-in-a-row landing you in jail rule. However, since the number of turns it takes to escape jail does
not matter for our purposes, and since money doesn't either, this simulator does not implement any details related to either of those.
=end




SPACENAMEARRAY = [:go, :mediterranean, :c_c_1, :baltic, :income_tax, :reading_rr, :oriental, :chance_1, :vermont, :connecticut, :jail,
	:st_charles_place, :electric_company, :states, :virginia, :pennsylvania_rr, :st_james_place, :c_c_2, :tenessee, :new_york,
	:free_parking, :kentucky, :chance_2, :indiana, :illinois, :b_and_o_rr, :atlantic, :ventnor, :water_works, :marvin_gardens,
	:go_to_jail, :pacific, :north_carolina, :c_c_3, :pennsylvania, :short_line_rr, :chance_3, :park_place, :luxury_tax, :boardwalk]

BOARDLENGTH = SPACENAMEARRAY.size
CHANCE_DECK_SIZE = 16
C_C_DECK_SIZE = 17

# This global variable keeps track of the number of doubles you roll in a row, to implement the appropriate
# three-doubles-in-a-row-lands-you-in-jail logic
$doubles_in_a_row = 0
def roll
	# Note: the ".." indicates a range inclusive of both the specified start and end
	firstDie = rand(1..6)
	secondDie = rand(1..6)
	if firstDie == secondDie
		$doubles_in_a_row += 1
	else
		$doubles_in_a_row = 0
	end

    return firstDie + secondDie
end


def test
	spaceFrequency = Array.new(40, 0)
	location = 0
	
	# The main loop of a simulated "game": rolling the die 250 times and recording the landed on spaces
	250.times {
	  newRoll = roll
	  if $doubles_in_a_row == 3 
	  	location = 10
	  	$doubles_in_a_row = 0
	  	spaceFrequency[location] += 1
	  	next
	  else
	  	location = (location + newRoll) % BOARDLENGTH
	  end
	  
	  spaceFrequency[location] += 1  

	  # NOTABLE ASSUMPTION: Cards drawn from both community chest and chance are shuffled back in after each draw.
	  case location
	  # When landing on a community chest space
	  when 2 || 17 || 33
	  	# Draw a card
	  	case rand(0...C_C_DECK_SIZE)
	  	# One of the cards sends you to Go
	  	when 0
	  		location = 0
	  		spaceFrequency[location] += 1
	  	# Another sends you to jail
	  	when 1
	  		location = 10
	  		spaceFrequency[location] += 1	  
	  	# No other community chest cards modify your location
	  	end		

	  	# When landing on a chance space
	  when 7 || 22 || 36
	  	# Draw a chance card
	  	case rand(0...CHANCE_DECK_SIZE)
	  	# One of them advances you to Go
	  	when 0
	  		location = 0
	  		spaceFrequency[location] += 1
	  	# One advances you to Illinois Avenue
	  	when 1
	  		location = 24
	  		spaceFrequency[location] += 1
	  	# One advances you to St. Charles Place
	  	when 2
	  		location = 11
	  		spaceFrequency[location] += 1
	  	# One advances you to the nearest utility
	  	when 3
	  		case SPACENAMEARRAY[location]
	  		when :chance_1 || :chance_3
	  			location = 12
	  			spaceFrequency[location] += 1
	  		when :chance_2
	  			location = 28
	  			spaceFrequency[location] += 1
	  		end
	  	# One advances you to the nearest railroad
	  	when 4
	  		case SPACENAMEARRAY[location]
	  		when :chance_1
	  			location = 15
	  			spaceFrequency[location] += 1
	  		when :chance_2
	  			location = 25
	  			spaceFrequency[location] += 1
	  		when :chance_3
	  			location = 5
	  			spaceFrequency[location] += 1
	  		end
	  	# One sends you back 3 spaces 
	  	when 5
	  		location -= 3
	  		spaceFrequency[location] += 1
	  	# One sends you to jail
	  	when 6
	  		location = 10
	  		spaceFrequency[location] += 1
	  	# One advances you to boardwalk
	  	when 7
	  		location = 39
	  		spaceFrequency[location] += 1
	  	end

	  # Landing on the "go to jail" space
	  when 30
	  	location = 10
	  	spaceFrequency[location] += 1 
	  end
	}

	# This creates a mapping of the spaces on the board to their frequency
	spaceHash = Hash[SPACENAMEARRAY.zip(spaceFrequency)]

	spaceAverage = 0
	spaceFrequency.each {|frequency| spaceAverage += frequency}
	spaceAverage /= BOARDLENGTH

	goodSpaces = spaceHash
	# This finds all the spaces that have been landed on an above average number of times
	goodSpaces.delete_if { |space, frequency| frequency < spaceAverage }

	return goodSpaces
end

resultsArray = []
# The main loop of the script; this simulates a half million "games" and records the best spaces of each one
500_000.times {
	resultsArray.push(test)
}

bestResults = Hash.new(0)
maxFrequency = 0
# This stores the best space (or spaces, if there are multiple tied for first) from each of the simulated games
# and stores it for display later.
resultsArray.each {
	|frequencyHash|
	maxFrequency = frequencyHash.values.max
	frequencyHash.each {
		|space, frequency|
		# This accounts for the duplicates, which is important, since, if we look at our final results, we have about 20% more
		# results than we do tests, indicating that about 20% of tests have 2 "best spaces".
		if frequency == maxFrequency
			bestResults[space] += 1 
		end
	}
}

totals = 0
bestResults.each { |space, popularity| totals += popularity }
puts totals
print bestResults.sort_by{ |space, popularity| popularity }.reverse




