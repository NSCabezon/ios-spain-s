
import Foundation

struct RegionServer {
    let country: String
    let lat: Double
    let long: Double

    init(country: String, lat: Double, long: Double) {
        self.country = country
        self.lat = lat
        self.long = long
    }
}
