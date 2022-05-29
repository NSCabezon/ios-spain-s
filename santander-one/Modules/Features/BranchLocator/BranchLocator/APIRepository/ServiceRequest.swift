//
//  ServiceRequest.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 18/10/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation
import ObjectMapper

class ServiceRequest {
	
	func GET(with deviceURLString: String, params: [String: String]? = nil, completionHandler: @escaping (_: Data?, _: Int, _: Error?) -> Void) {
		let defaultSession = URLSession(configuration: .default)
		
		var components = URLComponents(string: deviceURLString)!
		if let params = params {
			let paramsArray = params.compactMap {
				return URLQueryItem(name: $0.key, value: $0.value)
			}
			components.queryItems = paramsArray
		}
		
		guard let url = components.url else { return }
		
		let task = defaultSession.dataTask(with: url) { data, response, error in
			guard error == nil else {
				completionHandler(nil, 0, error)
				return
			}
			
			guard let content = data,
				let httpResponse = response as? HTTPURLResponse else {
				return
			}
			
			completionHandler(content, httpResponse.statusCode, error)
		}
		
		task.resume()
	}
}
