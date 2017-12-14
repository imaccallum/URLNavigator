//
//  AppDelegate.swift
//  URLNavigatorExample
//
//  Created by Suyeol Jeon on 7/12/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import URLNavigator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private var navigator: NavigatorType?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let navigator = Navigator()

    // Initialize navigation map
    NavigationMap.initialize(navigator: navigator)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.makeKeyAndVisible()
    window.backgroundColor = .white

    let userListViewController = UserListViewController(navigator: navigator)
    window.rootViewController = UINavigationController(rootViewController: userListViewController)

    self.window = window
    self.navigator = navigator
	
	enum DeepLink {
		case login
		case chat(id: String)
	}
	
	let parser = URLParser<DeepLink>()
	
	parser.register("myapp://login") { (pattern, values, context) -> DeepLink? in
		return .login
	}
	
	parser.register("myapp://chat/<uuid:chatId>") { (pattern, values, context) -> DeepLink? in
		guard let chatId = values["chatId"] as? UUID else { return nil }
		return .chat(id: chatId.uuidString)
	}
	
	let deepLink = parser.parse("myapp://login")

    return true
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplicationOpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Try presenting the URL first
    if self.navigator?.present(url, wrap: UINavigationController.self) != nil {
      print("[Navigator] present: \(url)")
      return true
    }

    // Try opening the URL
    if self.navigator?.open(url) == true {
      print("[Navigator] open: \(url)")
      return true
    }

    return false
  }
}
