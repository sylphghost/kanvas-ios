//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for trimming
protocol TrimViewDelegate: class {
    func didStartMovingTrimArea()
    func didEndMovingTrimArea()
    func didMoveTrimArea(from startingPercentage: CGFloat, to finalPercentage: CGFloat)
}

/// Constants for Trim view
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let height: CGFloat = 71
    static let cornerRadius: CGFloat = 8
    static let backgroundColor: UIColor = .black
}

private enum MovingSide {
    case left
    case right
}

/// A UIView for the trim tool
final class TrimView: UIView {
    
    static let height: CGFloat = Constants.height
    
    weak var delegate: TrimViewDelegate?
    private let trimArea: TrimArea
    private var currentlyMovingSide: MovingSide? = nil
    
    var leadingConstraint: NSLayoutConstraint
    var trailingConstraint: NSLayoutConstraint
    
    // MARK: - Initializers
    
    init() {
        trimArea = TrimArea()
        leadingConstraint = NSLayoutConstraint()
        trailingConstraint = NSLayoutConstraint()
        super.init(frame: .zero)
        
        backgroundColor = Constants.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        setupViews()
        setupGestureRecognizers()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setupTrimArea()
    }
    
    private func setupTrimArea() {
        trimArea.accessibilityIdentifier = "GIF Maker Trim Area"
        trimArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trimArea)
        
        leadingConstraint = trimArea.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
        trailingConstraint = trimArea.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        
        NSLayoutConstraint.activate([
            trimArea.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            trimArea.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            leadingConstraint,
            trailingConstraint
        ])
    }
    
    // MARK: - Gesture recognizers
    
    private func setupGestureRecognizers() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(trimAreaTouched(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func trimAreaTouched(recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: self).x
        
        switch recognizer.state {
        case .began:
            delegate?.didStartMovingTrimArea()
            currentlyMovingSide = closestSide(from: location)
            trimAreaMoved(location: location)
        case .changed:
            trimAreaMoved(location: location)
        case .ended:
            trimAreaMoved(location: location)
            currentlyMovingSide = nil
            delegate?.didEndMovingTrimArea()
        default:
            break
        }
    }
    
    private func closestSide(from location: CGFloat) -> MovingSide {
        let leftSide = trimArea.frame.origin.x
        let rightSide = trimArea.frame.origin.x + trimArea.frame.width
        
        let distanceToLeftSide = abs(location - leftSide)
        let distanceToRightSide = abs(rightSide - location)
        
        return distanceToLeftSide < distanceToRightSide ? .left : .right
    }
    
    private func trimAreaMoved(location: CGFloat) {
        let closestSideToTouch = closestSide(from: location)
        
        if closestSideToTouch == .left && currentlyMovingSide != .right {
            
            if location >= TrimArea.selectorWidth {
                leadingConstraint.constant = location - TrimArea.selectorWidth
            }
            else {
                leadingConstraint.constant = 0
            }
        }
        else if closestSideToTouch == .right && currentlyMovingSide != .left {
            
            if location <= bounds.width - TrimArea.selectorWidth {
                trailingConstraint.constant = location - bounds.width + TrimArea.selectorWidth
            }
            else {
                trailingConstraint.constant = 0
            }
        }
        
        let start = (trimArea.frame.origin.x) * 100 / (bounds.width - TrimArea.selectorWidth * 2)
        let end = 100 - ((bounds.width - trimArea.frame.origin.x - trimArea.frame.size.width) * 100 / (bounds.width - TrimArea.selectorWidth * 2))
        delegate?.didMoveTrimArea(from: start, to: end)
    }

    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
}
