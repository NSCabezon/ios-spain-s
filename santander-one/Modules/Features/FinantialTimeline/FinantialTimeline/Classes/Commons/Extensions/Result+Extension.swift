//
//  Result+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 05/07/2019.
//

import Foundation

extension Result where Success == Data {
    
    func decode<Response: Codable>() -> Result<Response, Error> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            let decoder = JSONDecoder()
            if let dateParseable = Response.self as? DateParseable.Type {
                decoder.dateDecodingStrategy = .custom(dateParseable.decode)
            }
            do {
                let decodedResponse = try decoder.decode(Response.self, from: data)
                return .success(decodedResponse)
            } catch {
                print(error)
                return .failure(error)
            }
        }
    }
    
    public func asString() -> Result<String, Error> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let data):
            let str = String(decoding: data, as: UTF8.self)
            return .success(str)
        }
    }
}
