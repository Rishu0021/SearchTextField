//
//  SearchTableViewCell.swift
//  SearchTextField
//
//  Created by Rishu Gupta on 05/12/20.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViewIcon.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(_ title: String, icon: String? = nil) {
        if let iconName = icon {
            self.imageViewIcon.image = UIImage(named: iconName)
            self.imageViewIcon.isHidden = false
        } else {
            self.imageViewIcon.isHidden = true
        }
        self.labelTitle.text = title
    }
    
}
