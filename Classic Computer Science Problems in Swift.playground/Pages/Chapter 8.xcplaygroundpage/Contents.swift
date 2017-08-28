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

// based on sedgewick second edition p 596
func knapsack(items: [Item], maxCapacity: Int) -> [Item] {
    //build up dynamic programming table
    var table: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: maxCapacity + 1), count: items.count + 1)  //initialize table - overshooting in size
    for i in 1...items.count {
        for capacity in 1...maxCapacity {
            if capacity - items[i - 1].weight >= 0 { // still room in knapsack
                table[i][capacity] = max(table[i - 1][capacity - items[i - 1].weight] + items[i - 1].value, table[i - 1][capacity])  // only take if more valuable than previous combo
            } else { // no room for this item
                table[i][capacity] = table[i - 1][capacity] //use prior combo
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
             Item(name: "refridgerator", weight: 200, value: 700),
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
    let possiblePaths = tspPaths(allPermutations(cities))
    var bestPath: [T] = []
    var minDistance: Int = Int.max
    for path in possiblePaths {
        if path.count < 2 { continue }
        var distance = 0
        var last = path.first! // we know there is one becuase of above line
        for next in path[1..<path.count] {
            distance += distances[last]![next]!
            last = next
        }
        if distance < minDistance {
            minDistance = distance
            bestPath = path
        }
    }
    return (solution: bestPath, distance: minDistance)
}

let vtTSP = solveTSP(cities: vtCities, distances: vtDistances)
print("The shortest path is \(vtTSP.solution) in \(vtTSP.distance) miles.")

//func dog(test: inout [String]) {
//    test.append("hello")
//
//}

// City 0

//: [Next](@next)

