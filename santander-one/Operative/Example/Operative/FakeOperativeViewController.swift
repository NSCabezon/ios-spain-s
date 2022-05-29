//
//  FakeOperativeViewController.swift
//  Operative_Example
//
//  Created by Jose Carlos Estela Anguita on 18/12/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Operative
import UIKit

protocol FakeOperativeViewProtocol: OperativeView {
    func setImage(name: String)
}

class FakeOperativeViewController: UIViewController {
    private let presenter: FakeOperativeStepPresenterProtocol
    @IBOutlet weak var imageView: UIImageView!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: FakeOperativeStepPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loaded()
    }
    
    @IBAction func next(_ sender: UIButton) {
        self.presenter.goNext()
    }
}

extension FakeOperativeViewController: FakeOperativeViewProtocol {
    func setImage(name: String) {
        self.imageView.image = UIImage(named: name)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
}
