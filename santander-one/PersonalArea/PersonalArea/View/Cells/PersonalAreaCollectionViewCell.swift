//
//  PersonalAreaCollectionViewCell.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 23/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

class PersonalAreaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var viewCell: GeneralPageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        viewCell.clipsToBounds = true
    }
    
    func configure(_ pageInfo: PageInfo) {
        let image = Assets.image(named: pageInfo.imageName)
        viewCell.imageView?.image = image
        viewCell.imageView?.contentMode = .scaleAspectFill
        viewCell.imageView?.clipsToBounds = true
    }
}
