//
//  MovementsHeaderView.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/10/19.
//
import UI
import CoreFoundationLib
import Foundation
import OpenCombine

final class MovementsHeaderView: XibView {
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var downloadButton: PressableButton!
    @IBOutlet weak var filterButton: PressableButton!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var pdfLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    private var anySubscriptions = Set<AnyCancellable>()
    let hideFilterSubject = PassthroughSubject<Bool, Never>()
    let didSelectActionSubject = PassthroughSubject<Loan, Never>()
    let selectLoanSubject = PassthroughSubject<Loan, Never>()
    private var loan: Loan?
    
    convenience init() {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 54)
        self.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
      
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
}

private extension MovementsHeaderView {
    func bind() {
        hideFilterSubject
            .sink {[unowned self] hide in
                self.filterLabel.isHidden = hide
                self.filterImageView.isHidden = hide
                self.filterButton.isHidden = hide
            }.store(in: &anySubscriptions)
        
        selectLoanSubject
            .sink {[unowned self] loan in
                self.loan = loan
            }.store(in: &anySubscriptions)
    }
    
    func setupView() {
        self.filterButton.accessibilityIdentifier = AccessibilityIDLoansHome.filters.rawValue
        self.filterImageView.image = Assets.image(named: "icnFilter")?.withRenderingMode(.alwaysTemplate)
        self.filterImageView.tintColor = .darkTorquoise
        self.movementLabel.text = localized("productHome_label_moves").uppercased()
        self.movementLabel.accessibilityIdentifier = AccessibilityIDLoansHome.movementTitle.rawValue
        self.filterLabel.textColor = .darkTorquoise
        self.filterLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.filterLabel.text = localized("generic_button_filters")
        self.pdfLabel.textColor = .darkTorquoise
        self.pdfLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.pdfLabel.text = localized("generic_button_downloadPDF")
        self.pdfLabel.isHidden = true
        self.filterLabel.isHidden = true
        self.filterImageView.isHidden = true
        self.filterButton.isHidden = true
        self.setButtonsGestureEvent()
    }

    func setButtonsGestureEvent() {
        let filterGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFilterMovements))
        self.filterButton.addGestureRecognizer(filterGesture)
    }
    
    @objc func didTapOnFilterMovements(_ sender: Any) {
        guard let loan = self.loan else { return }
        didSelectActionSubject.send(loan)
    }
}
