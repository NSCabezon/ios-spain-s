import Foundation
import ObjectMapper

struct SpecialDay: Mappable {
	var date: String!
	var times = [String]()
	
	init?(map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		date		<- map["date"]
		times		<- map["time"]
	}
}
