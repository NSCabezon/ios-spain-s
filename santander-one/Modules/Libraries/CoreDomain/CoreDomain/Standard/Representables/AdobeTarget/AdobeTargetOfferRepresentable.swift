import Foundation

 public protocol AdobeTargetOfferRepresentable {
    var id: String? { get }
    var groupId: String? { get }
    var locationId: String? { get }
    var renderingType: String? { get }
    var rendering: AdobeTargetRenderingRepresentable? { get }
}

public protocol AdobeTargetRenderingRepresentable {
    var url: String? { get }
    var width: Int? { get }
    var height: Int? { get }
    var action: AdobeTargetActionRepresentable? { get }
}

public protocol AdobeTargetActionRepresentable {
    var type: String? { get }
    var data: AdobeTargetActionDataRepresentable? { get }
}

public protocol AdobeTargetActionDataRepresentable {
    var topTitle: String? { get }
    var title: String? { get }
    var openURL: String? { get }
    var closeURL: String? { get }
    var pdfName: String? { get }
    var parameters: AdobeTargetActionDataParametersRepresentable? { get }
}

 public protocol AdobeTargetActionDataParametersRepresentable {
    var token: String? { get }
    var operativa: String? { get }
    var canal: String? { get }
}
