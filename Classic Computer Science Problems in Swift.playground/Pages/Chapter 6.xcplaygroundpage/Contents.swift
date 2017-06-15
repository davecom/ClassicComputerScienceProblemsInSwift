//: [Previous](@previous)

// Classic Computer Science Problems in Swift Chapter 6 Source

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

import Foundation // for pow(), srand48(), drand48()

extension Array where Element == Double {
    var sum: Double {
        return self.reduce(0.0, +)
    }
    
    // Find the average (mean)
    var mean: Double {
        return sum / Double(self.count)
    }
    
    // Find the variance sum((Xi - mean)^2) / N
    var variance: Double {
        let mean = self.mean // cache so not recalculated for every element
        return self.map { pow(($0 - mean), 2) }.mean
    }
    
    // Find the standard deviation sqrt(variance)
    var std: Double {
        return sqrt(variance)
    }
    
    // Convert elements to respective z-scores (formula z-score = (x - mean) / std)
    var zscored: [Double] {
        let mean = self.mean
        let std = self.std
        return self.map{ std != 0 ? (($0 - mean) / std) : 0.0 } // avoid divide by zero
    }
}

let test: [Double] = [600, 470, 170, 430, 300]
test.sum
test.mean
test.variance
test.std
test.zscored

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

public protocol DataPoint: CustomStringConvertible, Equatable {
    static var numDimensions: UInt { get }
    var dimensions: [Double] { get set }
    init(values: [Double])
}

extension DataPoint {
    // euclidean distance
    func distance<PointType: DataPoint>(to: PointType) -> Double {
        return sqrt(zip(dimensions, to.dimensions).map({ pow(($0.1 - $0.0), 2) }).sum)
    }
}

public struct Point3D: DataPoint {
    public static let numDimensions: UInt = 3
    public let x: Double
    public let y: Double
    public let z: Double
    public var dimensions: [Double]
    
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
        dimensions = [x, y, z]
    }
    
    public init(values: [Double]) {
        self.x = values[0]
        self.y = values[1]
        self.z = values[2]
        dimensions = values
    }
    
    // Implement Equatable
    public static func == (lhs: Point3D, rhs: Point3D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    // Implement CustomStringConvertible
    public var description: String {
        return "(\(x), \(y), \(z))"
    }
}

let j = Point3D(x: 2.0, y: 1.0, z: 1.0)
let k = Point3D(x: 2.0, y: 2.0, z: 5.0)
j.distance(to: k)

public final class KMeans<PointType: DataPoint> {
    public final class Cluster {
        var points: [PointType] = [PointType]()
        var centroid: PointType
        init(centroid: PointType) {
            self.centroid = centroid
        }
    }
    
    private var points: [PointType]
    private var clusters: [Cluster]
    
    private var centroids: [PointType] {
        return clusters.map{ $0.centroid }
    }
    
    init(k: UInt, points: [PointType]) {
        self.points = points
        clusters = [Cluster]()
        zscoreNormalize()
        for _ in 0..<k { // initialize a random centroid for each cluster
            let randPoint = randomPoint()
            clusters.append(Cluster(centroid: randPoint))
        }
    }
    
    private func dimensionSlice(_ index: Int) -> [Double] {
        return points.map{ $0.dimensions[index] }
    }
    
    private func zscoreNormalize() {
        for dimension in 0..<Int(PointType.numDimensions) {
            for (index, zscore) in dimensionSlice(dimension).zscored.enumerated() {
                points[index].dimensions[dimension] = zscore
            }
        }
    }
    
    private func randomPoint() -> PointType {
        var randDimensions = [Double]()
        for dimension in 0..<Int(PointType.numDimensions) {
            let values = dimensionSlice(dimension)
            let randValue = Random.double(from: values.min()!, to:values.max()!)
            randDimensions.append(randValue)
        }
        return PointType(values: randDimensions)
    }
    
    // Find the closest cluster centroid to each point and assign the point to that cluster
    private func assignClusters() {
        for point in points {
            var lowestDistance = Double.greatestFiniteMagnitude // temporary
            var closestCluster = clusters.first!
            for (index, centroid) in centroids.enumerated() {
                if centroid.distance(to: point) < lowestDistance {
                    lowestDistance = centroid.distance(to: point)
                    closestCluster = clusters[index]
                }
            }
            closestCluster.points.append(point)
        }
    }
    
    // find the center of each cluster and move the centroid to there
    private func generateCentroids() {
        for cluster in clusters {
            var means: [Double] = [Double]()
            for dimension in 0..<Int(PointType.numDimensions) {
                means.append(cluster.points.map({ $0.dimensions[dimension] }).mean)
            }
            cluster.centroid = PointType(values: means)
        }
    }
    
    public func run(maxIterations: UInt = UInt.max) -> [Cluster] {
        for iteration in 0..<maxIterations {
            clusters.forEach{ $0.points.removeAll() } // clear all clusters
            assignClusters() // find clusters each is closest to - assign
            let lastCentroids = centroids // record centroids
            generateCentroids() // find new centroids
            if lastCentroids == centroids { // have centroids moved?
                print("Converged after \(iteration) iterations.")
                return clusters // they haven't moved, so we've converged
            }
        }
        
        return clusters
    }
}

