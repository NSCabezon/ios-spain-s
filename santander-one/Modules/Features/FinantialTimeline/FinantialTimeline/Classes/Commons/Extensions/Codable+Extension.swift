//
//  Codable+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/09/2019.
//

import Foundation

extension Encodable {
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self), let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return nil }
        return result as? [String: Any]
    }
}
