//
//  MapPresenter.swift
//  LocatorApp
//
//  Created Ivan Cabezon on 22/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import Foundation
import MapKit


// MARK: Presenter -

protocol MapPresenterProtocol: POIDetailDelegate, UITextFieldDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, FilterDelegate {
    var detailVC: POIDetailViewController? { get set }
    var locationManager: CLLocationManager { get }
    var comeFromFilters: Bool { get set }
    var userWantHisLocation: Bool { get set }
    var view: MapViewProtocol? { get set }
    
    func viewDidAppear()
    func addPOIsToMap(_ poisArray: [POI])
    func getNearPOIsToUserLocation()
    func openFilters(shouldShowTitle: Bool)
    func getNearPOIs(to location: CLLocationCoordinate2D)
    func removeAllAnnotationsFromMap()
    func clearMatchingItems()
    func hasFiltersApplied() -> Bool
    func trackSearchAgain()
    func getSelectedFilters() -> [Filter]
    func checkIfVisiblePOIS()
    
    func listSelected()
    func mapSelected()
    
    func canOpenURL(url: URL) -> Bool
    func openURL(url: URL)
}

private let kTableViewAnimationDuration = 0.35
private let kMapSpan: Double = 3000  // meters span
private let kBasicInfoAnimationDuration: TimeInterval = 0.35
private let kAnnotationName = "kAnnotationName"
private let searchResultTableViewCellHeight: CGFloat = 60.0
private let kMaxDistanceMetersToZoomOut: Double = 2000
private let selectedAnnoMapSpan: Double = 6000
private var sendSearchViewEvent = true // This handles when we have to send the event

class MapPresenter: NSObject, MapPresenterProtocol {
    weak var view: MapViewProtocol?
    var interactor: MapInteractorProtocol?
    private let router: MapWireframeProtocol
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    var selectedAnnotation: POIAnnotation?
    var lastKnownUserLocation: CLLocation?
    var showNearestPOI: Bool = true
    var matchingItems = [MKMapItem]()
    var comeFromFilters: Bool = false
    var mapMode: Bool = true
    var specialAnno: POIAnnotation?
    var listItemSelected = false
    
    private let maxZoomLevel = 9
    private var previousZoomLevel: Int?
    private var currentZoomLevel: Int?  {
        willSet {
            self.previousZoomLevel = self.currentZoomLevel
        }
    }
    
    var listAnnotation = [POIAnnotation](){
        didSet {
            view?.getListTableView().reloadData()
        }
    }
    
    var userWantHisLocation = false {
        didSet {
            if userWantHisLocation == true {
                //AnalyticsHandler.track(event: .backToUserLocation, isScreen: false)
            }
        }
    }
    
    var detailVC: POIDetailViewController?
    var firstTime: Bool = true
    
    init(interface: MapViewProtocol, interactor: MapInteractorProtocol?, router: MapWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        
        super.init()
    }
    
    func getNavBarHeight() -> (viewHeight: CGFloat, searchBarContainerY: CGFloat) {
        return (view?.getSearchBarContainerY())!
    }
    
    func viewDidAppear() {
        if firstTime == true {
            let img = UIImage.bl_gif(name: "BS_loader-i")
            view?.showToast(withText: localizedString("bl_toast_getting_position"), andDuration: 4, inPosition: .bottom, image: img)
        }
    }
    
    func hasFiltersApplied() -> Bool {
        if interactor?.getSelectedFilters().count == 0 {
            return false
        }
        //when component starts, if have filters selected, put comeFromFilters = true for put a message
        if firstTime {
            comeFromFilters = true
        }
        return true
    }
    
    func getNearPOIsToUserLocation() {
        if let coordinate = lastKnownUserLocation?.coordinate {
            getNearPOIs(to: coordinate)
        }
    }
    
    func getNearPOIs(to location: CLLocationCoordinate2D) {
        interactor?.getNearPOIs(to: location)
    }
    
    func checkIfVisiblePOIS() {
        if (view?.mapView.visibleAnnotations().count)! > 0 {
        } else {
            view?.showToast(withText: localizedString("bl_toast_filter_no_results"), andDuration: 5.0, inPosition: .bottom, image: nil)
        }
    }
    
