//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 7 Source

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

/// Fairly Simple Neural Networks

import Accelerate
import Foundation

// MARK: Randomization & Statistical Helpers

// A derivative of the Fisher-Yates algorithm to shuffle an array
extension Array {
    public func shuffled() -> Array<Element> {
        var shuffledArray = self // value semantics (Array is Struct) makes this a copy
        if count < 2 { return shuffledArray } // already shuffled
        for i in (1..<count).reversed() { // count backwards
            let position = Int(arc4random_uniform(UInt32(i + 1))) // random to swap
            if i != position { // swap with the end, don't bother with self swaps
                shuffledArray.swapAt(i, position)
            }
        }
        return shuffledArray
    }
}

struct Random {
    private static var seeded = false
    
    // a random Double between *from* and *to*, assumes *from* < *to*
    static func double(from: Double, to: Double) -> Double {
        if !Random.seeded {
            srand48(time(nil))
            Random.seeded = true
        }
        
        return (drand48() * (to - from)) + from
    }
}

/// Create *number* of random Doubles between 0.0 and 1.0
func randomWeights(number: Int) -> [Double] {
    return (0..<number).map{ _ in Random.double(from: 0.0, to: 1.0) }
}

// MARK: SIMD Accelerated Math

// The next four functions are based on example from Surge project
// https://github.com/mattt/Surge/blob/master/Source/Arithmetic.swift
/// Find the dot product of two vectors
/// assuming that they are of the same length
/// using SIMD instructions to speed computation
func dotProduct(_ xs: [Double], _ ys: [Double]) -> Double {
    var answer: Double = 0.0
    vDSP_dotprD(xs, 1, ys, 1, &answer, vDSP_Length(xs.count))
    return answer
}

/// Subtract one vector from another
public func sub(_ x: [Double], _ y: [Double]) -> [Double] {
    var results = [Double](y)
    catlas_daxpby(Int32(x.count), 1.0, x, 1, -1, &results, 1)
    return results
}

/// Multiply two vectors together
public func mul(_ x: [Double], _ y: [Double]) -> [Double] {
    var results = [Double](repeating: 0.0, count: x.count)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
    return results
}

/// Sum a vector
public func sum(_ x: [Double]) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))
    return result
}

// MARK: Activation Functions and Their Derivatives

/// the classic sigmoid activation function
func sigmoid(_ x: Double) -> Double {
    return 1.0 / (1.0 + exp(-x))
}

// as derived at http://www.ai.mit.edu/courses/6.892/lecture8-html/sld015.htm
func derivativeSigmoid(_ x: Double) -> Double {
    return sigmoid(x) * (1 - sigmoid(x))
}

/// An individual node in a layer
class Neuron {
    var weights: [Double]
    var activationFunction: (Double) -> Double
    var derivativeActivationFunction: (Double) -> Double
    var outputCache: Double = 0.0
    var delta: Double = 0.0
    var learningRate: Double
    
    init(weights: [Double], activationFunction: @escaping (Double) -> Double, derivativeActivationFunction: @escaping (Double) -> Double, learningRate: Double) {
        self.weights = weights
        self.activationFunction = activationFunction
        self.derivativeActivationFunction = derivativeActivationFunction
        self.learningRate = learningRate
    }
    
    /// The output that will be going to the next layer
    /// or the final output if this is an output layer
    func output(inputs: [Double]) -> Double {
        outputCache = dotProduct(inputs, weights)
        return activationFunction(outputCache)
    }
    
}

class Layer {
    let previousLayer: Layer?
    var neurons: [Neuron]
    var outputCache: [Double]
    
    init(previousLayer: Layer? = nil, numNeurons: Int, activationFunction: @escaping (Double) -> Double, derivativeActivationFunction: @escaping (Double) -> Double, learningRate: Double) {
        self.previousLayer = previousLayer
        self.neurons = Array<Neuron>()
        for _ in 0..<numNeurons {
            self.neurons.append(Neuron(weights: randomWeights(number: previousLayer?.neurons.count ?? 0), activationFunction: activationFunction, derivativeActivationFunction: derivativeActivationFunction, learningRate: learningRate))
        }
        self.outputCache = Array<Double>(repeating: 0.0, count: neurons.count)
    }
    
    func outputs(inputs: [Double]) -> [Double] {
        if previousLayer == nil { // input layer (first layer)
            outputCache = inputs
        } else { // hidden layer or output layer
            outputCache = neurons.map { $0.output(inputs: inputs) }
        }
        return outputCache
    }
    
    // should only be called on an output layer
    func calculateDeltasForOutputLayer(expected: [Double]) {
        for n in 0..<neurons.count {
            neurons[n].delta = neurons[n].derivativeActivationFunction(neurons[n].outputCache) * (expected[n] - outputCache[n])
        }
    }
    
