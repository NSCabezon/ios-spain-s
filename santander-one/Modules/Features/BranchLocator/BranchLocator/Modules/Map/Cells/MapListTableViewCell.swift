//
//  MapListTableViewCell.swift
//  BranchLocator
//
//  Created by Tarsha De Souza on 18/06/2019.
//

import UIKit

class MapListTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!{
        didSet {
            titleLabel.textColor = ListViewColor.title.value
            titleLabel.font = ListViewFont.title.value
        }
    }
    
    @IBOutlet var descriptionLabel: UILabel!{
        didSet {
            descriptionLabel.textColor = ListViewColor.subtitle.value
            descriptionLabel.font = ListViewFont.subtitle.value
        }
    }
    
    @IBOutlet var distanceLabel: UILabel!{
        didSet {
            distanceLabel.textColor = ListViewColor.distanceLabel.value
            distanceLabel.font = ListViewFont.distanceLabel.value
        }
    }
    
    @IBOutlet var disclosureImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with result: POIAnnotation) {
        self.backgroundColor = .white
        disclosureImageView.image = UIImage.init(named:"right_arrow")
        descriptionLabel.text = result.mapPin.location?.fullAddress.lowercased().capitalized
        
        let locale = Locale.current
        if locale.usesMetricSystem {
             distanceLabel.text = String(format: "%.2f km", result.mapPin.distanceInKM)
        } else {
              distanceLabel.text = String(format: "%.2f mi", result.mapPin.distanceInMiles)
        }

        
        var initTitleText = ""
        
        switch (result.mapPin.objectType.code){
        case .corresponsales?:
            initTitleText = localizedString("bl_branchInfoCorresponsales").capitalized
            break
        default:
            initTitleText = localizedString("bl_santander").capitalized
            break
        }
        
        guard let city = result.mapPin.location?.city else {
            titleLabel.text = initTitleText
            return
        }
        
        
        titleLabel.text = "\(initTitleText) - \(city)".capitalized
        
    }
}
