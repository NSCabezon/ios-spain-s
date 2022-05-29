import UIKit
import UI

class DigitalProfileSeparatorTooltipView: XibView {
    @IBOutlet var separatorView: DottedLineView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension DigitalProfileSeparatorTooltipView {
    func setupView() {
        separatorView.strokeColor = .mediumSkyGray
        separatorView.backgroundColor = .clear
    }
}
