import UIKit

extension UIColor {
    static func color(forDispositionStatus status: DispensationStatus) -> UIColor {
        let color: UIColor
        switch status {
        case .pending,
             .disputed,
             .partiallyExempt:
            color = .orange
        case .exempt:
            color = .green
        case .cancelled,
             .blocked,
             .expired,
             .annulled,
             .partiallyAnnulled,
             .revoked:
            color = .sanRed
        case .undefined:
            color = .uiWhite
        }
        
        return color
    }
}
