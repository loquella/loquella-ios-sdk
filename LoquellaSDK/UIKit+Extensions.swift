//
//  UIKit+Extensions.swift
//  LoquellaSDK
//
//  Created by Rasmus Styrk on 20/02/2018.
//  Copyright © 2018 House of Code ApS. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    /**
     Translate a single string
     
     */
    public func translate() -> String {
        return LoquellaSDK.sharedInstance.translate(key: self, comment: nil)
    }
    
    /**
     Translates a single string and saves a comment for the translator
     
     */
    public func translate(comment: String) -> String {
        return LoquellaSDK.sharedInstance.translate(key: self, comment: comment)
    }
    
    /**
     Translate two strings but only showing either one or the other depending on count input
     
     */
    public func translatePlural(count: Int, other: String) -> String {
        return translateEither(count == 1, either: other)
    }
    
    /**
     Translates either string depending on result of `r`
     
     */
    public func translateEither(_ r: Bool, either: String) -> String {
        if r {
            return translate()
        } else {
            return either.translate()
        }
    }
}

public extension UILabel {
    /**
     Translates a label. Requries text already set
     
     */
    public func translate() {
        if let text = self.text {
            self.text = text.translate()
        }
    }
    
    /**
     Translates a label and saves a comment for the translator. Requries text already set
     
     */
    public func translate(comment: String) {
        translate() // TODO: implement
    }
}

public extension UIButton {
    /**
     Translates a button for .normal state. Requries title already set
     
     */
    public func translate() {
        self.translate(state: .normal)
    }
    
    /**
     Translates a button for  state. Requries title already set
     
     */
    public func translate(state: UIControlState) {
        setTitle(self.title(for: state)?.translate() ?? "", for: state)
    }
    
    /**
     Translates a button and saves a comment for the translator. Requries title already set.
     
     */
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