    // should not be called on output layer
    func calculateDeltasForHiddenLayer(nextLayer: Layer) {
        for (index, neuron) in neurons.enumerated() {
            let nextWeights = nextLayer.neurons.map { $0.weights[index] }
            let nextDeltas = nextLayer.neurons.map { $0.delta }
            let sumOfWeightsXDeltas = dotProduct(nextWeights, nextDeltas)
            neuron.delta = neuron.derivativeActivationFunction(neuron.outputCache) * sumOfWeightsXDeltas
        }
    }
}

/// Represents an entire neural network. From largest to smallest we go
/// Network -> Layers -> Neurons
class Network {
    var layers: [Layer]
    
    init(layerStructure:[Int], activationFunction: @escaping (Double) -> Double = sigmoid, derivativeActivationFunction: @escaping (Double) -> Double = derivativeSigmoid, learningRate: Double) {
        if (layerStructure.count < 3) {
            print("Error: Should be at least 3 layers (1 input, 1 hidden, 1 output)")
        }
        layers = [Layer]()
        // input layer
        layers.append(Layer(numNeurons: layerStructure[0], activationFunction: activationFunction, derivativeActivationFunction: derivativeActivationFunction, learningRate: learningRate))
        
        // hidden layers and output layer
        for x in layerStructure.enumerated() where x.offset != 0 {
            layers.append(Layer(previousLayer: layers[x.offset - 1], numNeurons: x.element, activationFunction: activationFunction, derivativeActivationFunction: derivativeActivationFunction, learningRate: learningRate))
        }
    }
    
    /// pushes input data to the first layer
    /// then output from the first as input to the second
    /// second to the third, etc.
    func outputs(input: [Double]) -> [Double] {
        return layers.reduce(input) { $1.outputs(inputs: $0) }
    }
    
    /// Figure out each neuron's changes based on the errors
    /// of the output versus the expected outcome
    func backpropagate(expected: [Double]) {
        //calculate delta for output layer neurons
        layers.last?.calculateDeltasForOutputLayer(expected: expected)
        //calculate delta for prior layers
        for l in (1..<layers.count - 1).reversed() {
            layers[l].calculateDeltasForHiddenLayer(nextLayer: layers[l + 1])
        }
    }
    
    /// backpropagate() doesn't actually change any weights
    /// this function uses the deltas calculated in backpropagate()
    /// to actually make changes to the weights
    func updateWeights() {
        for layer in layers.dropFirst() { // skip input layer
            for neuron in layer.neurons {
                for w in 0..<neuron.weights.count {
                    neuron.weights[w] = neuron.weights[w] + (neuron.learningRate * (layer.previousLayer?.outputCache[w])! * neuron.delta)
                }
            }
        }
    }
    
    /// train() uses the results of outputs() run over
    /// many *inputs* and compared against *expecteds* to feed
    /// backpropagate() and updateWeights()
    func train(inputs: [[Double]], expecteds: [[Double]], printError: Bool = false) {
        for (location, xs) in inputs.enumerated() {
            let ys = expecteds[location]
            let outs = outputs(input: xs)
            if (printError) {
                let diff = sub(outs, ys)
                let error = sqrt(sum(mul(diff, diff)))
                print("\(error) error in run \(location)")
            }
            backpropagate(expected: ys)
            updateWeights()
        }
    }
    
    /// for generalized results that require classification
    /// this function will return the correct number of trials
    /// and the percentage correct out of the total
    func validate<T: Equatable>(inputs:[[Double]], expecteds:[T], interpretOutput: ([Double]) -> T) -> (correct: Int, total: Int, percentage: Double) {
        var correct = 0
        for (input, expected) in zip(inputs, expecteds) {
            let result = interpretOutput(outputs(input: input))
            if result == expected {
                correct += 1
            }
        }
        let percentage = Double(correct) / Double(inputs.count)
        return (correct, inputs.count, percentage)
    }
}

/// MARK: Normalization

/// assumes all rows are of equal length
/// and feature scale each column to be in the range 0 – 1
func normalizeByFeatureScaling(dataset: inout [[Double]]) {
    for colNum in 0..<dataset[0].count {
        let column = dataset.map { $0[colNum] }
        let maximum = column.max()!
        let minimum = column.min()!
        for rowNum in 0..<dataset.count {
            dataset[rowNum][colNum] = (dataset[rowNum][colNum] - minimum) / (maximum - minimum)
        }
    }
}

// MARK: Iris Test

