//
//  Hose.swift
//  TrafficAnalyser
//
//  Created by Khanh Nguyen on 28/06/2016.
//  Copyright © 2016 knguyen. All rights reserved.
//


struct Vehicle {
    let day: Int
    let time: Double
    let axleTimeDiff: Double
    let north: Bool
    let hoseTimeDiff: Double! // Time running thru hose A -> B, available only for north bound vehicles
    
    init(day: Int, time: Double, axleTimeDiff: Double, north: Bool, hoseTimeDiff: Double! = nil) {
        self.day = day
        self.time = time
        self.axleTimeDiff = axleTimeDiff
        self.north = north
        self.hoseTimeDiff = hoseTimeDiff
    }
    
    func dprint() {
        // print("{axleTimeDiff: ")
    }
}
