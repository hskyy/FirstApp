//
//  ImageSelectionView.swift
//  Roast My Ride
//
//  Created by Brian Hundley on 9/10/25.
//

import SwiftUI
import PhotosUI

struct ImageSelectionView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingRoastResult = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Text("Select Your Car Photo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Take a new photo or choose from your library")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Image Display Area
            VStack(spacing: 20) {
                if let selectedImage = selectedImage {
                    // Selected Image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    
                    // Image Actions
                    HStack(spacing: 20) {
                        Button("Change Photo") {
                            showingActionSheet = true
                        }
                        .foregroundColor(.orange)
                        
                        Button("This Looks Good!") {
                            showingRoastResult = true
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                } else {
                    // Placeholder for no image
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 300)
                            
                            VStack(spacing: 15) {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No photo selected")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Select Photo Button
                        Button("Select Photo") {
                            showingActionSheet = true
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
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Instructions
            VStack(spacing: 10) {
                Text("💡 Tips for the best roast:")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("• Make sure your car is clearly visible")
                    Text("• Good lighting works best")
                    Text("• Include the whole car if possible")
                    Text("• Clean photos get better roasts!")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .navigationTitle("Select Photo")
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose how you'd like to add a photo of your car"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showingCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showingRoastResult) {
            RoastResultView(selectedImage: selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct RoastResultView: View {
    let selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var openAIService = OpenAIService()
    @State private var roastText: String?
    @State private var hasGeneratedRoast = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Car Roast")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(15)
            }
            
            VStack(spacing: 15) {
                if openAIService.isLoading {
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("🔥 Generating your roast... 🔥")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Our AI is analyzing your car and crafting the perfect roast!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                } else if let roast = roastText {
                    VStack(spacing: 15) {
                        Text("🔥 Your AI Roast 🔥")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text(roast)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                    }
                } else if let error = openAIService.errorMessage {
                    VStack(spacing: 15) {
                        Text("❌ Oops!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("🔥 Ready to Get Roasted? 🔥")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Tap the button below to generate your personalized car roast!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                if !hasGeneratedRoast && !openAIService.isLoading {
                    Button("Generate My Roast!") {
                        Task {
                            await generateRoast()
                        }
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
                    .padding(.horizontal, 20)
                }
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .cornerRadius(15)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            if !hasGeneratedRoast {
                Task {
                    await generateRoast()
                }
            }
        }
    }
    
    private func generateRoast() async {
        guard let image = selectedImage else { return }
        
        hasGeneratedRoast = true
        roastText = await openAIService.generateRoast(for: image)
    }
}

#Preview {
    NavigationView {
        ImageSelectionView()
    }
}
