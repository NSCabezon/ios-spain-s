import UIKit

protocol ProductHomeDialogPresenterProtocol {
    var options: [ProductOption] { get }
}

protocol ProductHomeViewDelegate: class {
    func didSelectOption(at index: Int)
}

let optionsCellIdentifier = "optionsCell"

class ProductHomeDialogViewController: BaseViewController<ProductHomeDialogPresenterProtocol>, ProductHomeDialogDelegate {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var exitButton: ResponsiveButton!
    @IBOutlet weak var optionsTableView: UITableView!
    
    weak var delegate: ProductHomeViewDelegate?
    
    //Private Vars
    private var dataSource: ProductHomeDialogDataSource?
    private var tableViewHeight: CGFloat {
        return optionsTableView.contentSize.height
    }
    
    //Margins
    @IBOutlet weak var heightTable: NSLayoutConstraint!
    
    override class var storyboardName: String {
        return "ProductHomeDialogViewController"
    }
    
    override func prepareView() {
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightTable.constant = tableViewHeight
    }
    
    private func setupViews() {
        
        gradientView.backgroundColor = .sanGreyDark
        
        optionsTableView.layer.cornerRadius = 10
        optionsTableView.register(UINib(nibName: "ProductHomeDialogViewCell", bundle: .module), forCellReuseIdentifier: optionsCellIdentifier)
        
        dataSource = ProductHomeDialogDataSource(items: presenter.options, cellIdentifier: optionsCellIdentifier, stringLoader: stringLoader)
        optionsTableView.dataSource = dataSource
        optionsTableView.delegate = dataSource
        dataSource?.delegate = self
        optionsTableView.reloadData()
        heightTable.constant = tableViewHeight
        
        gradientView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(exitButtonAction)))
    }
    
    // MARK: - Action buttons
    @IBAction func exitButtonAction(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    func getIndex(_ index: Int) {
        dismiss(animated: true) { self.delegate?.didSelectOption(at: index) }
    }
}
