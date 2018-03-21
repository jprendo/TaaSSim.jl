# read dial-a-ride problem files


#function to read vehicle data
function readVehicleFile(filename::String)

	tables = readTablesFromFile(filename)
	
	table = tables["vehicles"]
	n = size(table.data,1) # number of vehicles
	assert(n >= 1)
	
	# create vehicles from data in table
	vehicles = Vector{Vehicle}(n)
	columns = table.columns # shorthand
	for i = 1:n
		vehicles[i] = Vehicle()
		vehicles[i].index = columns["index"][i]
		vehicles[i].capacity = columns["capacity"][i]
		vehicles[i].cost_coeff = columns["cost_coeff"][i]
		vehicles[i].max_time = columns["max_time"][i]
		vehicles[i].speed = columns["speed"][i]
		assert(vehicles[i].index == i)
	end
	
	return vehicles
end

#function to read node data
function readNodeFile(filename::String)

	tables = readTablesFromFile(filename)
	
	table = tables["nodes"]
	n = size(table.data,1) #number of nodes
	assert(n >= 1)
	
	#create nodes from data in table
	nodes = Vector{Node}(n)
	columns = table.columns #shorthand
	for i = 1:n
		nodes[i] = Node()
		nodes[i].index = columns["index"][i]
		nodes[i].name = columns["name"][i]
		nodes[i].x_loc = columns["x_location"][i]
		nodes[i].y_loc = columns["y_location"][i]
	end

	return nodes
	
end

#function to read request data
function readRequestFile(filename::String)

	tables = readTablesFromFile(filename)
	
	table = tables["requests"]
	n = size(table.data,1) #number of requests
	assert(n >= 1)

	#create requests from data in table
	requests = Vector{Request}(n)
	columns = table.columns #shorthand
	for i = 1:n
		requests[i] = Request()
		requests[i].index = columns["index"][i]
		requests[i].num_pass = columns["num_pass"][i]
		requests[i].origin = Location(columns["origin_x_loc"][i],columns["origin_y_loc"][i])
		requests[i].destination = Location(columns["destination_x_loc"][i],columns["destination_y_loc"][i])
		#requests[i].from_x_loc = columns["from_x_loc"][i]
		#requests[i].from_y_loc = columns["from_y_loc"][i]
		#requests[i].to_x_loc = columns["to_x_loc"][i]
		#requests[i].to_y_loc = columns["to_y_loc"][i]
		requests[i].early = columns["early"][i]
		requests[i].late = columns["late"][i]
	end
	
	return requests
	
end