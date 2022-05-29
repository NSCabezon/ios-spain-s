import Foundation

public protocol PublicMenuExternalDependenciesResolver: PublicMenuSceneExternalDependenciesResolver,
                                                        ATMExternalDependenciesResolver,
                                                        HomeTipsExternalDependenciesResolver,
                                                        OurProductsExternalDependenciesResolver,
                                                        StockholdersExternalDependenciesResolver,
                                                        TipListExternalDependenciesResolver {}
