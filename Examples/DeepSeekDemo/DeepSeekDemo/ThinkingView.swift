//
//  ThinkingView.swift
//  DeepSeekDemo
//
//  Created by Ganesh Waje on 05/02/25.
//

import SwiftUI

struct ThinkingView: View {
  @State private var dotOffset: Int = 0
  
  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  
  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<3) { index in
        Circle()
          .fill(Color.gray.opacity(0.5))
          .frame(width: 8, height: 8)
          .offset(y: index == dotOffset ? -8 : 0)
      }
    }
    .padding()
    .onReceive(timer) { _ in
      dotOffset = (dotOffset + 1) % 3
    }
  }
}
