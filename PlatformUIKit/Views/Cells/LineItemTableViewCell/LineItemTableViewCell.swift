//
//  LineItemTableViewCell.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

/// Has two labels, one which is a `title` and the other a `description`.
public final class LineItemTableViewCell: UITableViewCell {

    private static let imageViewWidth: CGFloat = 22

    // MARK: - Exposed Properites

    public var presenter: LineItemCellPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            presenter.titleLabelContentPresenter.state
                .compactMap { $0 }
                .bind(to: rx.titleContent)
                .disposed(by: disposeBag)

            presenter.descriptionLabelContentPresenter.state
                .compactMap { $0 }
                .bind(to: rx.descriptionContent)
                .disposed(by: disposeBag)

            presenter.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)

            presenter.image
                .map { $0 == nil ? 0 : LineItemTableViewCell.imageViewWidth }
                .drive(imageWidthConstraint.rx.constant)
                .disposed(by: disposeBag)

            presenter.image
                .drive(accessoryImageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Private IBOutlets

    @IBOutlet private var accessoryImageView: UIImageView!
    @IBOutlet private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!

    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}

// MARK: - Rx

fileprivate extension Reactive where Base: LineItemTableViewCell {

    var titleContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }

    var descriptionContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.descriptionLabel.content = value.labelContent
            }
        }
    }
}
