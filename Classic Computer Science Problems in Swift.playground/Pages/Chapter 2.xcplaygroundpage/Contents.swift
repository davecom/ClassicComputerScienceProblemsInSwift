//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 2 Source

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

import Foundation

enum Nucleotide: Character, Comparable {
    case A = "A", C = "C", G = "G", T = "T"
}

func <(lhs: Nucleotide, rhs: Nucleotide) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

typealias Codon = (Nucleotide, Nucleotide, Nucleotide)
typealias Gene = [Codon]

let n1 = Nucleotide.A
let n2 = Nucleotide.C
let n3 = Nucleotide.A
n1 == n2
n1 == n3
n1 < n3
n1 < n2
n2 > n1
n2 < n1
n1 >= n2

let ac1: Codon = (.A, .T, .G)
let ac2: Codon = (.A, .C, .G)
let ac3: Codon = (.A, .T, .G)
ac1 == ac2
ac1 == ac3

let geneSequence = "ACGTGGCTCTCTAACGTACGTACGTACGGGGTTTATATATACCCTAGGACTCCCTTT"

func stringToGene(_ s: String) -> Gene {
    var gene = Gene()
    for i in stride(from: 0, to: s.characters.count, by: 3) {
        guard (i + 2) < s.characters.count else { return gene }
        if let n1 = Nucleotide.init(rawValue: s[s.index(s.startIndex, offsetBy: i)]), let n2 = Nucleotide.init(rawValue: s[s.index(s.startIndex, offsetBy: i + 1)]), let n3 = Nucleotide.init(rawValue: s[s.index(s.startIndex, offsetBy: i + 2)]) {
            gene.append((n1, n2, n3))
        }
    }
    return gene
}

var gene = stringToGene(geneSequence)

func linearContains(_ array: Gene, item: Codon) -> Bool {
    for element in gene where item == element {
        return true
    }
    return false
}

let acg: Codon = (.A, .C, .G)
linearContains(gene, item: acg)

func binaryContains(_ array: Gene, item: Codon) -> Bool {
    var low = 0
    var high = array.count - 1
    while low <= high {
        let mid = (low + high) / 2
        if array[mid] < item {
            low = mid + 1
        } else if array[mid] > item {
            high = mid - 1
        } else {
            return true
        }
    }
    return false
}

let sortedGene = gene.sorted(by: <)
binaryContains(sortedGene, item: acg)

/*let startTime = CFAbsoluteTimeGetCurrent()
for _ in 0..<1000 {
    linearContains(gene, item: acg)
}
let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime

let startTime2 = CFAbsoluteTimeGetCurrent()
for _ in 0..<1000 {
    binaryContains(sortedGene, item: acg)
}
let elapsedTime2 = CFAbsoluteTimeGetCurrent() - startTime2*/

/// Generic Versions

func linearContains<T: Equatable>(_ array: [T], item: T) -> Bool {
    for element in array where item == element {
        return true
    }
    return false
}

func binaryContains<T: Comparable>(_ array: [T], item: T) -> Bool {
    var low = 0
    var high = array.count - 1
    while low <= high {
        let mid = (low + high) / 2
        if array[mid] < item {
            low = mid + 1
        } else if array[mid] > item {
            high = mid - 1
        } else {
            return true
        }
    }
    return false
}

linearContains([1,5,15,15,15,15,15], item: 5)
binaryContains(["a", "d", "e", "f", "g"], item: "f")

///Generating a Maze

// A Cell represents the status of a grid location in the maze
enum Cell: Character {
    case Empty = "O"
    case Blocked = "X"
    case Start = "S"
    case Goal = "G"
    case Path = "P"
}

struct MazeLocation: Hashable {
    let row: Int
    let col: Int
    var hashValue: Int { return row.hashValue ^ col.hashValue }
    var up: MazeLocation {
        return MazeLocation(row: row + 1, col: col)
    }
    var down: MazeLocation {
        return MazeLocation(row: row - 1, col: col)
    }
    var left: MazeLocation {
        return MazeLocation(row: row, col: col - 1)
    }
    var right: MazeLocation {
        return MazeLocation(row: row, col: col + 1)
    }
}

