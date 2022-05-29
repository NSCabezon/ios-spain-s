public protocol PGUserPrefRepresentable {
    var boxesRepresentable: [UserPrefBoxType: PGBoxRepresentable] { get }
}
