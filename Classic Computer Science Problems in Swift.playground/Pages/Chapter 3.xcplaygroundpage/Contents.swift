//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 3 Source

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

/// Defines a constraint satisfaction problem. V is the type of the variables and D is the type of the domains.
public struct CSP <V: Hashable, D> {
    /// The variables in the CSP to be constrained.
    let variables: [V]
    /// The domains - every variable should have an associated domain.
    let domains: [V: [D]]
    /// The constraints on the variables.
    var constraints = Dictionary<V, [Constraint<V, D>]>()
    
    /// You should create the variables and domains before initializing the CSP.
    public init (variables: [V], domains:[V: [D]]) {
        self.variables = variables
        self.domains = domains
        for variable in variables {
            constraints[variable] = [Constraint]()
            if domains[variable] == nil {
                print("Error: Missing domain for variable \(variable).")
            }
        }
    }
    
    /// Add a constraint to the CSP. It will automatically be applied to all the variables it includes. It should only include variables actually in the CSP.
    ///
    /// - parameter constraint: The constraint to add.
    public mutating func addConstraint(_ constraint: Constraint<V, D>) {
        for variable in constraint.vars {
            if !variables.contains(variable) {
                print("Error: Could not find variable \(variable) from constraint \(constraint) in CSP.")
            }
            constraints[variable]?.append(constraint)
        }
    }
}

/// The base class of all constraints.
open class Constraint <V: Hashable, D> {
    /// All subclasses should override this method. It defines whether a constraint has successfully been satisfied
    /// - parameter assignment: Potential domain selections for variables that are part of the constraint.
    /// - returns: Whether the constraint is satisfied.
    func isSatisfied(assignment: Dictionary<V, D>) -> Bool {
        return true
    }
    /// The variables that make up the constraint.
    var vars: [V] {return []}
}

/// the meat of the backtrack algorithm - a recursive depth first search
///
/// - parameter csp: The CSP to operate on.
/// - parameter assignment: Optionally, an already partially completed assignment.
/// - returns: the assignment (solution), or nil if none can be found
public func backtrackingSearch<V, D>(csp: CSP<V, D>, assignment: Dictionary<V, D> = Dictionary<V, D>()) -> Dictionary<V, D>?
{
    // assignment is complete if it has as many assignments as there are variables
    if assignment.count == csp.variables.count { return assignment } // base case
    
    // get an unassigned variable
    var variable: V = csp.variables.first! // temporary
    for x in csp.variables where assignment[x] == nil {
        variable = x
    }
    
    // get the domain of it and try each value in the domain
    for value in csp.domains[variable]! {
        var localAssignment = assignment
        localAssignment[variable] = value
        // if the value is consistent with the current assignment we continue
        if isConsistent(variable: variable, value: value, assignment: localAssignment, csp: csp) {
            // if as we go down the tree we get a complete assignment, return it
            if let result = backtrackingSearch(csp: csp, assignment: localAssignment) {
                return result
            }
        }
    }
    return nil  // no solution
}

/// check if the value assignment is consistent by checking all constraints of the variable
func isConsistent<V, D>(variable: V, value: D, assignment: Dictionary<V, D>, csp: CSP<V,D>) -> Bool {
    for constraint in csp.constraints[variable]! {
        if !constraint.isSatisfied(assignment: assignment) {
            return false
        }
    }
    return true
}

/// ###Australian Map Coloring Problem
final class MapColoringConstraint: Constraint <String, String> {
    let place1: String
    let place2: String
    final override var vars: [String] {return [place1, place2]}
    
    init(place1: String, place2: String) {
        self.place1 = place1
        self.place2 = place2
    }
    
    override func isSatisfied(assignment: Dictionary<String, String>) -> Bool {
        // if either variable is not in the assignment then it must be consistent
        // since they still have their domain
        if assignment[place1] == nil || assignment[place2] == nil {
            return true
        }
        // check that the color of var1 does not equal var2
        return assignment[place1] != assignment[place2]
    }
}

let variables: [String] = ["Western Australia", "Northern Territory",
                           "South Australia", "Queensland", "New South Wales", "Victoria", "Tasmania"]
var domains = Dictionary<String, [String]>()
for variable in variables {
    domains[variable] = ["r", "g", "b"]
}

