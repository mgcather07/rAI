//
//  rAIService.swift
//  rAI
//
//  Created by Michael Cather on 4/4/25.
//

import Foundation

final class rAIService: @unchecked Sendable {
    static let shared = rAIService()
    
    private var baseURL: URL
    private var bearerToken: String?
    
    private var defaultRaiUrl = "http://192.168.1.42:11434"
    
    init() {
        // Default URL and token can be overridden using `initEndpoint`.
        self.baseURL = URL(string: defaultRaiUrl)!
        self.bearerToken = "okki"
        self.initEndpoint()
    }
    
    func initEndpoint(url: String? = nil, bearerToken: String? = nil) {
        
        let localStorageUrl = UserDefaults.standard.string(forKey: "ollamaUri")
        // Prefer the passed-in URL, then stored URL, then default.
        if var chatUrl = [url, localStorageUrl, defaultRaiUrl].compactMap({ $0 }).first(where: { !$0.isEmpty }) {
            if !chatUrl.lowercased().hasPrefix("http") {
                chatUrl = "http://" + chatUrl
            }
            if let url = URL(string: chatUrl) {
                self.baseURL = url
                // Update bearer token if provided or saved.
                self.bearerToken = UserDefaults.standard.string(forKey: "chatBearerToken") ?? bearerToken ?? self.bearerToken
            }
        }
    }
    
    func queryKnowledge(queryText: String, modelName: String? = nil) async throws -> KnowledgeResponse {
        // Construct the URL (using the "/v1/knowledge" endpoint)
        let endpoint = baseURL.appendingPathComponent("v1/knowledge")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST" // Our API expects a JSON payload in the body.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let model = modelName {
            request.addValue(model, forHTTPHeaderField: "model")
        }
        
        // Prepare the JSON request body.
        let requestBody: [String: Any] = [
            "query": queryText,
            "model": modelName ?? "default"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.timeoutInterval = 300

        // Perform the network request.
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP response status code.
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        // Attempt to decode a wrapped response first.
        do {
            let apiResponse = try decoder.decode(APIResponse<KnowledgeResponse>.self, from: data)
            return apiResponse.data
        } catch {
            // Fallback: try decoding KnowledgeResponse directly.
            return try decoder.decode(KnowledgeResponse.self, from: data)
        }
    }
    
    func query(queryText: String, modelName: String?=nil) async throws -> RaiQueryAgentResults {
        // Construct the URL (using the "/v1/query" endpoint)
        let endpoint = baseURL.appendingPathComponent("v1/query")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = bearerToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let model = modelName {
            request.addValue("model", forHTTPHeaderField: model )
        }
        // Prepare the JSON request body.
        // Adjust the payload as required by your API.
        let requestBody: [String: Any] = ["query": queryText, "model": modelName ?? "default"]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.timeoutInterval = 120
        // Perform the network request.
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP response status code.
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        // Attempt to decode a wrapped response (if your API wraps the data)
        do {
            let apiResponse = try decoder.decode(APIResponse<RaiQueryAgentResults>.self, from: data)
            return apiResponse.data
        } catch {
            // Fallback: try decoding SearchResponse directly.
            return try decoder.decode(RaiQueryAgentResults.self, from: data)
        }
    }
    
    /// Checks if the API is reachable.
    /// This implementation tries a simple GET to a "ping" endpoint.
    func reachable() async -> Bool {
        let pingURL = baseURL.appendingPathComponent("/status")
        var request = URLRequest(url: pingURL)
        request.httpMethod = "GET"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                return true
            }
        } catch {
            return false
        }
        return false
    }
    
    func getModels() async throws -> [LanguageModel] {
        let endpoint = baseURL.appendingPathComponent("v1/models")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(AgentAPIResponse<RaiModel>.self, from: data)
            let models = apiResponse.data.map{
                LanguageModel(
                    name: $0.name,
                    provider: .ollama,
                    imageSupport: false
                )
            }
            return models
        } catch {
            // Fallback: decode a single Agent if needed.
            let r = try decoder.decode(RaiModel.self, from: data)
            let models = [r]
            let lodels = models.map{
                LanguageModel(
                    name: $0.name,
                    provider: .ollama,
                    imageSupport: false
                )
            }
            return lodels
        }
    }
    
    // Function to fetch agents and decode the response.
    func getAgents() async throws -> [AgentModel] {
        let endpoint = baseURL.appendingPathComponent("v1/agents")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        do {
            let apiResponse = try decoder.decode(AgentAPIResponse<AgentModel>.self, from: data)
            return apiResponse.data
        } catch {
            // Fallback: decode a single Agent if needed.
            let agent = try decoder.decode(AgentModel.self, from: data)
            return [agent]
        }
    }
}

