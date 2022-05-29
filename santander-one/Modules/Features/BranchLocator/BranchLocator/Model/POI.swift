import Foundation
import ObjectMapper
import MapKit

public struct AdditionalServices {
	var financial: [String]?
	var nonFinancial: [String]?
	var atmAditionalServices: [String]?
}

public struct POI: Mappable {
	
	var appointmentURL: String?
	var code: String?
	var distanceInKM: Float = 0
	var distanceInMiles: Float = 0
	var entityCode: String?
	public var location: Address?
	var contactData: ContactData?
	var name: String?
	public var objectType: POIType!
	var poiStatus: POIStatus?
	var poiCode: String?
	public var schedule: Schedule?
    var scheduleCash = [String]()
	var socialData: SocialData?
	var spokenLanguages = [String]()
	var attrib = [JSON]()  // :[{"multi":{"default":"EXTERIOR","es":"EXTERIOR"},"code":"ATM_INSIDE"}]
	public var subType: SubType?
	var specialType: SubType?
	var urlDetailPage: URL?
	var attributtes: Attributes?
  var commercialProducts: [JSON]?
	var richTexts: [JSON]?    
    // extra arrays
  var extraAtmList = [String]()
  var extraFinancialList = [String]()
  var extraNonFinancialList = [String]()  
  var attribTest: [attribTest]?

	public var relatedPOIs = [POI]()
	
	public init?(map: Map) {
		
	}
    
    public init?(poi:POI,locationParam:CLLocationCoordinate2D){
        self.appointmentURL = poi.appointmentURL
        self.code = poi.code
        self.distanceInKM = poi.distanceInKM
        self.distanceInMiles = poi.distanceInMiles
        self.entityCode = poi.entityCode
        
        self.location = Address(address: poi.location!, location: locationParam)
        
        self.contactData = poi.contactData
        self.name = poi.name
        self.objectType = poi.objectType
        self.poiStatus = poi.poiStatus
        self.poiCode = poi.poiCode
        self.schedule = poi.schedule
        self.scheduleCash = poi.scheduleCash
        self.socialData = poi.socialData
        self.spokenLanguages = poi.spokenLanguages
        self.attrib = poi.attrib
        self.subType = poi.subType
        self.specialType = poi.specialType
        self.urlDetailPage = poi.urlDetailPage
        self.attributtes = poi.attributtes
        self.commercialProducts = poi.commercialProducts
        self.richTexts = poi.richTexts
        self.relatedPOIs = poi.relatedPOIs
        
        
    }
	
	mutating public func mapping(map: Map) {
		appointmentURL		<- map["appointment.branchAppointment"]
		code				<- map["code"]
		distanceInKM		<- map["distanceInKm"]
		distanceInMiles		<- map["distanceInMiles"]
		entityCode			<- map["entityCode"]
		location			<- map["location"]
		contactData			<- map["contactData"]
		name				<- map["name"]
		objectType			<- map["objectType"]
		poiStatus			<- (map["poiStatus"], EnumTransform<POIStatus>())
		poiCode				<- map["poiCode"]
		schedule			<- map["schedule"]
        scheduleCash            <- map["scheduleCash"]
		socialData			<- map["socialData"]
		spokenLanguages		<- map["spokenlanguages"]
		attrib				<- map["attrib"]
		subType				<- map["subType"]
		specialType			<- map["specialType"]
		urlDetailPage		<- map["urlDetailPage"]
		attributtes			<- map["dialogAttribute"]
        commercialProducts  <- map["comercialProducts"]
		richTexts			<- map["richTexts"]
        attribTest          <- map["attrib"]
	}
	
	public var geoLocation: CLLocationCoordinate2D {
		return location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
	}

    
	func getIcon() -> UIImage {
		if subType?.code == SubTypeCode.popular ||
			subType?.code == SubTypeCode.pastor {
			return UIImage(resourceName: "popular") ?? UIImage()
		} else if subType?.code == SubTypeCode.workCafe {
			return UIImage(resourceName: "workcafe") ?? UIImage()
        } else if subType?.code == SubTypeCode.post {
            return UIImage(resourceName: "icCorreos") ?? UIImage()
		} else {
			return objectType.code.objIcon
		}
	}
	
	func getFirstRichTexts() -> [JSON]? {
		for poi in relatedPOIs where poi.richTexts != nil {
			if let richTexts = poi.richTexts {
				return richTexts
			}
		}
		return nil
	}
	
