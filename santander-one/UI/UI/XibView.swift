//
//  XibInstantiable.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 31/01/2020.
//

import Foundation

open class XibView: UIView {
    public var view: UIView?
    public var groupedAccessibilityElements: [Any]?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
    }
    
    private func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view ?? UIView())
        self.view?.fullFit()
    }
    
    private var bundle: Bundle? {
        let bundle = Bundle(for: type(of: self))
        guard let bundleName = bundle.bundleIdentifier?.split(".").last else { return nil }
        let bundleURL = bundle.url(forResource: bundleName, withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }
    
    private func loadViewFromNib() -> UIView {
        guard let bundle = self.bundle else { return UIView() }
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
}