    func openFilters(shouldShowTitle: Bool = true) {
        if let pin = selectedAnnotation {
            deselectPin(with: pin)
        }
        router.goToFilters(with: self, shouldShowTitle: shouldShowTitle)
        if matchingItems.count > 0 {
            if let value = matchingItems.first?.name {
                view?.setSearchTextField(value: value)
            }
            view?.setSearchTableViewHeight(0.0)
        }
        comeFromFilters = true
        //  ANALYTICS REMOVED
//        BLAnalyticsHandler.track(event: .tapFilters,
//                                 screenName: BlEvent.tapFilters.rawValue,
//                                 with: [BlKeys.screenName.rawValue: BlEvent.homeView.rawValue],
//                                 isScreen: false)
        
    }
    
    func centerMap(in placemark: MKPlacemark) {
        changeMapRegion(with: placemark.coordinate, animated: true)
        view?.addReferenceAnnotation(with: placemark.coordinate, title: placemark.thoroughfare ?? "")
    }
    
    func clearMatchingItems() {
        matchingItems.removeAll()
    }
    
    func addPOIsWhenNeedsToShowNearest(pois: [POIAnnotation]) {
        if let _ = pois.first,
            let _ = self.lastKnownUserLocation {
            var coords: [CLLocationCoordinate2D] = [] //array or coordinates to calculate region map with that points visibles
            coords.append(self.lastKnownUserLocation!.coordinate)
            var firstThree = pois
            if pois.count > 3 {
                firstThree = Array(pois[0...2])
            }
            _ = firstThree.map({ coords.append($0.coordinate)})
            pois.first?.isClosestPOI = true
            view?.calculateRegionAndCenterWithCompletion(coordinates: coords, completion: {
                //            // old design with route on intial load
                //            //                self.createRoute(from: lastKnownLocation.coordinate, destination: first.coordinate, completion: { response in
                ////                    self.view?.showRoute(response)
                ////                })
            })
        } else if comeFromFilters {
            view?.showToast(withText: localizedString("bl_toast_filter_no_results"), andDuration: 5.0, inPosition: .bottom, image: nil)
            comeFromFilters = false
        }
    }
    
    // Here we check if search again button is not hidden to center the map
    fileprivate func addPOIsWhenSearchingHasAtLeastOneResult(pois: [POIAnnotation]) {
        if let first = pois.first {
            let firstPOILocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
            let refPoint = CLLocation(latitude: matchingItems.first?.placemark.coordinate.latitude ?? 0, longitude: matchingItems.first?.placemark.coordinate.longitude ?? 0)
            if firstPOILocation.distance(from: refPoint) > kMaxDistanceMetersToZoomOut {
                view?.calculateRegionAndCenterWithCompletion(coordinates: [firstPOILocation.coordinate, refPoint.coordinate], completion: nil)
            }
            view?.hideSearchAgainButton()
            view?.showToast(withText: localizedString("bl_toast_closest_search"), andDuration: 5.0, inPosition: .bottom, image: nil)
        }
    }
    
    fileprivate func addPOIsWhenUserClickedOnSearchInThisAreaButton(pois: [POIAnnotation]) {
        if let first = pois.first {
            let firstPOILocation = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
            self.view?.hideSearchAgainButton()
            if let userLoc = lastKnownUserLocation,
                firstPOILocation.distance(from: userLoc) > 2000 {
                view?.calculateRegionAndCenterWithCompletion(coordinates: [], completion: {
                    self.checkIfVisiblePOIS()
                })
            }
        }
    }
    
