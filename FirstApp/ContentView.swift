//
//  ContentView.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Section
                VStack(spacing: 20) {
                    // App Icon/Logo
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                        
                        Text("🔥")
                            .font(.system(size: 50))
                    }
                    
                    // App Name
                    Text("Roast My Ride")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Tagline
                    Text("Let AI roast your car to perfection")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // How It Works Section
                VStack(spacing: 15) {
                    Text("How It Works")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        HowItWorksStep(
                            number: "1",
                            title: "Take a Photo",
                            description: "Snap a picture of your car",
                            icon: "camera.fill"
                        )
                        
                        HowItWorksStep(
                            number: "2",
                            title: "AI Analysis",
                            description: "Our AI analyzes your ride",
                            icon: "brain.head.profile"
                        )
                        
                        HowItWorksStep(
                            number: "3",
                            title: "Get Roasted",
                            description: "Receive your personalized roast",
                            icon: "flame.fill"
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Call to Action
                VStack(spacing: 15) {
                    NavigationLink(destination: PricingView()) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Get Started")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                    
                    Text("Join thousands of car owners who've been roasted!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.orange)
                        .font(.subheadline)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PricingOption: View {
    let title: String
    let price: String
    let description: String
    let isPopular: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    init(title: String, price: String, description: String, isPopular: Bool = false, isSelected: Bool = false, onTap: @escaping () -> Void = {}) {
        self.title = title
        self.price = price
        self.description = description
        self.isPopular = isPopular
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if isPopular {
                Text("MOST POPULAR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : (isPopular ? Color.orange : Color.clear), lineWidth: 2)
                    )
            )
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct PricingView: View {
    @StateObject private var paymentManager = PaymentManager()
    @State private var showingCamera = false
    @State private var selectedPlan: PaymentManager.PricingPlan = .threeRoasts
    @State private var showingPaymentAlert = false
    @State private var paymentSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Text("Choose Your Plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Select how many roasts you'd like")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Pricing Options
            VStack(spacing: 15) {
                ForEach(PaymentManager.PricingPlan.allCases, id: \.self) { plan in
                    PricingOption(
                        title: plan.rawValue,
                        price: plan.price,
                        description: plan.description,
                        isPopular: plan.isPopular,
                        isSelected: selectedPlan == plan
                    ) {
                        selectedPlan = plan
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Purchase Button
            Button(action: {
                Task {
                    await handlePurchase()
                }
            }) {
                HStack {
                    if paymentManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "creditcard.fill")
                    }
                    Text(paymentManager.isLoading ? "Processing..." : "Purchase \(selectedPlan.rawValue) - \(selectedPlan.price)")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
            }
            .disabled(paymentManager.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .navigationTitle("Pricing")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
        .alert("Payment", isPresented: $showingPaymentAlert) {
            Button("OK") {
                if paymentSuccess {
                    showingCamera = true
                }
            }
        } message: {
            Text(paymentSuccess ? 
                 "Payment successful! You can now start roasting your car!" : 
                 paymentManager.errorMessage ?? "Payment failed. Please try again.")
        }
    }
    
    private func handlePurchase() async {
        guard let product = paymentManager.getProduct(for: selectedPlan) else {
            errorMessage = "Product not available"
            showingPaymentAlert = true
            return
        }
        
        let success = await paymentManager.purchase(product)
        paymentSuccess = success
        showingPaymentAlert = true
    }
}

struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Camera View")
                .font(.title)
                .padding()
            
            Text("This is where the camera functionality will go!")
                .foregroundColor(.secondary)
                .padding()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
