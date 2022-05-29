import Foundation

// swiftlint:disable colon
public typealias JSON = [String : Any]
// swiftlint:enable colon

public func localizedString(_ key: String) -> String {
	return NSLocalizedString(key, bundle: Bundle(for: MapViewController.self).branchLocatorBundle!, comment: "")
}

struct AppConfiguration {
    let buildConfiguration: BuildConfiguration
    init(fromCountry: CountryServer?) {
        if let country = fromCountry{
            buildConfiguration = BuildConfiguration.pro(country)
        }else{
            buildConfiguration = BuildConfiguration.pre
        }

    }
    func getBaseURL() -> URL {
        return self.buildConfiguration.baseURL
    }
}

extension JSON {

    
    func equatable(_ toJSON: JSON) -> Bool {
        let originalData: Data = NSKeyedArchiver.archivedData(withRootObject: self)
        let dataToCompareTo: Data = NSKeyedArchiver.archivedData(withRootObject: toJSON)

        // at the moment they dont equate to eachother  we need to find a way to check if the elements inside the other poi == that of what i have already (self)
        // see if in the new toJson if its already in the new original..
        // swiftlint:disable force_cast
        let original = self as! [String:String]
        let incoming = toJSON as! [String:String]
        // swiftlint:enable force_cast
        if original == incoming{
            print("true")
        }
        for y in original {
           // check if the other jsons values match what
            
        }


        return original == incoming
    }
}


extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
