import Foundation

public extension Bundle {
    
    var branchLocatorBundle: Bundle? {
        if let url = self.url(forResource: "BranchLocator", withExtension: "bundle") {
            return Bundle(url: url)
        } else {
            return nil
        }
    }
    var buildVersion: String {
		return object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
	}
	
	var appVersion: String {
		return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
	}
	
	var bundleId: String {
		return object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String ?? ""
	}
	
	var applicationReadableVersion: String {
		let mainBundle = Bundle.main
		return "v\(mainBundle.appVersion) (\(mainBundle.buildVersion))"
	}
	
	enum BundleResource: String {
		case images = "Images"
		case plist = "Plist"
		case views = "Views"
		case branchLocator = "BranchLocator"
	}
	
	convenience init?(resource: BundleResource) {
		guard let bundleURL = Bundle.main.url(forResource: resource.rawValue, withExtension: "bundle") else { return nil }
		self .init(url: bundleURL)
	}
}
