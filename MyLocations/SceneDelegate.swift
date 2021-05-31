//
//  SceneDelegate.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 2/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        customizeAppearance()
        listenForFatalCoreDataNotifications()
        
        let tabController = window!.rootViewController as? UITabBarController
        
        if let tabViewController = tabController?.viewControllers{
            let navController = tabViewController[1] as! UINavigationController
            let locationViewController = navController.viewControllers.first as! LocationsViewController
            let _ = locationViewController.view
        }
        
        
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func listenForFatalCoreDataNotifications(){
        NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let message = """
            There was a fatal error in the app and it cannot continue.
            Press OK to terminate the app. Sorry for the inconvenience.
            """
            
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "oK", style: .default) { _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
        }
    }
    
    func customizeAppearance(){
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UITabBar.appearance().barTintColor = UIColor.black
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
    }
    
}

