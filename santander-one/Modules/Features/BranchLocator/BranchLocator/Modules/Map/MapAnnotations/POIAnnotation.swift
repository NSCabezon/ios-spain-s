import UIKit
import MapKit

public class POIAnnotation: NSObject {
	public var isClosestPOI = false
	var mapPin: POI
	
	public init(mapPin: POI) {
		self.mapPin = mapPin
		super.init()
	}
}


extension POIAnnotation: MKAnnotation {
	public var coordinate: CLLocationCoordinate2D {
		return mapPin.geoLocation
	}
	
	public var title: String? {
		return mapPin.name
	}
	
	public var subtitle: String? {
		return mapPin.code
	}
}

