//
//  List+CoreDataProperties.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 4/5/2022.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension List {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Product)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Product)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension List : Identifiable {

}
