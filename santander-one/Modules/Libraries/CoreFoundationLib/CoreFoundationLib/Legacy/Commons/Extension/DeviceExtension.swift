import UIKit

extension UIDevice {
    // MARK: - Check if simulator
    public var machineName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    // MARK: - Screen Sizes
    var isIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isSimulator: Bool {
        return getDeviceModel() == .simulator
    }
    
    var isIphoneSEModel: Bool {
        return getDeviceModel() == .iPhoneSE
    }
    
    var isIpodTouch5: Bool {
        return getDeviceModel() == .iPodTouch5
    }
    
    var isIpodTouch6: Bool {
        return getDeviceModel() == .iPodTouch6
    }
    
    var isIphone4: Bool {
        return getDeviceModel() == .iPhone4
    }
    
    var isIphone4S: Bool {
        return getDeviceModel() == .iPhone4S
    }
    
    var isIphone5: Bool {
        return getDeviceModel() == .iPhone5
    }
    
    var isIphone5C: Bool {
        return getDeviceModel() == .iPhone5C
    }
    
    var isIphone5S: Bool {
        return getDeviceModel() == .iPhone5S
    }
    
    var isIphone6: Bool {
        return getDeviceModel() == .iPhone6
    }
    
    var isIphone6P: Bool {
        return getDeviceModel() == .iPhone6plus
    }
    
    var isIphone6S: Bool {
        return getDeviceModel() == .iPhone6S
    }
    
    var isIphone6SP: Bool {
        return getDeviceModel() == .iPhone6Splus
    }
    
    var isIphone7: Bool {
        return getDeviceModel() == .iPhone7
    }
    
    var isIphone7P: Bool {
        return getDeviceModel() == .iPhone7plus
    }
    
    var isIphone8: Bool {
        return getDeviceModel() == .iPhone8
    }
    
    var isIphone8P: Bool {
        return getDeviceModel() == .iPhone8plus
    }
    
    var isIphoneX: Bool {
        return getDeviceModel() == .iPhoneX
    }
    
    var isIpad2: Bool {
        return getDeviceModel() == .iPad2
    }
    
    var isIpad3: Bool {
        return getDeviceModel() == .iPad3
    }
    
    var isIpad4: Bool {
        return getDeviceModel() == .iPad4
    }
    
    var isIpadAir: Bool {
        return getDeviceModel() == .iPadAir1
    }
    
    var isIpadAir2: Bool {
        return getDeviceModel() == .iPadAir2
    }
    
    var isIpadMini: Bool {
        return getDeviceModel() == .iPadMini1
    }
    
    var isIpadMini2: Bool {
        return getDeviceModel() == .iPadMini2
    }
    
    var isIpadMini3: Bool {
        return getDeviceModel() == .iPadMini3
    }
    
    var isIpadMini4: Bool {
        return getDeviceModel() == .iPadMini4
    }
    
    public var hasNoBiometry: Bool {
        return isIphone4 || isIphone4S || isIphone5 || isIphone5C
    }
    
    public var isSmallScreenIphone: Bool {
        return isIphone4 || isIphone4S || isIphone5 || isIphone5C || isIphone5S
    }

    public var humanReadableDeviceModel: String {
        getDeviceModel().rawValue
    }
    
    public func getDeviceName() -> String {
        let deviceNameData = UIDevice.current.name.data(using: String.Encoding.ascii, allowLossyConversion: true)
        if let deviceNameData = deviceNameData {
            let deviceName = String(data: deviceNameData, encoding: String.Encoding.ascii)
            return deviceName ?? ""
        }
        return ""
    }
}
