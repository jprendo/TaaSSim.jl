type Location
	x_loc::Float64
	y_loc::Float64
	
	Location(x,y) = new(x, y)
	Location() = new(nullValue, nullValue)
	
end

type Vehicle
	index::Int
	capacity::Int #capacity of vehicle
	cost_coeff::Float64 #cost of travelling for a km
	max_time::Float64 #maximum time vehicle can take before returning to depot
	speed::Float64 #average speed of vehicle in km/h
	
	Vehicle() = new(nullIndex, nullValue, nullValue, nullValue)
end

type Request
	index::Int
	num_pass::Int #number of passengers requested for
	origin::Location
	destination::Location
	#from_x_loc::Float64 #origin longitude from depot
	#from_y_loc::Float64 #origin latitude from depot
	#to_x_loc::Float64 #destination longitude from depot
	#to_y_loc::Float64 #destination latitude from depot
	early::String #earliest time the pickup can occur
	late::String #latest time the delivery can occur
	
	Request() = new(nullIndex, nullValue, Location(), Location(), nullString, nullString)
end

type Node
	index::Int
	name::String #name of the location
	x_loc::Float64 #latitude relative to the depot in km
	y_loc::Float64 #longitude relative to the depot in km
	
	Node() = new(nullIndex, nullString, nullValue, nullValue)
end


type Test
	origin::Location
end