//
//  ShoppingMapiewController.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import UI
import UIKit
import OpenCombine
import MapKit
import CoreFoundationLib
import CoreDomain

private struct ShoppingMapAppearance {
    let title = "toolbar_title_shoppingMap"
    let nibname = "CardShoppingMap"
    let toolTipTitle: LocalizedStylableText = localized("shoppingMapTooltip_title_shoppingMap")
    let toolTipDescription: LocalizedStylableText = localized("shoppingMapTooltip_text_shoppingMap")
    let dialogiTitle = "generic_alert_warning"
    let dialogAccept = "generic_button_understand"
    let poiIdentifier = "PoiPointView"
    let clousterIdentifier = "CardMapClousterView"
    let error = "shoppingMap_text_alertError"
    let enableMixedItems = true
    let marginFactor: Double = 2
    let bucketSize: CGFloat = 76
    var isClustering = false
}

final class CardShoppingMapViewController: UIViewController {
    @IBOutlet private weak var mapview: MKMapView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerSeparator: UIView!
    private var annotationsToAdd: [MKAnnotation] = []
    private var annotationsToRemove: [MKAnnotation] = []
    private var allAnnotationsMapView: [PoiAnnotation] = []
    private var appearance = ShoppingMapAppearance()
    private var adjustedVisibleMapRect: MKMapRect {
        let visibleMapRect = self.mapview.visibleMapRect
        return visibleMapRect.insetBy(dx: -self.appearance.marginFactor * visibleMapRect.size.width,
                                      dy: -self.appearance.marginFactor * visibleMapRect.size.height)
    }
    private let viewModel: CardShoppingMapViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardShoppingMapDependenciesResolver
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    
    init(dependencies: CardShoppingMapDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: appearance.nibname, bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        mapview.delegate = self
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Draw mMap
private extension CardShoppingMapViewController {
    func showGeneralTooltip(_ sender: UIView) {
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(closeIndentifier: AccessibilityCardMap.tooltipCloseButton)
        navigationToolTip.add(titleIdentifier: AccessibilityCardMap.tooltipTitle)
        navigationToolTip.add(textIdentifier: AccessibilityCardMap.tooltipText)
        navigationToolTip.add(containerIdentifier: AccessibilityCardMap.tooltipContainer)
        navigationToolTip.add(title: appearance.toolTipTitle)
        navigationToolTip.add(description: appearance.toolTipDescription)
        navigationToolTip.show(in: self, from: sender)
    }
    
    func showError(_ keyText: String) {
        let accept = Dialog.Action(title: appearance.dialogAccept) { [unowned self] in
            self.viewModel.didSelectAcceptError()
        }
        let dialog = Dialog(title: appearance.dialogiTitle, items: [Dialog.Item.text(keyText)], image: nil, actionButton: accept, isCloseButtonAvailable: false)
        dialog.show(in: self)
    }
    
    func showSingleLocation(_ location: CardMapItemRepresentable) {
        let annotation = PoiAnnotation(model: location)
        center(on: annotation.coordinate, animated: true)
        mapview.addAnnotation(annotation)
        mapview.selectAnnotation(annotation, animated: true)
    }
    
    func showMultipleLocations(_ locations: [CardMapItemRepresentable]) {
        let annotations = locations.map {
            return PoiAnnotation(model: $0)
        }
        center(on: annotations, animated: true)
        allAnnotationsMapView = annotations
        mapview.addAnnotations(annotations)
        updateVisibleAnnotations()
    }

    func updateVisibleAnnotations() {
        if allAnnotationsMapView.count < 2 || getZoomLevel() >= 15 {
            disableClustering()
        } else {
            updateClustering()
        }
    }
    
    func center(on annotations: [MKAnnotation], animated: Bool) {
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        for annotation in annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        var region = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.7
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.7
        region = mapview.regionThatFits(region)
        mapview.setRegion(region, animated: animated)
    }
    
    func center(on coordinate: CLLocationCoordinate2D, animated: Bool) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapview.setRegion(coordinateRegion, animated: animated)
    }
    
    func getZoomLevel() -> CGFloat {
        let width = mapview.frame.size.width
        let zoom = log2(360 * width / CGFloat(mapview.region.span.longitudeDelta * 128))
        return zoom
    }
    
    func updateClustering() {
        annotationsToAdd = []
        annotationsToRemove = []
        appearance.isClustering = true
        let visibleMapRect: MKMapRect = adjustedVisibleMapRect
        let leftCoordinate = mapview.convert(CGPoint.zero, toCoordinateFrom: self.view)
        let rightCoordinate = mapview.convert(CGPoint(x: appearance.bucketSize, y: 0), toCoordinateFrom: self.view)
        let upCoordinate = mapview.convert(CGPoint.zero, toCoordinateFrom: self.view)
        let downCoordinate = mapview.convert(CGPoint(x: 0, y: appearance.bucketSize), toCoordinateFrom: self.view)
        let gridSizeWidth: Double = MKMapPoint(rightCoordinate).x - MKMapPoint(leftCoordinate).x
        let gridSizeHeight: Double = MKMapPoint(downCoordinate).y - MKMapPoint(upCoordinate).y
        var gridMapRect: MKMapRect = MKMapRect(x: 0, y: 0, width: gridSizeWidth, height: gridSizeHeight)
        let startX: Double = visibleMapRect.minX
        let startY: Double = visibleMapRect.minY
        let endX: Double = visibleMapRect.maxX
        let endY: Double = visibleMapRect.maxY
        gridMapRect.origin.y = startY
        while gridMapRect.minY <= endY {
            gridMapRect.origin.x = startX
            while gridMapRect.minX <= endX {
                processBucket(for: gridMapRect)
                gridMapRect.origin.x += abs(gridSizeWidth)
            }
            gridMapRect.origin.y += abs(gridSizeHeight)
        }
        mapview.removeAnnotations(annotationsToRemove)
        mapview.addAnnotations(annotationsToAdd)
    }
    
    func disableClustering() {
        guard appearance.isClustering else {
            return
        }
        appearance.isClustering = false
        let clusteringItems = mapview.annotations.compactMap {
            return $0 as? PoiAnnotationClouster
        }
        let clusteredItems = clusteringItems.reduce([]) { (result, mapClousterAnnotation) -> [MKAnnotation] in
            var items = result
            items.append(contentsOf: mapClousterAnnotation.annotations)
            return items
        }
        mapview.removeAnnotations(clusteringItems)
        mapview.addAnnotations(clusteredItems)
    }
    
    func processBucket(for gridMapRect: MKMapRect) {
        let allAnnotations: [PoiAnnotation] = self.allAnnotationsMapView.filter { annotation in
            return gridMapRect.contains(MKMapPoint(annotation.coordinate))
        }
        guard let visibleAnnotations = Array(self.mapview.annotations(in: gridMapRect)) as? [BaseAnnotation] else {
            return
        }
        guard allAnnotations.count > 0 || visibleAnnotations.count > 0 else {
            return
        }
        if allAnnotations.count == 0 {
            self.annotationsToRemove.append(contentsOf: (visibleAnnotations))
        } else if allAnnotations.count == 1 {
            let annotation = allAnnotations[0]
            checkMixedUniqueAnnotation(mapAnnotation: annotation, visibleAnnotations: visibleAnnotations)
        } else {
            let coordinate = getBucketCoordinates(annotations: allAnnotations)
            let clousterAnnotation = PoiAnnotationClouster(coordinate: coordinate, annotations: allAnnotations)
            self.annotationsToRemove.append(contentsOf: (visibleAnnotations))
            self.annotationsToAdd.append(clousterAnnotation)
        }
    }
    
    func checkMixedUniqueAnnotation(mapAnnotation: PoiAnnotation, visibleAnnotations: [BaseAnnotation]) {
        if visibleAnnotations.count == 1 {
            let visibleAnnotation = visibleAnnotations[0]
            if visibleAnnotation.coordinate.latitude == mapAnnotation.coordinate.latitude &&
                visibleAnnotation.coordinate.longitude == mapAnnotation.coordinate.longitude {
                return
            }
        }
        annotationsToRemove.append(contentsOf: (visibleAnnotations))
        annotationsToAdd.append(mapAnnotation)
    }
    
    func checkUniqueMapClousterAnnotaion(mapAnnotation: PoiAnnotation, visibleAnnotations: [BaseAnnotation]) -> Bool {
        guard visibleAnnotations.count == 1, let mapClouterAnnotation = visibleAnnotations.first as? PoiAnnotationClouster else {
            return false
        }
        guard mapClouterAnnotation.annotations.count == 1 else {
            return false
        }
        let annotaionClustered = mapClouterAnnotation.annotations[0]
        return annotaionClustered.isEqual(mapAnnotation)
    }
    
    func getBucketCoordinates(annotations: [PoiAnnotation]) -> CLLocationCoordinate2D {
        var latitudeSum = 0.0
        var longitudeSum = 0.0
        annotations.forEach { annotation in
            latitudeSum += Double(annotation.coordinate.latitude)
            longitudeSum += Double(annotation.coordinate.longitude)
        }
        let latitude = CLLocationDegrees(latitudeSum/Double(annotations.count))
        let longitude = CLLocationDegrees(longitudeSum/Double(annotations.count))
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func annotationView(for annotation: PoiAnnotation) -> MKAnnotationView {
        let identifier = appearance.poiIdentifier
        if let view = mapview.dequeueReusableAnnotationView(withIdentifier: identifier) as? PoiPointView {
            view.annotation = annotation
            view.set(model: annotation.model)
            bindUpdateCenterFromPoiPoint(view)
            return view
        } else {
            let view = PoiPointView(annotation: annotation, reuseIdentifier: identifier)
            view.set(model: annotation.model)
            bindUpdateCenterFromPoiPoint(view)
            return view
        }
    }
    
    func annotationView(for annotation: PoiAnnotationClouster) -> MKAnnotationView {
        let identifier = appearance.clousterIdentifier
        if let view = mapview.dequeueReusableAnnotationView(withIdentifier: identifier) as? CardMapClousterView {
            view.annotation = annotation
            view.set(annotations: annotation.annotations)
            return view
        } else {
            let view = CardMapClousterView(annotation: annotation, reuseIdentifier: identifier)
            view.set(annotations: annotation.annotations)
            return view
        }
    }
    
    func forceUpdateVisibleAnnotations() {
        let visibleMapRect: MKMapRect = adjustedVisibleMapRect
        let visibleAnnotations = Array(mapview.annotations(in: visibleMapRect)) as? [BaseAnnotation]
        if let annotationsToForce = visibleAnnotations {
            mapview.removeAnnotations(annotationsToForce)
            mapview.addAnnotations(annotationsToForce)
        }
    }
    
    func updateCenter(view: PoiPointView) {
        let annotations = mapview.annotations
        for annotation in annotations {
            if let annotationView = mapview.view(for: annotation) {
                if let pointView = annotationView as? PoiPointView, view != pointView {
                    pointView.update()
                } else if let clousterView = annotationView as? CardMapClousterView {
                    clousterView.update()
                }
            }
        }
    }
}

// MARK: - Appearance
private extension CardShoppingMapViewController {
    func setAppearance() {
        setHeaderView()
        setHeaderLabel()
        setupNavigationBar()
    }
    
    func setHeaderView() {
        headerSeparator.backgroundColor = UIColor.mediumSkyGray
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 15
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        headerView.alpha = 0.89
    }
    
    func setHeaderLabel() {
        headerLabel.accessibilityIdentifier = AccessibilityCardMap.headerLabel
        headerLabel.textColor = UIColor.lisboaGray
        headerLabel.font = UIFont.santander(family: FontFamily.text, type: FontType.bold, size: 13)
    }
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.tooltip(titleKey: appearance.title,
                               type: .red,
                               action: showGeneralTooltip(_:)))
            .addRightAction(.close, associatedAction: .closure(didSelectClose))
            .build(on: self)
    }
    
