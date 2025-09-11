//
//  CreditManager.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import Foundation
import SwiftUI

@MainActor
class CreditManager: ObservableObject {
    @Published var availableCredits: Int = 0
    @Published var totalCreditsPurchased: Int = 0
    @Published var hasUsedFreeTrial: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let creditsKey = "availableCredits"
    private let totalCreditsKey = "totalCreditsPurchased"
    private let freeTrialKey = "hasUsedFreeTrial"
    
    // Shared instance for the app
    static let shared = CreditManager()
    
    init() {
        loadCredits()
    }
    
    // MARK: - Credit Management
    
    func addCredits(_ amount: Int) {
        availableCredits += amount
        totalCreditsPurchased += amount
        saveCredits()
    }
    
    func useCredit() -> Bool {
        guard availableCredits > 0 else {
            return false
        }
        
        availableCredits -= 1
        saveCredits()
        return true
    }
    
    func hasCredits() -> Bool {
        return availableCredits > 0 || !hasUsedFreeTrial
    }
    
    func canUseFreeTrial() -> Bool {
        return !hasUsedFreeTrial
    }
    
    func useFreeTrial() -> Bool {
        guard canUseFreeTrial() else {
            return false
        }
        
        hasUsedFreeTrial = true
        saveCredits()
        return true
    }
    
    func getCreditsForPlan(_ plan: PaymentManager.PricingPlan) -> Int {
        switch plan {
        case .single:
            return 1
        case .threeRoasts:
            return 3
        case .fiveRoasts:
            return 5
        }
    }
    
    // MARK: - Persistence
    
    private func loadCredits() {
        availableCredits = userDefaults.integer(forKey: creditsKey)
        totalCreditsPurchased = userDefaults.integer(forKey: totalCreditsKey)
        hasUsedFreeTrial = userDefaults.bool(forKey: freeTrialKey)
    }
    
    private func saveCredits() {
        userDefaults.set(availableCredits, forKey: creditsKey)
        userDefaults.set(totalCreditsPurchased, forKey: totalCreditsKey)
        userDefaults.set(hasUsedFreeTrial, forKey: freeTrialKey)
    }
    
    // MARK: - Testing
    
    func resetCredits() {
        availableCredits = 0
        totalCreditsPurchased = 0
        hasUsedFreeTrial = false
        saveCredits()
    }
    
    func addTestCredits(_ amount: Int = 5) {
        addCredits(amount)
    }
    
    // Temporary function to reset free trial for testing
    func resetFreeTrial() {
        hasUsedFreeTrial = false
        saveCredits()
    }
}
