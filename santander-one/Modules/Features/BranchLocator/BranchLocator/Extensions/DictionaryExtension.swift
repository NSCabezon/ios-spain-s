//
//  DictionaryExtension.swift
//  Alamofire
//
//  Created by Ivan Cabezon on 18/10/2018.
//

import Foundation

extension Dictionary {
	var queryString: String {
		var output: String = ""
		for (key, value) in self {
			output +=  "\(key)=\(value)&"
		}
		output = String(output.dropLast())
		return output
	}
}
