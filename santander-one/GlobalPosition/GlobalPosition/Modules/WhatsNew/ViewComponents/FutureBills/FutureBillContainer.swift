import Foundation
import CoreFoundationLib
import UI

final class FutureBillContainer: DesignableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: FutureBillCollectionView!
    @IBOutlet weak var topLineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.appearance()
    }
    
    override func commonInit() {
        super.commonInit()
        self.appearance()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appearance()
    }
    
    func setDelegate(_ delegate: FutureBillCollectionDatasourceDelegate) {
        self.collectionView.setDelegate(delegate: delegate)
    }
    
    func setFutureBillState(_ state: ViewState<[FutureBillViewModel]>) {
        self.collectionView.didStateChanged(state)
    }
    
    func disableTimeLine() {
        self.collectionView.disableTimeLine()
    }
}

private extension FutureBillContainer {
    func appearance() {
        self.backgroundColor = .blueAnthracita
        self.collectionView.backgroundColor = .blueAnthracita
        self.topLineView.backgroundColor = .mediumSkyGray
        self.titleLabel.textColor = .white
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.titleLabel.configureText(withKey: "nextBill_title_related")
    }
}
