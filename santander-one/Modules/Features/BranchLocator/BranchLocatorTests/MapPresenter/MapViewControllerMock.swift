//
//  MapViewControllerMock.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 3/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit
import MapKit

@testable import BranchLocator

class MapViewControllerMock: MapViewProtocol {
    func getListTableView() -> UITableView {
        return UITableView()
    }
    
    func getTabBarView() -> DetailButtonsSectionTableView? {
        return nil
    }
    
    func getSearchBarContainerY() -> CGFloat {
        return 0.0
    }
    
    func getSearchBarTextFieldText() -> String {
        return ""
    }
    
	
    var searchAgainButton: UIButton!
	
    var horizontalFiltersCollectionView: UICollectionView!

	var presenter: MapPresenterProtocol?
	var mapView: MKMapView!
	var searchTextField: UITextField!
	var locationMapButton: UIButton!
	var horizontalFilter: UICollectionView!
	var filtersPlaceHolder: UILabel!
	var viewIsShown: Bool = false
	
	var didCallChangeMapRegion = false
	var didAddReferenceAnnotation = false
	var didCallCalculateRegionWithCompletion = false
	var didSetTextField = false
	var didCallBeginEditing = false
	var didCallDismiss = false
	var didCallReloadTableView = false
	var didCallShowRoute = false
	var didCallShowToast = false
	var didCallShowToast2 = false
	var didCallSearchTextField = false
	var didCallSetSearchTableViewHeight = false
	var didCallHideSearchAgainButton = false
    var didShowMap = false
    var didShowList = false
    
    func showMap() {
        didShowMap = true
    }
    
    func showList() {
        didShowList = true
    }
    
	func userMovedMap() {
		
	}
	
    func showSearchAgainButton() {
        
    }
    
	func calculateRegionAndCenter(coordinates: [CLLocationCoordinate2D]) {
		
	}
	
	func calculateRegionAndCenterWithCompletion(coordinates: [CLLocationCoordinate2D], completion: (() -> ())?) {
		didCallCalculateRegionWithCompletion = true
		if let completion = completion {
			completion()
		}
	}
	
	func setSearchTableViewHeight(_ value: CGFloat) {
		didCallSetSearchTableViewHeight = true
	}
	
	func removeRouteAndDismissPOIDetailViewController() {
		
	}
	
	func deselectPin(with selectedAnnotation: POIAnnotation) {
		
	}
	
	func mapView(didAdd views: [MKAnnotationView]) {
		
	}
	
	func configureUI() {
		
	}
	
	func dismissTextField() {
		didCallDismiss = true
	}
	
    func showRoute(_ response: MKDirections.Response) {
		didCallShowRoute = true
	}
	
	func hideSearchAgainButton() {
		didCallHideSearchAgainButton = true
	}
	
	func configureTextField(with text: String?) {
		didSetTextField = true
	}
	
	func addReferenceAnnotation(with coordinate: CLLocationCoordinate2D, title: String) {
		didAddReferenceAnnotation = true
	}
	
	func removeRoute() {
		
	}
	
	func isSearchAgainButtonHidden() -> Bool {
		return false
	}
	
	func textFieldDidBeginEditing() {
		didCallBeginEditing = true
	}
	
	func reloadSearchTableView() {
		didCallReloadTableView = true
	}
	
	func openFilter(_ sender: Any) {
		
	}
	
	func setSearchTextField(value: String) {
		didCallSearchTextField = true
	}
	
	func showToast(withText text: String, andDuration duration: Double) {
		didCallShowToast = true
	}
	
	func changeRegion(to region: MKCoordinateRegion, animated: Bool) {
		didCallChangeMapRegion = true
	}
	
	func showSpinner() {
		
	}
	
	func hideSpinner() {
		
	}
	
	func showToast(withText text: String, andDuration duration: Double, inPosition position: ToastPosition, image img: UIImage?) {
		didCallShowToast2 = true
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return UICollectionViewCell()
	}
	
	func locationMapButtonDisabled() {
		
	}
	
	func locationMapButtonEnabled() {
		
	}
}
