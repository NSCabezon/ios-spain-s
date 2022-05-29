import UIKit

class DeviceHelper {
   func screenResolution() -> String {
        let screenBounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let width = screenBounds.size.width * scale
        let height = screenBounds.size.height * scale
        let resolution = String(format: "%.fx%.f", width, height)
        return resolution
    }
    
    func screenInches() -> String? {
        let scale = UIScreen.main.scale
        let screenBounds = UIScreen.main.bounds
        let ppi: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 132 : 163
        let width = screenBounds.size.width * scale
        let height = screenBounds.size.height * scale
        let horizontal = width / ppi, vertical = height / ppi
        let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        let numberString = formatter.string(from: NSNumber(value: Float(diagonal)))
        if numberString == "5,2" {
            return "5,5"
        } else {
            return numberString
        }
    }
    
    func model() -> String {
        return UIDevice.current.model
    }
    
    func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
}
