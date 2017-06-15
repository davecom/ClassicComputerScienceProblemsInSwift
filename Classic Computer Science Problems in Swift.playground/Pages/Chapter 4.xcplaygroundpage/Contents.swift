//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 4 Source

// Copyright 2017 David Kopec
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

public protocol Edge: CustomStringConvertible {
    var u: Int { get set } // index of the "from" vertex
    var v: Int { get set } // index of the "to" vertex
    var reversed: Edge { get }
}

protocol Graph: class, CustomStringConvertible {
    associatedtype VertexType: Equatable
    associatedtype EdgeType: Edge
    var vertices: [VertexType] { get set }
    var edges: [[EdgeType]] { get set }
}

extension Graph {
    /// How many vertices are in the graph?
    public var vertexCount: Int { return vertices.count }
    
    /// How many edges are in the graph?
    public var edgeCount: Int { return edges.joined().count }
    
    /// Get a vertex by its index.
    ///
    /// - parameter index: The index of the vertex.
    /// - returns: The vertex at i.
    public func vertexAtIndex(_ index: Int) -> VertexType {
        return vertices[index]
    }
    
    /// Find the first occurence of a vertex if it exists.
    ///
    /// - parameter vertex: The vertex you are looking for.
    /// - returns: The index of the vertex. Return nil if it can't find it.
    public func indexOfVertex(_ vertex: VertexType) -> Int? {
        if let i = vertices.index(of: vertex) {
            return i
        }
        return nil;
    }
    
    /// Find all of the neighbors of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the neighbors of.
    /// - returns: An array of the neighbor vertices.
    public func neighborsForIndex(_ index: Int) -> [VertexType] {
        return edges[index].map({self.vertices[$0.v]})
    }
    
    /// Find all of the neighbors of a given Vertex.
    ///
    /// - parameter vertex: The vertex to find the neighbors of.
    /// - returns: An optional array of the neighbor vertices.
    public func neighborsForVertex(_ vertex: VertexType) -> [VertexType]? {
        if let i = indexOfVertex(vertex) {
            return neighborsForIndex(i)
        }
        return nil
    }
    
    /// Find all of the edges of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the children of.
    public func edgesForIndex(_ index: Int) -> [EdgeType] {
        return edges[index]
    }
    
    /// Find all of the edges of a given vertex.
    ///
    /// - parameter vertex: The vertex to find the edges of.
    public func edgesForVertex(_ vertex: VertexType) -> [EdgeType]? {
        if let i = indexOfVertex(vertex) {
            return edgesForIndex(i)
        }
        return nil
    }
    
    /// Add a vertex to the graph.
    ///
    /// - parameter v: The vertex to be added.
    /// - returns: The index where the vertex was added.
    public func addVertex(_ v: VertexType) -> Int {
        vertices.append(v)
        edges.append([EdgeType]())
        return vertices.count - 1
    }
    
    /// Add an edge to the graph.
    ///
    /// - parameter e: The edge to add.
    public func addEdge(_ e: EdgeType) {
        edges[e.u].append(e)
        edges[e.v].append(e.reversed as! EdgeType)
    }
}

/// A basic unweighted edge.
open class UnweightedEdge: Edge {
    public var u: Int // "from" vertex
    public var v: Int // "to" vertex
    public var reversed: Edge {
        return UnweightedEdge(u: v, v: u)
    }
    
    public init(u: Int, v: Int) {
        self.u = u
        self.v = v
    }
    
    //MARK: CustomStringConvertable
    public var description: String {
        return "\(u) <-> \(v)"
    }
}

/// A graph with only unweighted edges.
open class UnweightedGraph<V: Equatable>: Graph {
    var vertices: [V] = [V]()
    var edges: [[UnweightedEdge]] = [[UnweightedEdge]]() //adjacency lists
    
    public init() {
    }
    
    public init(vertices: [V]) {
        for vertex in vertices {
            _ = self.addVertex(vertex)
        }
    }
    
    /// This is a convenience method that adds an unweighted edge.
    ///
    /// - parameter from: The starting vertex's index.
    /// - parameter to: The ending vertex's index.
    public func addEdge(from: Int, to: Int) {
        addEdge(UnweightedEdge(u: from, v: to))
    }
    
