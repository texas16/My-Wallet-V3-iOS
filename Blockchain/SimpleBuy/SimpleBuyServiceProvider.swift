//
//  SimpleBuyServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

final class SimpleBuyServiceProvider: SimpleBuyServiceProviderAPI {
    
    static let `default`: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider()
    
    // MARK: - Properties

    let supportedPairsInteractor: SimpleBuySupportedPairsInteractorServiceAPI
    let supportedPairs: SimpleBuySupportedPairsServiceAPI
    let suggestedAmounts: SimpleBuySuggestedAmountsServiceAPI
    let ordersDetails: SimpleBuyOrdersServiceAPI
    let pendingOrderDetails: SimpleBuyPendingOrderDetailsServiceAPI
    let availability: SimpleBuyAvailabilityServiceAPI
    let flowAvailability: SimpleBuyFlowAvailabilityServiceAPI
    let eligibility: SimpleBuyEligibilityServiceAPI
    let orderCancellation: SimpleBuyOrderCancellationServiceAPI
    let orderConfirmation: SimpleBuyOrderConfirmationServiceAPI
    var paymentMethods: SimpleBuyPaymentMethodsServiceAPI
    let paymentMethodTypes: SimpleBuyPaymentMethodTypesService
    let cache: SimpleBuyEventCache
    
    var orderCompletion: SimpleBuyPendingOrderCompletionServiceAPI {
        SimpleBuyPendingOrderCompletionService(ordersService: ordersDetails)
    }
    
    private let orderCreation: SimpleBuyOrderCreationServiceAPI
    private let orderQuote: SimpleBuyOrderQuoteServiceAPI
    private let paymentAccount: SimpleBuyPaymentAccountServiceAPI
    
    let settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI
    let dataRepository: DataRepositoryAPI

    // MARK: - Setup
    
    init(cardServiceProvider: CardServiceProviderAPI = CardServiceProvider.default,
         wallet: ReactiveWalletAPI = ReactiveWallet(),
         authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         simpleBuyClient: SimpleBuyClientAPI = SimpleBuyClient(),
         cacheSuite: CacheSuite = UserDefaults.standard,
         settings: FiatCurrencySettingsServiceAPI & SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         dataRepository: DataRepositoryAPI = BlockchainDataRepository.shared,
         tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         featureFetcher: FeatureFetching = AppFeatureConfigurator.shared) {
        
        cache = SimpleBuyEventCache(cacheSuite: cacheSuite)
        
        supportedPairs = SimpleBuySupportedPairsService(client: simpleBuyClient)
        
        supportedPairsInteractor = SimpleBuySupportedPairsInteractorService(
            pairsService: supportedPairs,
            fiatCurrencySettingsService: settings
        )
        suggestedAmounts = SimpleBuySuggestedAmountsService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencySettingsService: settings
        )
        ordersDetails = SimpleBuyOrdersService(
            analyticsRecorder: AnalyticsEventRecorder.shared,
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService
        )
        availability = SimpleBuyAvailabilityService(
            pairsService: supportedPairsInteractor,
            featureFetcher: featureFetcher
        )
        eligibility = SimpleBuyEligibilityService(
            client: simpleBuyClient,
            reactiveWallet: wallet,
            authenticationService: authenticationService,
            fiatCurrencyService: settings,
            featureFetcher: featureFetcher
        )
        orderQuote = SimpleBuyOrderQuoteService(
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        paymentAccount = SimpleBuyPaymentAccountService(
            client: simpleBuyClient,
            dataRepository: dataRepository,
            authenticationService: authenticationService,
            fiatCurrencyService: settings
        )
        orderConfirmation = SimpleBuyOrderConfirmationService(
            analyticsRecorder: AnalyticsEventRecorder.shared,
            client: simpleBuyClient,
            authenticationService: authenticationService
        )
        orderCancellation = SimpleBuyOrderCancellationService(
            client: simpleBuyClient,
            orderDetailsService: ordersDetails,
            authenticationService: authenticationService
        )
        pendingOrderDetails = SimpleBuyPendingOrderDetailsService(
            paymentAccountService: paymentAccount,
            ordersService: ordersDetails,
            cancallationService: orderCancellation
        )
        orderCreation = SimpleBuyOrderCreationService(
            analyticsRecorder: AnalyticsEventRecorder.shared,
            client: simpleBuyClient,
            pendingOrderDetailsService: pendingOrderDetails,
            authenticationService: authenticationService
        )
        paymentMethods = SimpleBuyPaymentMethodsService(
            client: simpleBuyClient,
            tiersService: tiersService,
            reactiveWallet: wallet,
            featureFetcher: featureFetcher,
            authenticationService: authenticationService,
            fiatCurrencyService: settings
        )
        paymentMethodTypes = SimpleBuyPaymentMethodTypesService(
            paymentMethodsService: paymentMethods,
            cardListService: cardServiceProvider.cardList
        )
        flowAvailability = SimpleBuyFlowAvailabilityService()

        self.dataRepository = dataRepository
        self.settings = settings
    }
    
    public func orderCreation(for paymentMethod: SimpleBuyPaymentMethod.MethodType) -> SimpleBuyPendingOrderCreationServiceAPI {
        switch paymentMethod {
        case .bankTransfer:
            return SimpleBuyBankOrderCreationService(
                paymentAccountService: paymentAccount,
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        case .card:
            return SimpleBuyCardOrderCreationService(
                orderQuoteService: orderQuote,
                orderCreationService: orderCreation
            )
        }
    }
}
