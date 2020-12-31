//
//  HomeTableViewCell.swift
//  Currency Converter
//
//  Created by Harol_Higuera on 2020/12/29.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelCurrencyCode: UILabel!
    @IBOutlet weak var labelCurrencyName: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
