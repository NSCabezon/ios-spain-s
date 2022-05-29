
import Foundation

public class AvailableFilters {
    
    public static func defaultAvailableFilters() -> [FilterTypeProtocol] {
        return [FilterType.mostPopular,
                FilterType.service,
                FilterType.facilities,
                FilterType.accessibility,
                FilterType.pointsOfInterest]
    }
    
    public static func defaultWithOutPopularAndOthers() -> [FilterTypeProtocol] {
        return [FilterType.mostPopular,
                FilterType.service,
                FilterType.facilities,
                FilterType.accessibility,
                FilterType.pointsOfInterestWithOutPopularAndOthers]
    }

}
