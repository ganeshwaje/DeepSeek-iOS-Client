//
//  DeepSeekDemoApp.swift
//  DeepSeekDemo
//
//  Created by Ganesh Waje on 05/02/25.
//

import SwiftUI
import netfox

@main
struct DeepSeekDemoApp: App {
  init() {
#if DEBUG
    NFX.sharedInstance().start()
#endif
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
