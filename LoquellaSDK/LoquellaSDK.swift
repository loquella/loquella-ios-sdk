//
//  LoquellaSDK.swift
//  LoquellaSDK
//
//  Created by Rasmus Styrk on 19/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    /**
     Translate a single string
     
     */
    public func translate() -> String {
        // TODO: Imeplement actual logic
        return "[tr]: \(self)"
    }
    
    /**
     Translates a single string and saves a comment for the translator
     
     */
    public func translate(comment: String) -> String {
        // TODO: Imeplement actual logic
        return "[tr]: \(self)"
    }
    
    /**
     Translate two strings but only showing either one or the other depending on count input
     
     */
    public func translatePlural(count: Int, other: String) -> String {
        if count == 1 {
            return translate()
        } else {
            return other.translate()
        }
    }
}

public extension UILabel {
    public func translate() {
        if let text = self.text {
            self.text = text.translate()
        }
    }
    
    public func translate(comment: String) {
        translate() // TODO: implement
    }
}

public extension UIButton {
    public func translate() {
        self.translate(state: .normal)
    }
    
    public func translate(state: UIControlState) {
        setTitle(self.title(for: state)?.translate() ?? "", for: state)
    }
    
    public func translate(comment: String) {
        self.translate(state: .normal)
    }
}

public extension UIView {
    /**
     Traverses all subviews and autotranslates anything with a label
     
     */
    public func translateAll() {
        self.subviews.forEach { (view) in
            if view.isKind(of: UILabel.self) {
                if let label = view as? UILabel {
                    label.translate()
                }
            } else if view.isKind(of: UIButton.self) {
                if let button = view as? UIButton {
                    // TODO: Support all states
                    button.translate(state: .normal)
                }
            }
        }
    }
}