func == (lhs: MazeLocation, rhs: MazeLocation) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

class Maze {
    var rows: [[Cell]]

    init(rows: Int, columns: Int, sparseness: Double) {
        // initialize maze full of empty spaces
        self.rows = [[Cell]](repeating: [Cell](repeating: .Empty, count: columns), count: rows)
        srand48(time(nil)) // seed random number generator
        // put walls in
        for row in 0..<rows {
            for col in 0..<columns {
                if drand48() < sparseness { //chance of wall
                    self.rows[row][col] = .Blocked
                }
            }
        }
    }

    private init(rows: [[Cell]]) {
        self.rows = rows
    }

    func isClear(_ location: MazeLocation) -> Bool {
        guard location.row >= 0 && location.col >= 0 && location.row < rows.count && location.col < rows[0].count else { return false }
        return rows[location.row][location.col] != .Blocked
    }

    func successors(location: MazeLocation) -> [MazeLocation] {
        //no  diagonals
        return [location.up, location.down, location.left, location.right].filter({ isClear($0) })
    }

    func marked(path: [MazeLocation], start: MazeLocation, goal: MazeLocation) -> Maze {
        let maze = Maze(rows: rows)
        for location in path {
            maze.rows[location.row][location.col] = .Path
        }
        maze.rows[start.row][start.col] = .Start
        maze.rows[goal.row][goal.col] = .Goal
        return maze
    }
}

func printMaze(_ maze: Maze) {
    for i in 0..<maze.rows.count {
        print(String(maze.rows[i].map{ $0.rawValue }))
    }
}

var maze = Maze(rows: 10, columns: 10, sparseness: 0.2)
printMaze(maze)

let goal = MazeLocation(row: 9, col: 9)
func goalTest(location: MazeLocation) -> Bool {
    return location == goal
}

///Stack
public class Stack<T> {
    private var container: [T] = [T]()
    public var isEmpty: Bool { return container.isEmpty }
    public func push(_ thing: T) { container.append(thing) }
    public func pop() -> T { return container.removeLast() }
}

///node
class Node<T>: Comparable, Hashable {
    let state: T
    let parent: Node?
    let cost: Float
    let heuristic: Float
    init(state: T, parent: Node?, cost: Float = 0.0, heuristic: Float = 0.0) {
        self.state = state
        self.parent = parent
        self.cost = cost
        self.heuristic = heuristic
    }
    
    var hashValue: Int { return Int(cost + heuristic) }
}

func < <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return (lhs.cost + lhs.heuristic) < (rhs.cost + rhs.heuristic)
}

func == <T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
    return lhs === rhs
}


///dfs
//returns a node containing the goal state
func dfs<StateType: Hashable>(initialState: StateType, goalTestFn: (StateType) -> Bool, successorFn: (StateType) -> [StateType]) -> Node<StateType>? {
    // frontier is where we've yet to go
    let frontier: Stack<Node<StateType>> = Stack<Node<StateType>>()
    frontier.push(Node(state: initialState, parent: nil))
    // explored is where we've been
    var explored: Set<StateType> = Set<StateType>()
    explored.insert(initialState)
    
    // keep going while there is more to explore
    while !frontier.isEmpty {
        let currentNode = frontier.pop()
        let currentState = currentNode.state
        // if we found the goal, we're done
        if goalTestFn(currentState) { return currentNode }
        // check where we can go next and haven't explored
        for child in successorFn(currentState) where !explored.contains(child) {
            explored.insert(child)
            frontier.push(Node(state: child, parent: currentNode))
        }
    }
    return nil // never found the goal
}

func nodeToPath<StateType>(_ node: Node<StateType>) -> [StateType] {
    var path: [StateType] = [node.state]
    var node = node
    // work backwards from end to front
    while let currentNode = node.parent {
        path.insert(currentNode.state, at: 0)
        node = currentNode
    }
    return path
}

let start = MazeLocation(row: 0, col: 0)

