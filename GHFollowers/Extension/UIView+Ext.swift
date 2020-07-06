//
//  UIView+Ext.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/01.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

extension UIView {
    
    func pinToEdges(of superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    //Variadic Param. 가변 파라미터
    func addSubViews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
