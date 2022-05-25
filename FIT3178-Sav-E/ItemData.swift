//
//  ItemData.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import Foundation

class ItemData: NSObject, Decodable {
    var name: String?
    var price: Double?
    
    private enum RootKeys: String, CodingKey {
        case Products
    }
    
    private struct ProductDetails: Decodable {
        var Name: StringLiteralType
        var Price: Double
    }
    
    required init(from decoder: Decoder) throws {
        let itemContainer = try decoder.container(keyedBy: RootKeys.self)
        // Get item info
        let productArray = try itemContainer.decode([ProductDetails].self, forKey: .Products)
        for code in productArray {
            name = code.Name
            price = code.Price
        }
    }
}
