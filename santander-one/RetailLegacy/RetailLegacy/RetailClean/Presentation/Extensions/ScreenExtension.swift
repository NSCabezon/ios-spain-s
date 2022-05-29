//

import UI

extension UIScreen {
    var isIphone4or5: Bool {
        return Screen.isIphone4or5
    }
    
    var isIpadNoRetina: Bool {
        return Screen.isIpadNoRetina
    }
    
    var isIphone4: Bool {
        return Screen.isIphone4
    }
    
    var isIphone5: Bool {
        return Screen.isIphone5
    }
    
    var isIphone6: Bool {
        return Screen.isIphone6
    }
    
    var isIphone6P: Bool {
        return Screen.isIphone6P
    }
    
    var isIphone8Plus: Bool {
        return Screen.isIphone8Plus
    }
    
    var isIphoneX: Bool {
        return Screen.isIphoneX
    }
    
    var resolution: CGSize {
        return Screen.resolution
    }
    
    func isScreenSizeBiggerThanIphone8plus() -> Bool {
        return Screen.isScreenSizeBiggerThanIphone8plus()
    }
    
    func isScreenSizeBiggerThanIphone5() -> Bool {
        return Screen.isScreenSizeBiggerThanIphone5()
    }
    
    func isScreenSizeBiggerThanIphone10XS() -> Bool {
        return Screen.isScreenSizeBiggerThanIphone10XS()
    }
    
    // MARK: - StatusBar
    var statusBarHeight: CGFloat {
        return Screen.statusBarHeight
    }
}
