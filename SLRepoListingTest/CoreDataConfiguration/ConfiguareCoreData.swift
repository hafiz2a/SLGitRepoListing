//
//  ConfiguareCoreData.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 14/03/2025.
//

import CoreData
import SL_RepoCoreData

class ConfiguareCoreData {
    static let shared = ConfiguareCoreData()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "SLRepoListingTest")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
