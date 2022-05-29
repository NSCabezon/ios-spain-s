import UIKit

extension UIDevice {
    enum Model: String {
        case simulator   = "simulator/sandbox",
             iPodTouch1       = "iPod Touch 1",
             iPodTouch2       = "iPod Touch 2",
             iPodTouch3       = "iPod touch 3",
             iPodTouch4       = "iPod Touch 4",
             iPodTouch5       = "iPod Touch 5",
             iPodTouch6       = "iPod Touch 6",
             iPodTouch7       = "iPod Touch 7",
             iPad2            = "iPad 2",
             iPad3            = "iPad 3",
             iPad4            = "iPad 4",
             iPad5            = "iPad 5",
             iPad6            = "iPad 6",
             iPad7            = "iPad 7",
             iPad8            = "iPad 8",
             iPadAir1         = "iPad Air 1",
             iPadAir2         = "iPad Air 2",
             iPadAir3         = "iPad Air 3",
             iPadMini1        = "iPad Mini 1",
             iPadMini2        = "iPad Mini 2",
             iPadMini3        = "iPad Mini 3",
             iPadMini4        = "iPad Mini 4",
             iPadMini5        = "iPad Mini 5",
             iPadPro97        = "iPad Pro 9.7",
             iPadPro129       = "iPad Pro 12.9",
             iPadPro1292nd    = "iPad Pro 12.9(2nd)",
             iPadPro105       = "iPad Pro 10.5",
             iPadPro11        = "iPad Pro 11",
             iPadPro1293rd    = "iPad Pro 12.9(3rd)",
             iPadPro112nd     = "iPad Pro 11(2nd)",
             iPadPro1294th    = "iPad Pro 12.9(4th)",
             iPhone4          = "iPhone 4",
             iPhone4S         = "iPhone 4S",
             iPhone5          = "iPhone 5",
             iPhone5S         = "iPhone 5S",
             iPhone5C         = "iPhone 5C",
             iPhone6          = "iPhone 6",
             iPhone6plus      = "iPhone 6 Plus",
             iPhone6S         = "iPhone 6S",
             iPhone6Splus     = "iPhone 6S Plus",
             iPhoneSE         = "iPhone SE",
             iPhone7          = "iPhone 7",
             iPhone7plus      = "iPhone 7 Plus",
             iPhone8          = "iPhone 8",
             iPhone8plus      = "iPhone 8 Plus",
             iPhoneX          = "iPhone X",
             iPhoneXS         = "iPhone XS",
             iPhoneXSmax      = "iPhone XS Max",
             iPhoneXR         = "iPhone XR",
             iPhone11         = "iPhone 11",
             iPhone11Pro      = "iPhone 11 Pro",
             iPhone11ProMax   = "iPhone 11 Pro Max",
             iPhoneSE2        = "iPhone SE 2",
             iPhone12Mini     = "iPhone 12 Mini",
             iPhone12         = "iPhone 12",
             iPhone12Pro      = "iPhone 12 Pro",
             iPhone12ProMax   = "iPhone 12 Pro Max",
             unrecognized     = "Unrecognized device"
    }
    
