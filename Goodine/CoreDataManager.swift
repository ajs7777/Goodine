//
//  CoreDataManager.swift
//  Goodine
//
//  Created by Abhijit Saha on 06/02/25.
//


import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Goodine") // Use your .xcdatamodeld file name
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving Core Data: \(error.localizedDescription)")
        }
    }

    func saveRestaurant(restaurant: Restaurant, images: [UIImage]) {
        let entity = RestaurantEntity(context: context)
        entity.restaurantName = restaurant.restaurantName
        entity.restaurantType = restaurant.restaurantType
        entity.restaurantAddress = restaurant.restaurantAddress
        entity.restaurantState = restaurant.restaurantState
        entity.restaurantCity = restaurant.restaurantCity
        entity.restaurantZipCode = restaurant.restaurantZipCode
        entity.restaurantAverageCost = restaurant.restaurantAverageCost
        entity.startTime = restaurant.startTime
        entity.endTime = restaurant.endTime

        // Convert images to Data and store them
        if let imageData = try? JSONEncoder().encode(images.compactMap { $0.pngData() }) {
            entity.images = imageData
        }

        saveContext()
    }

    func fetchRestaurant() -> RestaurantEntity? {
        let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching restaurant: \(error.localizedDescription)")
            return nil
        }
    }
}
