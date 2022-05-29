//
//  BackgroundImageRepositoryProtocolMock.swift
//  QuickSetup
//
//  Created by Jose Camallonga on 17/12/21.
//

import Foundation
import CoreFoundationLib

public final class BackgroundImageRepositoryProtocolMock: BackgroundImageRepositoryProtocol {
    public init() {}
    
    public func loadWithName(_ name: String, baseUrl: String, oldName: String?) -> Bool {
        return true
    }
}
