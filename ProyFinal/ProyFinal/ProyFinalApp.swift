//
//  ProyFinalApp.swift
//  ProyFinal
//
//  Created by Brenda Lino on 06/05/23.
//
import SwiftUI
import Firebase

@main
struct ProyFinalApp: App {
    init(){
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
