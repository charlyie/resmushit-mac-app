import SwiftUI

struct ContentView: View {
    @State private var droppedImages: [URL] = [] // URLs of dropped images
    @State private var optimizedImages: [URL?] = [] // URLs of optimized images
    @State private var processedCount: Int = 0 // Number of processed files
    @State private var totalCount: Int = 0 // Total number of dropped files
    @State private var quality: Int = UserDefaults.standard.integer(forKey: "quality") != 0 ? UserDefaults.standard.integer(forKey: "quality") : 75
    @State private var replaceOriginal: Bool = UserDefaults.standard.bool(forKey: "replaceOriginal")
    @State private var showDetails: Bool = false
    @State private var isDragging: Bool = false
    @State private var statusMessage: String? = nil
    @State private var invalidFiles: Set<URL> = [] // Tracks invalid files

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2e3a5e"), Color(hex: "#2ead9b")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Overlay when files are being dragged
            if isDragging {
                Color.white.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Text("Drop your files here")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#2e3a5e"))
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#2e3a5e"), style: StrokeStyle(lineWidth: 3, dash: [10]))
                                .padding()
                        )
                    )
            }

            // Main content
            VStack {
                // LogoImage (New logo)
                Image("logoimage") // Ensure "logoimage" matches the name of your image in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150) // Fixed width
                    .padding(.top)

                // Main logo
                Image("logo") // Ensure "logo" matches the name of your image in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
                    .padding()

                // Subtitle
                Text("Drop your pictures to start optimisations")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.bottom)

                // Status message
                if let statusMessage = statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 5)
                }

                // Global progress bar
                VStack {
                    ProgressView(value: Double(processedCount), total: Double(totalCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                        .padding()
                    Text("\(processedCount) out of \(totalCount) files processed")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                // Options
                VStack {
                    HStack {
                        Text("Quality: \(quality)")
                            .foregroundColor(.white)
                        Slider(value: Binding(
                            get: { Double(quality) },
                            set: { newValue in
                                quality = Int(newValue)
                                UserDefaults.standard.set(Int(newValue), forKey: "quality")
                            }
                        ), in: 0...100, step: 1)
                            .accentColor(.white)
                    }
                    .padding()

                    Toggle("Replace original files", isOn: Binding(
                        get: { replaceOriginal },
                        set: { newValue in
                            replaceOriginal = newValue
                            UserDefaults.standard.set(newValue, forKey: "replaceOriginal")
                        }
                    ))
                    .foregroundColor(.white)
                    .padding()
                }

                // Expandable area for file details
                VStack(alignment: .leading) {
                    Button(action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    }) {
                        HStack {
                            Text(showDetails ? "Hide Details" : "Show Details")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.up")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top)

                    if showDetails {
                        List {
                            ForEach(droppedImages, id: \.self) { url in
                                HStack {
                                    Text(url.lastPathComponent) // File name
                                    Spacer()
                                    if invalidFiles.contains(url) {
                                        Image(systemName: "xmark.circle")
                                            .foregroundColor(.red)
                                    } else if optimizedImages[droppedImages.firstIndex(of: url) ?? -1] != nil {
                                        Text(replaceOriginal ? "Replaced" : "Downloaded")
                                            .foregroundColor(.green)
                                    } else {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .frame(height: 200)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .onDrop(of: ["public.file-url"], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
                return true
            }
        }
    }

    // Handle drag-and-drop
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            validateAndAddFile(url: url)
                            self.isDragging = false
                        }
                    }
                }
            }
        }
        self.isDragging = false
        return true
    }

    // Validate file type and size before adding
    private func validateAndAddFile(url: URL) {
        let validExtensions = ["jpg", "jpeg", "png", "gif"]
        let fileExtension = url.pathExtension.lowercased()
        let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0

        if !validExtensions.contains(fileExtension) || fileSize > 5_000_000 {
            statusMessage = "Invalid file: \(url.lastPathComponent). Only JPEG, PNG, GIF under 5MB are allowed."
            invalidFiles.insert(url)
        } else {
            droppedImages.append(url)
            optimizedImages.append(nil) // Placeholder for the optimized result
            totalCount = droppedImages.count
            optimizeImage(at: url, quality: quality) { optimizedUrl in
                if let optimizedUrl = optimizedUrl {
                    self.downloadOptimizedImage(from: optimizedUrl, originalUrl: url) { localUrl in
                        if let index = self.droppedImages.firstIndex(of: url) {
                            DispatchQueue.main.async {
                                self.optimizedImages[index] = localUrl
                                self.processedCount += 1
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.processedCount += 1
                    }
                }
            }
        }
    }

    // Automatically download the optimized image
    private func downloadOptimizedImage(from url: URL, originalUrl: URL, completion: @escaping (URL?) -> Void) {
        let destinationUrl: URL
        if replaceOriginal {
            destinationUrl = originalUrl
        } else {
            destinationUrl = originalUrl.deletingLastPathComponent().appendingPathComponent(
                originalUrl.deletingPathExtension().lastPathComponent + "-optimised" + "." + originalUrl.pathExtension
            )
        }

        URLSession.shared.downloadTask(with: url) { tempUrl, response, error in
            guard let tempUrl = tempUrl, error == nil else {
                print("Error during download: \(error?.localizedDescription ?? "Unknown")")
                completion(nil)
                return
            }

            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }
                try FileManager.default.moveItem(at: tempUrl, to: destinationUrl)
                completion(destinationUrl)
            } catch {
                print("Error moving file: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}

// Extension for hexadecimal colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // Ignore the "#"
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