    func addPOIsWhenOther(_ first: CLLocationCoordinate2D, _ visible: MKMapRect, _ lastKnownLocation: CLLocationCoordinate2D) {
        // Here check if there are some POI visible in map
        let firstCoordinate = MKMapPoint(first)
        if !visible.contains(firstCoordinate) {
            // If a came from filters, make zoom until nearest POI
            if comeFromFilters {
                let lastLocationMapPoint = MKMapPoint(lastKnownLocation)
                comeFromFilters = false
                if visible.contains(lastLocationMapPoint) {
                    view?.calculateRegionAndCenterWithCompletion(coordinates: [lastKnownLocation, first], completion: nil)
                    view?.showToast(withText: localizedString("bl_toast_filter_apply"), andDuration: 5, inPosition: .bottom, image: nil)
                } else {
                    if let center = view?.mapView.centerCoordinate {
                        view?.calculateRegionAndCenterWithCompletion(coordinates: [center, first], completion: nil)
                        view?.showToast(withText: localizedString("bl_toast_filter_results_nearest"), andDuration: 5, inPosition: .bottom, image: nil)
                    }
                }
                view?.hideSearchAgainButton()
            } else if !userWantHisLocation {
                view?.showToast(withText: localizedString("bl_toast_no_poi_area"), andDuration: 5.0, inPosition: .bottom, image: nil)
            }
            //first POI is visible in the map
        } else if comeFromFilters {
            comeFromFilters = false
            view?.showToast(withText: localizedString("bl_toast_filter_apply"), andDuration: 5.0, inPosition: .bottom, image: nil)
        }
    }
    
    func addPOIsToMap(_ poisArray: [POI]) {
        var pois = [POIAnnotation]()
        for poi in poisArray {
            pois.append(POIAnnotation(mapPin: poi))
        }
        
        listAnnotation = pois
        
        view?.mapView.addAnnotations(pois)
        
        if self.showNearestPOI {
            //Show nearest POI
            addPOIsWhenNeedsToShowNearest(pois: pois)
        } else if matchingItems.count > 0 {
            addPOIsWhenSearchingHasAtLeastOneResult(pois: pois)
            
        } else if !(view?.isSearchAgainButtonHidden() ?? false) {
            addPOIsWhenUserClickedOnSearchInThisAreaButton(pois: pois)
        } else if let first = pois.first?.coordinate,
            let visible = view?.mapView.visibleMapRect,
            let lastKnownLocation = self.lastKnownUserLocation?.coordinate {
            
            addPOIsWhenOther(first, visible, lastKnownLocation)
            
        } else {
            addPOIsWhenUserClickedOnSearchInThisAreaButton(pois: pois)
            
            
            view?.showToast(withText: localizedString("bl_toast_filter_no_results"), andDuration: 5.0, inPosition: .bottom, image: nil)
        }
        
        userWantHisLocation = false
    }
    
    func selecteItem(at index: Int ,isFromTableView: Bool) {
        
        let item = matchingItems[index]
        let textSearched = view?.getSearchBarTextFieldText().folding(options: .diacriticInsensitive, locale: .current)
        
        if isFromTableView {
            
            let withoutAccentsText = item.name?.folding(options: .diacriticInsensitive, locale: .current)
            //  ANALYTICS REMOVED
//            BLAnalyticsHandler.track(event: .tapSearchResult,
//                                     screenName: BlEvent.searchView.rawValue,
//                                     with: [BlKeys.eventAction.rawValue: BlEvent.tapSearchResult.rawValue,
//                                            BlKeys.termSearched.rawValue: textSearched as Any,
//                                            BlKeys.clickedResult.rawValue: withoutAccentsText as Any],
//                                     isScreen: false)
        }else{
            //  ANALYTICS REMOVED
//            BLAnalyticsHandler.track(event: .searchedInSearchBar,
//                                     screenName: BlEvent.searchView.rawValue,
//                                     with: [BlKeys.eventAction.rawValue: BlEvent.searchedInSearchBar.rawValue,
//                                            BlKeys.termSearched.rawValue: textSearched as Any],
//                                     isScreen: false)
        }
        
        if let annotation = selectedAnnotation {
            didTapOnPin(poiAnnotation: annotation, selected: false)
        }
        
        view?.mapView.removeAnnotations(view?.mapView.annotations ?? [])
        showNearestPOI  = false
        
        view?.dismissTextField()
        view?.configureTextField(with: item.name)
        view?.mapView.removeAnnotations((view?.mapView.annotations)!)
        
        centerMap(in: item.placemark)
        getNearPOIs(to: item.placemark.coordinate)
        
        //AnalyticsHandler.track(event: .searchedInSearchBar, isScreen: false)
    }
    
