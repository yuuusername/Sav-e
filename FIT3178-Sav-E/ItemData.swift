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
    var wasPrice: Double?
    
    private enum RootKeys: String, CodingKey {
        case Products
    }
    
    private struct ProductDetails: Decodable {
        var DisplayName: StringLiteralType
        var Price: Double?
        var WasPrice: Double?
    }
    
    required init(from decoder: Decoder) throws {
        let itemContainer = try decoder.container(keyedBy: RootKeys.self)
        // Get item info
        if let productArray = try? itemContainer.decode([ProductDetails].self, forKey: .Products) {
            for code in productArray {
                // When a product is out of stock, the price is stored as nill. Woolworths stores the old price in wasPrice. This checks for this case
                if code.Price != nil {
                    name = code.DisplayName
                    price = code.Price
                    wasPrice = code.WasPrice
                } else {
                    name = code.DisplayName
                    price = 0.0
                    wasPrice = code.WasPrice
                }
            }
        }
    }
}