    /// This is a convenience method that adds an unweighted, undirected edge between the first occurence of two vertices.
    ///
    /// - parameter from: The starting vertex.
    /// - parameter to: The ending vertex.
    public func addEdge(from: V, to: V) {
        if let u = indexOfVertex(from) {
            if let v = indexOfVertex(to) {
                addEdge(UnweightedEdge(u: u, v: v))
            }
        }
    }
    
    /// MARK: Implement CustomStringConvertible
    public var description: String {
        var d: String = ""
        for i in 0..<vertices.count {
            d += "\(vertices[i]) -> \(neighborsForIndex(i))\n"
        }
        return d
    }
}



// Represents the 15 largest MSAs in the United States
var cityGraph: UnweightedGraph<String> = UnweightedGraph<String>(vertices: ["Seattle", "San Francisco", "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston", "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit", "Philadelphia", "Washington"])

cityGraph.addEdge(from: "Seattle", to: "Chicago")
cityGraph.addEdge(from: "Seattle", to: "San Francisco")
cityGraph.addEdge(from: "San Francisco", to: "Riverside")
cityGraph.addEdge(from: "San Francisco", to: "Los Angeles")
cityGraph.addEdge(from: "Los Angeles", to: "Riverside")
cityGraph.addEdge(from: "Los Angeles", to: "Phoenix")
cityGraph.addEdge(from: "Riverside", to: "Phoenix")
cityGraph.addEdge(from: "Riverside", to: "Chicago")
cityGraph.addEdge(from: "Phoenix", to: "Dallas")
cityGraph.addEdge(from: "Phoenix", to: "Houston")
cityGraph.addEdge(from: "Dallas", to: "Chicago")
cityGraph.addEdge(from: "Dallas", to: "Atlanta")
cityGraph.addEdge(from: "Dallas", to: "Houston")
cityGraph.addEdge(from: "Houston", to: "Atlanta")
cityGraph.addEdge(from: "Houston", to: "Miami")
cityGraph.addEdge(from: "Atlanta", to: "Chicago")
cityGraph.addEdge(from: "Atlanta", to: "Washington")
cityGraph.addEdge(from: "Atlanta", to: "Miami")
cityGraph.addEdge(from: "Miami", to: "Washington")
cityGraph.addEdge(from: "Chicago", to: "Detroit")
cityGraph.addEdge(from: "Detroit", to: "Boston")
cityGraph.addEdge(from: "Detroit", to: "Washington")
cityGraph.addEdge(from: "Detroit", to: "New York")
cityGraph.addEdge(from: "Boston", to: "New York")
cityGraph.addEdge(from: "New York", to: "Philadelphia")
cityGraph.addEdge(from: "Philadelphia", to: "Washington")

print(cityGraph)

public typealias Path = [Edge]

extension Graph {
    /// Prints a path in a readable format
    public func printPath(_ path: Path) {
        for edge in path {
            print("\(vertexAtIndex(edge.u)) > \(vertexAtIndex(edge.v))")
        }
    }
}

///bfs
public class Queue<T> {
    private var container: [T] = [T]()
    public var isEmpty: Bool { return container.isEmpty }
    public func push(_ thing: T) { container.append(thing) }
    public func pop() -> T { return container.removeFirst() }
}

/// Takes a dictionary of edges to reach each node and returns an array of edges
/// that goes from `from` to `to`
public func pathDictToPath(from: Int, to: Int, pathDict:[Int: Edge]) -> Path {
    if pathDict.count == 0 {
        return []
    }
    var edgePath: Path = Path()
    var e: Edge = pathDict[to]!
    edgePath.append(e)
    while (e.u != from) {
        e = pathDict[e.u]!
        edgePath.append(e)
    }
    return Array(edgePath.reversed())
}

extension Graph {
    //returns a path to the goal vertex
    func bfs(initialVertex: VertexType, goalTestFn: (VertexType) -> Bool) -> Path? {
        guard let startIndex = indexOfVertex(initialVertex) else { return nil }
        // frontier is where we've yet to go
        let frontier: Queue<Int> = Queue<Int>()
        frontier.push(startIndex)
        // explored is where we've been
        var explored: Set<Int> = Set<Int>()
        explored.insert(startIndex)
        // how did we get to each vertex
        var pathDict: [Int: EdgeType] = [Int: EdgeType]()
        // keep going while there is more to explore
        while !frontier.isEmpty {
            let currentIndex = frontier.pop()
            let currentVertex = vertexAtIndex(currentIndex)
            // if we found the goal, we're done
            if goalTestFn(currentVertex) {
                return pathDictToPath(from: startIndex, to: currentIndex, pathDict: pathDict)
            }
            // check where we can go next and haven't explored
            for edge in edgesForIndex(currentIndex) where !explored.contains(edge.v) {
                explored.insert(edge.v)
                frontier.push(edge.v)
                pathDict[edge.v] = edge
            }
        }
        return nil // never found the goal
    }
}



