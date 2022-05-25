//
//  ProductsData.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import Foundation

class ProductsData: NSObject, Decodable {
    var products: [ItemData]?
    private enum CodingKeys: String, CodingKey {
        case products = "Products"
    }
}
