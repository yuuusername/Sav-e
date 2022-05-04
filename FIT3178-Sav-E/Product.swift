//
//  Product.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit

class Product: NSObject {
    var productName: String?
    var productPrice: Double?
    var productSupermarket: Supermarket?
    
    init(name: String, price: Double, supermarket: Supermarket) {
        productName = name
        productPrice = price
        productSupermarket = supermarket
    }
}

enum Supermarket: Int {
    case coles = 0
    case woolworths = 1
}
