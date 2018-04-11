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
        return fibMemo[n]!
    }
}

fib3(n: 2)
fib3(n: 4)
fib3(n: 10)
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

/// Trivial Compression
struct CompressedGene {
    let length: Int
    private let bitVector: CFMutableBitVector
    
    init(original: String) {
        length = original.count
        // default allocator, need 2 * length number of bits
        bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, length * 2)
        CFBitVectorSetCount(bitVector, length * 2) // fills the bit vector with 0s
        compress(gene: original)
    }
    
    private func compress(gene: String) {
        for (index, nucleotide) in gene.uppercased().enumerated() {
            let nStart = index * 2 // start of each new nucleotide
            switch nucleotide {
            case "A": // 00
                CFBitVectorSetBitAtIndex(bitVector, nStart, 0)
                CFBitVectorSetBitAtIndex(bitVector, nStart + 1, 0)
            case "C": // 01
                CFBitVectorSetBitAtIndex(bitVector, nStart, 0)
                CFBitVectorSetBitAtIndex(bitVector, nStart + 1, 1)
            case "G": // 10
                CFBitVectorSetBitAtIndex(bitVector, nStart, 1)
                CFBitVectorSetBitAtIndex(bitVector, nStart + 1, 0)
            case "T": // 11
                CFBitVectorSetBitAtIndex(bitVector, nStart, 1)
                CFBitVectorSetBitAtIndex(bitVector, nStart + 1, 1)
            default:
                print("Unexpected character \(nucleotide) at \(index)")
            }
        }
    }
    
    func decompress() -> String {
        var gene: String = ""
        for index in 0..<length {
            let nStart = index * 2 // start of each nucleotide
            let firstBit = CFBitVectorGetBitAtIndex(bitVector, nStart)
            let secondBit = CFBitVectorGetBitAtIndex(bitVector, nStart + 1)
            switch (firstBit, secondBit) {
            case (0, 0): // 00 A
                gene += "A"
            case (0, 1): // 01 C
                gene += "C"
            case (1, 0): // 10 G
                gene += "G"
            case (1, 1): // 11 T
                gene += "T"
            default:
                break // unreachable, but need default
            }
        }
        return gene
    }
}

print(CompressedGene(original: "ATGAATGCC").decompress())

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
        pi += operation * (numerator / denominator)
        denominator += 2
        operation *= -1
    }
    return abs(pi)
}

calculatePi(nTerms: 1000)


/// The Towers of Hanoi

/// Implements a stack - LIFO helper class that uses an array internally.
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