	func hasSchedule() -> Bool {
		if objectType.code == .atm {
			return true
		} else {
			return schedule?.hasSchedule() ?? false
		}
	}
    
    func hasScheduleCash() -> Bool {
        
        if scheduleCash.count > 0 {
            return true
        }else{
            return false
        }
    }
	
	func hasFinancialServices() -> Bool {
		if let count = attributtes?.financialServices().count,
			count > 0 {
			return true
		}
		if commercialProducts?.count ?? -1 > 0 {
			return true
		}
		return false
	}
	
    func getFinancialServices(isBranch: Bool) -> [String] {
        var services = [String]()
        if let financialServ = attributtes?.financialServices() {
            services += financialServ
        }
        
        if isBranch {
            guard let commercialProducts = commercialProducts else { return services }
            for commercial in commercialProducts {
                services.append(getLanguageOption(from: commercial))
            }
        }
        // showing more values if the poi has them..
        
                for atmElement in extraAtmList {
                    services.append(atmElement)
                }
                for nonFinancialElement in extraNonFinancialList{
                    services.append(nonFinancialElement)
                }
                for financialElement in extraFinancialList {
                    services.append(financialElement)
                }
        
        var newArray = [String]()
        newArray = addExtraServices(arrayOfAvailableCodes: getAvailableServicesCodes(), comparableArray: services)
        // got array now  check this array against the old one to see if we have any duplicates
        let newServicesArray = removeDuplicatesFromArray(newArray: newArray, originalArray: services)
        print(newServicesArray)
        return newServicesArray
    }
	
    // when we merge the two arrays we need to remove the duplicates.
    func removeDuplicatesFromArray(newArray: [String], originalArray: [String]) -> [String] {
        var newOriginalArray = originalArray
        if newArray.count > 0 {
            for x in newArray {
                if !newOriginalArray.contains(x){
                    newOriginalArray.append(x)
                }
            }
        }
        return newOriginalArray
    }
    
    func getAvailableServicesCodes() -> [String] {
        var result = [String]()
        if let test = attribTest {
            for x in test {
                if let dict = x.multi {
                    if let yes = dict["default"] as? String {
                        if (yes == "YES" ) || (yes == "SI") {
                            if let code = x.code {
                                result.append(code)
                            }
                        }
                    }
                }
            }
        }
        return result
    }
    
    
    func addExtraServices(arrayOfAvailableCodes: [String], comparableArray : [String]) -> [String] {
        var newArray = [String]()
        
        for x in arrayOfAvailableCodes {
            
            if x == "MULTICAJERO" {
                newArray.append(localizedString("bl_deposit_money"))
            }
            
            if x == "CONTACTLESS" {
                newArray.append(localizedString("bl_contactless"))
            }
            
            if x == "WITHDRAW" {
                newArray.append(localizedString("bl_withdraw_money"))
            }
            
            if x == "LOW_DENOMINATION_BILL" {
                newArray.append(localizedString("bl_low_denomination_bills"))
            }
            
            if x == "RETIRO_CON_CODIGO" {
                newArray.append(localizedString("bl_withdraw_without_card"))
            }
            
            if x == "NON_SANTANDER_ATM" {
                newArray.append(localizedString("bl_other_atms"))
            }
        }
        return newArray
    }
    
	func hasBasicServices() -> Bool {
		return objectType.code == .atm && getATMBasicServices().count > 0
	}
	
	func getATMBasicServices() -> [String] {
		var services = [String]()
		guard let commercialProducts = commercialProducts else { return services }
		for commercial in commercialProducts {
			services.append(getLanguageOption(from: commercial))
		}
		return services
	}
    
    //MARK:  we are no longer using additional services for atm they are together, alongside financial
    func hasAdditionalServices() -> Bool {
        var isBranch = true
        if objectType.code == .atm { isBranch = false}
        return getFinancialServices(isBranch: isBranch).count > 0 || getNonFinancialServices().count > 0
    }
	
    func getAdditionalServices() -> AdditionalServices {
        var isBranch = true
        
        if objectType.code == .atm {
            isBranch = false
        }
        
        var additionalServices = AdditionalServices()
        additionalServices.financial = getFinancialServices(isBranch: isBranch)
        additionalServices.nonFinancial = getNonFinancialServices()
        return additionalServices
    }
    
    func hasNoFinancialServices() -> Bool {
        if let count = attributtes?.nonFinancialServices().count,
            count > 0 {
            return true
        }

        if self.spokenLanguages.count > 0 {
            return true
        }

        return false
    }
	
