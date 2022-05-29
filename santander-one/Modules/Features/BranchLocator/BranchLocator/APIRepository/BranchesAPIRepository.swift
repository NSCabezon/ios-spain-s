import Foundation
import MapKit
import ObjectMapper

public class BranchesAPIRepository {
    
    let branchesService = ServiceRequest()
    
    let regionsServer: [RegionServer] = [
        RegionServer(country: "United States", lat: 29.4247, long: -98.4935),
        RegionServer(country: "Netherlands", lat: 52.35, long: 4.9167)]

    public init() {
        
    }
    
    //	func getFees(forCountry country: String, completionHandler: @escaping (_: [Fee], _: Int) -> Void) {
    //		let url = AppConfiguration.baseURL.appendingPathComponent("atm/getSurchargefromCountry").absoluteString
    //
    //		branchesService.GET(with: url, params: ["country": country]) { data, statusCode, _ in
    //			guard let data = data,
    //				let dataString = String(data: data, encoding: String.Encoding.utf8) else {
    //					completionHandler([], statusCode)
    //					return
    //			}
    //
    //			DispatchQueue.main.async {
    //				if let feesResponse = Mapper<FeeResponse>().map(JSONString: dataString) {
    //					completionHandler(feesResponse.surcharges, statusCode)
    //				} else {
    //					completionHandler([], 0)
    //				}
    //			}
    //		}
    //	}
    
    public func findBranches(with location: CLLocationCoordinate2D, filters: [Filter] = [], numResults: Int? = nil, country: String? = "ES", isCustomer: Bool? = false, completionHandler: @escaping (_: [POI], _: Int) -> Void) {
        
        let lat = location.latitude
        let lon = location.longitude
        
        let country = country ?? "ES"
        let isCustomer = isCustomer ?? false
        
        // swiftlint:disable colon
        var params: [String : String] = ["country" : country, "customer" : isCustomer ? "true" : "false"]
        // swiftlint:enable colon
        
        if let numResults = numResults {
            params["config"] = "{\"resultsConfig\":{\"maxResults\":\(numResults),\"minRadius\":0.5,\"numElemPag\":10,\"maxRadius\":1000}, \"coords\":[\(lat), \(lon)]}"
        } else {
            params["config"] = "{\"coords\":[\(lat), \(lon)]}"
        }
        
        params = fill(params, with: filters)

        let countryName = closestServer(regions: regionsServer, closestToLocation: CLLocation(latitude: lat, longitude: lon))
        let url = AppConfiguration(fromCountry: countryName).getBaseURL().appendingPathComponent("find/defaultView").absoluteString
        
        branchesService.GET(with: url, params: params) { data, statusCode, _ in
            guard let data = data,
                let dataString = String(data: data, encoding: String.Encoding.utf8) else {
                    DispatchQueue.main.async {
                        completionHandler([], statusCode)
                    }
                    return
            }
            
            let pois = Mapper<POI>().mapArray(JSONString: dataString)
            let cleanPOIs = self.cleanDuplicates(poiArray: pois ?? [])
            let cleanSuperClosePOIs = self.refactorSuperClosePOIs(poiArray: cleanPOIs)
            
            DispatchQueue.main.async {
                completionHandler(cleanSuperClosePOIs, statusCode)
            }
        }
    }
    func closestServer(regions: [RegionServer], closestToLocation location: CLLocation) -> CountryServer? {
        if regions.count == 0 {
            return nil
        }
        var locations = [CLLocation]()
        for location in regions {
            locations.append(CLLocation(latitude: location.lat, longitude: location.long))
        }

        var closestLocation: CLLocation?
        var smallestDistance: CLLocationDistance?
        for loc in locations {
            let distance = loc.distance(from: location)
            if smallestDistance == nil || distance < smallestDistance! {
                closestLocation = loc
                smallestDistance = distance
            }
        }
        var countryName: String?
        let closestLat: Double = Double(closestLocation?.coordinate.latitude ?? 0)
        let closestLong: Double = Double(closestLocation?.coordinate.longitude ?? 0)
        for loc in regions{
            if closestLat == loc.lat && closestLong == loc.long {
                countryName = loc.country
            }
        }

        switch countryName {
        case CountryServer.unitedStates.rawValue:
            return CountryServer.unitedStates

        case CountryServer.netherlands.rawValue:
            return CountryServer.netherlands
            
        default:
            return CountryServer.netherlands
        }


    }
    
