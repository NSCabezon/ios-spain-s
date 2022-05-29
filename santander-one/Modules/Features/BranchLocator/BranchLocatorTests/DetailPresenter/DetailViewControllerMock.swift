//
//  DetailViewControllerMock.swift
//  BranchLocatorTests
//
//  Created by vectoradmin on 26/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@testable import BranchLocator

class DetailViewControllerMock: POIDetailViewController {
	
	var didCallConfigureWithMapPin = false
	var didCallDeselectPin = false
	var didCallHandleOpenOrClose = false
	
	override func configureWith(mapPin: POI) {
		didCallConfigureWithMapPin = true
	}
}

extension DetailViewControllerMock: POIDetailDelegate {
	func deselectPin(with selectedAnnotation: POIAnnotation) {
		didCallDeselectPin = true
	}
	
	func didTapOnPin(poiAnnotation: POIAnnotation, selected: Bool) {
		
	}
	
	func handleOpenOrClose() {
		didCallHandleOpenOrClose = true
	}
}
