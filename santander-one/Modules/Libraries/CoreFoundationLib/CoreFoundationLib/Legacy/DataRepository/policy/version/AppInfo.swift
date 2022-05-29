//
//  AppInfo.swift
//  iOS Base
//
//  Created by Toni Moreno on 6/11/17.
//  Copyright © 2017 Toni. All rights reserved.
//

import Foundation

public class VersionInfoDTO: Equatable, Codable {

    let bundleIdentifier: String
    let versionName: String

    public init(bundleIdentifier: String, versionName: String) {
        self.bundleIdentifier = bundleIdentifier
        self.versionName = versionName
    }
    
    public func getBundleIdentifier() -> String {
        return bundleIdentifier
    }
    
    public func getVersionName() -> String {
        return versionName
    }

    public static func ==(lhs: VersionInfoDTO, rhs: VersionInfoDTO) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier && rhs.versionName == lhs.versionName
    }

}
