//
//  PublicFilesEnvironmentDTO.swift
//  Models
//
//  Created by César González Palomino on 19/02/2020.
//

import Foundation

public class PublicFilesEnvironmentDTO: Codable, Hashable, CustomStringConvertible {

    public let name: String?
    public let urlBase: String?
    public let fromLocal: Bool

    public init(_ name: String?, _ urlBase: String?, _ fromLocal: Bool) {
        self.name = name
        self.urlBase = urlBase
        self.fromLocal = fromLocal
    }

    public var description: String {
        return "\(name ?? ""): \(urlBase ?? "")"
    }

    public static func == (lhs: PublicFilesEnvironmentDTO, rhs: PublicFilesEnvironmentDTO) -> Bool {
        if lhs.name != nil ? lhs.name! != rhs.name : rhs.name != nil {
            return false
        }
        return lhs.urlBase != nil ? lhs.urlBase! == rhs.urlBase : rhs.urlBase == nil
    }
    
    public func hash(into hasher: inout Hasher) {
        let result = 32 * (name?.hashValue ?? 0) + (urlBase?.hashValue ?? 0)
        hasher.combine(result)
    }
}
