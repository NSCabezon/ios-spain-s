import UIKit.UIDevice
import CoreFoundationLib

extension UIDevice {
    func getFootPrint() -> String {
        return IOSDevice().footprint
    }
}
