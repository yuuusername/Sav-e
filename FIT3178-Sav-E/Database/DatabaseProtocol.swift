//
//  DatabaseProtocol.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 6/6/2022.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case list
    case items
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onListChange(change: DatabaseChange, listItems: [Product])
    func onAllItemsChange(change: DatabaseChange, items: [Product])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addProduct(name: String, igaPrice: Double, woolworthsPrice: Double) -> Product
    func deleteProduct(item: Product)
    
    var defaultList: List {get}
    
    func addList(listName: String) -> List
    func deleteList(list: List)
    func addItemToList(item: Product, list: List) -> Bool
    func removeItemFromList(item: Product, list: List)
}
