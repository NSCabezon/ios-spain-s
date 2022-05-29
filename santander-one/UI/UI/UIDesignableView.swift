//
//  UIDesignableView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 10/02/2020.
//

public protocol BundleSpecificable: AnyObject {
    func getBundleName() -> String
}

/*
 provide automatic loading of a xib located on a bundle with the same name as the module. Resources in the UI module may skip overriding getBundleName.
 if the resource is outside this module, please override getBundleName in order to prpperly locate the resource. 
 */
open class UIDesignableView: UIView, BundleSpecificable {
    
    open func getBundleName() -> String { return "UI" }

    private var instanceClass: AnyClass {
        let thisType = type(of: self)
        return thisType
    }
    
    var bundle: Bundle? {
        return Bundle(for: instanceClass.self)
    }

    private var bundleName: String {
        return self.getBundleName()
    }
    
    @IBOutlet weak var contentView: UIView?
    
    lazy var module: Bundle? = {
        guard let podBundle = self.bundle else {
            preconditionFailure("Bundle Name must be specified, please override getBundleName()")
        }
        let bundleURL = podBundle.url(forResource: bundleName, withExtension: "bundle")
        return bundleURL.flatMap(Bundle.init)
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    open func commonInit() {
        let nibName = String(describing: instanceClass)
        guard let optionalBundle = self.module else {
            preconditionFailure("resource XIB seems that is not on a bundle with the same name as module. Consider subclassing DesignableView instead")
        }
        optionalBundle.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        content.backgroundColor = UIColor.clear
    }
}