    @objc func didSelectClose() {
        viewModel.didSelectClose()
    }
}

// MARK: - Bind
private extension CardShoppingMapViewController {
    func bind() {
        bindLocalizedText()
        bindLocations()
        bindLoader()
    }
    
    func bindLocalizedText() {
        viewModel.state
            .case(CardShoppingMapState.localizedTextLoaded)
            .sink { [unowned self] text in
                self.headerLabel.configureText(withLocalizedString: text)
            }.store(in: &subscriptions)
    }
    
    func bindLocations() {
        viewModel.state
            .case(CardShoppingMapState.locationsLoaded)
            .filter { $0.count == 0 }
            .sink { [unowned self] _ in
                dismissLoading {
                    self.showError(self.appearance.error)
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardShoppingMapState.locationsLoaded)
            .filter { $0.count == 1 }
            .sink { [unowned self] locations in
                dismissLoading {
                    self.showSingleLocation(locations[0])
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case(CardShoppingMapState.locationsLoaded)
            .filter { $0.count > 1 }
            .sink { [unowned self] locations in
                dismissLoading {
                    self.showMultipleLocations(locations)
                }
            }.store(in: &subscriptions)
    }
    
    func bindLoader() {
        viewModel.state
            .case(CardShoppingMapState.presentLoader)
            .filter { $0 }
            .sink { [unowned self] _ in
                self.showLoading()
            }.store(in: &subscriptions)
    }
    
    func bindUpdateCenterFromPoiPoint(_ poiPoint: PoiPointView) {
        poiPoint.state
            .case(PoiPointViewtate.centerUpdated)
            .sink { [unowned self] poiPoint in
                self.updateCenter(view: poiPoint)
            }.store(in: &subscriptions)
    }
}

// MARK: - MKMapViewDelegate
extension CardShoppingMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let poiAnnotation = annotation as? PoiAnnotation {
            return annotationView(for: poiAnnotation)
        } else if let poiAnnotation = annotation as? PoiAnnotationClouster {
            return annotationView(for: poiAnnotation)
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let poiView = view as? PoiPointView {
            poiView.showCalloutView()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let poiView = view as? PoiPointView {
            poiView.hiddeCalloutView()
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
         if self.getZoomLevel() >= 15 {
                forceUpdateVisibleAnnotations()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateVisibleAnnotations()
    }
}

extension CardShoppingMapViewController: LoadingViewPresentationCapable {}
