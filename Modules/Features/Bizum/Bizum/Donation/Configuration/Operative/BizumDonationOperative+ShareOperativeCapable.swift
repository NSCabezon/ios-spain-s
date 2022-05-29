import UI
import CoreFoundationLib
import Operative

extension BizumDonationOperative: ShareOperativeCapable {
    // MARK: - ShareBizumView
    /// The modalPresentationStyle is overCurrentContext because avoid screen rotation
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container,
              let contact =  operativeData.organization else { return }
        let operativeData: BizumDonationOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        let contactEntity = BizumContactEntity(
            identifier: contact.identifier,
            name: contact.name,
            phone: contact.identifier
        )
        Scenario(useCase: useCase)
            .execute(on: self.dependencies.resolve())
            .onSuccess { response in
                let shareView = ShareBizumView()
                let viewModel = ShareBizumSummaryViewModel(
                    bizumOperativeType: operativeData.bizumOperativeType,
                    bizumAmount: operativeData.bizumSendMoney?.amount,
                    bizumConcept: operativeData.bizumSendMoney?.concept,
                    simpleMultipleType: .simple,
                    bizumContacts: [contactEntity],
                    sentDate: operativeData.operationDate,
                    dependenciesResolver: self.dependencies)
                viewModel.setUserName(response.globalPosition.fullName)
                shareView.modalPresentationStyle = .overCurrentContext
                shareView.loadViewIfNeeded()
                shareView.setInfoFromSummary(viewModel)
                completion(.success((shareView, shareView.containerView)))
            }.onError { _ in
                completion(.failure(.generalError))
            }
    }
}