    func getNonFinancialServices() -> [String] {
        var arrayOfCodes = [String]()
        arrayOfCodes = getAvailableServicesCodes()
        var newArray = [String]()
        
        let orignalArray = attributtes?.nonFinancialServices() ?? []
        
        for x in arrayOfCodes {
            if x == "OPEN_SATURDAY" {
                newArray.append(localizedString("bl_opens_saturdays"))
            }
            
            if x == "OPEN_EVENINGS" {
                newArray.append(localizedString("bl_opens_evenings"))
            }
        }
        
        let newOriginalArray = removeDuplicatesFromArray(newArray: newArray, originalArray: orignalArray)
        print("new array \(newArray)")
        print(newOriginalArray)
        return newOriginalArray
    }
	
    //MARK: depreacted no longer using get additionalServicesForAtm
    
//    func getAdditionalServicesForATM() -> [String] {
//    }
	
	func getSpokenLanguagesLocalizedString() -> String? {
		if spokenLanguages.count > 0 {
			var langsString = localizedString("bl_languages").appending(" ")
			langsString.append(spokenLanguages.joined(separator: ", "))
			return langsString
		}
		return nil
	}
	
//    func getAdditionalServicesForNonATM() -> [String] {
//        var arr: [String] = []
//
//        arr.append(contentsOf: attributtes?.financialServices() ?? [])
//        return arr
//    }
	
	func getDefaultATMOpeningTime() -> NSAttributedString {
		let attrsForTiming: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.bodyText.value,
															.foregroundColor: DetailCardCellAndViewThemeColor.bodyText.value]
		return NSAttributedString(string: "24h", attributes: attrsForTiming)
	}
}

extension POI: Equatable {
    public static func == (lhs: POI, rhs: POI) -> Bool {
        
        
        return lhs.geoLocation.latitude == rhs.geoLocation.latitude &&
            lhs.geoLocation.longitude == rhs.geoLocation.longitude
    }
}


// MARK: - Main poi

extension POI {
	// Phone title
	func getFirstPhoneTitleFromMainPOI() -> String? {
		if contactData?.phoneNumber != nil {
			return objectType.code.phoneTitle
		}
		return nil
	}
	
	// Phone
	func phoneForMainPOI() -> String? {
		return contactData?.phoneNumber
	}
	
	// Schedule
	func scheduleForMainPOI() -> NSAttributedString {
		if let attrString = schedule?.fullScheduleAttributtedString {
			if attrString.string == "" && objectType.code == .atm {
				return getDefaultATMOpeningTime()
			} else {
				return attrString
			}
		} else {
			assert(false)
			return NSAttributedString(string: "")
		}
	}
    
    func scheduleInCompounds() -> [ScheduleDay] {
        
        var elementsInOrder = [ScheduleDay]()
        var defaultDay = ScheduleDay()
        defaultDay.date = "24h"
        
        guard let dict = schedule?.getElementsInDictionary() else {
            elementsInOrder.append(defaultDay)
            return elementsInOrder
        }
        
        elementsInOrder = mapDays(dict: dict)
        elementsInOrder += mapSpecialDays()
        
        
        
        if elementsInOrder.count == 0 {
            elementsInOrder.append(defaultDay)
            return elementsInOrder
        } else {
            return elementsInOrder
        }
        
    }
    
	
    func mapDays(dict: [Int: [String]]) -> [ScheduleDay] {
        var initialIndex = 0
        var elementsInOrder = [ScheduleDay]()
        var day = ScheduleDay()
        
        //recorremos diccionario
        for (_, _) in dict {
            
            if initialIndex <= 6 {
                
                let initialHours = dict[initialIndex] as? [String] ?? []
                
                if initialHours.count > 0 {
                    //guardamos las horas iguales
                    let sameHours = dict.filter {
                        initialHours == $0.value as? [String]
                    }
                    var keysArraySorted = Array(sameHours.map({ $0.key})) as? [Int] ?? []
                    keysArraySorted.sort(by: <)
                    
                    //recorremos el array desde el primer valor+1 hasta la primera hora diferente, si es diferente guardamos la key del último valor igual concatenado con el primero y el valor de las horas y damos valor a initial de nuevo
                    var finalIndex = initialIndex
                    for dayInt in keysArraySorted {
                        if dayInt == finalIndex && finalIndex <= 6 {
                            finalIndex+=1
                        } else {
                            break
                        }
                    }
                    
                    //si los index son diferentes, son distinto día y toca agrupar, si el indice inical es más alto estamos en un día intermedio con horario diferente
                    if  (finalIndex-1) != initialIndex &&
                        initialIndex < finalIndex {
                        day.date = "\(initialIndex.getDayStringFromInt().cutString()) - \((finalIndex-1).getDayStringFromInt().cutString()):"
                        day.times = initialHours
                        elementsInOrder.append(day)
                    } else {
                        day.date = "\(initialIndex.getDayStringFromInt().cutString()):"
                        day.times = initialHours
                        elementsInOrder.append(day)
                        //por si estamos en un día intermedio
                        finalIndex+=1
                    }
                    initialIndex = finalIndex
                }
            }
            
        }
        
        return elementsInOrder
    }
    