if let bostonToMiami = cityGraph.bfs(initialVertex: "Boston", goalTestFn: { $0 == "Miami" }) {
    cityGraph.printPath(bostonToMiami)
}

/// This protocol is needed for Dijkstra's algorithm - we need weights in weighted graphs
/// to be able to be added together
public protocol Summable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int: Summable {}
extension Double: Summable {}
extension Float: Summable {}

/// A weighted edge, who's weight subscribes to Comparable.
open class WeightedEdge<W: Comparable & Summable>: Edge, Comparable {
    public var u: Int
    public var v: Int
    public let weight: W
    
    public var reversed: Edge {
        return WeightedEdge(u: v, v: u, weight: weight)
    }
    
    public init(u: Int, v: Int, weight: W) {
        self.weight = weight
        self.u = u
        self.v = v
    }
    
    //Implement CustomStringConvertible protocol
    public var description: String {
        return "\(u) <\(weight)> \(v)"
    }
    
    //MARK: Operator Overloads for Comparable
    static public func == <W>(lhs: WeightedEdge<W>, rhs: WeightedEdge<W>) -> Bool {
        return lhs.u == rhs.u && lhs.v == rhs.v && lhs.weight == rhs.weight
    }
    
    static public func < <W>(lhs: WeightedEdge<W>, rhs: WeightedEdge<W>) -> Bool {
        return lhs.weight < rhs.weight
    }
}

/// A subclass of Graph that has convenience methods for adding and removing WeightedEdges. All added Edges should have the same generic Comparable type W as the WeightedGraph itself.
open class WeightedGraph<V: Equatable & Hashable, W: Comparable & Summable>: Graph {
    var vertices: [V] = [V]()
    var edges: [[WeightedEdge<W>]] = [[WeightedEdge<W>]]() //adjacency lists
    
    public init() {
    }
    
    public init(vertices: [V]) {
        for vertex in vertices {
            _ = self.addVertex(vertex)
        }
    }
    
    /// Find all of the neighbors of a vertex at a given index.
    ///
    /// - parameter index: The index for the vertex to find the neighbors of.
    /// - returns: An array of tuples including the vertices as the first element and the weights as the second element.
    public func neighborsForIndexWithWeights(_ index: Int) -> [(V, W)] {
        var distanceTuples: [(V, W)] = [(V, W)]();
        for edge in edges[index] {
            distanceTuples += [(vertices[edge.v], edge.weight)]
        }
        return distanceTuples;
    }
    
    /// This is a convenience method that adds a weighted edge.
    ///
    /// - parameter from: The starting vertex's index.
    /// - parameter to: The ending vertex's index.
    /// - parameter weight: the Weight of the edge to add.
    public func addEdge(from: Int, to: Int, weight:W) {
        addEdge(WeightedEdge<W>(u: from, v: to, weight: weight))
    }
    
    /// This is a convenience method that adds a weighted edge between the first occurence of two vertices. It takes O(n) time.
    ///
    /// - parameter from: The starting vertex.
    /// - parameter to: The ending vertex.
    /// - parameter weight: the Weight of the edge to add.
    public func addEdge(from: V, to: V, weight: W) {
        if let u = indexOfVertex(from) {
            if let v = indexOfVertex(to) {
                addEdge(WeightedEdge<W>(u: u, v: v, weight:weight))
            }
        }
    }
    
    //Implement Printable protocol
    public var description: String {
        var d: String = ""
        for i in 0..<vertices.count {
            d += "\(vertices[i]) -> \(neighborsForIndexWithWeights(i))\n"
        }
        return d
    }
}

let cityGraph2: WeightedGraph<String, Int> = WeightedGraph<String, Int>(vertices: ["Seattle", "San Francisco", "Los Angeles", "Riverside", "Phoenix", "Chicago", "Boston", "New York", "Atlanta", "Miami", "Dallas", "Houston", "Detroit", "Philadelphia", "Washington"])