    func selectListItem(at index: Int){
        
        let poiAnnotation = listAnnotation[index]
        
        if let tabBar = view?.getTabBarView(){
            tabBar.leftAction()
            listItemSelected = true
            showNearestPOI  = false
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                //self.view?.mapView.removeAnnotation(self.specialAnno!)
                // self.view?.mapView.addAnnotation(self.specialAnno!)
                //self.view?.mapView.setCenter(self.specialAnno!.coordinate, animated: true)
                //self.didTapOnPin(poiAnnotation: poiAnnotation, selected: true)
                self.view?.mapView.selectAnnotation(poiAnnotation, animated: true)
            }
        }
    }
    
    func removeAllAnnotationsFromMap() {
        if let view = view {
            view.mapView.removeAnnotations(view.mapView.annotations)
        }
    }
    
    
    func performSearch(with text: String, completionHandler: (MKLocalSearch.CompletionHandler)?) {
        if text.count < 3 {
            matchingItems.removeAll()
            view?.reloadSearchTableView()
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let search = MKLocalSearch(request: request)
        if search.isSearching {
            search.cancel()
        }
        search.start(completionHandler: completionHandler!)
    }
    
    // MARK: - Container View Change
    
    func listSelected() {
        if let pin = selectedAnnotation {
            deselectPin(with: pin)
        }
        mapMode = false
        selectedAnnotation = nil
        
        view?.showList()
        view?.removeRouteAndDismissPOIDetailViewController()
    }
    
    func mapSelected() {
        mapMode = true
        view?.showMap()
    }
    
    // MARK: - Map route
    func createRoute(from origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion:  @escaping (_: MKDirections.Response) -> Void) {
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, _ in
            if let response = response {
                completion(response)
            }
        }
    }
    
    func trackSearchAgain() {
        //AnalyticsHandler.track(event: .searchThisArea, isScreen: false)
    }
    
    func getSelectedFilters() -> [Filter] {
        return interactor?.getSelectedFilters() ?? []
    }
    
    
    func canOpenURL(url: URL) -> Bool {
        return router.canOpenURL(url: url)
    }
    
    func openURL(url: URL) {
        router.openURL(url: url)
    }
    
}


// MARK: - UITextFieldDelegate

extension MapPresenter: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view?.textFieldDidBeginEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let count = textField.text?.count ?? 0
        switch count {
        case 0:
            view?.showToast(withText: localizedString("bl_toast_search_empty"), andDuration: 5, inPosition: .center, image: nil)
        //  view?.hideSpinner()
        case 1...2:
            view?.showToast(withText: localizedString("bl_toast_search_empty"), andDuration: 5, inPosition: .center, image: nil)
        //  view?.hideSpinner()
        default:
            if matchingItems.count >= 1 {
                selecteItem(at: 0, isFromTableView: false)
                view?.setSearchTableViewHeight(0.0)
                //     view?.showSpinner()
            } else {
                textField.resignFirstResponder()
                let img = UIImage.bl_gif(name: "BS_loader-i")
                view?.showToast(withText: localizedString("bl_toast_no_results") + (textField.text ?? ""), andDuration: 5.0, inPosition: .bottom, image: img)
                //  view?.hideSpinner()
            }
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //view?.dismissTextField()
        matchingItems.removeAll()
        view?.reloadSearchTableView()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        if currentText.count < 3 { sendSearchViewEvent = true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        performSearch(with: updatedText) { response, _ in
            guard let response = response else {
                sendSearchViewEvent = true
                self.matchingItems.removeAll()
                self.view?.reloadSearchTableView()
                return
            }
            self.matchingItems = response.mapItems
            self.view?.reloadSearchTableView()
            
            if sendSearchViewEvent {
                sendSearchViewEvent = false
                //  ANALYTICS REMOVED
//                BLAnalyticsHandler.track(event: .searchView, screenName: BlEvent.searchView.rawValue, isScreen: true)
            }
        }
        return true
    }
}


// MARK: - MKMapViewDelegate

