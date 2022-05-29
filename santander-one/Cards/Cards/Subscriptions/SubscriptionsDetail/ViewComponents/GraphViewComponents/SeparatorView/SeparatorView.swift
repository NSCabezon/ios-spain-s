import UIKit
import UI

public final class SeparatorView: XibView {

    @IBOutlet private weak var separatorView: UIView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension SeparatorView {
    func setupView() {
        backgroundColor = .clear
        separatorView.backgroundColor = .mediumSkyGray
    }
}
