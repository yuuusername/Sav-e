//
//  Product+CoreDataProperties.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var productName: String?
    @NSManaged public var woolworthsPrice: Double
    @NSManaged public var igaPrice: Double
    @NSManaged public var lists: NSSet?

}

// MARK: Generated accessors for lists
extension Product {

    @objc(addListsObject:)
    @NSManaged public func addToLists(_ value: List)

    @objc(removeListsObject:)
    @NSManaged public func removeFromLists(_ value: List)

    @objc(addLists:)
    @NSManaged public func addToLists(_ values: NSSet)

    @objc(removeLists:)
    @NSManaged public func removeFromLists(_ values: NSSet)

}

extension Product : Identifiable {

}