    func mapSpecialDays() -> [ScheduleDay] {
        var elementsInOrder = [ScheduleDay]()
        var day = ScheduleDay()
        var specialDaysOrdered = [ScheduleDay]()
        
        if let specialDay = schedule?.specialDay {
            if specialDay.count > 0 {
                var hourValue = ""
                for specialDay in specialDay {
                    
                    if specialDay.times.count > 0 {
                        hourValue = specialDay.times.joined(separator: ",")
                    } else {
                        hourValue = localizedString("bl_closed")
                    }
                    
                    var dateString = specialDay.date
                    let formater = DateFormatter()
                    formater.dateFormat = "MM-dd"
                    formater.locale = Locale.current
                    
                    if let date = formater.date(from: dateString ?? "") {
                        //Format to the correct way
                        let formaterCurrent = DateFormatter()
                        formaterCurrent.dateFormat = "dd-MM"
                        formaterCurrent.locale = Locale.current
                        
                        dateString = formaterCurrent.string(from: date)
                        day.date = "\(dateString ?? "")"
                        day.times = [hourValue]
                        specialDaysOrdered.append(day)
                        
                    } else {
                        day.date = "\(dateString ?? "")"
                        day.times = [hourValue]
                        specialDaysOrdered.append(day)
                    }
                    
                }
                
                elementsInOrder = filterSpecialDates(specialDays: specialDaysOrdered)
            }
        }
        return elementsInOrder
    }
    
    func filterSpecialDates(specialDays: [ScheduleDay]) -> [ScheduleDay] {
        
        let currentDate = Date()
        //Delete the days before
        return specialDays.filter {
            let formaterCurrent = DateFormatter()
            formaterCurrent.dateFormat = "dd-MM-yyyy"
            formaterCurrent.locale = Locale.current
            
            //Put the year to compare
            let year = Calendar.current.component(.year, from: currentDate)
            let date = "\($0.date ?? "")-\(year)"
            
            return formaterCurrent.date(from: date) ?? Date().addingTimeInterval(-100) >= currentDate
        }
        
    }
    
	// Notices and news
	func getNewsAndAditionalInfoForMainPOI() -> NSAttributedString? {
		if let richTexts = richTexts {
			let newsAttrString = NSMutableAttributedString(string: "")
			for json in richTexts {
				var attrs: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOITitle.value,
														   .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOITitle.value]
                var uppercased = false
				if let code = json["code"] as? String {
                    switch code.trimmingCharacters(in: .whitespaces) {
					case "0":
                        attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
                        .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                    case "1":
                        attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
                                 .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBodyFormat1.value]
                    case "2":
                        attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBodyFormat2.value,
                        .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                    case "3":
                        
						attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
								 .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                        uppercased = true
					default:
						break
					}
				}
				
				if let multiJSON = json["multi"] as? JSON {
                    //for # cases
                    //var string = getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter().appending("</p>")
                    var string = getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter()
                    if uppercased { string = string.uppercased() }
                    let compounds = string.components(separatedBy: "#")
                    if compounds.count == 2 {
                        string = compounds[0].capitalizingFirstLetter()+" / "+compounds[1].capitalizingFirstLetter()

                        newsAttrString.append(formatHTMLToAttributted(string: string, attrs: attrs))
                        //newsAttrString.append(NSAttributedString(string: string, attributes: attrs))
                    } else {
                        
                        newsAttrString.append(formatHTMLToAttributted(string: string, attrs: attrs))
                        //newsAttrString.append(NSAttributedString(string: getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter().appending("\n"), attributes: attrs))
                    }
				}
			}
			return newsAttrString.trailingNewlineChopped
		} else {
			return nil
		}
	}
	
    func formatHTMLToAttributted(string: String, attrs: [NSAttributedString.Key : Any])-> NSMutableAttributedString {
        let newsAttrString = NSMutableAttributedString(string: "")
        //for html references
        let stringHTML = NSMutableAttributedString(string: "")
        stringHTML.append(string.convertHtml())
        let range = NSRange(location: 0, length: stringHTML.length)
        //add old attributtes
        stringHTML.addAttributes(attrs, range: range)
        
        newsAttrString.append(stringHTML)
        newsAttrString.append(NSAttributedString(string: "\n", attributes: attrs))
        return newsAttrString
    }
    
    //TODO: clean this out its not calling
