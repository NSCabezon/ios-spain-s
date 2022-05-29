import Foundation
import ObjectMapper

struct ContactData: Mappable {
	var phoneNumber: String?
	var fax: String?
	var email: String?
	var customerPhone: String?
	
	init?(map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		phoneNumber		<- map["phoneNumber"]
		fax				<- map["fax"]
		email			<- map["email"]
		customerPhone	<- map["customerPhone"]
	}
}

