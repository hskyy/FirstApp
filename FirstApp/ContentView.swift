//
//  ContentView.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
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
                                .frame(width: 120, height: 120)
                            
                            Text("🔥")
                                .font(.system(size: 60))
                        }
                        
                        // App Name
                        Text("Roast My Ride")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        // Tagline
                        Text("Let AI roast your car to perfection")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // How It Works Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How It Works")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 15) {
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
                    .padding(.horizontal)
                    
                    // Pricing Section
                    VStack(spacing: 20) {
                        Text("Pricing")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 15) {
                            PricingOption(
                                title: "Single Roast",
                                price: "$0.99",
                                description: "One roast, one payment"
                            )
                            
                            PricingOption(
                                title: "5 Roasts",
                                price: "$2.99",
                                description: "Save $1.96",
                                isPopular: true
                            )
                            
                            PricingOption(
                                title: "10 Roasts",
                                price: "$4.99",
                                description: "Save $4.91",
                                isPopular: false
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Call to Action
                    VStack(spacing: 15) {
                        Button(action: {
                            showingCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Start Roasting")
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
                        .padding(.horizontal)
                        
                        Text("Join thousands of car owners who've been roasted!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
    }
}

struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(number)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.orange)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.subheadline)
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
    
    init(title: String, price: String, description: String, isPopular: Bool = false) {
        self.title = title
        self.price = price
        self.description = description
        self.isPopular = isPopular
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
                
                Text(price)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPopular ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
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
