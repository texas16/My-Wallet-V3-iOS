//
//  WalletIntroAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

/// Wallet Intro announcement is a periodic announcement that can also be entirely removed
final class WalletIntroAnnouncement: PeriodicAnnouncement & RemovableAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let ctaButton = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Welcome.ctaButton
        )
        ctaButton.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            } 
            .disposed(by: disposeBag)
        
        let skipButton = ButtonViewModel.secondary(
            with: LocalizationConstants.AnnouncementCards.Welcome.skipButton
        )
        skipButton.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markDismissed()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "logo"),
            title: LocalizationConstants.AnnouncementCards.Welcome.title,
            description: LocalizationConstants.AnnouncementCards.Welcome.description,
            buttons: [ctaButton, skipButton],
            recorder: errorRecorder,
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.WalletIntro.walletIntroOffered)
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }
    
    var shouldShow: Bool {
        return !isDismissed
    }
    
    let type = AnnouncementType.walletIntro
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    
    let action: CardAnnouncementAction
    
    let appearanceRules: PeriodicAnnouncementAppearanceRules
    
    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(cacheSuite: CacheSuite = UserDefaults.standard,
         reappearanceTimeInterval: TimeInterval,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction,
         dismiss: @escaping CardAnnouncementAction) {
        self.errorRecorder = errorRecorder
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        appearanceRules = PeriodicAnnouncementAppearanceRules(
            recessDurationBetweenDismissals: reappearanceTimeInterval,
            maxDismissalCount: 3
        )
        self.action = action
        self.dismiss = dismiss
        self.analyticsRecorder = analyticsRecorder
    }
}
