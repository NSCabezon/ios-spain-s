import UIKit
import CoreFoundationLib
import UI

enum Greeting: String {
    case goodMorning = "login_label_goodMornig"
    case goodAfternoon = "login_label_goodAfternoon"
    case goodNight = "login_label_goodEvening"
}

final class TimeImageAndGreetings {
    var greetingTextKey: Greeting {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let parts = calendar.dateComponents([.hour], from: now)
        switch parts.hour! {
        case 5..<14:
            return .goodMorning
        case 14..<20:
            return .goodAfternoon
        default:
            return .goodNight
        }
    }
    
    var backgroundImage: UIImage? {
        let randomId: Int = Int.random(in: 1...10)
        let theme: BackgroundImagesTheme = BackgroundImagesTheme.nature
        return Assets.image(named: "\(theme.name)_\(randomId)")
    }
}
