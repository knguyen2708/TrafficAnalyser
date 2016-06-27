//
//  Entry.swift
//  Traffic_Eric
//
//  Created by Khanh Nguyen on 27/06/2016.
//  Copyright © 2016 knguyen. All rights reserved.
//

import Foundation

struct Entry: CustomStringConvertible {
    let hose: Hose
    let day: Int
    let time: Double
    var diff: Double!
    
    init(hose: Hose, day: Int, time: Double) {
        self.hose = hose
        self.day = day
        self.time = time
    }
    
    var description: String {
        if let d = diff {
            return "{\(hose) - \(d)}"
        } else {
            return "{\(hose)}"
        }
        
    }
}

enum Hose: String {
    case A = "A"
    case B = "B"
}
