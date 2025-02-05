//
//  ChatViewModel.swift
//  DeepSeekDemo
//
//  Created by Ganesh Waje on 05/02/25.
//

import Foundation
import DeepSeekClient
import Combine

@MainActor
class ChatViewModel: ObservableObject {
  private let client: DeepSeekClient
  
  @Published var messages: [Message] = []
  @Published var currentInput: String = ""
  @Published var isLoading = false
  @Published var error: Error?
  
  init() {
    let config = DeepSeekClient.Configuration(
      apiKey: "your-api-key"
    )
    self.client = DeepSeekClient(configuration: config)
  }
  
  func sendMessage() async {
    guard !currentInput.isEmpty else { return }
    
    let userMessage = Message(role: "user", content: currentInput)
    messages.append(userMessage)
    
    currentInput = ""
    isLoading = true
    
    do {
      let request = DeepSeekClient.ChatCompletionRequest(
        messages: messages,
        temperature: 0.7,
        maxTokens: 1000
      )
      
      let response = try await client.chat(request)
      
      if let assistantMessage = response.choices.first?.message {
        messages.append(assistantMessage)
      }
    } catch {
      self.error = error
      print("API error: \(error)")
    }
    
    isLoading = false
  }
}
