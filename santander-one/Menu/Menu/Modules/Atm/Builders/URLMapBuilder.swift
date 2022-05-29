//
//  URLMapBuilder.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 11/3/20.
//

import Foundation

class URLMapBuilder {
    fileprivate var urlString = "maps://?"
    var fromLocation: LocationBuilder {
        return  LocationBuilder(urlString: urlString, param: "saddr")
    }
    var toLocation: LocationBuilder {
        return LocationBuilder(urlString: urlString, param: "&daddr")
    }
    
    func build() -> URL? {
        return URL(string: urlString)
    }
}

final class LocationBuilder: URLMapBuilder {
    
    init(urlString: String, param: String) {
        super.init()
        super.urlString = urlString
        self.urlString += "\(param)="
    }
    
    func latitude(_ latitude: Double) -> LocationBuilder {
        self.urlString += "\(latitude)"
        return self
    }
    
    func longitude(_ longitude: Double) -> LocationBuilder {
        self.urlString += ",\(longitude)"
        return self
    }
}
