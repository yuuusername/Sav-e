//
//  DatabaseProtocol.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 3/5/2022.
//

import Foundation
import SwiftUI

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
}
