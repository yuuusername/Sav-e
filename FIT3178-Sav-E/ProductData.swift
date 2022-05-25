//
//  ProductData.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import Foundation

class ProductData: NSObject, Decodable {
    var product: [ItemData]?
    private enum CodingKeys: String, CodingKey {
        case product = "Products"
    }
}
