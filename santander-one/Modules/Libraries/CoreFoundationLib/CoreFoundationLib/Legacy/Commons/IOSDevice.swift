import UIKit
import CryptoSwift
import Locker

private let keychainServiceId = "com.ciber-es.utils"
private let keychainFootprint = "devicePersistentFootprint"

public protocol Device {
    var osName: String { get }
    var osVersion: String { get }
    var identifierForVendor: String { get }
    var footprint: String { get }
    var isJailBreaked: Bool { get }
}

public struct IOSDevice: Device {
    
    private var jailBreakVeryfier = JailBreakVeryfier()
    
    public init() {}

    public var osName: String {
        return UIDevice.current.systemName
    }
    
    public var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    public var identifierForVendor: String {
        guard let identifier = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Identifier for vendor must exist")
        }
        return "\(identifier)"
    }

    public var footprint: String {
        guard let storedDeviceFootprint = Locker.read(stringFromService: keychainServiceId, andAccount: keychainFootprint) else {
            // Build a new footprint
            let identifierForVendorSha256 = identifierForVendor.sha256()
            let modelSha256 = UIDevice.current.model.sha256() // Use current Model instead of fancy model.
            let systemNameSha256 = osName.sha256()
            
            let superHash = "\(identifierForVendorSha256)\(modelSha256)\(systemNameSha256)".sha256()
            let saved = Locker.save(superHash, inService: keychainServiceId, andAccount: keychainFootprint)
            if !saved {
                print("Error saving device footprint in Keychain. Check if \"Keychain sharing capability\" is enabled.")
            }
            
            return superHash.getEncodeString(withOptions: .endLineWithCarriageReturn) ?? ""
        }
        return storedDeviceFootprint.getEncodeString(withOptions: .endLineWithCarriageReturn) ?? ""
    }
    
    public var isJailBreaked: Bool {
        return jailBreakVeryfier.isJailBreaked()
    }
}