cityGraph2.addEdge(from: "Seattle", to: "Chicago", weight: 1737)
cityGraph2.addEdge(from: "Seattle", to: "San Francisco", weight: 678)
cityGraph2.addEdge(from: "San Francisco", to: "Riverside", weight: 386)
cityGraph2.addEdge(from: "San Francisco", to: "Los Angeles", weight: 348)
cityGraph2.addEdge(from: "Los Angeles", to: "Riverside", weight: 50)
cityGraph2.addEdge(from: "Los Angeles", to: "Phoenix", weight: 357)
cityGraph2.addEdge(from: "Riverside", to: "Phoenix", weight: 307)
cityGraph2.addEdge(from: "Riverside", to: "Chicago", weight: 1704)
cityGraph2.addEdge(from: "Phoenix", to: "Dallas", weight: 887)
cityGraph2.addEdge(from: "Phoenix", to: "Houston", weight: 1015)
cityGraph2.addEdge(from: "Dallas", to: "Chicago", weight: 805)
cityGraph2.addEdge(from: "Dallas", to: "Atlanta", weight: 721)
cityGraph2.addEdge(from: "Dallas", to: "Houston", weight: 225)
cityGraph2.addEdge(from: "Houston", to: "Atlanta", weight: 702)
cityGraph2.addEdge(from: "Houston", to: "Miami", weight: 968)
cityGraph2.addEdge(from: "Atlanta", to: "Chicago", weight: 588)
cityGraph2.addEdge(from: "Atlanta", to: "Washington", weight: 543)
cityGraph2.addEdge(from: "Atlanta", to: "Miami", weight: 604)
cityGraph2.addEdge(from: "Miami", to: "Washington", weight: 923)
cityGraph2.addEdge(from: "Chicago", to: "Detroit", weight: 238)
cityGraph2.addEdge(from: "Detroit", to: "Boston", weight: 613)
cityGraph2.addEdge(from: "Detroit", to: "Washington", weight: 396)
cityGraph2.addEdge(from: "Detroit", to: "New York", weight: 482)
cityGraph2.addEdge(from: "Boston", to: "New York", weight: 190)
cityGraph2.addEdge(from: "New York", to: "Philadelphia", weight: 81)
cityGraph2.addEdge(from: "Philadelphia", to: "Washington", weight: 123)

print(cityGraph2.description)

/// Find the total weight of an array of weighted edges
/// - parameter edges The edge array to find the total weight of.
public func totalWeight<W>(_ edges: [WeightedEdge<W>]) -> W? {
    guard let firstWeight = edges.first?.weight else { return nil }
    return edges.dropFirst().reduce(firstWeight) { (result, next) -> W in
        return result + next.weight
    }
}

/// Extensions to WeightedGraph for building a Minimum-Spanning Tree (MST)
public extension WeightedGraph {
    typealias WeightedPath = [WeightedEdge<W>]
    // Citation: Based on Algorithms 4th Edition by Sedgewick, Wayne pg 619
    
    /// Find the minimum spanning tree in a weighted graph. This is the set of edges
    /// that touches every vertex in the graph and is of minimal combined weight. This function
    /// uses Jarnik's Algorithm (aka Prim's Algorithm) and so assumes the graph has
    /// undirected edges. For a graph with directed edges, the result may be incorrect. Also,
    /// if the graph is not fully connected, the tree will only span the connected component from which
    /// the starting vertex belongs.
    ///
    /// - parameter start: The index of the vertex to start creating the MST from.
    /// - returns: An array of WeightedEdges containing the minimum spanning tree, or nil if the starting vertex is invalid. If there are is only one vertex connected to the starting vertex, an empty list is returned.
    public func mst(start: Int = 0) -> WeightedPath? {
        if start > (vertexCount - 1) || start < 0 { return nil }
        var result: [WeightedEdge<W>] = [WeightedEdge<W>]() // the final MST goes in here
        var pq: PriorityQueue<WeightedEdge<W>> = PriorityQueue<WeightedEdge<W>>(ascending: true) // minPQ
        var visited: [Bool] = Array<Bool>(repeating: false, count: vertexCount) // already been to these
        
        func visit(_ index: Int) {
            visited[index] = true // mark as visited
            for edge in edgesForIndex(index) { // add all edges coming from here to pq
                if !visited[edge.v] { pq.push(edge) }
            }
        }
        
        visit(start) // the first vertex is where everything begins
        
        while let edge = pq.pop() { // keep going as long as there are edges to process
            if visited[edge.v] { continue } // if we've been here, ignore
            result.append(edge) // otherwise this is the current smallest so add it to the result set
            visit(edge.v) // visit where this connects
        }
        
        return result
    }
    