extension MapPresenter: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !animated {
            view?.removeRoute()
            if !firstTime && lastKnownUserLocation != nil {
                view?.showSearchAgainButton()
            } else {
                //view?.showSearchAgainButton()
            }
        }
        
        let zoomWidth = mapView.visibleMapRect.size.width
        if zoomWidth == 0 {
            self.currentZoomLevel = 0
        } else {
            let zoomLevel = Int(log2(zoomWidth))
            self.currentZoomLevel = zoomLevel
        }
        print("current zoom level is \(currentZoomLevel)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        } else {
            if let poiAnnotation = annotation as? POIAnnotation {
                let poiAnnotationView = POIAnnotationView(poiAnnotation: poiAnnotation, reuseIdentifier: kAnnotationName)
                poiAnnotationView.basicInfoDelegate = self
                if poiAnnotation.isClosestPOI {
                    poiAnnotation.isClosestPOI = false
                    if mapMode{
                        DispatchQueue.main.async {
                            mapView.selectAnnotation(poiAnnotation, animated: true)
                        }
                    }
                }
                if #available(iOS 11.0, *) {
                    poiAnnotationView.displayPriority = .defaultHigh
                }
                return poiAnnotationView
            } else if let refPoint = annotation as? ReferencePoint {
                let referencePointView = ReferencePointView(referencePoint: refPoint, reuseIdentifier: "referencePOI")
                return referencePointView
            } else {
                return nil
            }
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(overlay: overlay)
        myLineRenderer.strokeColor = .santanderRed
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        view?.mapView(didAdd: views)
    }
    
    func changeMapRegion(with location: CLLocationCoordinate2D, animated: Bool = true) {
        view?.changeRegion(to: MKCoordinateRegion(center: location, latitudinalMeters: kMapSpan, longitudinalMeters: kMapSpan), animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if #available(iOS 11.0, *){
            if let cluster = view.annotation as? MKClusterAnnotation{
                let edgeInsets = UIEdgeInsets(top: 90, left: 25, bottom: 80, right: 25)
                mapView.setVisibleMapRect(cluster.mapRect(), edgePadding: edgeInsets, animated: true)
            } else if let anno = view.annotation as? POIAnnotation{
                
                // 8 is the largest zoom
                //  if currentZoomLevel ?? 0 < 9 || currentZoomLevel == 9 {
                
                mapView.setRegion(MKCoordinateRegion(center: anno.coordinate, latitudinalMeters: 0.01, longitudinalMeters:  0.01 ), animated: true)
                
                // } else {
                //    mapView.setRegion(MKCoordinateRegion(center: anno.coordinate, latitudinalMeters: 200, longitudinalMeters:  200), animated: true)
                
                //}
                
            }
        }
    }
    
    
    
}

// MARK: - UITableViewDelegate

extension MapPresenter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if view?.getListTableView() == tableView {
            return UITableView.automaticDimension
        }else{
            return searchResultTableViewCellHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if view?.getListTableView() == tableView {
            
            return listAnnotation.count;
        }else{
            let height = CGFloat(matchingItems.count) * searchResultTableViewCellHeight
            if height >= 200 {
                view?.setSearchTableViewHeight(200)
            } else {
                view?.setSearchTableViewHeight(height)
            }
            return matchingItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if view?.getListTableView() == tableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: MapListTableViewCell.nibString(), for: indexPath) as? MapListTableViewCell {
                
                cell.configureCell(with: listAnnotation[indexPath.row])
                cell.selectionStyle = .none
                
                return cell
            }
            assert(false, "cell is not registered")
            return UITableViewCell()
        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.nibString(), for: indexPath) as? SearchResultTableViewCell {
                cell.configureCell(with: matchingItems[indexPath.row])
                return cell
            }
            assert(false, "cell is not registered")
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if view?.getListTableView() == tableView {
            selectListItem(at: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else{
            tableView.deselectRow(at: indexPath, animated: true)            
            selecteItem(at: indexPath.row, isFromTableView: true)
            view?.setSearchTableViewHeight(0.0)
            view?.hideSearchAgainButton()
            //view?.showSpinner()
        }
    }
}


// MARK: - BasicInfoDelegate

