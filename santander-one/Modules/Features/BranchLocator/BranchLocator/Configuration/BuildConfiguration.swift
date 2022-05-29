import Foundation

enum CountryServer: String {
    case unitedStates = "United States"
    case netherlands  = "Netherlands"
}
enum BuildConfiguration {
	case dev
	case pre
	case pro(CountryServer)


	var name: String {
		switch self {
		case .dev:
			return "DEV"
		case .pre:
			return "PRE"
		case .pro:
			return "PRO"
		}
	}
	
	var baseURL: URL {
		switch self {
		case .dev:
			return URL(string: "http://back.branchlocatorsb.p.azurewebsites.net/branch-locator/")!
		case .pre:
			return URL(string: "http://branchlocator-pre.azurewebsites.net/branch-locator/")!
		case .pro(let countryServer):
            switch countryServer {
            case .unitedStates:
                return URL(string: "https://back-scus.azurewebsites.net/branch-locator/")!
            case .netherlands:
                return URL(string: "https://back-weu.azurewebsites.net/branch-locator/")!

            }
		}
	}
	
	var hockeyId: String {
		switch self {
		default:
			return ""
		}
	}
}
