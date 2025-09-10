//
//  OpenAIService.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import Foundation
import UIKit

class OpenAIService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Your API key - add this securely in production
    // For now, we'll use simulated roasts for testing
    private let apiKey = "YOUR_API_KEY_HERE"
    
    // For testing, we'll use GPT-4o mini (text-only)
    // Later we can switch to gpt-4-vision-preview for image analysis
    private let model = "gpt-4o-mini"
    
    func generateRoast(for image: UIImage) async -> String? {
        isLoading = true
        errorMessage = nil
        
        // For testing with GPT-4o mini, we'll simulate a roast
        // In production with GPT-4 Vision, we'll send the actual image
        let simulatedRoast = await generateSimulatedRoast()
        
        isLoading = false
        return simulatedRoast
    }
    
    private func generateSimulatedRoast() async -> String? {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Return a simulated roast for testing
        let roasts = [
            "🔥 Well, well, well... look what we have here! This car is so basic, it makes a Honda Civic look like a Ferrari. I bet this thing has more miles than a cross-country road trip and fewer working features than a 1990s calculator. The only thing this car roasts better than itself is the environment! 🌍",
            
            "🚗💨 Oh my, where do I even begin? This ride is so underwhelming, it makes a bicycle look like a luxury vehicle. I can practically hear the engine crying for mercy every time you turn the key. The only thing this car has going for it is that it's probably paid off! 💸",
            
            "🎭 Ladies and gentlemen, behold the automotive equivalent of a participation trophy! This car is so forgettable, even its own manufacturer probably forgot they made it. I bet the only thing that gets roasted more than this car is your bank account when you fill up the tank! ⛽",
            
            "🏆 Congratulations! You've managed to find a car that's more basic than a white t-shirt. This thing is so plain, it makes a beige wall look exciting. The only thing this car roasts better than itself is your dignity when you parallel park it! 🅿️",
            
            "🎪 Step right up and witness the most mediocre vehicle this side of the Mississippi! This car is so average, it makes a Toyota Camry look like a race car. I bet the only thing that gets more mileage than this car is the jokes people make about it! 😂"
        ]
        
        return roasts.randomElement()
    }
    
    // This function will be used when we switch to GPT-4 Vision
    private func generateRealRoast(for image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            return nil
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        You are a hilarious car roasting expert. Analyze this car photo and create a funny, creative roast that's:
        - Playful and lighthearted (not mean-spirited)
        - Specific to what you can see in the image
        - Funny and entertaining
        - About 2-3 sentences long
        - Include relevant emojis
        
        Focus on the car's appearance, condition, modifications, or any interesting details you can see.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 200,
            "temperature": 0.8
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            errorMessage = "Invalid API URL"
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "API request failed"
                return nil
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            errorMessage = "Failed to parse API response"
            return nil
            
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
            return nil
        }
    }
}
