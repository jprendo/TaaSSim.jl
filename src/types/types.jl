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
	num_pass::Int #number of passengers required
	from_node::String #origin node name
	to_node::String #destination node name
	early::String #earliest time the pickup can occur
	late::String #latest time the delivery can occur
	
	Request() = new(nullIndex, nullValue, nullString, nullString, nullString, nullString)
end

type Node
	index::Int
	name::String #name of the location
	x_loc::Float64 #latitude relative to the depot in km
	y_loc::Float64 #longitude relative to the depot in km
	
	Node() = new(nullIndex, nullString, nullValue, nullValue)
end
