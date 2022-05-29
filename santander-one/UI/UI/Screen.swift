//
//  Screen.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 16/12/2019.
//

import UIKit

/// Helps asking the system about current device taking into account vertical dimension
public final class Screen {
    
    private static let mainScreen = UIScreen.main
    private static let application = UIApplication.shared
    
   public class var isIphone4or5: Bool {
        return isIphone5 || isIphone4
    }
       
   public class var isIpadNoRetina: Bool {
        return mainScreen.nativeBounds.height == 480
   }
   
   public class var isIphone4: Bool {
       return mainScreen.nativeBounds.height == 960
   }
   
   public class var isIphone5: Bool {
       return mainScreen.nativeBounds.height == 1136
   }
   
   public class var isIphone6: Bool {
       return mainScreen.nativeBounds.height == 1334
   }
    
    public class var isBiggerThanIphone6: Bool {
        return mainScreen.nativeBounds.height > 1334
    }
   
   public class var isIphone6P: Bool {
       return mainScreen.nativeBounds.height == 1920 || mainScreen.nativeBounds.height == 2208
   }
    
    public class var isIphone8Plus: Bool {
        return mainScreen.nativeBounds.height == 2208
    }
   
   public class var isIphoneX: Bool {
       return mainScreen.nativeBounds.height == 2436
   }
    
    public class var isBiggerOrEqualThanIphoneX: Bool {
        return mainScreen.nativeBounds.height >= 2436
    }
   
   public class var resolution: CGSize {
       return mainScreen.bounds.size
   }
    
    public class var iphone5Height: CGFloat {
        return 568.0
    }
    
   public class var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            var safeAreaInset: CGFloat?
            switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                safeAreaInset = UIApplication.shared.delegate?.window??.safeAreaInsets.top
            case .landscapeLeft:
                safeAreaInset = UIApplication.shared.delegate?.window??.safeAreaInsets.left
            case .landscapeRight:
                safeAreaInset = UIApplication.shared.delegate?.window??.safeAreaInsets.right
            default:
                break
            }
            return safeAreaInset ?? 0 > 24
        }
        return false
    }
   
   public class func isScreenSizeBiggerThanIphone8plus() -> Bool {
       switch mainScreen.nativeBounds.height {
       case 1136, 1334, 1920, 2208:
           return false
       default:
           return true
       }
   }
   
   public class func isScreenSizeBiggerThanIphone5() -> Bool {
       switch mainScreen.nativeBounds.height {
       case 1136, 960:
           return false
       default:
           return true
       }
   }
    
    public class func isScreenSizeBiggerThanIphone10XS() -> Bool {
        switch mainScreen.nativeBounds.height {
        case 1136, 1334, 2436:
            return true
        default:
            return false
        }
    }
    
    public class func isZoomModeEnabled() -> Bool {
        return mainScreen.nativeScale > mainScreen.scale
    }
   
   // MARK: - StatusBar
   public class var statusBarHeight: CGFloat {
       return application.statusBarFrame.height
   }
}