extension MapPresenter: POIDetailDelegate {
    func didTapOnPin(poiAnnotation: POIAnnotation, selected: Bool) {
        print("SELECTED")
        view?.viewIsShown = true
        if selected {
            
            selectedAnnotation = poiAnnotation
            
            self.router.changeToPOIDetail(with: poiAnnotation, lastKnownLocation: lastKnownUserLocation?.coordinate, showingNearestPOI: showNearestPOI, firstTime: firstTime, heights: getNavBarHeight(), mapView: view)
            
            if firstTime {
                firstTime = false
            } else {
                //  ANALYTICS REMOVED
//                BLAnalyticsHandler.track(event: .tapBranchIcon,
//                                         screenName: BlEvent.homeView.rawValue,
//                                         with: [BlKeys.eventAction.rawValue: BlEvent.tapBranchIcon.rawValue,
//                                                BlKeys.branchATMType.rawValue: poiAnnotation.mapPin.objectType.code.analiticsValue,
//                                                BlKeys.branchATMName.rawValue: poiAnnotation.mapPin.name ?? "" as Any],
//                                         isScreen: false)
            }
            showNearestPOI = false
            view?.hideSearchAgainButton()
        } else {
            router.halfModalTransitioningDelegate?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func deselectPin(with selectedAnnotation: POIAnnotation) {
        print("DESLECTED")
        view?.deselectPin(with: selectedAnnotation)
    }
    
    func isOpen() -> Bool? {
        return router.halfModalTransitioningDelegate?.isOpen()
    }
    
    func handleOpenOrClose() {
        
        guard let annotation = selectedAnnotation else {
            //  ANALYTICS REMOVED
//            BLAnalyticsHandler.track(event: .tapBranchDetail,
//                                     screenName: BlEvent.homeView.rawValue,
//                                     with: [BlKeys.eventAction.rawValue: BlEvent.tapBranchDetail.rawValue],
//                                     isScreen: false)
        
            router.halfModalTransitioningDelegate?.handleOpenOrClose()
            return
        }
        //  ANALYTICS REMOVED
//        BLAnalyticsHandler.track(event: .tapBranchDetail,
//                                 screenName: BlEvent.homeView.rawValue,
//                                 with: [BlKeys.eventAction.rawValue: BlEvent.tapBranchDetail.rawValue,
//                                        BlKeys.branchATMName.rawValue: annotation.mapPin.name ?? "" as Any,
//                                        BlKeys.branchATMType.rawValue: annotation.mapPin.objectType.code.analiticsValue],
//                                 isScreen: false)
        
        
        router.halfModalTransitioningDelegate?.handleOpenOrClose()
    }
}


// MARK: - CLLocationManagerDelegate

extension MapPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            view?.locationMapButtonEnabled()
        case .denied, .notDetermined, .restricted:
            view?.locationMapButtonDisabled()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if lastKnownUserLocation == nil {
            if let firstLocation = locations.first,
                firstLocation.horizontalAccuracy > Double(0) &&
                    firstLocation.horizontalAccuracy < 80 {
                self.lastKnownUserLocation = firstLocation
                self.locationManager.stopUpdatingLocation()
                self.changeMapRegion(with: firstLocation.coordinate, animated: false)
                self.getNearPOIs(to: firstLocation.coordinate)
            }
        }
    }
}

extension MapPresenter: FilterDelegate {
    func apply(_ filters: [Filter]) {
        removeAllAnnotationsFromMap()
        if let item = matchingItems.first {
            centerMap(in: item.placemark)
            interactor?.getFilteredPOIs(to: item.placemark.coordinate, applyedFilters: filters)
        } else if let coordinate = view?.mapView.centerCoordinate {
            interactor?.getFilteredPOIs(to: coordinate, applyedFilters: filters)
        } else if let coordinate = lastKnownUserLocation?.coordinate {
            interactor?.getFilteredPOIs(to: coordinate, applyedFilters: filters)
        }
        view?.hideSearchAgainButton()
    }
}



extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map({ (obj) -> MKAnnotation in
            return (obj as? MKAnnotation)!
        })
        //return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}
