module TaaSSim
# package code goes here

#optimisation
using JuMP
using Clp
using GLPK
using Cbc
using LightGraphs
using LightXML

#tester functions
export build_network

#file functions
export 
	readTablesFromFile, readTablesFromData, readDlmFile, readVehicleFile, readRequestFile, readNodeFile
	
#network functions
export
	getDistance, getTravelTime, getTravelTimes, getTravelDistance, getTravelCost, getTripPoint, getRequestedTimes, getRequestedLoads,
	getMaxTravelTimes, getCapacities,
	generateCordeauCostMatrix, generateCordeauLoads, generateCordeauTravelTimes, generateTimeWindows, generateCordeauInputs, formulateCordeauModel, solveCordeauModel

#types
export 
	Vehicle, Request, Node, Location, Test

include("defs.jl")

include("file/file_io.jl")
include("file/read_darp_files.jl")

include("types/types.jl")

include("network/darp_network.jl")

end # module