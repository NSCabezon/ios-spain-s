import UIKit
import UI
import CoreFoundationLib

class SeparatorEmittedTransferView: XibView {
    @IBOutlet weak var separator: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: 3).isActive = true
        self.backgroundColor = .mediumSkyGray
        borders(for: [.left, .right], color: .mediumSkyGray)
    }
    
    override func draw(_ rect: CGRect) {
        separator.dotted(with: [1, 1, 1, 1], color: UIColor.mediumSkyGray.cgColor)
    }
    
    func hideDottedLine() {
        self.separator.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}
