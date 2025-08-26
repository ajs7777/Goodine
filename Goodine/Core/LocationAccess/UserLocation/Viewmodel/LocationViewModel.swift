import Foundation
import Firebase
import CoreLocation
import FirebaseAuth

class LocationViewModel: ObservableObject {
    @Published var cityName: String = "City"
    @Published var areaName: String = "Select Location"
    @Published var formattedAddress: String = "Loading Address..."

    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchLocation()
    }

    func fetchLocation() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("users")
            .document(userId)
            .collection("userLocations")
            .document("locations")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }

                let lat = data["latitude"] as? Double ?? 0.0
                let lon = data["longitude"] as? Double ?? 0.0

                // 🔹 Update latitude & longitude properties
                DispatchQueue.main.async {
                    self.latitude = lat
                    self.longitude = lon
                }

                self.getAddressFromCoordinates(latitude: lat, longitude: lon)
            }
    }

    func getAddressFromCoordinates(latitude: Double, longitude: Double) {
        let apiKey = "AIzaSyCmguXx4TL0z-ZaMOn-VmiaS7FtxKgBVCM"
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }

            print("Response string:", String(data: data, encoding: .utf8) ?? "N/A")

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let address = results.first,
                   let addressComponents = address["address_components"] as? [[String: Any]],
                   let formatted = address["formatted_address"] as? String {

                    var city: String = "Unknown City"
                    var area: String = "Unknown Area"

                    for component in addressComponents {
                        if let types = component["types"] as? [String] {
                            if types.contains("locality") {
                                city = component["long_name"] as? String ?? city
                            }
                            if types.contains("route") {
                                area = component["short_name"] as? String ?? area
                            } else if area == "Unknown Area", types.contains("sublocality") {
                                area = component["short_name"] as? String ?? area
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        self?.cityName = city
                        self?.areaName = area
                        self?.formattedAddress = formatted
                    }
                } else {
                    print("Invalid JSON format")
                }
            } catch {
                print("JSON parse error: \(error)")
            }
        }.resume()
    }

    deinit {
        listener?.remove()
    }
}