//    func getAdditionalServicesForMainPOI() -> String {
//        if objectType.code == .atm {
//            return getAdditionalServicesForATM().joined(separator: "\n")
//        } else {
//            return getAdditionalServicesForNonATM().joined(separator: "\n")
//        }
//    }
	
	func accesibilityShouldShowAudioGuidance() -> Bool {
		if objectType.code == .atm {
			return attributtes?.audioGuidance ?? false
		}
		return false
	}
}


// MARK: - Secondary poi

extension POI {
	// Phone title
	func getFirstPhoneTitleFromFirstRelatedPOI() -> String? {
		for poi in relatedPOIs where poi.contactData?.phoneNumber != nil {
			return poi.objectType.code.phoneTitle
		}
		return nil
	}
	
	// Phone
	func getFirstPhoneFromRelatedPoi() -> String? {
		for poi in relatedPOIs where poi.contactData?.phoneNumber != nil {
			if let phone = poi.contactData?.phoneNumber {
				return phone
			}
		}
		return nil
	}
	
	// Schedule
	func getSecondarySchedule() -> NSAttributedString {
		for poi in relatedPOIs {
			if let attrString = poi.schedule?.fullScheduleAttributtedString,
				attrString.string != "" {
				return attrString
			}
		}
		return getDefaultATMOpeningTime()
	}
    
    func getSecondaryScheduleInCompunds() -> [ScheduleDay] {
        for poi in relatedPOIs {
            let compunds = poi.scheduleInCompounds()
            
            if compunds.count > 0 {
                return compunds
            }
            
        }
        var defaultDay = ScheduleDay()
        defaultDay.date = "24h"
        var elementsInOrder = [ScheduleDay]()
        elementsInOrder.append(defaultDay)
        return elementsInOrder
    }
	
	func getNewsAndAditionalInfoForFirstRelatedPOI() -> NSAttributedString? {
		for poi in relatedPOIs where poi.richTexts != nil {
			if let richTexts = poi.richTexts {
				let newsAttrString = NSMutableAttributedString(string: "")
				for json in richTexts {
					var attrs: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForFirstRelatedPOITitle.value,
															   .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForFirstRelatedPOITitle.value]
                    var uppercased = false
					if let code = json["code"] as? String {
                        
						switch code.trimmingCharacters(in: .whitespaces) {
                        case "0":
                            attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
                            .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                        case "1":
                            attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
                                     .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBodyFormat1.value]
                        case "2":
                            attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBodyFormat2.value,
                            .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                        case "3":
                            
                            attrs = [.font: DetailCardCellAndViewThemeFont.newAddtionalInfoForMainRelatedPOIBody.value,
                                     .foregroundColor: DetailCardCellAndViewThemeColor.newAddtionalInfoForMainRelatedPOIBody.value]
                            uppercased = true
						default:
							break
						}
					}
					
					if let multiJSON = json["multi"] as? JSON {
                        //for # cases
                        //var string = getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter().appending("</p>")
                        var string = getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter()
                        if uppercased { string = string.uppercased() }
                        let compounds = string.components(separatedBy: "#")
                        if compounds.count == 2 {
                            string = compounds[0].capitalizingFirstLetter()+" / "+compounds[1].capitalizingFirstLetter()

                            newsAttrString.append(formatHTMLToAttributted(string: string, attrs: attrs))
                            //newsAttrString.append(NSAttributedString(string: string, attributes: attrs))
                        } else {
                            
                            newsAttrString.append(formatHTMLToAttributted(string: string, attrs: attrs))
                            //newsAttrString.append(NSAttributedString(string: getLanguageOption(from: multiJSON).lowercased().capitalizingFirstLetter().appending("\n"), attributes: attrs))
                        }
                    }
				}
				return newsAttrString.trailingNewlineChopped
			}
		}
		return nil
	}
}


