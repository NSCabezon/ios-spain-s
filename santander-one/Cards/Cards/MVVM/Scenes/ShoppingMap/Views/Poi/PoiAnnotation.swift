import MapKit
import CoreDomain

class PoiAnnotation: BaseAnnotation {
    let model: CardMapItem
    
    init(model: CardMapItemRepresentable) {
        let coordinate = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
        self.model = CardMapItem(model)
        super.init(coordinate: coordinate)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? PoiAnnotation else {
            return false
        }
        return annotation.model.isEqual(other: self.model) && annotation.coordinate.longitude == self.coordinate.longitude && annotation.coordinate.latitude == self.coordinate.latitude
    }
}

class BaseAnnotation: NSObject {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

extension BaseAnnotation: MKAnnotation {
}

class PoiAnnotationClouster: BaseAnnotation {
    let annotations: [PoiAnnotation]
    
    init(coordinate: CLLocationCoordinate2D, annotations: [PoiAnnotation]) {
        self.annotations = annotations
        super.init(coordinate: coordinate)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? PoiAnnotationClouster else {
            return false
        }
        guard annotation.coordinate.longitude == self.coordinate.longitude && annotation.coordinate.latitude == self.coordinate.latitude else {
            return false
        }
        guard annotation.annotations.count == self.annotations.count else {
            return false
        }
        for index in 0..<self.annotations.count {
            if !annotation.annotations[index].isEqual(self.annotations[index]) {
                return false
            }
        }
        return true
    }
}
