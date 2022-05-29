//
//  OneAvatarViewModel.swift
//  Models
//
//  Created by Juan Diego Vázquez Moreno on 8/9/21.
//

public final class OneAvatarViewModel {
    public let fullName: String?
    public let imageUrlString: String?
    public let image: UIImage?
    public let dependenciesResolver: DependenciesResolver

    public init(
        fullName: String?,
        imageUrlString: String? = nil,
        image: UIImage? = nil,
        dependenciesResolver: DependenciesResolver
    ) {
        self.fullName = fullName
        self.imageUrlString = imageUrlString
        self.image = image
        self.dependenciesResolver = dependenciesResolver
    }
}

public extension OneAvatarViewModel {
    
    var initials: String? {
        return self.fullName?.nameInitials
    }
}
