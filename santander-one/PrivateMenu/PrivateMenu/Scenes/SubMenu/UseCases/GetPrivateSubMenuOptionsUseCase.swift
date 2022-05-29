import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetMyProductSubMenuUseCase: GetPrivateSubMenuOptionsUseCase { }
public protocol GetOtherServicesSubMenuUseCase: GetPrivateSubMenuOptionsUseCase { }
public protocol GetSofiaInvestmentSubMenuUseCase: GetPrivateSubMenuOptionsUseCase { }
public protocol GetWorld123SubMenuUseCase: GetPrivateSubMenuOptionsUseCase { }

public protocol GetPrivateSubMenuOptionsUseCase {
    func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never>
}

public struct DefaultPrivateSubMenuOptionsUseCase: GetMyProductSubMenuUseCase,
                                                   GetOtherServicesSubMenuUseCase,
                                                   GetSofiaInvestmentSubMenuUseCase,
                                                   GetWorld123SubMenuUseCase {
    public func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
}
