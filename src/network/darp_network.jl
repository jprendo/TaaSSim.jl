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

#returns the number of hours from the start of the problem as a float
function getFloatTime(time::String,start_time::Float64 = 0.0)
    dt = DateTime(time,"HH:MM")
    return Float64(Dates.hour(dt) + Dates.minute(dt)/60 - start_time)
end

#function to return the travel time between two locations in a given vehicle
function getTravelTime(origin::Location, destination::Location, vehicle::Vehicle)
    return getTravelDistance(origin, destination)/vehicle.speed
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

#gets the vehicle maximum capacities
function getCapacities(vehicles::Vector{Vehicle})
    
    v = length(vehicles)
    
    capacities = zeros(v)
    
    for k = 1:v
        capacities[k] = vehicles[k].capacity
    end
    
    return capacities
    
end

#gets the maximum duration each vehicle is allowed to be away from the depot
function getMaxTravelTimes(vehicles::Vector{Vehicle})
    
    v = length(vehicles)
    
    max_times = zeros(v)
    
    for i = 1:v
        max_times[i] = vehicles[i].max_time
    end
    
    return max_times
    
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

#gets the earliest pick up and latest delivery times which are specified
function getRequestedTimes(reqs::Vector{Request}, start_time::Float64 = 0.0)
    
    n = length(reqs)
    
    early = zeros(n)
    late = zeros(n)
    
    for i = 1:n
        early[i] = getFloatTime(reqs[i].early,start_time)
        late[i] = getFloatTime(reqs[i].late,start_time)
    end
    
    return early, late
end

#gets the requested passenger loads from the request data
function getRequestedLoads(reqs::Vector{Request})
   
    n = length(reqs)
    
    loads = zeros(n)
    
    for i = 1:n
        loads[i] = reqs[i].num_pass
    end
    
    return loads
    
end

#gets the travel times between all nodes in the cordeau formulation
function generateCordeauTravelTimes(reqs::Vector{Request}, vehicles=Vector{Vehicle})
    
    n = length(reqs)
    v = length(vehicles)
    times = zeros(2n+2,2n+2,v)

    #times for feasibly travelling between all drop off and pick up locations
    for i = 2:2n+1
        for j = 2:2n+1
            if i != j && i != n + j #cannot travel to the same node, and cannot travel from a drop off to the corresponding pick up
                for k = 1:v
                    times[i,j,k] = getTravelTime(getTripPoint(i,n,reqs), getTripPoint(j,n,reqs),vehicles[k])
                end
            end
        end
    end
    
    return times
    
end

#generates the cost matrix for the Cordeau DARP formulation
function generateCordeauCostMatrix(reqs::Vector{Request}, vehicles::Vector{Vehicle})
    
    n = length(reqs)
    v = length(vehicles)
    
    c = 10000.0*ones(2n+2,2n+2,v) #pre-allocate array
    
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


#generates the requested load at every point in the Cordeau network
function generateCordeauLoads(reqs::Vector{Request})

	n = length(reqs)
	
	P_loads = getRequestedLoads(reqs)
	
	q = zeros(2n+2)
	q[2:n+1] = P_loads
	q[n+2:2n+1] = -P_loads
	
	return q
	
end

#generates the time windows for service of each node
function generateTimeWindows(reqs::Vector{Request}, pick_up_window::Float64, delivery_window::Float64)

    n = length(reqs)
    
    pick_up, delivery = getRequestedTimes(reqs);
    
    e = zeros(2n+2) #no initial early time
    l = 1000.0*ones(2n+2) #no initial late time
    
    e[2:n+1] = pick_up
    l[2:n+1] = pick_up + pick_up_window
    
    #e[n+2:2n+1] = delivery
    l[n+2:2n+1] = delivery + delivery_window;
    
    return e, l
    
end

