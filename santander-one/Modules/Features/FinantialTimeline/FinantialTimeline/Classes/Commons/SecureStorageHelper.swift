//
//  SecureStorageHelper.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 30/09/2019.
//

import Foundation
// import STGSecure_Storage


class SecureStorageHelper {
    static let setupFiltersFile = "setup_filters.json"
//    static let secure = STGSecureFiles()
    
    
    class func saveBlackList(_ value: BlackList) {
//        if let encodedData = try? JSONEncoder().encode(value) {
//            _ = secure.writeToSecureFile(alias: setupFiltersFile, data: encodedData, fileMode: .overwriteMode)
//        }
    }
    
    class func getBlackList() -> BlackList? {
//        guard let data = secure.readFromSecureFile(alias: setupFiltersFile),
//            let blackList = try? JSONDecoder().decode(BlackList.self, from: data) else { return nil }
//        return blackList
        return nil
    }
    
    class func resetBlackList() -> Bool {
//        return secure.removeSecureFile(alias: setupFiltersFile)
        return true
    }
}



