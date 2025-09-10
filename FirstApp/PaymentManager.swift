//
//  PaymentManager.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import Foundation
import StoreKit

@MainActor
class PaymentManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Testing mode - set to true for development
    let isTestingMode = true
    
    // Credit management - using shared instance
    
    private let productIdentifiers: Set<String> = [
        "com.roastmyride.single_roast",
        "com.roastmyride.three_roasts", 
        "com.roastmyride.five_roasts"
    ]
    
    init() {
        if isTestingMode {
            // Skip loading real products in testing mode
            return
        }
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        do {
            isLoading = true
            products = try await Product.products(for: productIdentifiers)
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func purchase(_ product: Product) async -> Bool {
        if isTestingMode {
            // Simulate payment processing in testing mode
            isLoading = true
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay
            isLoading = false
            return true
        }
        
        do {
            isLoading = true
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProducts.insert(product.id)
                isLoading = false
                return true
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                errorMessage = "Purchase is pending approval"
                isLoading = false
                return false
                
            @unknown default:
                errorMessage = "Unknown purchase result"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func getProduct(for plan: PricingPlan) -> Product? {
        if isTestingMode {
            // In testing mode, we'll handle this differently
            return nil
        }
        let identifier = getProductIdentifier(for: plan)
        return products.first { $0.id == identifier }
    }
    
    private func getProductIdentifier(for plan: PricingPlan) -> String {
        switch plan {
        case .single:
            return "com.roastmyride.single_roast"
        case .threeRoasts:
            return "com.roastmyride.three_roasts"
        case .fiveRoasts:
            return "com.roastmyride.five_roasts"
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Credit Management
    
    func handleSuccessfulPurchase(for plan: PricingPlan) {
        let credits = CreditManager.shared.getCreditsForPlan(plan)
        CreditManager.shared.addCredits(credits)
    }
    
    func getCreditManager() -> CreditManager {
        return CreditManager.shared
    }
}

enum PaymentError: Error {
    case failedVerification
}


// Extension to match the PricingPlan enum from ContentView
extension PaymentManager {
    enum PricingPlan: String, CaseIterable {
        case single = "Single Roast"
        case threeRoasts = "3 Roasts"
        case fiveRoasts = "5 Roasts"
        
        var price: String {
            switch self {
            case .single: return "$0.99"
            case .threeRoasts: return "$2.49"
            case .fiveRoasts: return "$3.99"
            }
        }
        
        var description: String {
            switch self {
            case .single: return "One roast, one payment"
            case .threeRoasts: return "Save $0.48"
            case .fiveRoasts: return "Save $0.96"
            }
        }
        
        var isPopular: Bool {
            return self == .threeRoasts
        }
    }
}
