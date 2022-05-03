//
//  FirebaseController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 3/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    let DEFAULT_LIST_NAME = "Default List"
    var listeners = MulticastDelegate<DatabaseListener>()
    var itemList: [Product]
    var defaultList: List
    var authController: Auth
    var database: Firestore
    var itemsRef: CollectionReference?
    var listsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        itemList = [Product]()
        defaultList = List()
        super.init()
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
                currentUser = authDataResult.user
            }
            catch {
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
            }
            self.setupItemListener()
        }
    }
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .items || listener.listenerType == .all {
            listener.onAllItemsChange(change: .update, items: itemList)
        }
        if listener.listenerType == .list || listener.listenerType == .all {
            listener.onListChange(change: .update, listItems: defaultList.items)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addList(listName: String) -> List {
        let list = List()
        list.name = listName
        if let listRef = listsRef?.addDocument(data: ["name": listName]) {
            list.id = listRef.documentID
        }
        return list
    }
    
    func addItemToList(item: Product, list: List) -> Bool {
        guard let itemID = item.id, let listID = list.id else {
            return false
        }
        if let newItemRef = itemsRef?.document(itemID) {
            listsRef?.document(listID).updateData(["items" : FieldValue.arrayUnion([newItemRef])])
        }
        return true
    }
    
    func deleteList(list:List) {
        if let listID = list.id {
            listsRef?.document(listID).delete()
        }
    }
    
    func removeItemFromList(item: Product, list: List) {
        if list.items.contains(item), let listID = list.id, let itemID = item.id {
            if let removedItemRef = itemsRef?.document(itemID) {
                listsRef?.document(listID).updateData(["lists": FieldValue.arrayRemove([removedItemRef])])
            }
        }
    }
    
    func cleanup() {
    }
    
    
    // MARK: - Firebase Controller Specific Methods
    func getItemByID(_ id: String) -> Product? {
        for item in itemList {
            if item.id == id {
                return item
            }
        }
        return nil
    }
        
    func setupItemListener() {
        itemsRef = database.collection("products")
        itemsRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseItemsSnapshot(snapshot: querySnapshot)
            if self.listsRef == nil {
                self.setupListListener()
            }
        }
    }
    
    func setupListListener() {
        listsRef = database.collection("lists")
        listsRef?.whereField("name", isEqualTo: DEFAULT_LIST_NAME).addSnapshotListener {
                (querySnapshot, error) in
                guard let querySnapshot = querySnapshot, let listSnapshot = querySnapshot.documents.first else {
                print("Error fetching lists: \(error!)")
                return
            }
            self.parseListSnapshot(snapshot: listSnapshot)
        }
    }
    func parseItemsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedItem: Product?
            
            do {
                parsedItem = try change.document.data(as: Product.self)
            } catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            guard let item = parsedItem else {
                print("Document doesn't exist")
                return;
            }
            if change.type == .added {
                itemList.insert(item, at: Int(change.newIndex))
            } else if change.type == .modified {
                itemList[Int(change.oldIndex)] = item
            } else if change.type == .removed {
                itemList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.items ||
                listener.listenerType == ListenerType.all {
                    listener.onAllItemsChange(change: .update, items: itemList)
                }
            }
        }
    }
    func parseListSnapshot(snapshot: QueryDocumentSnapshot) {
        defaultList = List()
        defaultList.name = snapshot.data()["name"] as? String
        defaultList.id = snapshot.documentID
        if let itemReferences = snapshot.data()["items"] as? [DocumentReference] {
            for reference in itemReferences {
                if let item = getItemByID(reference.documentID) {
                    defaultList.items.append(item)
                }
                listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.list ||
                    listener.listenerType == ListenerType.all {
                            listener.onListChange(change: .update, listItems: defaultList.items)
                    }
                }
            }
        }
    }
}
