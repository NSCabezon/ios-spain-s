import UIKit

public protocol Device {
    var osName: String { get }
    var osVersion: String { get }
    var deviceModel: String { get }
    var identifierForVendorString: String { get }
}

extension UIDevice: Device {
	
	public var osName: String {
		return "ios"
	}
	
	public var osVersion: String {
		return UIDevice.current.systemVersion
	}
	
	public static var isSimulator: Bool = {
		var isSim = false
		#if arch(i386) || arch(x86_64)
		isSim = true
		#endif
		return isSim
	}()
	
	public var deviceModel: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		
		let machine = systemInfo.machine
		let mirror = Mirror(reflecting: machine)
		var identifier = ""
		
		for child in mirror.children {
			if let value = child.value as? Int8, value != 0 {
				let escaped = UnicodeScalar(UInt8(value)).escaped(asASCII: false)
				identifier.append(escaped)
			}
		}
		
		
		if identifier == "i386" || identifier == "x86_64" {
			let smallerScreen = UIScreen.main.bounds.size.width < 768
			return smallerScreen ? "iPhoneSimulator" : "iPadSimulator"
		}
		
		return identifier
	}
	
	var isIpad: Bool {
		return deviceModel.contains("iPad")
	}
	
	public var identifierForVendorString: String {
		guard let identifier = UIDevice.current.identifierForVendor?.uuidString else {
			fatalError("Identifier for vendor must exist")
		}
		return "\(identifier)"
	}
}
