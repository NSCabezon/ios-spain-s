//
//  SantanderKeySecureDeviceViewModel.swift
//  Account
//
//  Created by Margaret López Calderón on 9/9/21.
//

import Foundation

public struct SantanderKeySecureDeviceViewModel {
    let title: String
    let bodyHead: String
    let bodyDescription: String
    
    public init(title: String, bodyHead: String, bodyDescription: String) {
        self.title = title
        self.bodyHead = bodyHead
        self.bodyDescription = bodyDescription
    }
}
