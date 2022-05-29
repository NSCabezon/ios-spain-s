import UIKit

/// Conforms this protocol in any ViewController that you want to rotate
public protocol Rotatable: AnyObject {
    func preferredOrientationForPresentation() -> UIInterfaceOrientation
    func supportedOrientations() -> UIInterfaceOrientationMask
    func orientation() -> UIInterfaceOrientation
}

/// Conforms this protocol in any ViewController that you want to force rotation
public protocol ForcedRotatable: AnyObject {
    func forceOrientationForPresentation()
    func forceOrientationForDismission()
    func forcedOrientationForPresentation() -> UIInterfaceOrientation
    func forcedOrientationForDismission() -> UIInterfaceOrientation?
}

public extension ForcedRotatable where Self: UIViewController {
    func forceOrientationForPresentation() {
        UIApplication.shared.forceOrientation(to: forcedOrientationForPresentation())
    }
    
    func forceOrientationForDismission() {
        if let orientation = forcedOrientationForDismission() {
            UIApplication.shared.forceOrientation(to: orientation)
        }
    }
        
    func forcedOrientationForDismission() -> UIInterfaceOrientation? {
        return nil
    }
}

public extension Rotatable {
    func orientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
}

public extension Rotatable where Self: UIViewController {
    func preferredOrientationForPresentation() -> UIInterfaceOrientation {
        switch self {
        case is LandscapeRotatable, is LandscapeRightRotatable:
            return .landscapeRight
        case is LandscapeLeftRotatable:
            return .landscapeLeft
        case is LandscapeAndPortraitRotatable, is AllButUpsideDownRotatable, is AllOrientationsRotatable, is NotRotatable:
            return .portrait
        default:
            return .portrait
        }
    }
    
    func supportedOrientations() -> UIInterfaceOrientationMask {
        switch self {
        case is LandscapeRotatable:
            return .landscape
        case is LandscapeLeftRotatable:
            return .landscapeLeft
        case is LandscapeRightRotatable:
            return .landscapeRight
        case is LandscapeAndPortraitRotatable:
            return [.landscape, .portrait]
        case is AllButUpsideDownRotatable:
            return .allButUpsideDown
        case is AllOrientationsRotatable:
            return .all
        case is NotRotatable:
            return .portrait
        default:
            return .portrait
        }
    }
}

/// Conforms this protocol if you want to keep the orientation as portrait in your View Controller
public protocol NotRotatable: Rotatable { }

/// Conforms this protocol if you want landscape and portrait orientations in your View Controller
public protocol LandscapeAndPortraitRotatable: Rotatable {}

/// Conforms this protocol if you want just landscape left orientation in your View Controller
public protocol LandscapeLeftRotatable: Rotatable {}

/// Conforms this protocol if you want just landscape right orientation in your View Controller
public protocol LandscapeRightRotatable: Rotatable {}

/// Conforms this protocol if you want just landscape orientation in your View Controller
public protocol LandscapeRotatable: Rotatable {}

/// Conforms this protocol if you want all but upside down orientations in your View Controller
public protocol AllButUpsideDownRotatable: Rotatable {}

/// Conforms this protocol if you want all orientations in your View Controller
public protocol AllOrientationsRotatable: Rotatable {}

public extension UIApplication {
     var updateOrientation: UIInterfaceOrientation? {
         if #available(iOS 13.0, *) {
             return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
         } else {
             return UIApplication.shared.statusBarOrientation
         }
     }
    
    func forceOrientation(to orientation: UIInterfaceOrientation) {
        if updateOrientation != orientation {
            UIDevice.current.setValue(Int(orientation.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
            DispatchQueue(label: "force.rotation.timer").asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    if strongSelf.updateOrientation != orientation {
                        strongSelf.forceOrientation(to: orientation)
                    }
                }
            }
        }
    }
}

public final class NotRotableNavigationViewController: UINavigationController, NotRotatable {
    public override var shouldAutorotate: Bool {
        return true
    }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return preferredOrientationForPresentation()
    }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientations()
    }
}
