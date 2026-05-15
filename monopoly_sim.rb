SPACENAMEARRAY = [:go, :mediterranean, :c_c_1, :baltic, :income_tax, :reading_rr, :oriental, :chance_1, :vermont, :connecticut, :jail,
	:st_charles_place, :electric_company, :states, :virginia, :pennsylvania_rr, :st_james_place, :c_c_2, :tennessee, :new_york,
	:free_parking, :kentucky, :chance_2, :indiana, :illinois, :b_and_o_rr, :atlantic, :ventnor, :water_works, :marvin_gardens,
	:go_to_jail, :pacific, :north_carolina, :c_c_3, :pennsylvania, :short_line_rr, :chance_3, :park_place, :luxury_tax, :boardwalk]

BOARDLENGTH = SPACENAMEARRAY.size
CHANCE_DECK_SIZE = 16
C_C_DECK_SIZE = 16
NON_PROPERTY_SPACES = [:go, :c_c_1, :income_tax, :chance_1, :jail, :c_c_2, :free_parking, :chance_2, :go_to_jail, :c_c_3, :chance_3, :luxury_tax]

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
	$doubles_in_a_row = 0
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

	# NOTABLE ASSUMPTION: Cards drawn from both community chest and chance are shuffled back in after each draw.
	case location
	# When landing on a community chest space
	when 2, 17, 33
		# Draw a card
		case rand(0...C_C_DECK_SIZE)
		# One of the cards sends you to Go
		when 0
			location = 0
		# Another sends you to jail
		when 1
			location = 10
		# No other community chest cards modify your location
		end

		# When landing on a chance space
	when 7, 22, 36
		# Draw a chance card
		case rand(0...CHANCE_DECK_SIZE)
		# One of them advances you to Go
		when 0
			location = 0
		# One advances you to Illinois Avenue
		when 1
			location = 24
		# One advances you to St. Charles Place
		when 2
			location = 11
		# One advances you to the nearest utility
		when 3
			case SPACENAMEARRAY[location]
			when :chance_1, :chance_3
				location = 12
			when :chance_2
				location = 28
			end
		# Two advance you to the nearest railroad
		when 4, 5
			case SPACENAMEARRAY[location]
			when :chance_1
				location = 15
			when :chance_2
				location = 25
			when :chance_3
				location = 5
			end
		# One sends you back 3 spaces
		when 6
			location -= 3
			if location == 33
				case rand(0...C_C_DECK_SIZE)
				when 0
					location = 0
				when 1
					location = 10
				end
			end
		# One sends you to jail
		when 7
			location = 10
		# One advances you to boardwalk
		when 8
			location = 39
		end

	# Landing on the "go to jail" space
	when 30
		location = 10
	end

	spaceFrequency[location] += 1
	}

	return spaceFrequency
end

totalFrequency = Array.new(BOARDLENGTH, 0)
# The main loop of the script; this simulates a half million "games" and aggregates final landing counts
500_000.times {
	gameFrequency = test
	gameFrequency.each_with_index {
		|frequency, index|
		totalFrequency[index] += frequency
	}
}

totals = 0
totalFrequency.each { |frequency| totals += frequency }
puts "Total rolls: #{totals}"
Hash[SPACENAMEARRAY.zip(totalFrequency)].delete_if{ |space, frequency| NON_PROPERTY_SPACES.include?(space) }.sort_by{ |space, frequency| frequency }.reverse.each {
	|space, frequency|
	percentage = frequency.to_f / totals * 100
	puts "#{space}: #{frequency} (#{percentage.round(2)}%)"
}




