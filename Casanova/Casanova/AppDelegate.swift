//
//  AppDelegate.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Tab bar config
        UITabBar.appearance().tintColor = UIColor.brandColor
        UINavigationBar.appearance().isTranslucent = false
        
        // Firebase
        FirebaseApp.configure()
        
        // WeChat
        WXApi.registerApp("wxb81ba29458679b8b")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        if req.isKind(of: GetMessageFromWXReq.self) {
            let strTitle = "微信请求App提供内容"
            let strMsg = "微信请求App提微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信"
            let alertController = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
        } else if req.isKind(of: ShowMessageFromWXReq.self) {
            let temp = req as! ShowMessageFromWXReq
            let msg = temp.message
            let obj = msg?.mediaObject as! WXAppExtendObject
            let strTitle = "微信请求App显示内容"
            let strMsg = String(format: "标题：%@ \n内容：%@ \n附带信息：%@ \n\n\n", (msg?.title)!, (msg?.description)!, obj.extInfo)
            let alertController = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
        } else if req.isKind(of: LaunchFromWXReq.self) {
            let strTitle = "从微信启动"
            let strMsg = "这是从微信启动的消息"
            let alertController = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendMessageToWXResp.self) {
            let strTitle = "发送媒体消息结果"
            let strMsg = String(format: "errcode:%d", resp.errCode)
            let alertController = UIAlertController(title: strTitle, message: strMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(ok)
            alertController.addAction(cancel)
            UIApplication.shared.topMostViewController()?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

