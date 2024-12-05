//
//  SceneDelegate.swift
//  Chapter15
//
//  Created by Akanksha.A on 27/02/24.
//

import UIKit
import SwiftUI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var subscriptions = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let userSettings = Settings()
        let viewModel = ReaderViewModel()
        userSettings.$keywords
            .map { $0.map { $0.value } }
            .assign(to: \.filter, on: viewModel)
            .store(in: &subscriptions)
        let rootView = ReaderView(model: viewModel)
            .environmentObject(userSettings)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
            
        }
    }
}
