//
//  ValidationTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization
import ToolKit

/// A view model that represents a password text field
public final class ValidationTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    /// Visibility of the accessoryView
    var accessoryVisibility: Driver<Visibility> {
        return visibilityRelay
            .asDriver()
            .distinctUntilChanged()
    }
        
    private let visibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(with type: TextFieldType,
                validator: TextValidating,
                formatter: TextFormatting = TextFormatterFactory.alwaysCorrect,
                textMatcher: CollectionTextMatchValidator? = nil,
                messageRecorder: MessageRecording) {
        super.init(
            with: type,
            validator: validator,
            formatter: formatter,
            textMatcher: textMatcher,
            messageRecorder: messageRecorder
        )
        
        Observable
            .combineLatest(
                validator.isValid,
                validator.valueRelay
            )
            .map { (isValid: $0.0, value: $0.1) }
            .map {
                guard !$0.value.isEmpty else { return .hidden }
                return $0.isValid ? .hidden : .visible
            }
            .bind(to: visibilityRelay)
            .disposed(by: disposeBag)
    }
}