var csp = CSP<String, String>(variables: variables, domains: domains)
csp.addConstraint(MapColoringConstraint(place1: "Western Australia", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Western Australia", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "South Australia", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland", place2: "Northern Territory"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland",
    place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Queensland", place2: "New South Wales"))
csp.addConstraint(MapColoringConstraint(place1: "New South Wales", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Victoria", place2: "South Australia"))
csp.addConstraint(MapColoringConstraint(place1: "Victoria",place2: "New South Wales"))

if let solution = backtrackingSearch(csp: csp) {
    print(solution)
} else { print("Couldn't find solution!") }

/// ###Eight Queens Problem

final class QueensConstraint: Constraint <Int, Int> {
    let columns: [Int]
    final override var vars: [Int] {return columns}
    
    init(columns: [Int]) {
        self.columns = columns
    }
    
    override func isSatisfied(assignment: Dictionary<Int, Int>) -> Bool {
        for (q1c, q1r) in assignment {
            if (q1c >= vars.count) {
                break
            }
            for q2c in (q1c + 1)..<vars.count {
                if let q2r = assignment[q2c] {
                    if q1r == q2r { return false }
                    if abs(q1r - q2r) == abs(q1c - q2c) { return false }
                }
            }
        }
        
        return true
    }
}

let cols: [Int] = [Int](1...8)
var rows = Dictionary<Int, [Int]>()
for variable in cols {
    rows[variable] = [Int](1...8)
}

var qcsp = CSP<Int, Int>(variables: cols, domains: rows)
qcsp.addConstraint(QueensConstraint(columns: cols))
if let solution = backtrackingSearch(csp: qcsp) {
    print(solution)
} else { print("Couldn't find solution!") }

/// ###Word Search Problem

// notice not too dissimilar from our Maze code from chapter 2
typealias Grid = [[Character]]

// A point on the grid
struct GridLocation: Hashable {
    let row: Int
    let col: Int
    var hashValue: Int { return row.hashValue ^ col.hashValue }
}
func == (lhs: GridLocation, rhs: GridLocation) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

// All the letters in our word search
let ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// randomly inserted with characters
func generateGrid(rows: Int, columns: Int) -> Grid {
    // initialize grid full of empty spaces
    var grid: Grid = Grid(repeating: [Character](repeating: " ", count: columns), count: rows)
    // replace spaces with random letters
    for row in 0..<rows {
        for col in 0..<columns {
            let loc = ALPHABET.index(ALPHABET.startIndex, offsetBy: Int(arc4random_uniform(UInt32(ALPHABET.characters.count))))
            grid[row][col] = ALPHABET[loc]
        }
    }
    return grid
}

func printGrid(_ grid: Grid) {
    for i in 0..<grid.count {
        print(String(grid[i]))
    }
}

var grid = generateGrid(rows: 9, columns: 9)

// generate domain for a word

func generateDomain(word: String, grid: Grid) -> [[GridLocation]] {
    var domain: [[GridLocation]] = [[GridLocation]]()
    let height = grid.count
    let width = grid[0].count
    let wordLength = word.characters.count
    for row in 0..<height {
        for col in 0..<width {
            let columns = col...(col + wordLength)
            let rows = row...(row + wordLength)
            if (col + wordLength <= width) {
                // left to right
                domain.append(columns.map({GridLocation(row: row, col: $0)}))
                // diagonal towards bottom right
                if (row + wordLength <= height) {
                    domain.append(rows.map({GridLocation(row: $0, col: col + ($0 - row))}))
                }
            }
            if (row + wordLength <= height) {
                // top to bottom
                domain.append(rows.map({GridLocation(row: $0, col: col)}))
                // diagonal towards bottom left
                if (col - wordLength >= 0) {
                    domain.append(rows.map({GridLocation(row: $0, col: col - ($0 - row))}))
                }
            }
        }
    }
    return domain
}


final class WordSearchConstraint: Constraint <String, [GridLocation]> {
    let words: [String]
    final override var vars: [String] {return words}
    
    init(words: [String]) {
        self.words = words
    }
    
    override func isSatisfied(assignment: Dictionary<String, [GridLocation]>) -> Bool {
        if Set<GridLocation>(assignment.values.flatMap({$0})).count < assignment.values.flatMap({$0}).count {
            return false
        }
        
        return true
    }
}

// Commented out because it takes a long time to execute! Uncomment all of the following
// lines to see the word search in action.

//let words: [String] = ["MATTHEW", "JOE", "MARY", "SARAH", "SALLY"]
//var locations = Dictionary<String, [[GridLocation]]>()
//for word in words {
//    locations[word] = generateDomain(word: word, grid: grid)
//}
//
//var wordsearch = CSP<String, [GridLocation]>(variables: words, domains: locations)
//wordsearch.addConstraint(WordSearchConstraint(words: words))
//if let solution = backtrackingSearch(csp: wordsearch) {
//    for (word, gridLocations) in solution {
//        let gridLocs = arc4random_uniform(2) > 0 ? gridLocations : gridLocations.reversed() // randomly reverse word half the time
//        for (index, letter) in word.characters.enumerated() {
//            let (row, col) = (gridLocs[index].row, gridLocations[index].col)
//            grid[row][col] = letter
//        }
//    }
//    printGrid(grid)
//} else { print("Couldn't find solution!") }

/// ###SEND+MORE=MONEY

final class SendMoreMoneyConstraint: Constraint <Character, Int> {
    let letters: [Character]
    final override var vars: [Character] {return letters}
    init(variables: [Character]) {
        letters = variables
    }
    
    override func isSatisfied(assignment: Dictionary<Character, Int>) -> Bool {
        // if there are duplicate values then it's not correct
        let d = Set<Int>(assignment.values)
        if d.count < assignment.count {
            return false
        }
        
        // if all variables have been assigned, check if it adds up correctly
        if assignment.count == letters.count {
            if let s = assignment["S"], let e = assignment["E"], let n = assignment["N"], let d = assignment["D"], let m = assignment["M"], let o = assignment["O"], let r = assignment["R"], let y = assignment["Y"] {
                let send: Int = s * 1000 + e * 100 + n * 10 + d
                let more: Int = m * 1000 + o * 100 + r * 10 + e
                let money: Int = m * 10000 + o * 1000 + n * 100 + e * 10 + y
                if (send + more) == money {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        // until we have all of the variables assigned, the assignment is valid
        return true
    }
}

let letters: [Character] = ["S", "E", "N", "D", "M", "O", "R", "Y"]
var possibleDigits = Dictionary<Character, [Int]>()
for letter in letters {
    possibleDigits[letter] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
}
possibleDigits["S"] = [9]
possibleDigits["M"] = [1]
possibleDigits["O"] = [0]

var smmcsp = CSP<Character, Int>(variables: letters, domains: possibleDigits)
let smmcon = SendMoreMoneyConstraint(variables: letters)
smmcsp.addConstraint(smmcon)

if let solution = backtrackingSearch(csp: smmcsp) {
    print(solution)
} else { print("Couldn't find solution!") }

//: [Next](@next)