    /// Pretty-print an edge list returned from an MST
    /// - parameter edges The edge array representing the MST
    public func printWeightedPath(_ weightedPath: WeightedPath) {
        for edge in weightedPath {
            print("\(vertexAtIndex(edge.u)) \(edge.weight)> \(vertexAtIndex(edge.v))")
        }
        if let tw = totalWeight(weightedPath) {
            print("Total Weight: \(tw)")
        }
    }
}

if let mst = cityGraph2.mst() {
    cityGraph2.printWeightedPath(mst)
}

//MARK: `WeightedGraph` extension for doing dijkstra

public extension WeightedGraph {
    
    //MARK: Dijkstra Utilites
    
    /// Represents a node in the priority queue used
    /// for selecting the next
    struct DijkstraNode: Comparable, Equatable {
        let vertex: Int
        let distance: W
        
        public static func < (lhs: DijkstraNode, rhs: DijkstraNode) -> Bool {
            return lhs.distance < rhs.distance
        }
        
        public static func == (lhs: DijkstraNode, rhs: DijkstraNode) -> Bool {
            return lhs.distance == rhs.distance
        }
    }
    
    /// Finds the shortest paths from some route vertex to every other vertex in the graph.
    ///
    /// - parameter graph: The WeightedGraph to look within.
    /// - parameter root: The index of the root node to build the shortest paths from.
    /// - parameter startDistance: The distance to get to the root node (typically 0).
    /// - returns: Returns a tuple of two things: the first, an array containing the distances, the second, a dictionary containing the edge to reach each vertex. Use the function pathDictToPath() to convert the dictionary into something useful for a specific point.
    public func dijkstra(root: Int, startDistance: W) -> ([W?], [Int: WeightedEdge<W>]) {
        var distances: [W?] = [W?](repeating: nil, count: vertexCount) // how far each vertex is from start
        distances[root] = startDistance // the start vertex is startDistance away
        var pq: PriorityQueue<DijkstraNode> = PriorityQueue<DijkstraNode>(ascending: true)
        var pathDict: [Int: WeightedEdge<W>] = [Int: WeightedEdge<W>]() // how we got to each vertex
        pq.push(DijkstraNode(vertex: root, distance: startDistance))
        
        while let u = pq.pop()?.vertex { // explore the next closest vertex
            guard let distU = distances[u] else { continue } // should already have seen it
            for we in edgesForIndex(u) { // look at every edge/vertex from the vertex in question
                let distV = distances[we.v] // the old distance to this vertex
                if distV == nil || distV! > we.weight + distU { // if we have no old distance or we found a shorter path
                    distances[we.v] = we.weight + distU // update the distance to this vertex
                    pathDict[we.v] = we // update the edge on the shortest path to this vertex
                    pq.push(DijkstraNode(vertex: we.v, distance: we.weight + distU)) // explore it soon
                }
            }
        }
        
        return (distances, pathDict)
    }
    
    
    /// A convenience version of dijkstra() that allows the supply of the root
    /// vertex instead of the index of the root vertex.
    public func dijkstra(root: V, startDistance: W) -> ([W?], [Int: WeightedEdge<W>]) {
        if let u = indexOfVertex(root) {
            return dijkstra(root: u, startDistance: startDistance)
        }
        return ([], [:])
    }
    
    /// Helper function to get easier access to Dijkstra results.
    public func distanceArrayToVertexDict(distances: [W?]) -> [V : W?] {
        var distanceDict: [V: W?] = [V: W?]()
        for i in 0..<distances.count {
            distanceDict[vertexAtIndex(i)] = distances[i]
        }
        return distanceDict
    }
}

let (distances, pathDict) = cityGraph2.dijkstra(root: "Los Angeles", startDistance: 0)
var nameDistance: [String: Int?] = cityGraph2.distanceArrayToVertexDict(distances: distances)
for (key, value) in nameDistance {
    print("\(key) : \(String(describing: value!))")
}

let path = pathDictToPath(from: cityGraph2.indexOfVertex("Los Angeles")!, to: cityGraph2.indexOfVertex("Boston")!, pathDict: pathDict)
cityGraph2.printWeightedPath(path as! [WeightedEdge<Int>])

//: [Next](@next)
