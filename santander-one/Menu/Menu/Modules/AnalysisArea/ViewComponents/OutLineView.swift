//
//  OutLineView.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 18/05/2020.
//
import UI
import CoreFoundationLib

class OutLineView: UIDesignableView {
    @IBOutlet weak private var bottomBar: UIView!
    @IBOutlet weak private var monthLabel: UILabel!
    @IBOutlet weak private var bottomBarHeightConstraint: NSLayoutConstraint!

    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
        let shadowSize: CGFloat = 8
        let contactRect = CGRect(x: 0,
                                 y: bounds.height - (shadowSize * 0.7),
                                 width: bounds.width,
                                 height: shadowSize)
        layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
    }
    
    func setMonth(_ month: String) {
        self.monthLabel.text = month
        self.monthLabel.accessibilityIdentifier = AccessibilityAnalysisSegment.segmentTitle.rawValue + month
    }
}

private extension OutLineView {
    func setupViews() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.drawBorder(cornerRadius: 5.0, color: .darkTorquoise, width: 1.6)
        self.bottomBar.backgroundColor = .white
        self.bottomBar.clipsToBounds = true
        self.bottomBar.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4)
        self.monthLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .darkTorquoise)
    }
}
