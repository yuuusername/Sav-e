//
//  CoreDataController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 4/5/2022.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    let DEFAULT_LIST_NAME = "Default List"
    var listItemsFetchedResultsController: NSFetchedResultsController<Product>?
    var allItemsFetchedResultsController: NSFetchedResultsController<Product>?
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer

    override init() {
        persistentContainer = NSPersistentContainer(name: "Sav-E-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    // MARK: - Lazy Initialisation of Default List
    lazy var defaultList: List = {
        var lists = [List]()
        
        let request: NSFetchRequest<List> = List.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_LIST_NAME)
        request.predicate = predicate
        
        do {
            try lists = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        if let firstList = lists.first {
            return firstList
        }
        return addList(listName: DEFAULT_LIST_NAME)
    }()
    
    // MARK: - Database Adoption
    func addProduct(itemData: ItemData) -> Product {
        let item = NSEntityDescription.insertNewObject(forEntityName: "Product", into: persistentContainer.viewContext) as! Product
        
        item.productName = item.productName
        item.woolworthsPrice = item.woolworthsPrice
        item.igaPrice = item.igaPrice
        
        return item
    }
    
    func deleteProduct(item: Product) {
        persistentContainer.viewContext.delete(item)
    }
    
    func addList(listName: String) -> List {
        let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: persistentContainer.viewContext) as! List
        list.name = listName
        
        return list
    }
    
    func deleteList(list: List) {
        persistentContainer.viewContext.delete(list)
    }
    
    func addItemToList(item: Product, list: List) -> Bool {
        guard let items = list.items, items.contains(item) == false else {
            return false
        }
        
        list.addToItems(item)
        return true
    }
    
    func removeItemFromList(item: Product, list: List) {
        list.removeFromItems(item)
    }
    
    func fetchListItems() -> [Product] {
        if listItemsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
            let predicate = NSPredicate(format: "ANY lists.name == %@", DEFAULT_LIST_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            listItemsFetchedResultsController =
                NSFetchedResultsController<Product>(fetchRequest: fetchRequest,
                managedObjectContext: persistentContainer.viewContext,
                sectionNameKeyPath: nil, cacheName: nil)
            
            listItemsFetchedResultsController?.delegate = self
            
            do {
                try listItemsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var items = [Product]()
        if listItemsFetchedResultsController?.fetchedObjects != nil {
            items = (listItemsFetchedResultsController?.fetchedObjects)!
        }
        
        return items
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func fetchAllItems() -> [Product] {
        if allItemsFetchedResultsController == nil {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "productName", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allItemsFetchedResultsController = NSFetchedResultsController<Product>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allItemsFetchedResultsController?.delegate = self
            
            do {
                try allItemsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        if let items = allItemsFetchedResultsController?.fetchedObjects {
            return items
        }
        return [Product]()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .items || listener.listenerType == .all {
            listener.onAllItemsChange(change: .update, items: fetchAllItems())
        }
        
        if listener.listenerType == .list || listener.listenerType == .all {
            listener.onListChange(change: .update, listItems: fetchListItems())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    //MARK: - Fetched Results Controller Protocol methods
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        
        if controller == allItemsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .items
                    || listener.listenerType == .all {
                    
                    listener.onAllItemsChange(change: .update, items: fetchAllItems())
                }
            }
        } else if controller == listItemsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .list || listener.listenerType == .all {
                    listener.onListChange(change: .update, listItems: fetchListItems())
                }
            }
        }
    }
}
