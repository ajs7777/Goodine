import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class RestaurantsDetailsViewModel: ObservableObject {
    @Published var restaurantName = ""
    @Published var restaurantType = ""
    @Published var restaurantAddress = ""
    @Published var restaurantState = ""
    @Published var restaurantCity = ""
    @Published var restaurantZipCode = ""
    @Published var restaurantAverageCost = ""
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var reservationAvailable = false
    @Published var parkingAvailable = false
    @Published var selectedImages: [UIImage] = []
    @Published var imageURLs: [String] = []
    @Published var isSaving = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    init() {
        fetchRestaurantData()
    }

    func fetchRestaurantData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        db.collection("restaurants").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]

                DispatchQueue.main.async {
                    self.restaurantName = data["name"] as? String ?? ""
                    self.restaurantType = data["type"] as? String ?? ""
                    self.restaurantAddress = data["address"] as? String ?? ""
                    self.restaurantState = data["state"] as? String ?? ""
                    self.restaurantCity = data["city"] as? String ?? ""
                    self.restaurantZipCode = data["zipCode"] as? String ?? ""
                    self.restaurantAverageCost = data["averageCost"] as? String ?? ""
                    self.reservationAvailable = data["reservationAvailable"] as? Bool ?? false
                    self.parkingAvailable = data["parkingAvailable"] as? Bool ?? false
                    self.startTime = (data["startTime"] as? Timestamp)?.dateValue() ?? Date()
                    self.endTime = (data["endTime"] as? Timestamp)?.dateValue() ?? Date()

                    if let urls = data["imageUrls"] as? [String] {
                        self.imageURLs = urls
                        self.loadImages(from: urls)
                    }
                }
            }
        }
    }

    private func loadImages(from urls: [String]) {
        let dispatchGroup = DispatchGroup()
        var images: [UIImage] = []

        for urlString in urls {
            dispatchGroup.enter()
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data, let image = UIImage(data: data) {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }.resume()
            } else {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.selectedImages = images
        }
    }

    func saveRestaurantData(dismiss: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        isSaving = true

        uploadImages(userID: userID) { imageUrls in
            let restaurantData: [String: Any] = [
                "userID": userID,
                "name": self.restaurantName,
                "type": self.restaurantType,
                "address": self.restaurantAddress,
                "state": self.restaurantState,
                "city": self.restaurantCity,
                "zipCode": self.restaurantZipCode,
                "averageCost": self.restaurantAverageCost,
                "startTime": self.startTime,
                "endTime": self.endTime,
                "reservationAvailable": self.reservationAvailable,
                "parkingAvailable": self.parkingAvailable,
                "imageUrls": imageUrls
            ]

            self.db.collection("restaurants").document(userID).setData(restaurantData) { error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if let error = error {
                        print("Error saving restaurant: \(error.localizedDescription)")
                    } else {
                        print("Restaurant saved successfully!")
                        dismiss()
                    }
                }
            }
        }
    }

    private func uploadImages(userID: String, completion: @escaping ([String]) -> Void) {
        var uploadedImageURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        for image in selectedImages {
            dispatchGroup.enter()

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                dispatchGroup.leave()
                continue
            }

            let imageRef = storage.reference().child("restaurant_images/\(userID)/\(UUID().uuidString).jpg")

            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }

                imageRef.downloadURL { url, error in
                    if let url = url {
                        uploadedImageURLs.append(url.absoluteString)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(uploadedImageURLs)
        }
    }
}
