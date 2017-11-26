//
//  MenuItemTableViewCell.swift
//  UVa Dining App
//
//  Created by Michael Chang on 11/26/17.
//  Copyright © 2017 Michael Chang. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuItemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
