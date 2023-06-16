//
//  SeltzerAppApp.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

@main
struct SeltzerApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(UserModel())
        }
    }
}
