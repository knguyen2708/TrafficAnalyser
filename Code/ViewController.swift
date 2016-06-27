//
//  ViewController.swift
//  Traffic_Eric
//
//  Created by Khanh Nguyen on 27/06/2016.
//  Copyright © 2016 knguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Entries
        let entries = parseData()
        
//        for e in entries {
//            print("\(e)")
//        }
        
        // Cluster analyses
        let clusters = cluster(entries)
        
        print("total clusters = \(clusters.count)")
        
        let loneClusters = clusters.filter { $0.entries.count <= 1 }
//        loneClusters.forEach { $0.dprint() }
        print("lone clusters = \(loneClusters.count)")
        
        
        // clusters = clusters.filter { $0.span > 200 }
        let stretchedClusters = clusters.filter { $0.maxDiff > 300 }
        print("stretched clusters = \(stretchedClusters.count)")
        
        let stretchedMaxDiff = stretchedClusters.map { $0.maxDiff }.maxElement()!
        print("stretched clusters - max diff = \(stretchedMaxDiff)")
        
        stretchedClusters.forEach {
            $0.dprint()
            print("-----")
        }
        
        // Extract vehicles
        var vehicles: [Vehicle] = []
        for cluster in clusters {
            let vs = analyzeCluster(cluster)
            vehicles += vs
        }
        
        // let northVehicles = vehicles.filter { $0.north }
        
        // let southVehicles = vehicles.filter { !$0.north }
//        let avgHoseTime = southVehicles.map { $0.hoseTimeDiff! }.reduce(0, combine: { $0 + $1 }) / Double(southVehicles.count)
//        let hoseDistance =
        
        // Display
        let northCount = vehicles.filter { $0.north }.count
        let southCount = vehicles.filter { !$0.north }.count
        let total = vehicles.count
        let maxPerHour = count(vehicles, timeWindow: 1 * 3600 * 1000).maxElement()!
        
        graphView.vehicles = vehicles
        infoLabel.text = "North: \(northCount) | South: \(southCount) | Total: \(total) | Max / hour: \(maxPerHour)"
    }
    
    private func count(vehicles: [Vehicle], timeWindow: Double) -> [Int] {
        
        var counts: [Int] = []
        // var countPerDay = 24 * 3600 * 1000 / timeWindow
        
        let minDay = vehicles.map { $0.day }.minElement()!
        let maxDay = vehicles.map { $0.day }.maxElement()!
        
        for day in minDay...maxDay {
            var t: Double = 0
            while t < 24 * 3600 * 1000 {
                let t1 = t + timeWindow
                
                let count = vehicles.filter { $0.day == day && t <= $0.time && $0.time < t1 }.count
                counts.append(count)
                
                t = t1
            }
        }

        return counts
    }
    
    private func analyzeCluster(cluster: Cluster) -> [Vehicle] {
        var vehicles: [Vehicle] = []
        
        let a = cluster.entries
        
        var i = 0
        
        while true {
            if i == a.count { break }
            
            let e = a[i]
            
            // Pattern: A - A, where time diff < 150
            do {
                if i + 1 < a.count {
                    let e1 = a[i + 1]
                    
                    if e.hose == .A && e1.hose == .A && e1.time - e.time < 300 {
                        vehicles.append(
                            Vehicle(
                                day: e.day,
                                time: e.time,
                                axleTimeDiff: e1.time - e.time,
                                north: true
                            )
                        )
                        
                        i = i + 2
                        continue
                        
                    }
                }
            }
            
            // Pattern: A - B - A - B where A-B time differs < 10ms, A-A time diff less than 300ms
            do {
                if i + 3 < a.count {
                    let e1 = a[i + 1]
                    let e2 = a[i + 2]
                    let e3 = a[i + 3]
                    
                    if e.hose == .A && e1.hose == .B && e2.hose == .A && e3.hose == .B &&
                        e1.time - e.time < 10 && e3.time - e2.time < 10 && e2.time - e.time < 300 {
                        
                        let hoseTimeDiff = ((e1.time - e.time) + (e3.time - e2.time)) / 2
                        
                        vehicles.append(
                            Vehicle(
                                day: e.day,
                                time: e.time,
                                axleTimeDiff: e2.time - e.time,
                                north: false,
                                hoseTimeDiff: hoseTimeDiff
                            )
                        )
                        
                        i = i + 4
                        continue

                    }
                }
            }
            
            // Neither pattern matched
            print("problematic cluster: ")
            cluster.dprint()
            break
        }
        
        return vehicles
    }

    struct Cluster {
        var entries: [Entry] = []
        var first: Entry? { return entries.first }
        var last: Entry? { return entries.last }
        var count: Int { return entries.count }
        var span: Double { return entries.last!.time - entries.first!.time }
        var maxDiff: Double {
            assert(entries.count >= 2)
            
            var d_max: Double = 0
            for i in 1..<entries.count {
                let d = entries[i].time - entries[i - 1].time
                if d > d_max {
                    d_max = d
                }
            }
            
            return d_max
        }
        
        func dprint() {
            for e in entries {
                print("\(e)")
            }
        }
    }
    
    private func cluster(entries: [Entry]) -> [Cluster] {
        var clusters: [Cluster] = []
        var cluster: Cluster = Cluster()
        
        for var e in entries {
            if cluster.count == 0 {
                cluster.entries.append(e)
                continue
            }
            
            if e.time < cluster.last!.time {
                // Drop in time --> new day
                clusters.append(cluster)
                
                cluster = Cluster()
                cluster.entries.append(e)
                
                continue
            }
            
            if e.time - cluster.last!.time < 400 {
                // On average (60km/h), it takes 150ms to go from one axle to the other one
                // Allow some room for speed variation
                // Also, the rubber hoses are very close to each other (4ms at 60km/h -> distance = 0.060m)
                e.diff = e.time - cluster.last!.time
                cluster.entries.append(e)
                
            } else {
                clusters.append(cluster)

                cluster = Cluster()
                cluster.entries.append(e)
            }
        }
        
        return clusters
    }

    private func parseData() -> [Entry] {
        let path = NSBundle.mainBundle().pathForResource("data.txt", ofType: nil)!
        var contents = try! String(contentsOfFile: path)
        contents = contents.stringByReplacingOccurrencesOfString("\r", withString: "")
        
        let lines = contents.componentsSeparatedByString("\n")
        
        let f = NSNumberFormatter()
        
        var day = 0
        var lastTime: Double = 0
        
        let entries: [Entry] = lines.enumerate().flatMap { (i, s) in
            
            // Empty line
            if s.characters.count == 0 { return nil }
            
            guard let first = s.characters.first else {
                print("invalid line (line #\(i + 1)): \(s)")
                return nil
            }
            
            let rest = s.substringFromIndex(s.startIndex.advancedBy(1))
            
            let hose: Hose
            switch first {
            case "A": hose = .A
            case "B": hose = .B
            default:
                print("invalid line (line #\(i + 1)): \(s)")
                return nil
            }
            
            guard let time = f.numberFromString(rest)?.doubleValue else {
                print("invalid line (line #\(i + 1)): \(s)")
                return nil
            }
            
            if time < lastTime {
                // New day
                day = day + 1
            }
            
            lastTime = time
            
            return Entry(hose: hose, day: day, time: time)
        }
        
        return entries
    }

}

