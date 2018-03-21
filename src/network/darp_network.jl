#Dial-a-ride problem functions

#function to calculate distance between two nodes, as the crow flies, in km
function getDistance(origin::Node, destination::Node)
    return  sqrt((origin.x_loc - destination.x_loc)^2 + (origin.y_loc - destination.y_loc)^2)
end


#function to calculate the travel time between two nodes, in hours
function getTravelTime(origin::Node, destination::Node, speed::Float64)
    distance = getDistance(origin, destination)
    return distance/speed
end

#creates an array of the travel times in a symmetric network of nodes
function getTravelTimes(nodes::Vector{Node}, vehicles::Vector{Vehicle})

    n = length(nodes)
    v = length(vehicles)

    #pre-allocate array
    travel_time = zeros(n, n, v)

    #calculate travel time in network
    for i in 1:n
        for j in i+1:n
            for k in 1:v
                travel_time[i,j,k] = getTravelTime(nodes[i],nodes[j],vehicles[k].speed)
            end
        end
    end

    #assuming time both ways is the same
    for i = n:-1:1
        for j = i-1:-1:1
            for k = 1:v
                travel_time[i,j,k] = travel_time[j,i,k]
            end
        end
    end

    return travel_time

end

#function to return the straight line distance between a point and the cartesian origin
function getTravelDistance(location::Location)
   return sqrt(location.x_loc^2 + location.y_loc^2) 
end

#function to return the straight line distance between two points
function getTravelDistance(origin::Location, destination::Location)
   return sqrt((origin.x_loc-destination.x_loc)^2 + (origin.y_loc-destination.y_loc)^2) 
end

#function to return the travel cost between a point and the cartesian origin
function getTravelCost(location::Location, vehicle::Vehicle)
    return vehicle.cost_coeff*getTravelDistance(location)
end

#function to return the travel cost between two points
function getTravelCost(origin::Location, destination::Location, vehicle::Vehicle)
    return vehicle.cost_coeff*getTravelDistance(origin,destination)
end

#function to return the location which is specified by the Cordeau network formulation for a node i, given n requests
function getTripPoint(i::Int, n::Int, reqs::Vector{Request})
    
    if i <= n +1
        point = reqs[i-1].origin
    elseif n + 1 < i <= 2n + 1
        point = reqs[i-n-1].destination
    end
    
    return point
    
end

#generates the cost matrix for the Cordeau DARP formulation
function generateCordeauCostMatrix(reqs::Vector{Request}, vehicles::Vector{Vehicle})
    
    n = length(reqs)
    v = length(vehicles)
    
    c = Inf*ones(2n+2,2n+2,v) #pre-allocate array
    
	#add cost from depot to first pick up locations
    for j = 2:n+1
        for k = 1:v
            c[1,j,k] = getTravelCost(reqs[j-1].origin,vehicles[k])
        end
    end    
    
	#costs for feasibly travelling between all drop off and pick up locations
    for i = 2:2n+1
        for j = 2:2n+1
            if i != j && i != n + j #cannot travel to the same node, and cannot travel from a drop off to the corresponding pick up
                for k = 1:v
                    c[i,j,k] = getTravelCost(getTripPoint(i,n,reqs), getTripPoint(j,n,reqs),vehicles[k])
                end
            end
        end
    end
    
	#costs for last drop off locations to depot
    for i = n+2:2n+1
        for k = 1:v
            c[i,2n+2,k] = getTravelCost(reqs[i-n-1].destination, vehicles[k])
        end
    end
    
    return c
    
end