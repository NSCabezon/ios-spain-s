//
//  ReferencePoint.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 28/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit
import MapKit

class ReferencePoint: NSObject {
	var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	var titleStr = ""
	
	init(coord: CLLocationCoordinate2D, title: String) {
		self.coord = coord
		self.titleStr = title
	}
}

extension ReferencePoint: MKAnnotation {
	var coordinate: CLLocationCoordinate2D {
		return coord
	}
	
	var title: String? {
		return titleStr
	}
}
