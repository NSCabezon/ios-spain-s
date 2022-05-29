//
//  TouchIdData.swift
//  Models
//
//  Created by Juan Carlos López Robles on 11/17/20.
//

import Foundation

open class TouchIdData: NSObject, NSCoding {
    public let deviceMagicPhrase: String
    public var touchIDLoginEnabled: Bool = false
    public let footprint: String
    
    public init(deviceMagicPhrase: String, touchIDLoginEnabled: Bool, footprint: String) {
        self.deviceMagicPhrase = deviceMagicPhrase
        self.touchIDLoginEnabled = touchIDLoginEnabled
        self.footprint = footprint
    }
    
    // MARK: NSCoding
    public convenience required init?(coder aDecoder: NSCoder) {
        let deviceMagicPhrase = aDecoder.decodeObject(forKey: "deviceToken") as? String
        let touchIDLoginEnabled = aDecoder.decodeObject(forKey: "touchIDLoginEnabled") as? String
        let footprint = aDecoder.decodeObject(forKey: "footprint") as? String
        
        self.init(deviceMagicPhrase: deviceMagicPhrase ?? "", touchIDLoginEnabled: touchIDLoginEnabled == "true", footprint: footprint ?? "")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(deviceMagicPhrase, forKey: "deviceToken")
        aCoder.encode(touchIDLoginEnabled ? "true" : "false", forKey: "touchIDLoginEnabled")
        aCoder.encode(footprint, forKey: "footprint")
    }
}
