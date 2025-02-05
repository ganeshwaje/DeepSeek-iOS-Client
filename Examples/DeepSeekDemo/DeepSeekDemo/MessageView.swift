//
//  MessageView.swift
//  DeepSeekDemo
//
//  Created by Ganesh Waje on 05/02/25.
//

import SwiftUI

struct MessageView: View {
  let message: Message
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(message.role)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Text(message.content)
        .padding()
        .background(message.role == "user" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
