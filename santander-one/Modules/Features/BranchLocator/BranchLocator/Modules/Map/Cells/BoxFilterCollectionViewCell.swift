//
//  BoxFilterCollectionViewCell.swift
//  LocatorApp
//
//  Created by Santander on 21/08/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class BoxFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lbFilter: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configureCell(with result: Filter) {
		lbFilter.backgroundColor = .santanderRed
		lbFilter.textColor = .white
		lbFilter.layer.masksToBounds = true
		lbFilter.layer.cornerRadius = 4
        lbFilter.font = .santander(family: .text, type: .regular, size: 12)
		lbFilter.text = result.title
	}
}
