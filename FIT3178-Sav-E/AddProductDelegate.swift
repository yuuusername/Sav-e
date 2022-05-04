//
//  AddProductDelegate.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 2/5/2022.
//

import Foundation

protocol AddProductDelegate: AnyObject {
    func addProduct(_ newProduct: Product) -> Bool
}
