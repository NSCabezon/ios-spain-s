//
//  MapPresenterTests.swift
//  LocatorAppTests
//
//  Created by Ivan Cabezon on 3/9/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import XCTest
import MapKit

@testable import BranchLocator

class MapPresenterTests: XCTestCase {
	
	var presenter: MapPresenter!
	var mockView: MapViewControllerMock!
	var mockRepository: BranchesAPIRepositoryMock!
	var mockInteractor: MapInteractorMock!
	var mockRouter: MapRouterMock!
	
    override func setUp() {
		super.setUp()
		mockView = MapViewControllerMock()
		mockRepository = BranchesAPIRepositoryMock()
		mockInteractor = MapInteractorMock(with: mockRepository)
		mockRouter = MapRouterMock()
		presenter = MapPresenter(interface: mockView, interactor: mockInteractor, router: mockRouter)
		mockView.mapView = MKMapView()
    }
	
	func fillPresentersSelectedAnnotation() {
		guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.selectedAnnotation = POIAnnotation(mapPin: poi)
	}

	func defaultMapItem() -> MKMapItem {
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -3), addressDictionary: nil))
		return mapItem
	}
	
	func testLocationManagerInits() {
		XCTAssertNotNil(presenter.locationManager)
	}
	
	func testViewDidAppearOk() {
		presenter.firstTime = true
		presenter.viewDidAppear()
		XCTAssertTrue(mockView.didCallShowToast2)
	}
    
	func testHasNoFilters() {
		XCTAssertFalse(presenter.hasFiltersApplied())
	}
	
	func testHasFiltersApplied() {
		mockInteractor.shouldReturnFilters = true
		XCTAssert(presenter.hasFiltersApplied())
	}
	
	func testOpenFiltersWithoutMatchingItems() {
		fillPresentersSelectedAnnotation()
		presenter.openFilters()
		XCTAssert(mockRouter.goToFiltersCalled)
	}
	
	func testOpenFiltersWithMatchingItems() {
		fillPresentersSelectedAnnotation()
		presenter.matchingItems.append(defaultMapItem())
		presenter.openFilters()
		XCTAssertTrue(mockRouter.goToFiltersCalled)
		XCTAssertTrue(mockView.didCallSetSearchTableViewHeight)
		XCTAssertTrue(mockView.didCallSearchTextField)
	}
	
	func testCenterMapInPlacemark() {
		let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -3), addressDictionary: nil)
		presenter.centerMap(in: placemark)
		XCTAssert(mockView.didCallChangeMapRegion)
		XCTAssert(mockView.didAddReferenceAnnotation)
	}
	
	func testAddPOIsWhenNeedsToShowNearestOk() {
		guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.lastKnownUserLocation = CLLocation(latitude: 40, longitude: -3)
		presenter.addPOIsWhenNeedsToShowNearest(pois: [POIAnnotation(mapPin: poi)])
		XCTAssertTrue(mockView.didCallCalculateRegionWithCompletion)
	}
	
	func testAddPOIsWhenNeedsToShowNearestFromFilters() {
		presenter.comeFromFilters = true
		presenter.addPOIsWhenNeedsToShowNearest(pois: [])
		XCTAssertTrue(mockView.didCallShowToast2)
	}
	
	func testAddPOIsWhenNeedsToShowNearestKO() {
		presenter.addPOIsWhenNeedsToShowNearest(pois: [])
		XCTAssertFalse(mockView.didCallShowToast2)
		XCTAssertFalse(mockView.didCallCalculateRegionWithCompletion)
	}
	
	func testClearMatchingItems() {
		presenter.matchingItems.append(defaultMapItem())
		presenter.clearMatchingItems()
		XCTAssertEqual(presenter.matchingItems.count, 0)
	}
	
	func testAddPOIsToMapWhenNearestPOIWithMoreThanThreeResults() {
		guard let poi1 = POI(JSONString: kOnlyOnePOI),
			let poi2 = POI(JSONString: kOnlyOnePOI),
			let poi3 = POI(JSONString: kOnlyOnePOI),
			let poi4 = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.showNearestPOI = true
		presenter.lastKnownUserLocation = CLLocation(latitude: 40, longitude: -3)
		presenter.addPOIsToMap([poi1, poi2, poi3, poi4])
		XCTAssert(mockView.didCallCalculateRegionWithCompletion)
	}

	
	func testAddPOIsToMapWhenNearestPOIWithTwoResults() {
		guard let poi1 = POI(JSONString: kOnlyOnePOI),
			let poi2 = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.showNearestPOI = true
		presenter.lastKnownUserLocation = CLLocation(latitude: 40, longitude: -3)
		presenter.addPOIsToMap([poi1, poi2])
		XCTAssert(mockView.didCallCalculateRegionWithCompletion)
	}

	
	func testAddPOIsToMapWhenSearching() {
		guard let poi1 = POI(JSONString: kOnlyOnePOI),
			let poi2 = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.showNearestPOI = false
		presenter.matchingItems.append(defaultMapItem())
		presenter.lastKnownUserLocation = CLLocation(latitude: 40, longitude: -3)
		presenter.addPOIsToMap([poi1, poi2])
		XCTAssert(mockView.didCallCalculateRegionWithCompletion)
	}

	
	func testAddPOIsToMapWhenSearchingInArea() {
		guard let poi1 = POI(JSONString: kOnlyOnePOI),
			let poi2 = POI(JSONString: kOnlyOnePOI) else { return }
		presenter.showNearestPOI = false
		presenter.lastKnownUserLocation = CLLocation(latitude: 40, longitude: -3)
		presenter.addPOIsToMap([poi1, poi2])
		XCTAssert(mockView.didCallCalculateRegionWithCompletion)
	}
	
	func testAddPOIWhenOtherPointNotInRect() {
		presenter.comeFromFilters = true
        presenter.addPOIsWhenOther(CLLocationCoordinate2DMake(40, -3), MKMapRect(x: 0, y: 0, width: 400, height: 400), CLLocationCoordinate2DMake(40.9847, -3.5678))
		XCTAssertTrue(mockView.didCallHideSearchAgainButton)
	}
	
	func testSelectItemAtIndex() {
		fillPresentersSelectedAnnotation()
		presenter.matchingItems.append(defaultMapItem())
		presenter.selecteItem(at: 0)
		XCTAssert(mockView.didSetTextField)
	}
	
	func testRemoveAnnotationsFromMap() {
		presenter.removeAllAnnotationsFromMap()
	}
	
	func testPerformSearchFail() {
		presenter.performSearch(with: "l", completionHandler: nil)
		XCTAssert(mockView.didCallReloadTableView)
	}
	
	func testPerformSearch() {
		let searchExpectation = self.expectation(description: "search for addresses")
		
		presenter.performSearch(with: "lond") { response, _ in
			if let response = response {
				XCTAssertGreaterThanOrEqual(response.mapItems.count, 1)
				searchExpectation.fulfill()
			}
		}
		
		waitForExpectations(timeout: 20, handler: nil)
	}
	
	
	func testCreateRoute() {
		let searchExpectation = self.expectation(description: "search for addresses")
		let originCoord = CLLocationCoordinate2D(latitude: 40, longitude: -3)
		let destinationCoord = CLLocationCoordinate2D(latitude: 40.2, longitude: -3.4)
		presenter.createRoute(from: originCoord, destination: destinationCoord) { response in
			XCTAssertGreaterThanOrEqual(response.routes.count, 1)
			searchExpectation.fulfill()
		}
		
		waitForExpectations(timeout: 20, handler: nil)
	}
	
	
	func testGetNearPOIsToUserLocation() {
		presenter.lastKnownUserLocation = CLLocation(latitude: 0, longitude: 0)
		presenter.getNearPOIsToUserLocation()
		XCTAssert(mockInteractor.didCallGetNearPOIs)
	}
	
	func testBeginEditing() {
		presenter.textFieldDidBeginEditing(UITextField())
		XCTAssert(mockView.didCallBeginEditing)
	}
	
	func testTextFieldShouldReturnCallsSelectItem() {
		fillPresentersSelectedAnnotation()
		presenter.matchingItems.append(defaultMapItem())
		let textField = UITextField()
		textField.text = "goooo"
		presenter.showNearestPOI = true
		let shouldReturn = presenter.textFieldShouldReturn(textField)
		XCTAssert(shouldReturn)
		XCTAssertFalse(presenter.showNearestPOI)
	}
	
	func testTextFieldShouldNotReturnDoesntCallSelectItem() {
		fillPresentersSelectedAnnotation()
		presenter.matchingItems.append(defaultMapItem())
		let textField = UITextField()
		textField.text = "go"
		presenter.showNearestPOI = true
		let shouldReturn = presenter.textFieldShouldReturn(textField)
		XCTAssert(shouldReturn)
		XCTAssert(presenter.showNearestPOI)
	}
	
	func testTextFieldClears() {
		presenter.matchingItems.append(defaultMapItem())
		XCTAssert(presenter.textFieldShouldClear(UITextField()))
		XCTAssert(mockView.didCallDismiss)
		XCTAssert(mockView.didCallReloadTableView)
		XCTAssertEqual(presenter.matchingItems.count, 0)
	}

	func testGetNearPOIsWrong() {
		presenter.getNearPOIsToUserLocation()
		XCTAssertFalse(mockInteractor.didCallGetNearPOIs)
	}
	
	
	func testMapViewUserLocationAnnotationReturnsCorrectly() {
		let result = presenter.mapView(mockView.mapView, viewFor: MKUserLocation())
		XCTAssertNil(result)
	}
	
	func testGetSelectedFilters() {
		XCTAssertEqual(presenter.getSelectedFilters(), mockInteractor.getSelectedFilters())
	}
	
	func testCanOpenURL() {
		_ = presenter.canOpenURL(url: URL(string: "www.google.com")!)
		XCTAssertTrue(mockRouter.didCallCanOpenURL)
	}
	
	func testOpenURL() {
		_ = presenter.openURL(url: URL(string: "www.google.com")!)
		XCTAssertTrue(mockRouter.didCallOpenURL)
	}
	
	func testChangeCharactersInRange() {
		let textField = UITextField()
		textField.text = "hola"
		_ = presenter.textField(textField, shouldChangeCharactersIn: NSRange(location: 2, length: 1), replacementString: "w")
		
	}
    
    //MARK - Test Actuales
    
    func testSelectMapTabBar() {
        presenter.mapSelected()
        XCTAssertTrue(mockView.didShowMap)
    }
    
    func testSelectListTabBar() {
        presenter.listSelected()
        XCTAssertTrue(mockView.didShowList)
    }
	
//	func testMapViewPOIAnnotationReturnsCorrectly() {
//		guard let poi = POI(JSONString: kOnlyOnePOI) else { return }
//		let annotation = POIAnnotation(mapPin: poi)
//		let result = presenter.mapView(mockView.mapView, viewFor: annotation)
//		XCTAssert(result is POIAnnotationView)
//	}
	
//	func testMapViewReferencePointReturnsCorrectly() {
//		let originCoord = CLLocationCoordinate2D(latitude: 40, longitude: -3)
//		let annotation = ReferencePoint(coord: originCoord, title: "refPoint")
//		let result = presenter.mapView(mockView.mapView, viewFor: annotation)
//		XCTAssert(result is ReferencePointView)
//	}
	
	override func tearDown() {
		mockInteractor.shouldReturnFilters = false
		super.tearDown()
	}
}
