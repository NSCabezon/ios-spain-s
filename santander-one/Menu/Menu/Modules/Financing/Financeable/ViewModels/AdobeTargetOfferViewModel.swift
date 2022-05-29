import Foundation
import CoreFoundationLib

public struct AdobeTargetOfferViewModel {
    let viewModel: FinanceableInfoViewModel.AdobeTarget
    
    init(_ viewModel: FinanceableInfoViewModel.AdobeTarget) {
        self.viewModel = viewModel
    }
    
    public var imageURL: String? {
        return self.viewModel.data.rendering?.url
    }

    public var openURL: String? {
        return self.viewModel.data.rendering?.action?.data?.openURL
    }

    public var closeURL: String? {
        return self.viewModel.data.rendering?.action?.data?.closeURL
    }

    public var topTitle: String? {
        return self.viewModel.data.rendering?.action?.data?.topTitle
    }

    public var title: String? {
        return self.viewModel.data.rendering?.action?.data?.title
    }

    public var pdfName: String? {
        return self.viewModel.data.rendering?.action?.data?.pdfName
    }

    public var token: String? {
        return self.viewModel.data.rendering?.action?.data?.parameters?.token
    }

    public var operative: String? {
        return self.viewModel.data.rendering?.action?.data?.parameters?.operativa
    }

    public var channel: String? {
        self.viewModel.data.rendering?.action?.data?.parameters?.canal
    }
}
