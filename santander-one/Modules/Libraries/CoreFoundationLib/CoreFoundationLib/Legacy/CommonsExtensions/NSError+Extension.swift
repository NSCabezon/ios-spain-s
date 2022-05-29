//
//  NSError+Extension.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 23/12/21.
//

import Foundation

extension NSError {
    
    public convenience init(description: String) {
        self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