    func fill(_ params: [String: String], with filters: [Filter]) -> [String: String] {
        if filters.count == 0 {
            return params
        }
        
        var params = params
        
        var filtersStr = [String]()
        var typeStr = [String]()
        var subtypeStr = [String]()
        
        for filter in filters {
            switch filter {
            case .withdrawMoney: filtersStr.append("WITHDRAW")
            case .lowDenominationBill: filtersStr.append("LOW_DENOMINATION_BILL")
            case .withdrawWithoutCard: filtersStr.append("RETIRO_CON_CODIGO")
            case .coworkingSpaces: filtersStr.append("COWORKING_SPACES")
            case .wifi: filtersStr.append("WIFI")
            case .securityBox: filtersStr.append("SAFE_BOX")
            case .driveThru: filtersStr.append("DRIVE_THRU")
            case .wheelchairAccess: filtersStr.append("ACCESIBILITY")
            case .audioGuidance: filtersStr.append("AUDIO_GUIDANCE")
            case .contactLess: filtersStr.append("CONTACTLESS")
            case .opensEvenings: filtersStr.append("OPEN_EVENINGS")
            case .opensSaturdays: filtersStr.append("OPEN_SATURDAY")
            case .parking: filtersStr.append("PARKING")
            case .depositMoney: filtersStr.append("MULTICAJERO")
            case .partners:
                typeStr.append(Type.corresponsales.rawValue)
            case .individual:
                subtypeStr.append(SubTypeCode.universities.rawValue)
                subtypeStr.append(SubTypeCode.individuals.rawValue)    // No filter defined for individuals
            case .workcafe:
                subtypeStr.append(SubTypeCode.workCafe.rawValue)
            case .santanderSelect:
                subtypeStr.append(SubTypeCode.select.rawValue)
            case .privateBank:
                subtypeStr.append(SubTypeCode.privateBanking.rawValue)
            case .pymesEmpresas:
                subtypeStr.append(SubTypeCode.pyme.rawValue)
                subtypeStr.append(SubTypeCode.companies.rawValue)
            case .popularPastor:
                subtypeStr.append(SubTypeCode.popular.rawValue)
                subtypeStr.append(SubTypeCode.pastor.rawValue)
            case .santanderATM:
                subtypeStr.append(SubTypeCode.santanderATM.rawValue)
            case .otherATMs:
                subtypeStr.append(SubTypeCode.nonSantanderATM.rawValue)
            default:
                break
            }
        }
        
        if filtersStr.count > 0 {
            params["filterAttributeList"] = filtersStr.joined(separator: ",")
        }
        
        if typeStr.count > 0 {
            params["filterType"] = typeStr.joined(separator: ",")
        }
        
        if subtypeStr.count > 0 {
            params["filterSubtype"] = subtypeStr.joined(separator: ",")
        }
        
        return params
    }
    
