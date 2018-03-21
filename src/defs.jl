#common definitions for general usage

const Float = Float64
# const Int = Int64
# const UInt = UInt64

# float and int types for storing all-pairs shortest paths data
# can reduce precision in order to reduce memory used
const FloatSpTime = Float64 # precision for storing shortest path travel times
const IntRNode = Int16 # precision for storing number of nodes in rGraph
const IntFadj = Int8 # precision for storing maximum number of nodes adjacent to any node in rGraph (= length of longest vector in network.rGraph.fadjList)

const sourcePath = @__DIR__

# run modes
const debugMode = false
const checkMode = true # for data checking, e.g. assertions that are checked frequently

# file chars
const delimiter = ','
const newline = "\r\n"

# misc null values
const nullIndex = -1
const nullX = -200 # outside lat/lon range
const nullY = -200
const nullTime = -1.0
const nullDist = -1.0
const nullValue = -1.0
const nullString = ""

nullFunction() = nothing
