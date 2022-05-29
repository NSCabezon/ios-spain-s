//
//  XibInstantiable.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 31/01/2020.
//

import Foundation

public protocol XibInstantiable: AnyObject {
    var view: UIView? { get set }
    var bundle: Bundle? { get }
}

public extension XibInstantiable where Self: UIView {
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.view ?? UIView())
        self.view?.fullFit()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: self.bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
}
