//
//  Date+Ext.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/22.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import Foundation

extension Date {

    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
