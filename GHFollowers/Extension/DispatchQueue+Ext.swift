//
//  DispatchQueue+Ext.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import Foundation

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
