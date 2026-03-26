//
//  GeminiService.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 20/03/26.
//

import Foundation

@Observable
class GeminiService {
    
    var isLoading = false
    var errorMessage: String?
    
    private let model = "gemini-2.5-flash"
    private var baseURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(Secrets.geminiApiKey)"
    }
    
    // MARK: Generate insight from health data
    
    func generateInsight(
        steps: Int,
        restingHR: Double,
        hrv: Double,
        sleepHours: Double
    ) async -> String {

        isLoading = true
        defer { isLoading = false }

        let prompt = buildPrompt(
            steps: steps,
            restingHR: restingHR,
            hrv: hrv,
            sleepHours: sleepHours
        )

        // Retry up to 3 times with delay on rate limit
        for attempt in 1...3 {
            do {
                let insight = try await callGemini(prompt: prompt)
                return insight
            } catch GeminiError.apiError(let msg) where msg.contains("429") {
                if attempt < 3 {
                    print("⏳ Rate limited — retrying in \(attempt * 15)s...")
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 15_000_000_000)
                }
            } catch {
                errorMessage = error.localizedDescription
                print("🔴 Gemini error: \(error)")
                return "Could not generate insight right now. Try again later."
            }
        }
        return "Could not generate insight right now. Try again later."
    }
    
    // MARK: Build the health prompt
    
    private func buildPrompt(
            steps: Int,
            restingHR: Double,
            hrv: Double,
            sleepHours: Double
        ) -> String {
            """
                    You are VitaSync, a warm and knowledgeable personal health coach AI.
                    
                    Analyze this person's health data from today and last night:
                    - Steps today: \(steps)
                    - Resting heart rate: \(Int(restingHR)) bpm
                    - Heart rate variability (HRV): \(Int(hrv)) ms
                    - Sleep last night: \(String(format: "%.1f", sleepHours)) hours
                    
                    Write a personalized health insight in exactly 2-3 sentences.
                    
                    Rules:
                    - Be warm, specific, and encouraging — not generic
                    - Reference at least one actual number from the data
                    - End with one clear, actionable suggestion for today
                    - Do NOT use bullet points or markdown formatting
                    - Do NOT start with "Based on your data" or similar
                    - Write as if you know this person well
                    - Write exactly 2 complete sentences maximum
                    - Never end mid-sentence — always finish your thought completely
                    - Maximum 55 words total
                    """
        
    }
    
    // MARK: Call Gemini API
    
    private func callGemini(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 256,
                "topP": 0.9
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: request)
        
        guard let httpReponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard  httpReponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unkown"
            throw GeminiError.apiError("Status \(httpReponse.statusCode): \(body)")
        }
        return try parseResponse(data: data)
    }
    
    // MARK: Parse Gemini Response
    
    private func parseResponse(data: Data) throws -> String {
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw GeminiError.parseError
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Errors

enum GeminiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "Invalid API URL."
        case .invalidResponse:   return "Invalid server response."
        case .apiError(let msg): return msg
        case .parseError:        return "Could not read Gemini response."
        }
    }
}
