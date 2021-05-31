//
//  Helper.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 3/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation
import CoreLocation

struct Helper {
    static  func _String(from placemark: CLPlacemark) -> String{
        
        var line1 = ""
        
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }


static private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

static func formate(date: Date) -> String{
    dateFormatter.string(from: date)
}
}
