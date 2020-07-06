//
//  UITableView+Ext.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/02.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async { self.reloadData() }
    }
        
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
}
