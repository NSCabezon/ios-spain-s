import UIKit

class BaseHeader: UIView {
    
}

protocol HeaderViewModelType {
    func configure<View>(_ view: View) where View: BaseHeader
}

class HeaderViewModel<View>: HeaderViewModelType where View: BaseHeader {
    
    func configure<HeaderView>(_ view: HeaderView) where HeaderView: BaseHeader {
        if let view = view as? View {
            configureView(view)
        }
    }
    
    func configureView(_ view: View) {
        fatalError()
    }
}
