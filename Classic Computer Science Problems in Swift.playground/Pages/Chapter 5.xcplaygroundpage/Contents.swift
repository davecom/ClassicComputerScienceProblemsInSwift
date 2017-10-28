//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 5 Source

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

import Foundation // for arc4random_uniform() and drand48()

srand48(time(nil)) // seed random number generator for drand48()

// A derivative of the Fisher-Yates algorithm to shuffle an array
extension Array {
    public func shuffled() -> Array<Element> {
        var shuffledArray = self // value semantics (Array is Struct) makes this a copy
        if count < 2 { return shuffledArray } // already shuffled
        for i in (1..<count).reversed() { // count backwards
            let position = Int(arc4random_uniform(UInt32(i + 1))) // random to swap
            if i != position { // swap with the end, don't bother with swap
                shuffledArray.swapAt(i, position)
            }
        }
        return shuffledArray
    }
}

public protocol Chromosome {
    var fitness: Double { get } // how well does this individual solve the problem?
    init(from: Self) // must be able to copy itself
    static func randomInstance() -> Self
    func crossover(other: Self) -> (child1: Self, child2: Self) // combine with other to form children
    func mutate() // make a small change somewhere
    func prettyPrint()
}

open class GeneticAlgorithm<ChromosomeType: Chromosome> {
    enum SelectionType {
        case roulette
        case tournament(UInt) // the Int is the number of participants in the tournament
    }
    
    private let threshold: Double // at what fitness level to stop running
    private let maxGenerations: UInt // number of generations to run
    private let mutationChance: Double // probability of mutation for each individual in each generation
    private let crossoverChance: Double // probability of any two children being crossed each generation
    private let selectionType: SelectionType // which selection method?
    
    private var population: [ChromosomeType] // all of the individuals in a generation
    private var fitnessCache: [Double] // the fitness of each individual in the current generation
    private var fitnessSum: Double = -Double.greatestFiniteMagnitude // summed generation fitness
    
    init(size: UInt, threshold: Double, maxGenerations: UInt = 100, mutationChance: Double = 0.01, crossoverChance: Double = 0.7, selectionType: SelectionType = SelectionType.tournament(4)) {
        self.threshold = threshold
        self.maxGenerations = maxGenerations
        self.mutationChance = mutationChance
        self.crossoverChance = crossoverChance
        self.selectionType = selectionType
        
        population = [ChromosomeType]() // initialize the population with random chromosomes
        for _ in 0..<size {
            population.append(ChromosomeType.randomInstance())
        }
        fitnessCache = [Double](repeating: -Double.greatestFiniteMagnitude, count: Int(size))
    }
    
    // pick based on the proportion of summed total fitness that each individual represents
    private func pickRoulette(wheel: [Double]) -> ChromosomeType {
        var pick = drand48() // chance of picking a particular one
        for (index, chance) in wheel.enumerated() {
            pick -= chance
            if pick <= 0 { // we had one that took us over, leads to a pick
                return population[index]
            }
        }
        return population[0]
    }
    
    // find k random individuals in the population and pick the best one
    private func pickTournament(numParticipants: UInt) -> ChromosomeType {
        var best: ChromosomeType = ChromosomeType.randomInstance()
        var bestFitness: Double = best.fitness
        for _ in 0..<numParticipants { // find the best participant
            let test = Int(arc4random_uniform(UInt32(population.count)))
            if fitnessCache[test] > bestFitness {
                bestFitness = fitnessCache[test]
                best = population[test]
            }
        }
        return best
    }
    
    private func reproduceAndReplace() {
        var newPopulation: [ChromosomeType] = [ChromosomeType]() // replacement population
        var chanceEach: [Double] = [Double]() // used for pickRoulette, chance of each individual being picked
        if case .roulette = selectionType {
            chanceEach = fitnessCache.map({return $0/fitnessSum})
        }
        while newPopulation.count < population.count {
            var parents: (parent1: ChromosomeType, parent2: ChromosomeType)
            switch selectionType { // how to pick parents
            case let .tournament(k):
                parents = (parent1: pickTournament(numParticipants: k), parent2: pickTournament(numParticipants: k))
            default: // don't have a case for roulette because no other option
                parents = (parent1: pickRoulette(wheel: chanceEach), parent2: pickRoulette(wheel: chanceEach))
            }
            if drand48() < crossoverChance { // if crossover, produce children
                let children = parents.parent1.crossover(other: parents.parent2)
                newPopulation.append(children.child1)
                newPopulation.append(children.child2)
            } else { // no crossover, just use parents
                newPopulation.append(parents.parent1)
                newPopulation.append(parents.parent2)
            }
        }
        if newPopulation.count > population.count { // in case we had an odd population
            newPopulation.removeLast()
        }
        population = newPopulation
    }
    
    private func mutate() {
        for individual in population { // every individual could possibly be mutated each generation
            if drand48() < mutationChance {
                individual.mutate()
            }
        }
    }
    
