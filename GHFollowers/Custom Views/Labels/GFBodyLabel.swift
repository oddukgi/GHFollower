//
//  GFBodyLabel.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/03.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

class GFBodyLabel: UILabel {
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
    }
    
    // MARK: - Accessibility : change font size when device's content size change
    private func configure() {
        textColor                                 = .secondaryLabel
        font                                      = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth                 = true
        adjustsFontForContentSizeCategory         = true
        minimumScaleFactor                        = 0.75
        lineBreakMode                             = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }

}


/*:
 `adjustsFontForContentSizeCategory`
 
 A Boolean that indicates whether the object automatically updates
 its font when the device's content size category changes.
 */
