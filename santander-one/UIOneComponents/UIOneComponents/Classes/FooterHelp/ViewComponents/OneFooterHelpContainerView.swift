//
//  OneFooterHelpContainerView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 23/11/21.
//

import UI
import CoreFoundationLib
import CoreDomain

protocol OneFooterHelpContainerViewDelegate: AnyObject {
    func didSelectVirtualAssistant()
    func didSelectTip(_ offer: OfferRepresentable?)
}

class OneFooterHelpContainerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    weak var delegate: OneFooterHelpContainerViewDelegate?
    private var faqsList: [OneFaqView] = []
    private var tipsList: [OfferTipViewModel] = []
    private var tipsCollectionView: UICollectionView?
    
    private lazy var verticalStackView: Stackview = {
        let stackView = Stackview()
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var virtualAssistantView: OneFaqVirtualAssistantView = {
        let view = OneFaqVirtualAssistantView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.otherConsultSelected)))
        return view
    }()
    
    func addViews(_ viewModel: OneFooterHelpViewModel) {
        viewModel.faqs?.forEach { self.addFaqsView($0) }
        if !(viewModel.tips?.isEmpty ?? true) {
            self.tipsList = viewModel.tips ?? []
            self.setTipsCollectionView()
        }
        if viewModel.showVirtualAssistant {
            self.addVirtualAssistans()
        }
        layoutSubviews()
    }
}

private extension OneFooterHelpContainerView {
    func setup () {
        self.setOneCornerRadius(type: .oneShRadius8)
        self.backgroundColor = .oneWhite
        self.addStackView()
    }
    
    func addStackView() {
        self.addSubview(verticalStackView)
        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            self.verticalStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            self.verticalStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
        ])
    }
    
    func addFaqsView(_ viewModel: FaqsViewModel) {
        let view = OneFaqView(frame: .zero)
        self.verticalStackView.addArrangedSubview(view)
        self.verticalStackView.layoutSubviews()
        view.delegate = self
        view.setView(viewModel)
        self.faqsList.append(view)
    }
    
    func setTipsCollectionView() {
        let layout = self.setLayout()
        let collectionView: UICollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        let tipNib = UINib(nibName: OneFooterTipCell.identifier, bundle: Bundle.module)
        collectionView.register(tipNib, forCellWithReuseIdentifier: OneFooterTipCell.identifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(layout, animated: false)
        self.verticalStackView.addArrangedSubview(collectionView)
        self.addSeparatorView()
    }
    
    func setLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 163, height: 117)
        layout.minimumLineSpacing = 12
        return layout
    }
    
    func addSeparatorView() {
        let separatorView = UIView()
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.backgroundColor = .oneMediumSkyGray
        self.verticalStackView.addArrangedSubview(separatorView)
    }
    
    func addVirtualAssistans() {
        self.verticalStackView.addArrangedSubview(self.virtualAssistantView)
    }
    
    @objc func otherConsultSelected() {
        self.delegate?.didSelectVirtualAssistant()
    }
}

extension OneFooterHelpContainerView: OneFaqViewDelegate {
    func didTapOnFaq(_ view: OneFaqView) {
        self.faqsList.forEach {
            if $0 != view {
                $0.close()
            }
        }
        view.open()
    }
}

extension OneFooterHelpContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tipsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneFooterTipCell.identifier, for: indexPath) as? OneFooterTipCell
        let data = self.tipsList[indexPath.row]
        cell?.setCell(title: data.representable.title ?? "", url: data.imageUrl)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offer = self.tipsList[indexPath.row].offer
        self.delegate?.didSelectTip(offer)
    }
    
}
