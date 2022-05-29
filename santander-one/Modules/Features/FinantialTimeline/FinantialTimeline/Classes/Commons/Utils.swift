//
//  Commons.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 11/09/2019.
//

import Foundation

class Utils {
    
    static func getTimeZone() -> String {
        let seconds = TimeZone.current.secondsFromGMT()
        let minutes = seconds / 60
        let hours = minutes / 60
        
        let gmtSimbol = hours >= 0 ? "+" : "-"
        let gmtStr = String(format: "%@%02d", gmtSimbol, abs(hours))
        return gmtStr
    }
    
    public class func getAppName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
    
    public class func getAppVersion() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return "No CFBundleShortVersionString" }
        return version
    }
}
