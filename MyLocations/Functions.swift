//
//  Functions.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 4/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void){
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask)
    return paths[0]
}()
let CoreDataSaveFailedNotification = Notification.Name("CoreDataSaveFailedNotification")

func fatalCoreDataError(_ error: Error){
    print("Error: \(error)")
    NotificationCenter.default.post(name:CoreDataSaveFailedNotification,object: nil)
    
}