    public func run() -> ChromosomeType {
        var best: ChromosomeType = ChromosomeType.randomInstance() // best in any run so far
        var bestFitness: Double = best.fitness
        for generation in 1...maxGenerations { // try maxGenerations of the genetic algorithm
            print("generation \(generation) best \(best.fitness) avg \(fitnessSum / Double(fitnessCache.count))")
            for (index, individual) in population.enumerated() {
                fitnessCache[index] = individual.fitness
                if fitnessCache[index] >= threshold { // early end; found something great
                    return individual
                }
                if fitnessCache[index] > bestFitness { // best so far in any iteration
                    bestFitness = fitnessCache[index]
                    best = ChromosomeType(from: individual)
                }
            }
            fitnessSum = fitnessCache.reduce(0, +)
            reproduceAndReplace()
            mutate()
        }
        return best
    }
}

final class SimpleEquation: Chromosome {
    var x: Int = Int(arc4random_uniform(100))
    var y: Int = Int(arc4random_uniform(100))
    
    var fitness: Double { // 6x - x^2 + 4y - y^2
        return Double(6 * x - x * x + 4 * y - y * y)
    }
    
    init(from: SimpleEquation) { // like making a copy
        x = from.x
        y = from.y
    }
    
    init() {}
    
    static func randomInstance() -> SimpleEquation {
        return SimpleEquation()
    }
    
    func crossover(other: SimpleEquation) -> (child1: SimpleEquation, child2: SimpleEquation) {
        let child1 = SimpleEquation(from: self)
        let child2 = SimpleEquation(from: other)
        child1.y = other.y
        child2.y = self.y
        return (child1: child1, child2: child2)
    }
    
    func mutate() {
        if drand48() > 0.5 { // mutate x
            if drand48() > 0.5 {
                x += 1
            } else {
                x -= 1
            }
        } else { // otherwise mutate y
            if drand48() > 0.5 {
                y += 1
            } else {
                y -= 1
            }
        }
    }
    
    func prettyPrint() {
        print("x:\(x) y:\(y) fitness:\(fitness)")
    }
}

let se = GeneticAlgorithm<SimpleEquation>(size: 10, threshold: 13.0, maxGenerations: 100, mutationChance: 0.1, crossoverChance: 0.7)
let result1 = se.run()
result1.fitness
result1.prettyPrint()




final class SendMoreMoney: Chromosome {
    var genes: [Character]
    static let letters: [Character] = ["S", "E", "N", "D", "M", "O", "R", "Y", " ", " "]
    
    var fitness: Double {
        if let s = genes.index(of: "S"), let e = genes.index(of: "E"), let n = genes.index(of: "N"), let d = genes.index(of: "D"), let m = genes.index(of: "M"), let o = genes.index(of: "O"), let r = genes.index(of: "R"), let y = genes.index(of: "Y") {
            let send: Int = s * 1000 + e * 100 + n * 10 + d
            let more: Int = m * 1000 + o * 100 + r * 10 + e
            let money: Int = m * 10000 + o * 1000 + n * 100 + e * 10 + y
            let difference = abs(money - (send + more))
            return 1/Double(difference + 1)
        }
        return 0
    }
    
    init(from: SendMoreMoney) {
        genes = from.genes
    }
    
    init(genes: [Character]) {
        self.genes = genes
    }
    
    static func randomInstance() -> SendMoreMoney {
        return SendMoreMoney(genes: letters.shuffled())
    }
    
    func crossover(other: SendMoreMoney) -> (child1: SendMoreMoney, child2: SendMoreMoney) {
        let crossingPoint = Int(arc4random_uniform(UInt32(genes.count)))
        let childGenes1 = genes[0..<crossingPoint] + other.genes[crossingPoint..<other.genes.count]
        let childGenes2 = other.genes[0..<crossingPoint] + genes[crossingPoint..<genes.count]
        return (child1: SendMoreMoney(genes: Array(childGenes1)), child2: SendMoreMoney(genes: Array(childGenes2)))
    }
    
    func mutate() {
        // put a random letter in a random place
        let position1 = Int(arc4random_uniform(UInt32(SendMoreMoney.letters.count)))
        let position2 = Int(arc4random_uniform(UInt32(genes.count)))
        if drand48() < 0.5 { // half the time random letter
            genes[position2] = SendMoreMoney.letters[position1]
        } else { // half the time random swap
            if position1 != position2 { genes.swapAt(position1, position2) }
        }
    }
    
    func prettyPrint() {
        if let s = genes.index(of: "S"), let e = genes.index(of: "E"), let n = genes.index(of: "N"), let d = genes.index(of: "D"), let m = genes.index(of: "M"), let o = genes.index(of: "O"), let r = genes.index(of: "R"), let y = genes.index(of: "Y") {
            let send: Int = s * 1000 + e * 100 + n * 10 + d
            let more: Int = m * 1000 + o * 100 + r * 10 + e
            let money: Int = m * 10000 + o * 1000 + n * 100 + e * 10 + y
            print("\(send) + \(more) = \(money) difference:\(money - (send + more))")
        } else {
            print("Missing some letters")
        }
    }
}

// experimentally, n=100, mchance=.3, and cchance=.7 seem to work well
let smm: GeneticAlgorithm<SendMoreMoney> = GeneticAlgorithm<SendMoreMoney>(size: 100, threshold: 1.0, maxGenerations: 1000, mutationChance: 0.3, crossoverChance: 0.7, selectionType: .tournament(5))
let result2 = smm.run()
result2.prettyPrint()

//: [Next](@next)
