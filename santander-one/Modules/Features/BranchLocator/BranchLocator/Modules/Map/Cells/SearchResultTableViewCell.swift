//
//  SearchResultTableViewCell.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 26/7/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit
import MapKit

class SearchResultTableViewCell: UITableViewCell {
	
	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	
	func configureCell(with result: MKMapItem) {
        self.backgroundColor = .white
		mainLabel.text = result.placemark.name ?? ""
		secondaryLabel.text = result.placemark.title ?? ""
	}
}