    func getDeviceModel(from machineModel: String? = nil) -> Model {
        let actualMachineModel = machineModel ?? machineName
        let modelMap: [String: Model] = [
            // Simulator
            "i386": .simulator,
            "x86_64": .simulator,
            // iPod
            "iPod1,1": .iPodTouch1,
            "iPod2,1": .iPodTouch2,
            "iPod3,1": .iPodTouch3,
            "iPod4,1": .iPodTouch4,
            "iPod5,1": .iPodTouch5,
            "iPod7,1": .iPodTouch6,
            "iPod9,1": .iPodTouch7,
            // iPad
            "iPad2,1": .iPad2,
            "iPad2,2": .iPad2,
            "iPad2,3": .iPad2,
            "iPad2,4": .iPad2,
            "iPad2,5": .iPadMini1,
            "iPad2,6": .iPadMini1,
            "iPad2,7": .iPadMini1,
            "iPad3,1": .iPad3,
            "iPad3,2": .iPad3,
            "iPad3,3": .iPad3,
            "iPad3,4": .iPad4,
            "iPad3,5": .iPad4,
            "iPad3,6": .iPad4,
            "iPad6,11": .iPad5,
            "iPad6,12": .iPad5,
            "iPad7,5": .iPad6,
            "iPad7,6": .iPad6,
            "iPad7,11": .iPad7,
            "iPad7,12": .iPad7,
            "iPad11,6": .iPad8,
            "iPad11,7": .iPad8,
            // iPad Mini
            "iPad4,1": .iPadAir1,
            "iPad4,2": .iPadAir1,
            "iPad4,3": .iPadAir1,
            "iPad4,4": .iPadMini2,
            "iPad4,5": .iPadMini2,
            "iPad4,6": .iPadMini2,
            "iPad4,7": .iPadMini3,
            "iPad4,8": .iPadMini3,
            "iPad4,9": .iPadMini3,
            "iPad5,1": .iPadMini4,
            "iPad5,2": .iPadMini4,
            "iPad11,1": .iPadMini5,
            "iPad11,2": .iPadMini5,
            "iPad5,3": .iPadAir2,
            "iPad5,4": .iPadAir2,
            "iPad11,3": .iPadAir3,
            "iPad11,4": .iPadAir3,
            // iPad Pro
            "iPad6,3": .iPadPro97,
            "iPad6,4": .iPadPro97,
            "iPad6,7": .iPadPro129,
            "iPad6,8": .iPadPro129,
            "iPad7,1": .iPadPro1292nd,
            "iPad7,2": .iPadPro1292nd,
            "iPad7,3": .iPadPro105,
            "iPad7,4": .iPadPro105,
            "iPad8,1": .iPadPro11,
            "iPad8,2": .iPadPro11,
            "iPad8,3": .iPadPro11,
            "iPad8,4": .iPadPro11,
            "iPad8,5": .iPadPro1293rd,
            "iPad8,6": .iPadPro1293rd,
            "iPad8,7": .iPadPro1293rd,
            "iPad8,8": .iPadPro1293rd,
            "iPad8,9": .iPadPro112nd,
            "iPad8,10": .iPadPro112nd,
            "iPad8,11": .iPadPro1294th,
            "iPad8,12": .iPadPro1294th,
            // iPhone
            "iPhone3,1": .iPhone4,
            "iPhone3,2": .iPhone4,
            "iPhone3,3": .iPhone4,
            "iPhone4,1": .iPhone4S,
            "iPhone5,1": .iPhone5,
            "iPhone5,2": .iPhone5,
            "iPhone5,3": .iPhone5C,
            "iPhone5,4": .iPhone5C,
            "iPhone6,1": .iPhone5S,
            "iPhone6,2": .iPhone5S,
            "iPhone7,1": .iPhone6plus,
            "iPhone7,2": .iPhone6,
            "iPhone8,1": .iPhone6S,
            "iPhone8,2": .iPhone6Splus,
            "iPhone8,4": .iPhoneSE,
            "iPhone9,1": .iPhone7,
            "iPhone9,2": .iPhone7plus,
            "iPhone9,3": .iPhone7,
            "iPhone9,4": .iPhone7plus,
            "iPhone10,1": .iPhone8,
            "iPhone10,2": .iPhone8plus,
            "iPhone10,3": .iPhoneX,
            "iPhone10,4": .iPhone8,
            "iPhone10,5": .iPhone8plus,
            "iPhone10,6": .iPhoneX,
            "iPhone11,2": .iPhoneXS,
            "iPhone11,4": .iPhoneXSmax,
            "iPhone11,6": .iPhoneXSmax,
            "iPhone11,8": .iPhoneXR,
            "iPhone12,1": .iPhone11,
            "iPhone12,3": .iPhone11Pro,
            "iPhone12,5": .iPhone11ProMax,
            "iPhone12,8": .iPhoneSE2,
            "iPhone13,1": .iPhone12Mini,
            "iPhone13,2": .iPhone12,
            "iPhone13,3": .iPhone12Pro,
            "iPhone13,4": .iPhone12ProMax
        ]
        
        if let validatedString = String(validatingUTF8: actualMachineModel), let model = modelMap[validatedString] {
            return model
        }
        return .unrecognized
    }
    
}
