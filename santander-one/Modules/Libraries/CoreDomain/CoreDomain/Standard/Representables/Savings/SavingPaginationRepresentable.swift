import Foundation

public protocol SavingPaginationRepresentable {
    var next: String? { get }
    var current: String? { get }
}
