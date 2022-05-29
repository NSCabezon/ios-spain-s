//
//  FundsExternalDependenciesResolver.swift
//  Funds
//

public protocol FundsExternalDependenciesResolver:
    FundsHomeExternalDependenciesResolver,
    FundTransactionsExternalDependenciesResolver,
    FundsTransactionsFilterExternalDependenciesResolver,
    FundsCommonExternalDependenciesResolver {}
