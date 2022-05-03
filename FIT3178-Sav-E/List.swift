//
//  List.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 3/5/2022.
//

import UIKit

class List: NSObject, Codable {
    var id: String?
    var name: String?
    var items: [Product] = []
}
