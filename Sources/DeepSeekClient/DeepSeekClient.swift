//
//  DeepSeekClient.swift
//  DeepSeekClient
//
//  Created by Ganesh Waje on 05/02/25.
//

import Foundation

public actor DeepSeekClient {
  private let apiKey: String
  private let baseURL: URL
  private let session: URLSession
  
  public enum DeepSeekError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case decodingFailed(Error)
    case apiError(String)
  }
  
  public struct Configuration: Sendable {
    let apiKey: String
    let baseURL: URL
    let session: URLSession
    
    public init(
      apiKey: String,
      baseURL: URL = URL(string: "https://api.deepseek.com/v1")!,
      session: URLSession = .shared
    ) {
      self.apiKey = apiKey
      self.baseURL = baseURL
      self.session = session
    }
  }
  
  public init(configuration: Configuration) {
    self.apiKey = configuration.apiKey
    self.baseURL = configuration.baseURL
    self.session = configuration.session
  }
  
  public struct ChatMessage: Codable, Sendable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
      self.role = role
      self.content = content
    }
  }
  
  public struct ChatCompletionRequest: Codable, Sendable {
    public let messages: [ChatMessage]
    public let model: String
    public let temperature: Double?
    public let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
      case messages
      case model
      case temperature
      case maxTokens = "max_tokens"
    }
    
    public init(
      messages: [ChatMessage],
      model: String = "deepseek-chat",
      temperature: Double? = nil,
      maxTokens: Int? = nil
    ) {
      self.messages = messages
      self.model = model
      self.temperature = temperature
      self.maxTokens = maxTokens
    }
  }
  
  public struct ChatCompletionResponse: Codable, Sendable {
    public let id: String
    public let choices: [Choice]
    
    public struct Choice: Codable, Sendable {
      public let message: ChatMessage
      public let finishReason: String?
      
      enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
      }
    }
  }
  
  @discardableResult
  public func chat(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
    let urlComponents = URLComponents(url: baseURL.appendingPathComponent("chat/completions"), resolvingAgainstBaseURL: true)
    guard let url = urlComponents?.url else {
      throw DeepSeekError.invalidURL
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    do {
      urlRequest.httpBody = try JSONEncoder().encode(request)
      
      let (data, response) = try await performRequest(urlRequest)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw DeepSeekError.invalidResponse
      }
      
      if httpResponse.statusCode != 200 {
        let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
        throw DeepSeekError.apiError(errorResponse?.error?.message ?? "Unknown error")
      }
      
      return try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
    } catch let error as DeepSeekError {
      throw error
    } catch {
      throw DeepSeekError.requestFailed(error)
    }
  }
  
  private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
    if #available(iOS 15.0, macOS 12.0, *) {
      return try await session.data(for: request)
    } else {
      return try await withCheckedThrowingContinuation { continuation in
        let task = session.dataTask(with: request) { data, response, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }
          guard let data = data, let response = response else {
            continuation.resume(throwing: DeepSeekError.invalidResponse)
            return
          }
          continuation.resume(returning: (data, response))
        }
        task.resume()
      }
    }
  }
}

struct APIErrorResponse: Codable {
  let error: APIError?
  
  struct APIError: Codable {
    let message: String
  }
}