// MARK: - Response Models

struct Agency: Decodable {
    let sessionId: String
    let prefix: String
    let userPrompt: String
    let systemPrompt: String?
    let tool: String?
    let task: String?
    let flow: String?
    let agent: String?
    let data: Data?
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case prefix
        case userPrompt = "user_prompt"
        case systemPrompt = "system_prompt"
        case tool
        case task
        case flow
        case agent
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        prefix = try container.decode(String.self, forKey: .prefix)
        userPrompt = try container.decode(String.self, forKey: .userPrompt)
        systemPrompt = try container.decodeIfPresent(String.self, forKey: .systemPrompt)
        tool = try container.decodeIfPresent(String.self, forKey: .tool)
        task = try container.decodeIfPresent(String.self, forKey: .task)
        flow = try container.decodeIfPresent(String.self, forKey: .flow)
        agent = try container.decodeIfPresent(String.self, forKey: .agent)
        
        // Decode the base64-encoded string into Data
        if let base64String = try container.decodeIfPresent(String.self, forKey: .data) {
            if let decodedData = Data(base64Encoded: base64String) {
                data = decodedData
            } else {
                throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Invalid Base64 string for data")
            }
        } else {
            data = nil
        }
    }
}

struct RaiModel: Decodable {
    let id: String
    let name: String
    let model: String
    let zip: String
    let address: String
    let title: String
    let initials: String
    let aiName: String
    let aiFlow: String
    let orgRepType: String
    let collection: String
    let prompt: String
    let contextPrompt: String
    let primaryFunctions: String
    let secondaryFunctions: String
    let openai: String
    let ollama: String
    let orgType: String
    let orgSpecialty: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case model
        case zip
        case address
        case title
        case initials
        case aiName = "ai_name"
        case aiFlow = "ai_flow"
        case orgRepType = "org_rep_type"
        case collection
        case prompt
        case contextPrompt = "context_prompt"
        case primaryFunctions = "primary_functions"
        case secondaryFunctions = "secondary_functions"
        case openai
        case ollama
        case orgType = "org_type"
        case orgSpecialty = "org_specialty"
    }
}

/// A generic wrapper if your API returns a structure like { "status": 200, "data": ... }.
struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
}


struct AgentAPIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: [T]
}
/// Represents the full response from the API.
struct SearchResponse: Codable {
    let response: [String]
}
struct KnowledgeResponse: Decodable {
    let answer: String
    let data: [RaiLoaderDocument]
}

struct StoreDocument: Decodable, Identifiable {
    let id: String
    let document: String
    let metadata: [String: AnyDecodable]  // Use a helper like AnyDecodable to decode arbitrary JSON values
}
/// Mirrors the Python Pydantic model for a document.
struct RaiLoaderDocument: Codable, Identifiable {
    let id: String
    let distance: Float?
    let document: String
    let metadata: [String:String]
    let formatted: String?
}

/// Mirrors the Python Pydantic model for a summary.
struct RaiQueryAgentResults: Codable {
    let query: String
    let query_expanded: String
    
    let documents: [RaiLoaderDocument]
    let sub_documents: [RaiLoaderDocument]
    
    let formatted: String
    let response: String
    
}

/// Mirrors the Python Pydantic model for a result.
struct SearchResponseResult: Codable {
    let text: String
}


struct AnyDecodable: Decodable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyDecodable].self) {
            var result = [String: Any]()
            for (key, anyDecodableValue) in dictValue {
                result[key] = anyDecodableValue.value
            }
            value = result
        } else {
            value = ()
        }
    }
}