let kmeansTest = KMeans<Point3D>(k: 1, points: [j, k])
let testClusters = kmeansTest.run()
for (index, cluster) in testClusters.enumerated() {
    print("Cluster \(index): \(cluster.points)")
}


struct Governor: DataPoint {
    public static let numDimensions: UInt = 2
    public let longitude: Double
    public let age: Double
    public var dimensions: [Double]
    public let state: String
    
    public init(longitude: Double, age: Double, state: String) {
        self.longitude = longitude
        self.age = age
        self.state = state
        dimensions = [longitude, age]
    }
    
    public init(values: [Double]) {
        self.longitude = values[0]
        self.age = values[1]
        self.state = ""
        dimensions = values
    }
    
    // Implement Equatable
    public static func == (lhs: Governor, rhs: Governor) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.age == rhs.age && lhs.state == rhs.state
    }
    
    // Implement CustomStringConvertible
    public var description: String {
        return "\(state): (longitude: \(longitude), age: \(age))"
    }
}

let governors = [Governor(longitude: -86.79113, age: 72, state: "Alabama"), Governor(longitude: -152.404419, age: 66, state: "Alaska"), Governor(longitude: -111.431221, age: 53, state: "Arizona"), Governor(longitude: -92.373123, age: 66, state: "Arkansas"), Governor(longitude: -119.681564, age: 79, state: "California"), Governor(longitude: -105.311104, age: 65, state: "Colorado"), Governor(longitude: -72.755371, age: 61, state: "Connecticut"), Governor(longitude: -75.507141, age: 61, state: "Delaware"), Governor(longitude: -81.686783, age: 64, state: "Florida"), Governor(longitude: -83.643074, age: 74, state: "Georgia"), Governor(longitude: -157.498337, age: 60, state: "Hawaii"), Governor(longitude: -114.478828, age: 75, state: "Idaho"), Governor(longitude: -88.986137, age: 60, state: "Illinois"), Governor(longitude: -86.258278, age: 49, state: "Indiana"), Governor(longitude: -93.210526, age: 57, state: "Iowa"), Governor(longitude: -96.726486, age: 60, state: "Kansas"), Governor(longitude: -84.670067, age: 50, state: "Kentucky"), Governor(longitude: -91.867805, age: 50, state: "Louisiana"), Governor(longitude: -69.381927, age: 68, state: "Maine"), Governor(longitude: -76.802101, age: 61, state: "Maryland"), Governor(longitude: -71.530106, age: 60, state: "Massachusetts"), Governor(longitude: -84.536095, age: 58, state: "Michigan"), Governor(longitude: -93.900192, age: 70, state: "Minnesota"), Governor(longitude: -89.678696, age: 62, state: "Mississippi"), Governor(longitude: -92.288368, age: 43, state: "Missouri"), Governor(longitude: -110.454353, age: 51, state: "Montana"), Governor(longitude: -98.268082, age: 52, state: "Nebraska"), Governor(longitude: -117.055374, age: 53, state: "Nevada"), Governor(longitude: -71.563896, age: 42, state: "New Hampshire"), Governor(longitude: -74.521011, age: 54, state: "New Jersey"), Governor(longitude: -106.248482, age: 57, state: "New Mexico"), Governor(longitude: -74.948051, age: 59, state: "New York"), Governor(longitude: -79.806419, age: 60, state: "North Carolina"), Governor(longitude: -99.784012, age: 60, state: "North Dakota"), Governor(longitude: -82.764915, age: 65, state: "Ohio"), Governor(longitude: -96.928917, age: 62, state: "Oklahoma"), Governor(longitude: -122.070938, age: 56, state: "Oregon"), Governor(longitude: -77.209755, age: 68, state: "Pennsylvania"), Governor(longitude: -71.51178, age: 46, state: "Rhode Island"), Governor(longitude: -80.945007, age: 70, state: "South Carolina"), Governor(longitude: -99.438828, age: 64, state: "South Dakota"), Governor(longitude: -86.692345, age: 58, state: "Tennessee"), Governor(longitude: -97.563461, age: 59, state: "Texas"), Governor(longitude: -111.862434, age: 70, state: "Utah"), Governor(longitude: -72.710686, age: 58, state: "Vermont"), Governor(longitude: -78.169968, age: 60, state: "Virginia"), Governor(longitude: -121.490494, age: 66, state: "Washington"), Governor(longitude: -80.954453, age: 66, state: "West Virginia"), Governor(longitude: -89.616508, age: 49, state: "Wisconsin"), Governor(longitude: -107.30249, age: 55, state: "Wyoming")]

let kmeans = KMeans<Governor>(k: 2, points: governors)
let govClusters = kmeans.run()
for (index, cluster) in govClusters.enumerated() {
    print("Cluster \(index): \(cluster.points)")
}

//: [Next](@next)
