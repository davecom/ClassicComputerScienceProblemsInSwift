//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 8 Source

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

/// Knapsack

struct Item {
    let name: String
    let weight: Int
    let value: Float
}

// originally based on Algorithms in C by Sedgewick, Second Edition, p 596
func knapsack(items: [Item], maxCapacity: Int) -> [Item] {
    //build up dynamic programming table
    var table: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: maxCapacity + 1), count: items.count + 1)  //initialize table - overshooting in size
    for (i, item) in items.enumerated() {
        for capacity in 1...maxCapacity {
            let previousItemsValue = table[i][capacity]
            if capacity >= item.weight { // item fits in knapsack
                let valueFreeingWeightForItem = table[i][capacity - item.weight]
                table[i + 1][capacity] = max(valueFreeingWeightForItem + item.value, previousItemsValue)  // only take if more valuable than previous combo
            } else { // no room for this item
                table[i + 1][capacity] = previousItemsValue //use prior combo
            }
        }
    }
    // figure out solution from table
    var solution: [Item] = [Item]()
    var capacity = maxCapacity
    for i in stride(from: items.count, to: 0, by: -1) { // work backwards
        if table[i - 1][capacity] != table[i][capacity] {  // did we use this item?
            solution.append(items[i - 1])
            capacity -= items[i - 1].weight  // if we used an item, remove its weight
        }
    }
    return solution
}

let items = [Item(name: "television", weight: 50, value: 500),
             Item(name: "candlesticks", weight: 2, value: 300),
             Item(name: "stereo", weight: 35, value: 400),
             Item(name: "laptop", weight: 3, value: 1000),
             Item(name: "food", weight: 15, value: 50),
             Item(name: "clothing", weight: 20, value: 800),
             Item(name: "jewelry", weight: 1, value: 4000),
             Item(name: "books", weight: 100, value: 300),
             Item(name: "printer", weight: 18, value: 30),
             Item(name: "refrigerator", weight: 200, value: 700),
             Item(name: "painting", weight: 10, value: 1000)]
knapsack(items: items, maxCapacity: 75)

/// Travelling Salesman

let vtCities = ["Rutland", "Burlington", "White River Junction", "Bennington", "Brattleboro"]

let vtDistances = [
    "Rutland":
        ["Burlington": 67, "White River Junction": 46, "Bennington": 55, "Brattleboro": 75],
    "Burlington":
        ["Rutland": 67, "White River Junction": 91, "Bennington": 122, "Brattleboro": 153],
    "White River Junction":
        ["Rutland": 46, "Burlington": 91, "Bennington": 98, "Brattleboro": 65],
    "Bennington":
        ["Rutland": 55, "Burlington": 122, "White River Junction": 98, "Brattleboro": 40],
    "Brattleboro":
        ["Rutland": 75, "Burlington": 153, "White River Junction": 65, "Bennington": 40]
]

// backtracking permutations algorithm
func allPermutationsHelper<T>(contents: [T], permutations: inout [[T]], n: Int) {
    guard n > 0 else { permutations.append(contents); return }
    var tempContents = contents
    for i in 0..<n {
        tempContents.swapAt(i, n - 1) // move the element at i to the end
        // move everything else around, holding the end constant
        allPermutationsHelper(contents: tempContents, permutations: &permutations, n: n - 1)
        tempContents.swapAt(i, n - 1) // backtrack
    }
}

// find all of the permutations of a given array
func allPermutations<T>(_ original: [T]) -> [[T]] {
    var permutations = [[T]]()
    allPermutationsHelper(contents: original, permutations: &permutations, n: original.count)
    return permutations
}

// test allPermutations
let abc = ["a","b","c"]
let testPerms = allPermutations(abc)
print(testPerms)
print(testPerms.count)

// make complete paths for tsp
func tspPaths<T>(_ permutations: [[T]]) -> [[T]] {
    return permutations.map {
        if let first = $0.first {
            return ($0 + [first]) // append first to end
        } else {
            return [] // empty is just itself
        }
    }
}

print(tspPaths(testPerms))

func solveTSP<T>(cities: [T], distances: [T: [T: Int]]) -> (solution: [T], distance: Int) {
    let possiblePaths = tspPaths(allPermutations(cities)) // all potential paths
    var bestPath: [T] = [] // shortest path by distance
    var minDistance: Int = Int.max // distance of the shortest path
    for path in possiblePaths {
        if path.count < 2 { continue } // must be at least one city pair to calculate
        var distance = 0
        var last = path.first! // we know there is one becuase of above line
        for next in path[1..<path.count] { // add up all pair distances
            distance += distances[last]![next]!
            last = next
        }
        if distance < minDistance { // found a new best path
            minDistance = distance
            bestPath = path
        }
    }
    return (solution: bestPath, distance: minDistance)
}

let vtTSP = solveTSP(cities: vtCities, distances: vtDistances)
print("The shortest path is \(vtTSP.solution) in \(vtTSP.distance) miles.")

/// Phone Number Mnemonics

let phoneMapping: [Character: [Character]] = ["1": ["1"], "2": ["a", "b", "c"], "3": ["d", "e", "f"], "4": ["g", "h", "i"], "5": ["j", "k", "l"], "6": ["m", "n", "o"], "7": ["p", "q", "r", "s"], "8": ["t", "u", "v"], "9": ["w", "x", "y", "z"], "0": ["0"]]