#generates the inputs for the Cordeau DARP formulation
function generateCordeauInputs(reqs::Vector{Request}, vehicles::Vector{Vehicle})
    
    n = length(reqs)
    v = length(vehicles);
    
    e, l = generateTimeWindows(reqs, 10.0/60.0, 5.0/60.0) #TODO variable windows
    
    q = generateCordeauLoads(reqs);
    
    t = generateCordeauTravelTimes(reqs, vehicles)
    
    d = zeros(2n+2); #TODO variable service times (random with requests)
    
    T = getMaxTravelTimes(vehicles)
    
    Q = getCapacities(vehicles)
    
    L = 60.0/60.0 #maximum trip duration
    
    c = generateCordeauCostMatrix(reqs, vehicles);
    
    return n, v, e, l, q, t, d, T, Q, L, c
    
end

#formulates the Cordeau DARP LP
function formulateCordeauModel(n::Int, v::Int, e::Vector{Float64}, l::Vector{Float64}, q::Vector{Float64}, t::Array{Float64}, d::Vector{Float64}, T::Vector{Float64}, Q::Vector{Float64}, L::Float64, c::Array{Float64})
   
    m = Model(solver = CbcSolver()); #Initialise the model
    
    @variable(m, x[i=1:2n+2,j=1:2n+2,k=1:v], Bin)
    @variable(m, u[1:2n+2,1:v])
    @variable(m, w[1:2n+2,1:v])
    @variable(m, r[1:2n+2,1:v]);
    
    
    @constraint(m, noselftrips[i=1:2n+2,j=1:2n+2,k=1:v; i ==j], x[i,j,k] == 0.0)
    @constraint(m, sum(sum(x[i=2:n+1,j,k] for j=1:2n+2) for k=1:v) .== 1)
    @constraint(m, sum( x[1,j,k=1:v] for j=1:2n+2) .== 1)
    @constraint(m, sum(x[i,2n+2,k=1:v] for i=1:2n+2) .==1)
    @constraint(m, sum(x[i=2:n+1,j,k=1:v] for j = 1:2n+2) - sum(x[(i=2:n+1)+n,j,k=1:v] for j = 1:2n+2) .== 0)
    @constraint(m, sum(x[j,i=2:2n+1,k=1:v] for j = 1:2n+2) - sum(x[i=2:2n+1,j,k=1:v] for j = 1:2n+2) .== 0)
    
    @constraint(m, startservconstr[i=2:n+1,k=1:v], r[i,k] >= u[n+i,k] - (u[i,k] + d[i]))
    @constraint(m, maxtimeconstr[k=1:v], u[2n+2,k] - u[1,k] <= T[k])
    @constraint(m, reqbndconstr[i=1:2n+2,k=1:v], e[i] <= u[i,k] <= l[i])
    @constraint(m, ridelenconstr[i=2:n+1,k=1:v], t[i,n+i] <= r[i,k] <= L)
    @constraint(m, capconstr[i=1:2n+2,k=1:v], max(0,q[i]) <= w[i,k] <= min(Q[k], Q[k]+q[i]));
    
    M = 20.0*ones(2n+2,2n+2,v) #TODO dynamic
    W = 20.0*ones(2n+2,2n+2,v) #TODO dynamic

    @constraint(m, timefeasconstr[i=1:2n+2,j=1:2n+2,k=1:v], u[j,k] >= u[i,k] + d[i] + t[i,j] - M[i,j,k]*(1 - x[i,j,k]))
    @constraint(m, capfeasconstr[i=1:2n+2,j=1:2n+2,k=1:v], w[j,k] >= w[i,k] + q[i] - W[i,j,k]*(1 - x[i,j,k]))
    
    @objective(m, Min, sum(sum(sum(c[i,j,k]*x[i,j,k] for i=1:2n+2) for j=1:2n+2) for k = 1:v))
    
    return m, x, u, w, r
    
end

#solves the Cordeau DARP
function solveCordeauModel(reqs::Vector{Request}, vehicles::Vector{Vehicle})
    
    n, v, e, l, q, t, d, T, Q, L, cost = generateCordeauInputs(reqs, vehicles)
    
    m, x, u, w, r = formulateCordeauModel(n, v, e, l, q, t, d, T, Q, L, cost) #TODO add solver option
    
    status = solve(m)
    
    return status, m, x, u, w, r
    
end
