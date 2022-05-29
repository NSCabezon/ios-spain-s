//
//  CVVView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/19/19.
//

import Foundation

class CVVView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.xibSetup()
    }
    
    private func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    func setColor(_ color: UIColor) {
        self.stackView.arrangedSubviews.forEach { ($0 as? CircleView)?.setColor(color) }
    }
}