    // if it contains the poi it will find the index of the duplicate poi in the branches array and add to its relatedPOI property.
    
    
    func cleanDuplicates(poiArray: [POI]) -> [POI] {
        var branchesArray = poiArray.filter { poi -> Bool in
            return poi.objectType.code == .branch
        }

        let atmsArray = poiArray.filter { poi -> Bool in
            return poi.objectType.code == .atm
        }

        let corresponsalArray = poiArray.filter { poi -> Bool in
            return poi.objectType.code == .corresponsales
        }

//        for poi in atmsArray {
//            if !branchesArray.contains(poi) {
//                branchesArray.append(poi)
//            } else if let idx = branchesArray.index(of: poi) {
//                branchesArray[idx].relatedPOIs.append(poi)
//            }
//        }
        // this index is giving me back that the poi object is located as the 0 element in the array when its actually the first
        // its working with calle bravo murrilo 278-280 and the one ending in popular
        // the issue seems to be when we get the index.. its getting the wrong index for exisitng elements in array
        for poi in atmsArray {
            if !branchesArray.contains(poi) {
                branchesArray.append(poi)
            } else if let idx = branchesArray.index(of: poi) {
                branchesArray[idx].relatedPOIs.append(poi)
            }
        }

        for poi in corresponsalArray {
            if !branchesArray.contains(poi) {
                branchesArray.append(poi)
            } else if let idx = branchesArray.index(of: poi) {
                branchesArray[idx].relatedPOIs.append(poi)
            }
        }

        branchesArray = branchesArray.sorted(by: { poi1, poi2 -> Bool in
            return poi1.distanceInKM < poi2.distanceInKM
        })

        return branchesArray
    }
    
    
    
//    func cleanDuplicates(poiArray: [POI]) -> [POI] {
//        var poisWithoutDuplicates = [POI]()
//        var modifiedATMArray = [POI]()
//
//        var branchesArray = poiArray.filter { poi -> Bool in
//            return poi.objectType.code == .branch
//        }
//
//        let atmsArray = poiArray.filter { poi -> Bool in
//            return poi.objectType.code == .atm
//        }
//
//        let corresponsalArray = poiArray.filter { poi -> Bool in
//            return poi.objectType.code == .corresponsales
//        }
//
//        // !modfiedArray.contains(where: {$0.location?.address == comparisonPOI.location?.address})
//        // if direction is different and coordinates are the same
//        for branch in branchesArray {
//            for atm in atmsArray {
//                if (branch.location?.latitude == atm.location?.latitude) && (branch.location?.longitude == atm.location?.longitude) && (branch.location?.address == atm.location?.address) {
//                    if let idx = branchesArray.index(of: branch) {
//                        branchesArray[idx].relatedPOIs.append(atm)
//                        modifiedATMArray.append(atm)
//                    }
//                }
//            }
//            poisWithoutDuplicates.append(branch)
//        }
//
//        for atm in atmsArray {
//            if !modifiedATMArray.contains(atm) {
//                poisWithoutDuplicates.append(atm)
//            }
//        }
//
//
//        for poi in corresponsalArray {
//        poisWithoutDuplicates.append(poi)
//        }
//
//
//        poisWithoutDuplicates = poisWithoutDuplicates.sorted(by: { poi1, poi2 -> Bool in
//            return poi1.distanceInKM < poi2.distanceInKM
//        })
//
//        return poisWithoutDuplicates
//    }
    
    
    
    
    
    
    
    
    
    
    func refactorSuperClosePOIs(poiArray: [POI]) -> [POI] {
        // This method is because some pois are so close that mapkit wont display it and with clustering enabled it will make the cluster unclickable.
        
        // logic: after POIs have been cleaned of any duplicates we run through that list to find any POIs that have a coordinate closer than 0.000001 if thats the case we will create a new POI object and change its coordinate to a modified new distance of 0.0001 at both lat and lon values. In turn seperating the POIs so that they can both be seen and interacted with.
        
        // contains a list of already modified poi
        var modfiedArray = [POI]()
       
        // we will return our new array. with our modified pois included
        var branchesArray = [POI]()
        
        let distanceBetween = 0.00001
        let superCloseDistance = 0.000001
        var count = 0
       
        for comparisonPOI in poiArray {
            var closePOIS = [POI]()
            
            for x in poiArray {
                if comparisonPOI.location?.address != x.location?.address && !modfiedArray.contains(where: {$0.location?.address == comparisonPOI.location?.address}){
                    
                    if let lat = x.location?.latitude as? Double , let lon = x.location?.longitude as? Double, let comparisonLat = comparisonPOI.location?.latitude, let comparisonLon = comparisonPOI.location?.longitude {
                        let resultLat = lat - comparisonLat
                        let resultLon = lon - comparisonLon
                        
                        // checking distance between the pois if its super close then we will add it to a new array
                        if (abs(resultLat) <= superCloseDistance || abs(resultLon) <= superCloseDistance) && (abs(resultLat) != 0 && abs(resultLon) != 0){
                            count+=1
                            closePOIS.append(x)
                        } else {
                            if (abs(lat) == abs(comparisonLat) && abs(lon) == abs(comparisonLon)) {
                                print("two same coordinates!")
                                count+=1
                                closePOIS.append(x)
                                //closePOIS.append(comparisonPOI)
                                print(comparisonPOI.location?.address)
                                print(x.location?.address)

                            }
//                            count = count+1
//                            closePOIS.append(x)
                        }
                        
                    }
                }
            }
            
            //once added to array we we make a new poi object and pass new coordinates, then append it to our modified array which contains a list of already modified pois so that they arent modified twice
            if closePOIS.count > 0 {
                var i = 0.0001
                if !branchesArray.contains(where: {$0.location?.address == comparisonPOI.location?.address}){
                    branchesArray.append(comparisonPOI)
                }

                for x in closePOIS {
                    let loc = CLLocationCoordinate2D(latitude: x.location!.latitude + distanceBetween + i , longitude: x.location!.longitude + distanceBetween + i)
                    let newPOI: POI = POI(poi: x, locationParam: loc)!
                    modfiedArray.append(newPOI)
                    modfiedArray.append(comparisonPOI)
                    branchesArray.append(newPOI)
                    i += 0.0002
                }

            }else{
                if !branchesArray.contains(where: {$0.location?.address == comparisonPOI.location?.address}) {
                    branchesArray.append(comparisonPOI)
                }
            }
        }
        return branchesArray
    }
}



