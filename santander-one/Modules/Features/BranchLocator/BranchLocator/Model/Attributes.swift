import Foundation
import ObjectMapper

struct Attributes: Mappable {
	var lowDenominationBill: Bool = false
	var fees: Bool = false
	var openSaturday: Bool = false
	var accesibility: Bool = false
	var audioGuidance: Bool = false
	var safeBox: Bool = false
	var wifi: Bool = false
	var multiATM: Bool = false
	var operative: Bool = false
	var contactless: Bool = false
	var coworking: Bool = false
	var pay: Bool = false
	var embosadora: Bool = false			// Card issuer
	var parking: Bool = false
	var openEveneings: Bool = false
	var driveThru: Bool = false
	var withdrawMoney: Bool = false
	var withdrawWithoutCard: Bool = false
    var meetingRooms: Bool = false
	
	
    func financialServices() -> [String] {
        var arr: [String] = []
        
        if safeBox {
            arr.append(localizedString("bl_security_box"))
        }
        
        if embosadora {
            arr.append(localizedString("bl_card_issuer"))
        }
		
        return arr
    }
    
    func nonFinancialServices() -> [String] {
        var arr: [String] = []

        if wifi {
            arr.append(localizedString("bl_wifi"))
        }
        
        if coworking {
            arr.append(localizedString("bl_coworking_spaces"))
        }
        
        if parking {
            arr.append(localizedString("bl_parking"))
        }
		
		if meetingRooms {
			arr.append(localizedString("bl_meeting_rooms"))
		}
		
        return arr
    }

	init?(map: Map) {
		
	}
	
	mutating func mapping(map: Map) {
		lowDenominationBill			<- map["LOW_DENOMINATION_BILL"]
		fees						<- map["FEES"]
		openSaturday				<- map["OPEN_SATURDAY"]
		accesibility				<- map["ACCESIBILITY"]
		audioGuidance				<- map["AUDIO_GUIDANCE"]
		safeBox						<- map["SAFE_BOX"]
		wifi						<- map["WIFI"]
		multiATM					<- map["MULTICAJERO"]
		operative					<- map["OPERATIVE"]
		contactless					<- map["CONTACTLESS"]
		coworking					<- map["COWORKING_SPACES"]
		pay							<- map["PAY"]
		embosadora					<- map["EMBOSADORA"]
		parking						<- map["PARKING"]
		openEveneings				<- map["OPEN_EVENINGS"]
		driveThru					<- map["DRIVE_THRU"]
		withdrawMoney				<- map["WITHDRAW"]
		withdrawWithoutCard			<- map["RETIRO_CON_CODIGO"]
        meetingRooms                <- map["MEETING_ROOMS"]
	}
}

