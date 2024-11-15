//
//  EmptyDataSetView.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

public class EmptyDataSetView: UIView {

    internal lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        return contentView
    }()

    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.accessibilityIdentifier = "empty set background image"
        return imageView
    }()

    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.clear

        titleLabel.font = UIFont.systemFont(ofSize: 27.0)
        titleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "empty set title"
        return titleLabel
    }()

    internal lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.backgroundColor = UIColor.clear

        detailLabel.font = UIFont.systemFont(ofSize: 17.0)
        detailLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        detailLabel.textAlignment = .center
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.numberOfLines = 0
        detailLabel.accessibilityIdentifier = "empty set detail label"
        return detailLabel
    }()

    internal lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.accessibilityIdentifier = "empty set button"
        return button
    }()

    private var canShowImage: Bool {
        if let image = imageView.image, image.size.width > 0, image.size.height > 0 {
            return true
        }
        return false
    }

    private var canShowTitle: Bool {
        if let attributedText = titleLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }

    private var canShowDetail: Bool {
        if let attributedText = detailLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }

    private var canShowButton: Bool {
        if let attributedTitle = button.currentAttributedTitle, attributedTitle.length > 0 {
            return true
        } else if let title = button.currentTitle, !title.isEmpty {
            return true
        } else if let image = button.currentImage, image.size.width > 0, image.size.height > 0 {
            return true
        } else if let image = button.currentBackgroundImage, image.size.width > 0, image.size.height > 0 {
            return true
        }
        return false
    }


    internal var customView: UIView? {
        willSet {
            if let customView = customView {
                customView.removeFromSuperview()
            }
            if newValue != nil {
                imageView.removeFromSuperview()
                titleLabel.removeFromSuperview()
                detailLabel.removeFromSuperview()
                button.removeFromSuperview()
            }
        }
        didSet {
            if let customView = customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(customView)
            }
        }
    }

    internal var fadeInOnDisplay = false
    internal var verticalOffset: CGFloat = 0
    internal var verticalSpace: CGFloat?
    internal var titleVerticalTopSpace: CGFloat?
    internal var detailVerticalTopSpace: CGFloat?
    internal var buttonVerticalTopSpace: CGFloat?

    internal var didTapContentViewHandle: (() -> Void)?
    internal var didTapDataButtonHandle: (() -> Void)?
    internal var willAppearHandle: (() -> Void)?
    internal var didAppearHandle: (() -> Void)?
    internal var willDisappearHandle: (() -> Void)?
    internal var didDisappearHandle: (() -> Void)?

    fileprivate var _layoutConstraints = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(button)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(button)
    }

    override public func didMoveToSuperview() {
        if let superviewBounds = superview?.bounds {
            frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
        }
        if fadeInOnDisplay {
            UIView.animate(withDuration: 0.25) {
                self.contentView.alpha = 1
            }
        } else {
            contentView.alpha = 1
        }
    }

    // MARK: - Action Methods

    internal func removeAllConstraints() {
        NSLayoutConstraint.deactivate(_layoutConstraints)
        _layoutConstraints = []
    }

    internal func prepareForReuse() {

        titleLabel.text = nil
        detailLabel.text = nil
        imageView.image = nil
        button.setImage(nil, for: .normal)
        button.setImage(nil, for: .highlighted)
        button.setAttributedTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .highlighted)
        button.setBackgroundImage(nil, for: .normal)
        button.setBackgroundImage(nil, for: .highlighted)
        customView = nil

        removeAllConstraints()
    }


    // MARK: - Auto-Layout Configuration
    internal func setupConstraints() {

        defer {
            if !_layoutConstraints.isEmpty {
                NSLayoutConstraint.activate(_layoutConstraints)
            }
        }

        if !_layoutConstraints.isEmpty {
            removeAllConstraints()
        }

        let contentCenterYConstraint = contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor)

        // First, configure the content view constaints
        // The content view must alway be centered to its superview
        _layoutConstraints = [
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            contentCenterYConstraint
        ]

        // When a custom offset is available, we adjust the vertical constraints' constants
        if verticalOffset != 0 {
            contentCenterYConstraint.constant = verticalOffset
        }

        if let customView = customView {

            let centerXConstraint = customView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            let centerYConstraint = customView.centerYAnchor.constraint(equalTo: self.centerYAnchor)

            var customViewSize = customView.frame.size

            if customViewSize.width <= 0 || customViewSize.height <= 0 {
                customViewSize = customView.intrinsicContentSize
            }

            let customViewHeight = customViewSize.height
            let customViewWidth = customViewSize.width

            let heightConstarint: NSLayoutConstraint
            let widthConstarint: NSLayoutConstraint

            if customViewHeight <= 0 {
                heightConstarint = customView.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor)
            } else {
                heightConstarint = customView.heightAnchor.constraint(equalToConstant: customViewHeight)
            }

            if customViewWidth <= 0 {
                widthConstarint = customView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor)
            } else {
                widthConstarint = customView.widthAnchor.constraint(equalToConstant: customViewWidth)
            }

            // When a custom offset is available, we adjust the vertical constraints' constants
            if (verticalOffset != 0) {
                centerYConstraint.constant = verticalOffset
            }

            _layoutConstraints += [centerXConstraint, centerYConstraint]
            _layoutConstraints += [heightConstarint, widthConstarint]

            return
        }

        // layout build-in subviews

        let width = frame.size.width > 0 ? frame.size.width : UIScreen.main.bounds.width
        let padding = CGFloat(roundf(Float(width/16.0)))
        let verticalSpace = verticalSpace ?? 11.0
        let titleVerticalTopSpace = titleVerticalTopSpace ?? verticalSpace
        let detailVerticalTopSpace = detailVerticalTopSpace ?? verticalSpace
        let buttonVerticalTopSpace = buttonVerticalTopSpace ?? verticalSpace

        var prevView: UIView? = nil

        if canShowImage {

            imageView.isHidden = false

            _layoutConstraints += [
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ]

            prevView = imageView

        } else {
            imageView.isHidden = true
        }

        // Assign the title label's horizontal constraints
        if canShowTitle {

            titleLabel.isHidden = false
            titleLabel.sizeToFit()

            _layoutConstraints += [
                titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1, constant: -2.0 * padding),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ]

            if let prevView {
                _layoutConstraints += [
                    titleLabel.topAnchor.constraint(equalTo: prevView.bottomAnchor, constant: titleVerticalTopSpace)
                ]
            } else {
                _layoutConstraints += [
                    titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
                ]
            }

            prevView = titleLabel

        } else {
            titleLabel.isHidden = true
        }

        // Assign the detail label's horizontal constraints
        if canShowDetail {

            detailLabel.isHidden = false
            detailLabel.sizeToFit()

            _layoutConstraints += [
                detailLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1, constant: -2.0 * padding),
                detailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ]

            if let prevView {
                _layoutConstraints += [
                    detailLabel.topAnchor.constraint(equalTo: prevView.bottomAnchor, constant: detailVerticalTopSpace)
                ]
            } else {
                _layoutConstraints += [
                    detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
                ]
            }

            prevView = detailLabel

        } else {
            detailLabel.isHidden = true
        }

        // Assign the button's horizontal constraints
        if canShowButton {

            button.isHidden = false
            button.sizeToFit()

            var buttonSize = button.frame.size

            if buttonSize.width <= 0 || buttonSize.height <= 0 {
                buttonSize = button.intrinsicContentSize
            }

            if buttonSize.width > 0 && buttonSize.height > 0 {
                _layoutConstraints += [
                    button.widthAnchor.constraint(equalToConstant: buttonSize.width),
                    button.heightAnchor.constraint(equalToConstant: buttonSize.height)
                ]
            } else {
                _layoutConstraints += [
                    button.widthAnchor.constraint(
                        equalTo: contentView.widthAnchor,
                        multiplier: 1,
                        constant: -2.0 * padding
                    ),
                    button.heightAnchor.constraint(equalToConstant: 40),
                ]
            }

            _layoutConstraints += [
                button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ]

            if let prevView {
                _layoutConstraints += [
                    button.topAnchor.constraint(equalTo: prevView.bottomAnchor, constant: buttonVerticalTopSpace)
                ]
            } else {
                _layoutConstraints += [
                    button.topAnchor.constraint(equalTo: contentView.topAnchor)
                ]
            }

            prevView = button
            
        } else {
            button.isHidden = true
        }

        if let prevView {
            _layoutConstraints += [
                prevView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        } else {
            _layoutConstraints += [
                contentView.heightAnchor.constraint(equalToConstant: 0)
            ]
        }
    }

}