//func parseIrisCSV() -> (parameters: [[Double]], classifications: [[Double]], species: [String]) {
//    let urlpath = Bundle.main.path(forResource: "iris", ofType: "csv")
//    let url = URL(fileURLWithPath: urlpath!)
//    let csv = try! String.init(contentsOf: url)
//    let lines = csv.components(separatedBy: "\n")
//    var irisParameters: [[Double]] = [[Double]]()
//    var irisClassifications: [[Double]] = [[Double]]()
//    var irisSpecies: [String] = [String]()
//
//    let shuffledLines = lines.shuffled()
//    for line in shuffledLines {
//        if line == "" { continue } // skip blank lines
//        let items = line.components(separatedBy: ",")
//        let parameters = items[0...3].map{ Double($0)! }
//        irisParameters.append(parameters)
//        let species = items[4]
//        if species == "Iris-setosa" {
//            irisClassifications.append([1.0, 0.0, 0.0])
//        } else if species == "Iris-versicolor" {
//            irisClassifications.append([0.0, 1.0, 0.0])
//        } else {
//            irisClassifications.append([0.0, 0.0, 1.0])
//        }
//        irisSpecies.append(species)
//    }
//    normalizeByFeatureScaling(dataset: &irisParameters)
//    return (irisParameters, irisClassifications, irisSpecies)
//}
//
//let (irisParameters, irisClassifications, irisSpecies) = parseIrisCSV()
//
//let irisNetwork: Network = Network(layerStructure: [4, 6, 3], learningRate: 0.3)
//
//func irisInterpretOutput(output: [Double]) -> String {
//    if output.max()! == output[0] {
//        return "Iris-setosa"
//    } else if output.max()! == output[1] {
//        return "Iris-versicolor"
//    } else {
//        return "Iris-virginica"
//    }
//}
//
//// train over first 140 irises in data set 20 times
//let irisTrainers = Array(irisParameters[0..<140])
//let irisTrainersCorrects = Array(irisClassifications[0..<140])
//for _ in 0..<20 {
//    irisNetwork.train(inputs: irisTrainers, expecteds: irisTrainersCorrects, printError: false)
//}
//
//// test over the last 10 of the irses in the data set
//let irisTesters = Array(irisParameters[140..<150])
//let irisTestersCorrects = Array(irisSpecies[140..<150])
//let irisResults = irisNetwork.validate(inputs: irisTesters, expecteds: irisTestersCorrects, interpretOutput: irisInterpretOutput)
//print("\(irisResults.correct) correct of \(irisResults.total) = \(irisResults.percentage * 100)%")

/// Wine Test

func parseWineCSV() -> (parameters: [[Double]], classifications: [[Double]], species: [Int]) {
    let urlpath = Bundle.main.path(forResource: "wine", ofType: "csv")
    let url = URL(fileURLWithPath: urlpath!)
    let csv = try! String.init(contentsOf: url)
    let lines = csv.components(separatedBy: "\n")
    var wineParameters: [[Double]] = [[Double]]()
    var wineClassifications: [[Double]] = [[Double]]()
    var wineSpecies: [Int] = [Int]()

    let shuffledLines = lines.shuffled()
    for line in shuffledLines {
        if line == "" { continue } // skip blank lines
        let items = line.components(separatedBy: ",")
        let parameters = items[1...13].map{ Double($0)! }
        wineParameters.append(parameters)
        let species = Int(items[0])!
        if species == 1 {
            wineClassifications.append([1.0, 0.0, 0.0])
        } else if species == 2 {
            wineClassifications.append([0.0, 1.0, 0.0])
        } else {
            wineClassifications.append([0.0, 0.0, 1.0])
        }
        wineSpecies.append(species)
    }
    normalizeByFeatureScaling(dataset: &wineParameters)
    return (wineParameters, wineClassifications, wineSpecies)
}

let (wineParameters, wineClassifications, wineSpecies) = parseWineCSV()

let wineNetwork: Network = Network(layerStructure: [13, 7, 3], learningRate: 0.9)

func wineInterpretOutput(output: [Double]) -> Int {
    if output.max()! == output[0] {
        return 1
    } else if output.max()! == output[1] {
        return 2
    } else {
        return 3
    }
}

// train over the first 150 samples 5 times
let wineTrainers = Array(wineParameters.dropLast(28))
let wineTrainersCorrects = Array(wineClassifications.dropLast(28))
for _ in 0..<5 {
    wineNetwork.train(inputs: wineTrainers, expecteds: wineTrainersCorrects, printError: false)
}

let wineTesters = Array(wineParameters.dropFirst(150))
let wineTestersCorrects = Array(wineSpecies.dropFirst(150))
let results = wineNetwork.validate(inputs: wineTesters, expecteds: wineTestersCorrects, interpretOutput: wineInterpretOutput)
print("\(results.correct) correct of \(results.total) = \(results.percentage * 100)%")

//: [Next](@next)