if let solution = dfs(initialState: start, goalTestFn: goalTest, successorFn: maze.successors) {
    let path = nodeToPath(solution)
    let solved = maze.marked(path: path, start: start, goal: goal)
    printMaze(solved)
}

///bfs
public class Queue<T> {
    private var container: [T] = [T]()
    public var isEmpty: Bool { return container.isEmpty }
    public func push(_ thing: T) { container.append(thing) }
    public func pop() -> T { return container.removeFirst() }
}

//returns a node containing the goal state
func bfs<StateType: Hashable>(initialState: StateType, goalTestFn: (StateType) -> Bool, successorFn: (StateType) -> [StateType]) -> Node<StateType>? {
    // frontier is where we've yet to go
    let frontier: Queue<Node<StateType>> = Queue<Node<StateType>>()
    frontier.push(Node(state: initialState, parent: nil))
    // explored is where we've been
    var explored: Set<StateType> = Set<StateType>()
    explored.insert(initialState)
    // keep going while there is more to explore
    while !frontier.isEmpty {
        let currentNode = frontier.pop()
        let currentState = currentNode.state
        // if we found the goal, we're done
        if goalTestFn(currentState) { return currentNode }
        // check where we can go next and haven't explored
        for child in successorFn(currentState) where !explored.contains(child) {
            explored.insert(child)
            frontier.push(Node(state: child, parent: currentNode))
        }
    }
    return nil // never found the goal
}

var maze2 = Maze(rows: 10, columns: 10, sparseness: 0.2)
if let solution = bfs(initialState: start, goalTestFn: goalTest, successorFn: maze2.successors) {
    let path = nodeToPath(solution)
    let solved = maze.marked(path: path, start: start, goal: goal)
    printMaze(solved)
}

//Heuristics

func euclideanDistance(ml: MazeLocation) -> Float {
    let xdist = ml.col - goal.col
    let ydist = ml.row - goal.row
    return sqrt(Float((xdist * xdist) + (ydist * ydist)))
}

func manhattanDistance(ml: MazeLocation) -> Float {
    let xdist = abs(ml.col - goal.col)
    let ydist = abs(ml.row - goal.row)
    return Float(xdist + ydist)
}

//a*
//returns a node containing the goal state
func astar<StateType: Hashable>(initialState: StateType, goalTestFn: (StateType) -> Bool, successorFn: (StateType) -> [StateType], heuristicFn: (StateType) -> Float) -> Node<StateType>? {
    // frontier is where we've yet to go
    var frontier: PriorityQueue<Node<StateType>> = PriorityQueue<Node<StateType>>(ascending: true, startingValues: [Node(state: initialState, parent: nil, cost: 0, heuristic: heuristicFn(initialState))])
    // explored is where we've been
    var explored = Dictionary<StateType, Float>()
    explored[initialState] = 0
    // keep going while there is more to explore
    while let currentNode = frontier.pop() {
        let currentState = currentNode.state
        // if we found the goal, we're done
        if goalTestFn(currentState) { return currentNode }
        // check where we can go next and haven't explored
        for child in successorFn(currentState) {
            let newcost = currentNode.cost + 1  //1 assumes a grid, there should be a cost function for more sophisticated applications
            if (explored[child] == nil) || (explored[child]! > newcost) {
                explored[child] = newcost
                frontier.push(Node(state: child, parent: currentNode, cost: newcost, heuristic: heuristicFn(child)))
            }
        }
    }
    return nil // never found the goal
}

var maze3 = Maze(rows: 10, columns: 10, sparseness: 0.2)
if let solution = astar(initialState: start, goalTestFn: goalTest, successorFn: maze3.successors, heuristicFn: manhattanDistance) {
    let path = nodeToPath(solution)
    let solved = maze.marked(path: path, start: start, goal: goal)
    printMaze(solved)
}

/// Missionaries and Cannibals

let maxNum = 3 // max number of missionaries or cannibals

