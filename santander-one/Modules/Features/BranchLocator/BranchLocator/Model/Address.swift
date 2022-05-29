import Foundation
import ObjectMapper
import MapKit

public struct Address: Mappable {
	var address: String?
	var city: String?
	var country: String?
	var descriptionPhoto: String?
	var latitude: Double = 0
	var longitude: Double = 0
	var locationDetails: String?
	var parking: String?
	var type: String?
	var urlPhoto: String?
	var zipcode: String?

    public var fullAddress: String {
        if let address = address,
            let city = city {
            return String("\(address), \(city)")
        } else if let city = city {
            return city
        } else if let address = address {
            return address
        }
		return ""
    }
	
	
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
	
	public init?(map: Map) {
		
	}
    
    public init?(address : Address,location : CLLocationCoordinate2D){
        self.address = address.address
        self.city = address.city
        //mapeo de todo lo hay en mapping
        self.longitude = location.longitude
        self.latitude = location.latitude
        
        
    }
	
	mutating public func mapping(map: Map) {
		address					<- map["address"]
		city					<- map["city"]
		country					<- map["country"]
		descriptionPhoto		<- map["descriptionPhoto"]
		latitude				<- map["geoCoords.latitude"]
		longitude				<- map["geoCoords.longitude"]
		locationDetails			<- map["locationDetails"]
		parking					<- map["parking"]
		type					<- map["type"]
		urlPhoto				<- map["urlPhoto"]
		zipcode					<- map["zipcode"]
	}
}

