//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 10/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class MyTabController: UITabBarController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController?{
        return nil
    }
}