struct MCState: Hashable, CustomStringConvertible {
    let missionaries: Int
    let cannibals: Int
    let boat: Bool
    var hashValue: Int { return missionaries * 10 + cannibals + (boat ? 1000 : 2000) }
    var description: String {
        let wm = missionaries // west bank missionaries
        let wc = cannibals // west bank cannibals
        let em = maxNum - wm // east bank missionaries
        let ec = maxNum - wc // east bank cannibals
        var description = "On the west bank there are \(wm) missionaries and \(wc) cannibals.\n"
        description += "On the east bank there are \(em) missionaries and \(ec) cannibals.\n"
        description += "The boat is on the \(boat ? "west" : "east") bank.\n"
        return description
    }
}

func ==(lhs: MCState, rhs: MCState) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func goalTestMC(state: MCState) -> Bool {
    return state == MCState(missionaries: 0, cannibals: 0, boat: false)
}

func isLegalMC(state: MCState) -> Bool {
    let wm = state.missionaries // west bank missionaries
    let wc = state.cannibals // west bank cannibals
    let em = maxNum - wm // east bank missionaries
    let ec = maxNum - wc // east bank cannibals
    // check there's not more cannibals than missionaries
    if wm < wc && wm > 0 { return false }
    if em < ec && em > 0 { return false }
    return true
}

func successorsMC(state: MCState) -> [MCState] {
    let wm = state.missionaries // west bank missionaries
    let wc = state.cannibals // west bank cannibals
    let em = maxNum - wm // east bank missionaries
    let ec = maxNum - wc // east bank cannibals
    var sucs: [MCState] = [MCState]() // next states
    
    if state.boat { // boat on west bank
        if wm > 1 {
            sucs.append(MCState(missionaries: wm - 2, cannibals: wc, boat: !state.boat))
        }
        if wm > 0 {
            sucs.append(MCState(missionaries: wm - 1, cannibals: wc, boat: !state.boat))
        }
        if wc > 1 {
            sucs.append(MCState(missionaries: wm, cannibals: wc - 2, boat: !state.boat))
        }
        if wc > 0 {
            sucs.append(MCState(missionaries: wm, cannibals: wc - 1, boat: !state.boat))
        }
        if (wc > 0) && (wm > 0){
            sucs.append(MCState(missionaries: wm - 1, cannibals: wc - 1, boat: !state.boat))
        }
    } else { // boat on east bank
        if em > 1 {
            sucs.append(MCState(missionaries: wm + 2, cannibals: wc, boat: !state.boat))
        }
        if em > 0 {
            sucs.append(MCState(missionaries: wm + 1, cannibals: wc, boat: !state.boat))
        }
        if ec > 1 {
            sucs.append(MCState(missionaries: wm, cannibals: wc + 2, boat: !state.boat))
        }
        if ec > 0 {
            sucs.append(MCState(missionaries: wm, cannibals: wc + 1, boat: !state.boat))
        }
        if (ec > 0) && (em > 0){
            sucs.append(MCState(missionaries: wm + 1, cannibals: wc + 1, boat: !state.boat))
        }
    }
    
    return sucs.filter{ isLegalMC(state: $0) }
}

func printMCSolution(path: [MCState]) {
    var oldState = path.first!
    print(oldState)
    for currentState in path[1..<path.count] {
        let wm = currentState.missionaries // west bank missionaries
        let wc = currentState.cannibals // west bank cannibals
        let em = maxNum - wm // east bank missionaries
        let ec = maxNum - wc // east bank cannibals
        if !currentState.boat {
            print("\(oldState.missionaries - wm) missionaries and \(oldState.cannibals - wc) cannibals moved from the west bank to the east bank.")
        } else {
            print("\(maxNum - oldState.missionaries - em) missionaries and \(maxNum - oldState.cannibals - ec) cannibals moved from the east bank to the west bank.")
        }
        print(currentState)
        oldState = currentState
    }
}

let startMC = MCState(missionaries: 3, cannibals: 3, boat: true)
if let solution = bfs(initialState: startMC, goalTestFn: goalTestMC, successorFn: successorsMC) {
    let path = nodeToPath(solution)
    printMCSolution(path: path)
}

//: [Next](@next)
