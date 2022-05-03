//
//  ProductCountTableViewCell.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 2/5/2022.
//

import UIKit

class ProductCountTableViewCell: UITableViewCell {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var gLTotalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
