//
//  ContentView.swift
//  DeepSeekDemo
//
//  Created by Ganesh Waje on 05/02/25.
//

import SwiftUI
import DeepSeekClient
import netfox

typealias Message = DeepSeekClient.ChatMessage

struct ContentView: View {
  @StateObject private var viewModel = ChatViewModel()
  
  var body: some View {
    NavigationView {
      VStack {
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { _, message in
              MessageView(message: message)
            }
            
            if viewModel.isLoading {
              ThinkingView()
            }
          }
          .padding()
        }
        
        HStack {
          TextField("Type a message...", text: $viewModel.currentInput)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(viewModel.isLoading)
          
          Button(action: {
            Task {
              await viewModel.sendMessage()
            }
          }) {
            Image(systemName: "paperplane.fill")
          }
          .disabled(viewModel.currentInput.isEmpty || viewModel.isLoading)
        }
        .padding()
      }
      .navigationTitle("DeepSeek Chat")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            NFX.sharedInstance().show()
          }) {
            Image(systemName: "network")
          }
        }
      }
    }
    .alert("Error", isPresented: .constant(viewModel.error != nil)) {
      Button("OK") {
        viewModel.error = nil
      }
    } message: {
      Text(viewModel.error?.localizedDescription ?? "Unknown error")
    }
  }
}

#Preview {
  ContentView()
}
