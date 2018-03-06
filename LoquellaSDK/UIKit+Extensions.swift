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
        return translate(nil)
    }
    
    /**
     Translate a single string and replaces :1, :2, :3 etc inside string withr provided args
     
     */
    public func translate(_ args: String?...) -> String {
        return translate(comment: nil, args: args.map({ (input) -> String in
            return input ?? ""
        }))
    }
    
    /**
     Translates a single string and saves a comment for the translator
     
     */
    public func translate(comment: String?, args: [String]?) -> String {
        
        var translation = LoquellaSDK.sharedInstance.translate(key: self, comment: comment)
        
        if let providedArgs = args {
            var index = 1
            providedArgs.forEach { (arg) in
                translation = translation.replacingOccurrences(of: ":\(index)", with: arg)
                index = index + 1
            }
        }
        
        return translation
    }
}

extension String {
    /**
     Returns self or either depending on result of `r`
     
     */
    public func either(_ r: Bool, either: String) -> String {
        if r {
            return self
        } else {
            return either
        }
    }
}

@objc public extension UILabel {
    /**
     Translates a label. Requries text already set
     
     */
    public func translate() {
        if let text = self.text {
            self.text = text.translate()
        }
    }
}

@objc public extension UIButton {
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
}

@objc public extension UIView {
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
            } else if view.isKind(of: UIView.self) {
                view.translateAll()
            }
        }
    }
}
