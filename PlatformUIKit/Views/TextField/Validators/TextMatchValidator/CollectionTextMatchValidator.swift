//
//  CollectionTextMatchValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// Generalized version of text matcher, resolves a stream from multiple text sources into a boolean
/// that is `true` if and only if all the values are equal
public final class CollectionTextMatchValidator: TextMatchValidatorAPI {
        
    // MARK: - Exposed Properties
    
    /// An observable that streams the validation state for the streams
    public var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }
    
    // MARK: - Injected Properties
    
    private let collection: [TextSource]
    
    // MARK: - Accessors
    
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .valid)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(_ collection: TextSource..., options: Options = [], invalidReason: String) {
        self.collection = collection
        Observable
            .combineLatest(collection.map { $0.valueRelay })
            .map { array -> Bool in
                if array.areAllElementsEqual {
                    return true
                // If there is an empty string in the array and it should be validated
                } else if array.containsEmpty {
                    return !options.contains(.validateEmpty)
                } else {
                    return false
                }
            }
            .map { $0 ? .valid : .invalid(reason: invalidReason) }
            .bind(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Validation Options

extension CollectionTextMatchValidator {
    
    /// Options according to which the text streams are validated
    public struct Options: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }
        
        /// Validate all even though one of the text sources is empty
        public static let validateEmpty = Options(rawValue: 1 << 0)
    }
}