// return all of the possible characters combos, given a mapping, for a given number
func stringToPossibilities(_ s: String, mapping: [Character: [Character]]) -> [[Character]]{
    let possibilities = s.compactMap{ mapping[$0] }
    print(possibilities)
    return combineAllPossibilities(possibilities)
}

// takes a set of possible characters for each position and finds all possible permutations
func combineAllPossibilities(_ possibilities: [[Character]]) -> [[Character]] {
    guard let possibility = possibilities.first else { return [[]] }
    var permutations: [[Character]] = possibility.map { [$0] } // turn each into an array
    for possibility in possibilities[1..<possibilities.count] where possibility != [] {
        let toRemove = permutations.count // temp
        for permutation in permutations {
            for c in possibility { // try adding every letter
                var newPermutation: [Character] = permutation // need a mutable copy
                newPermutation.append(c) // add character on the end
                permutations.append(newPermutation) // new combo ready
            }
        }
        permutations.removeFirst(toRemove) // remove combos missing new last letter
    }
    return permutations
}

let permutations = stringToPossibilities("1440787", mapping: phoneMapping)

/// Tic-tac-toe

enum Piece: String {
    case X = "X"
    case O = "O"
    case E = " "
    var opposite: Piece {
        switch self {
        case .X:
            return .O
        case .O:
            return .X
        case .E:
            return .E
        }
    }
}

// a move is an integer 0-8 indicating a place to put a piece
typealias Move = Int

struct Board {
    let position: [Piece]
    let turn: Piece
    let lastMove: Move
    
    // by default the board is empty and X goes first
    // lastMove being -1 is a marker of a start position
    init(position: [Piece] = [.E, .E, .E, .E, .E, .E, .E, .E, .E], turn: Piece = .X, lastMove: Int = -1) {
        self.position = position
        self.turn = turn
        self.lastMove = lastMove
    }
    
    // location can be 0-8, indicating where to move
    // return a new board with the move played
    func move(_ location: Move) -> Board {
        var tempPosition = position
        tempPosition[location] = turn
        return Board(position: tempPosition, turn: turn.opposite, lastMove: location)
    }
    
    // the legal moves in a position are all of the empty squares
    var legalMoves: [Move] {
        return position.indices.filter { position[$0] == .E }
    }
    
    var isWin: Bool {
        return
            position[0] == position[1] && position[0] == position[2] && position[0] != .E || // row 0
            position[3] == position[4] && position[3] == position[5] && position[3] != .E || // row 1
            position[6] == position[7] && position[6] == position[8] && position[6] != .E || // row 2
            position[0] == position[3] && position[0] == position[6] && position[0] != .E || // col 0
            position[1] == position[4] && position[1] == position[7] && position[1] != .E || // col 1
            position[2] == position[5] && position[2] == position[8] && position[2] != .E || // col 2
            position[0] == position[4] && position[0] == position[8] && position[0] != .E || // diag 0
            position[2] == position[4] && position[2] == position[6] && position[2] != .E // diag 1
        
    }
    
    var isDraw: Bool {
        return !isWin && legalMoves.count == 0
    }
}

// Find the best possible outcome for originalPlayer
func minimax(_ board: Board, maximizing: Bool, originalPlayer: Piece) -> Int {
    // Base case — evaluate the position if it is a win or a draw
    if board.isWin && originalPlayer == board.turn.opposite { return 1 } // win
    else if board.isWin && originalPlayer != board.turn.opposite { return -1 } // loss
    else if board.isDraw { return 0 } // draw
    
    // Recursive case — maximize your gains or minimize the opponent's gains
    if maximizing {
        var bestEval = Int.min
        for move in board.legalMoves { // find the move with the highest evaluation
            let result = minimax(board.move(move), maximizing: false, originalPlayer: originalPlayer)
            bestEval = max(result, bestEval)
        }
        return bestEval
    } else { // minimizing
        var worstEval = Int.max
        for move in board.legalMoves {
            let result = minimax(board.move(move), maximizing: true, originalPlayer: originalPlayer)
            worstEval = min(result, worstEval)
        }
        return worstEval
    }
}

// Run minimax on every possible move to find the best one
func findBestMove(_ board: Board) -> Move {
    var bestEval = Int.min
    var bestMove = -1
    for move in board.legalMoves {
        let result = minimax(board.move(move), maximizing: false, originalPlayer: board.turn)
        if result > bestEval {
            bestEval = result
            bestMove = move
        }
    }
    return bestMove
}

// win in 1 move
let toWinEasyPosition: [Piece] = [.X, .O, .X,
                                  .X, .E, .O,
                                  .E, .E, .O]
let testBoard1: Board = Board(position: toWinEasyPosition, turn: .X, lastMove: 8)
let answer1 = findBestMove(testBoard1)
print(answer1)

// must block O's win
let toBlockPosition: [Piece] = [.X, .E, .E,
                                .E, .E, .O,
                                .E, .X, .O]
let testBoard2: Board = Board(position: toBlockPosition, turn: .X, lastMove: 8)
let answer2 = findBestMove(testBoard2)
print(answer2)

// find the best move to win in 2 moves
let toWinHardPosition: [Piece] = [.X, .E, .E,
                                  .E, .E, .O,
                                  .O, .X, .E]
let testBoard3: Board = Board(position: toWinHardPosition, turn: .X, lastMove: 6)
let answer3 = findBestMove(testBoard3)
print(answer3)
//: [Next](@next)

