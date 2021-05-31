//
//  String+AddText.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 9/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = ""){
        if let text = text{
            if !self.isEmpty{
                self += separator
            }
            self += text
        }
    }
}
