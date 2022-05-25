//
//  ItemData.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import Foundation

class ItemData: NSObject, Decodable {
    var name: String
    var price: Int
    
    private enum RootKeys: String, CodingKey {
        case Products
    }
    
    private enum ItemKeys: String, CodingKey {
        case Name
        case Price
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let itemContainer = try rootContainer.nestedContainer(keyedBy: ItemKeys.self, forKey: .Products)
        // Get item info
        name = try itemContainer.decode(String.self, forKey: .Name)
        price = try itemContainer.decode(Int.self, forKey: .Price)
    }
}
