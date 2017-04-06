//: Playground - noun: a place where people can play

// Classic Computer Science Problems in Swift Chapter 1 Source 

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

/// Fibonacci

// uh oh infinite recursion
func fib1(n: UInt) -> UInt {
    return fib1(n: n - 1) + fib1(n: n - 2)
}

// it works, but it's slow
func fib2(n: UInt) -> UInt {
    if (n < 2) {  // base cases
        return n
    }
    return fib2(n: n - 2) + fib2(n: n - 1)  // recursive cases
}

fib2(n: 2)
fib2(n: 5)
fib2(n: 10)

// memoization for the win
var fibMemo: [UInt: UInt] = [0: 0, 1: 1]  // our old base cases
func fib3(n: UInt) -> UInt {
    if let result = fibMemo[n] {  // our new base case
        return result
    } else {
        fibMemo[n] = fib3(n: n - 1) + fib3(n: n - 2)  // memoization
    }
    return fibMemo[n]!
}

fib3(n: 2)
fib3(n: 4)
fib2(n: 10)
fib3(n: 20)
fib3(n: 21)
//print(fibMemo)

func fib4(n: UInt) -> UInt {
    if (n == 0) {  // special case
        return n
    }
    var last: UInt = 0, next: UInt = 1  // initially set to fib(0) & fib(1)
    for _ in 1..<n {
        (last, next) = (next, last + next)
    }
    return next
}

fib4(n: 20)

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

/// Unbreakable Encryption

typealias OTPKey = [UInt8]
typealias OTPKeyPair = (key1: OTPKey, key2: OTPKey)

func randomOTPKey(length: Int) -> OTPKey {
    var randomKey: OTPKey = OTPKey()
    for _ in 0..<length {
        let randomKeyPoint = UInt8(arc4random_uniform(UInt32(UInt8.max)))
        randomKey.append(randomKeyPoint)
    }
    return randomKey
}

func encryptOTP(original: String) -> OTPKeyPair {
    let dummy = randomOTPKey(length: original.utf8.count)
    let encrypted: OTPKey = dummy.enumerated().map { i, e in
        return e ^ original.utf8[original.utf8.index(original.utf8.startIndex, offsetBy: i)]
    }
    return (dummy, encrypted)
}

func decryptOTP(keyPair: OTPKeyPair) -> String? {
    let decrypted: OTPKey = keyPair.key1.enumerated().map { i, e in
        e ^ keyPair.key2[i]
    }
    return String(bytes: decrypted, encoding:String.Encoding.utf8)
}

decryptOTP(keyPair: encryptOTP(original: "¡Vamos Swift!👍🏼"))

/// Calculating Pi

func calculatePi(nTerms: UInt) -> Double {
    let numerator: Double = 4
    var denominator: Double = 1
    var operation: Double = -1
    var pi: Double = 0
    for _ in 0..<nTerms {
        pi = pi + operation * (numerator / denominator)
        denominator += 2
        operation = operation * -1
    }
    return abs(pi)
}

calculatePi(nTerms: 1000)


/// The Towers of Hanoi

/// Implements a stack - helper class that uses an array internally.
public class Stack<T>: CustomStringConvertible {
    private var container: [T] = [T]()
    public func push(_ thing: T) { container.append(thing) }
    public func pop() -> T { return container.removeLast() }
    public var description: String { return container.description }
}

var numDiscs = 3
var towerA = Stack<Int>()
var towerB = Stack<Int>()
var towerC = Stack<Int>()
for i in 1...numDiscs {  // initialize the first tower
    towerA.push(i)
}

towerA

func hanoi(from: Stack<Int>, to: Stack<Int>, temp: Stack<Int>, n: Int) {
    if n == 1 {  // base case
        to.push(from.pop()) // move 1 disk
    } else {  // recursive case
        hanoi(from: from, to: temp, temp: to, n: n-1)
        hanoi(from: from, to: to, temp: temp, n: 1)
        hanoi(from: temp, to: to, temp: from, n: n-1)
    }
}

hanoi(from: towerA, to: towerC, temp: towerB,  n: numDiscs)
print(towerA)
print(towerB)
print(towerC)
