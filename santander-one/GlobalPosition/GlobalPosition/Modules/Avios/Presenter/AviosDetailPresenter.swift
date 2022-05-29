import CoreFoundationLib
import Foundation

protocol AviosDetailPresenterProtocol: MenuTextWrapperProtocol {
    var view: AviosDetailViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
}

final class AviosDetailPresenter {
    private let emptyLiteral = "- -"
    
    var dependenciesResolver: DependenciesResolver
    weak var view: AviosDetailViewProtocol?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension AviosDetailPresenter: AviosDetailPresenterProtocol {
    func viewDidLoad() {
        view?.startLoading { [weak self] in
            self?.loadAviosInfo()
        }
    }
    
    func didTapClose() {
        aviosDetailCoordinator.dismiss()
    }
}

private extension AviosDetailPresenter {
    var aviosDetailCoordinator: AviosDetailCoordinatorProtocol {
        return dependenciesResolver.resolve()
    }
    
    var aviosDetailUseCase: GetAviosDetailInfoUseCaseAlias {
        return dependenciesResolver.resolve()
    }
    
    func transformNumberToString(number: Int?) -> String? {
        guard let number = number else { return nil }
        let asNSNumber = NSNumber(value: number)
        return formatterForRepresentation(.withoutDecimals).string(from: asNSNumber)
    }
    
    func loadAviosInfo() {
        UseCaseWrapper(
            with: aviosDetailUseCase,
            useCaseHandler: dependenciesResolver.resolve(),
            onSuccess: { [weak self] result in
                self?.view?.stopLoading { [weak self] in
                    self?.configureInfo(
                        iberiaCode: result.detail.iberiaPlusCode,
                        lastLiquidationTotalPoints: result.detail.lastLiquidationTotalPoints,
                        totalPoints: result.detail.totalPoints
                    )
                }
            }, onError: { [weak self] _ in
                self?.view?.stopLoading { [weak self] in
                    self?.configureInfo(
                        iberiaCode: nil,
                        lastLiquidationTotalPoints: nil,
                        totalPoints: nil
                    )
                }
            }
        )
    }
    
    func configureInfo(iberiaCode: String?, lastLiquidationTotalPoints: Int?, totalPoints: Int?) {
        view?.setAviosDetail(
            model: AviosDetailComponentViewModel(
                iberiaCode: (iberiaCode != nil && !iberiaCode!.isEmpty) ? iberiaCode!: emptyLiteral,
                lastLiquidationPoints: transformNumberToString(number: lastLiquidationTotalPoints) ?? emptyLiteral,
                totalPoints: transformNumberToString(number: totalPoints) ?? emptyLiteral
            )
        )
        guard
            iberiaCode == nil,
            lastLiquidationTotalPoints == nil,
            totalPoints == nil
            else { return }
        view?.setUnavailableData()
    }
}
