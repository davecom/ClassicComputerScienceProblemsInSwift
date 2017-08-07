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

//: [Next](@next)

