import Foundation
import ObjectMapper

struct SocialData: Mappable {
	var facebook: URL?
	var google: URL?
	var instagram: URL?
	var linkedin: URL?
	var twitter: URL?
	var youtube: URL?
	
	init?(map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		facebook		<- map["facebookLink"]
		google			<- map["googleLink"]
		instagram		<- map["instagramLink"]
		linkedin		<- map["linkedinLink"]
		twitter			<- map["twitterLink"]
		youtube			<- map["youtubeLink"]
	}
}

