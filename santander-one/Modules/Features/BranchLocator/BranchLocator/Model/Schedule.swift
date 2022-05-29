import Foundation
import ObjectMapper

public struct Schedule: Mappable {
	var specialDay: [SpecialDay]!
	var monday = [String]()
	var tuesday = [String]()
	var wednesday = [String]()
	var thursday = [String]()
	var friday = [String]()
	var saturday = [String]()
    var sunday = [String]()
	
	var openingColor: UIColor {
		return .limeGreen
	}
	
	public var openingHoursForToday: String {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let weekDay = calendar.component(.weekday, from: Date())
		
		switch weekDay {
		case 1:
			return sunday.joined(separator: "\n")
		case 2:
			return monday.joined(separator: "\n")
		case 3:
			return tuesday.joined(separator: "\n")
		case 4:
			return wednesday.joined(separator: "\n")
		case 5:
			return thursday.joined(separator: "\n")
		case 6:
			return friday.joined(separator: "\n")
		case 7:
			return saturday.joined(separator: "\n")
		default:
			return ""
		}
	}
	
	var fullScheduleAttributtedString: NSAttributedString {
		var fullString = ""
		
		let attrsForTiming: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.daysOfWeek.value,
															.foregroundColor: DetailCardCellAndViewThemeColor.daysOfWeek.value]
		
		if monday.count > 0 {
			fullString.append(localizedString("bl_monday").appending(": ").appending(monday.joined(separator: "\n")).appending("\n"))
		}
		if tuesday.count > 0 {
			fullString.append(localizedString("bl_tuesday").appending(": ").appending(tuesday.joined(separator: "\n")).appending("\n"))
		}
		if wednesday.count > 0 {
			fullString.append(localizedString("bl_wednesday").appending(": ").appending(wednesday.joined(separator: "\n")).appending("\n"))
		}
		if thursday.count > 0 {
			fullString.append(localizedString("bl_thursday").appending(": ").appending(thursday.joined(separator: "\n")).appending("\n"))
		}
		if friday.count > 0 {
			fullString.append(localizedString("bl_friday").appending(": ").appending(friday.joined(separator: "\n")).appending("\n"))
		}
		if saturday.count > 0 {
			fullString.append(localizedString("bl_saturday").appending(": ").appending(saturday.joined(separator: "\n")).appending("\n"))
		}
		if sunday.count > 0 {
			fullString.append(localizedString("bl_sunday").appending(": ").appending(sunday.joined(separator: "\n")).appending("\n"))
		}
		
		let attrString = NSMutableAttributedString(string: "")
		
		if fullString != "" {
			attrString.append(NSMutableAttributedString(string: fullString, attributes: attrsForTiming))
		}
		
		if specialDay.count > 0 {
			var specialDayRawStr = ""
			for specialDay in specialDay {
				specialDayRawStr.append("\n")
				specialDayRawStr.append(specialDay.date)
				specialDayRawStr.append(": ")
				if specialDay.times.count > 0 {
					specialDayRawStr.append(specialDay.times.joined(separator: ","))
				} else {
					specialDayRawStr.append(localizedString("bl_closed"))
				}
			}
            attrString.append(NSAttributedString(string: "\n".appending(localizedString("bl_special_schedule")).appending(":"),
                                                 attributes: [.font: UIFont.santander(family: .text, type: .regular, size: 25),
                                                              .foregroundColor: UIColor.green]))
			let specialAttrString = NSAttributedString(string: specialDayRawStr, attributes: attrsForTiming)
			attrString.append(specialAttrString)
		}
		
		return attrString
	}
    
    var isScheduled: Bool {
        var count = monday.count
        count += tuesday.count
        count += wednesday.count
        count += thursday.count
        count += friday.count
        count += saturday.count
        count += sunday.count
        count += specialDay.count
        if count > 0 {
            return true
        } else {
            return false
        }
    }
	
	func hasSchedule() -> Bool {
		if monday.count > 0 {
			return true
		}
		if tuesday.count > 0 {
			return true
		}
		if wednesday.count > 0 {
			return true
		}
		if thursday.count > 0 {
			return true
		}
		if friday.count > 0 {
			return true
		}
		if saturday.count > 0 {
			return true
		}
		if sunday.count > 0 {
			return true
		}
		if specialDay.count > 0 {
			return true
		}
		return false
	}
    
    func scheduleDayFrom(day: Int) -> [String] {
        switch day {
        case 1:
            return sunday
        case 2:
            return monday
        case 3:
            return tuesday
        case 4:
            return wednesday
        case 5:
            return thursday
        case 6:
            return friday
        case 7:
            return saturday
        default:
            return []
        }
    }
    
    func getElementsInDictionary() -> [Int: [String]] {
        
        let dict = [0: monday, 1: tuesday, 2: wednesday, 3: thursday, 4: friday, 5: saturday, 6: sunday]
        
        return dict
    }
	
    func getElementsInArray() -> NSArray {
        let key = [localizedString("bl_monday"), localizedString("bl_tuesday"), localizedString("bl_wednesday"), localizedString("bl_thursday"), localizedString("bl_friday"), localizedString("bl_saturday"), localizedString("bl_sunday")]
        
        let value = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
        
        return [key, value]
    }
    
	public init?(map: Map) {
		
	}
	
	mutating public func mapping(map: Map) {
		specialDay		<- map["specialDay"]
		monday			<- map["workingDay.MONDAY"]
		tuesday			<- map["workingDay.TUESDAY"]
		wednesday		<- map["workingDay.WEDNESDAY"]
		thursday		<- map["workingDay.THURSDAY"]
		friday			<- map["workingDay.FRIDAY"]
		saturday		<- map["workingDay.SATURDAY"]
        sunday          <- map["workingDay.SUNDAY"]
	}
}

