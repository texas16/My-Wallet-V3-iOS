//
//  AnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import ERC20Kit
import EthereumKit

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {
    
    // MARK: - Services
    
    /// Dispatch queue
    private let dispatchQueueName = "announcements-interaction-queue"
    
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let infoService: GeneralInformationService
    private let exchangeService: ExchangeService
    private let paxTransactionService: AnyERC20HistoricalTransactionService<PaxToken>
    private let repository: AuthenticatorRepositoryAPI
    private let simpleBuyServiceProvider: SimpleBuyServiceProviderAPI
    
    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }
        
        let nabuUser = dataRepository.nabuUser
            .take(1)
            .asSingle()
        let tiers = dataRepository.tiers
            .take(1)
            .asSingle()
        let countries = infoService.countries
        let hasPaxTransactions = paxTransactionService.hasTransactions
        let hasTrades = exchangeService.hasExecutedTrades()
        let simpleBuyOrderDetails = simpleBuyServiceProvider
            .pendingOrderDetails
            .pendingActionOrderDetails

        let isSimpleBuyAvailable = simpleBuyServiceProvider.availability.valueSingle

        return Single
            .zip(nabuUser,
                 tiers,
                 hasTrades,
                 hasPaxTransactions,
                 countries,
                 repository.authenticatorType,
                 Single.zip(isSimpleBuyAvailable, simpleBuyOrderDetails))
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: dispatchQueueName))
            .observeOn(MainScheduler.instance)
            .map { (arg) -> AnnouncementPreliminaryData in
                let (user, tiers, hasTrades, hasPaxTransactions, countries, authenticatorType, (isSimpleBuyAvailable, pendingOrderDetails)) = arg
                return AnnouncementPreliminaryData(
                    user: user,
                    tiers: tiers,
                    hasTrades: hasTrades,
                    hasPaxTransactions: hasPaxTransactions,
                    countries: countries,
                    authenticatorType: authenticatorType,
                    pendingOrderDetails: pendingOrderDetails,
                    isSimpleBuyAvailable: isSimpleBuyAvailable
                )
            }
    }
    
    // MARK: - Setup
    
    init(repository: AuthenticatorRepositoryAPI = WalletManager.shared.repository,
         wallet: WalletProtocol = WalletManager.shared.wallet,
         ethereumWallet: EthereumWalletBridgeAPI = WalletManager.shared.wallet.ethereum,
         dataRepository: BlockchainDataRepository = .shared,
         exchangeService: ExchangeService = .shared,
         infoService: GeneralInformationService = UserInformationServiceProvider.default.general,
         paxAccountRepository: ERC20AssetAccountRepository<PaxToken> = PAXServiceProvider.shared.services.assetAccountRepository,
         simpleBuyServiceProvider: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default) {
        self.repository = repository
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.infoService = infoService
        self.exchangeService = exchangeService
        self.simpleBuyServiceProvider = simpleBuyServiceProvider
        // TODO: Move this into a difference service that aggregates this logic
        // for all assets and utilize it in other flows (dashboard, send, swap, activity).
        self.paxTransactionService = AnyERC20HistoricalTransactionService<PaxToken>(bridge: ethereumWallet)
    }
}
