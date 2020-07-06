//
//  MonthTitleCell.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

class MonthTitleCell: UICollectionViewCell {
  
    let lbMonth = UILabel()
    static let reuseIdentifier = "MonthTitleCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
}

extension MonthTitleCell {
    func configure() {
        
        lbMonth.translatesAutoresizingMaskIntoConstraints = false
        lbMonth.adjustsFontForContentSizeCategory = true
        contentView.addSubview(lbMonth)
        lbMonth.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        let inset = CGFloat(3)
        NSLayoutConstraint.activate([
            lbMonth.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            lbMonth.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            lbMonth.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            lbMonth.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
        ])
    }
    
    func set(title: String) {
        lbMonth.text = title
    }
}
