//
//  Product.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit
import FirebaseFirestoreSwift

class Product: NSObject, Codable {
    @DocumentID var id: String?
    var productName: String?
    var colesId: String?
    var woolworthsId: String?
    enum CodingKeys: String, CodingKey {
        case id
        case productName
        case colesId
        case woolworthsId
    }
}
