//
//  Product.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit

class Product: NSObject {
    var productName: String?
    var productPrice: Int?
    var productSupermarket: Supermarket?
}

enum Supermarket: Int {
    case coles = 0
    case woolworths = 1
}
