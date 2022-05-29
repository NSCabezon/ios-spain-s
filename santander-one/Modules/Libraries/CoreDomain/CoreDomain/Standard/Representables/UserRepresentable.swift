public protocol UserRepresentable {
    var userDataRepresentable: UserDataRepresentable? { get }
    var userId: String? { get }
    var userCodeType: String? { get }
    var userKey: String? { get }
}

extension UserRepresentable {
    var userId: String? {
        guard let userDataRepresentable = userDataRepresentable,
              let userType = userDataRepresentable.clientPersonType,
              let userCode = userDataRepresentable.clientPersonCode else {
                  return nil
              }
        return userType + userCode
    }
    var userCodeType: String? {
        guard let userDataRepresentable = userDataRepresentable,
              let userType = userDataRepresentable.clientPersonType,
              let userCode = userDataRepresentable.clientPersonCode else {
                  return nil
              }
        return userCode + userType
    }
    var userKey: String? {
        guard let userDataRepresentable = userDataRepresentable,
              let userType = userDataRepresentable.clientPersonType,
              let userCode = userDataRepresentable.clientPersonCode else {
                  return nil
              }
        return userType + "," + userCode
    }
}
