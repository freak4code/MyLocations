//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 4/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
 
    
    public var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //    public func title() -> String?{
    //        if locationDescription.isEmpty{
    //            return "(No Description)"
    //        }else{
    //            return locationDescription
    //        }
    //    }
    
    public var title: String?{
        if locationDescription.isEmpty{
            return "(No Description)"
        }else{
            return locationDescription
        }
    }
    
    public var subtitle: String?{
        category
    }
    
    var hasPhoto: Bool{
        photoID != nil
    }
    
    var photoUrl: URL{
        assert(photoID != nil,"No photo ID set")
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoUrl.path)
    }
    
    class func nextPhotoID() -> Int{
        let userDefault = UserDefaults.standard
        let currentID = userDefault.integer(forKey: "photoID") + 1
        userDefault.set(currentID, forKey: "photoID")
        userDefault.synchronize()
        return currentID
    }
    
    func removePhotoFile(){
        if hasPhoto{
            do{
                try FileManager.default.removeItem(at: photoUrl)
            }catch{
                 print("Error removing file: \(error)")
            }
        }
    }
}
