import UIKit
import CoreDomain

//UTILIZO ESTA BASE PARA PODER PASAR UN UIVIEW QUE CUMPLA EL PROTOCOLO COMO PARAMETRO
public class CoachmarkBaseUIView: UIView, CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier?
}

public class CoachmarkUIButton: UIButton, CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier?
}

public class CoachmarkUILabel: UILabel, CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier?
}

public class CoachmarkUISwitch: UISwitch, CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier?
}

class CoachmarkUIStackView: UIStackView, CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier?
}

protocol CoachmarkUIView {
    var coachmarkId: CoachmarkIdentifier? { get set }
}

struct IntermediateRect: Comparable {
    static func < (lhs: IntermediateRect, rhs: IntermediateRect) -> Bool {
        return lhs.x == rhs.x &&
                lhs.y == rhs.y &&
                lhs.width == rhs.width &&
                lhs.height == rhs.height
    }
    
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    static var zero: IntermediateRect = IntermediateRect(x: -1, y: -1, width: -1, height: -1)
}
