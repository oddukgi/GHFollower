//
//  UIHelper.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/10.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

// Singleton
// Struct 사용하면
// let helper = UIHelper() 선언해야 함 --> Waste code

enum UIHelper {
    
    // singleton
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
         let width                       = view.bounds.width
         let padding: CGFloat            = 12
         let minimumItemSpacing: CGFloat = 10
         let availableWidth              = width - (padding * 2) - (minimumItemSpacing * 2)
         // 컬럼 1의 가로정하기
         let itemWidth                   = availableWidth / 3
         let flowLayout                  = UICollectionViewFlowLayout()
         flowLayout.sectionInset         = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
         flowLayout.itemSize             = CGSize(width: itemWidth, height: itemWidth + 40)
         
         return flowLayout
     }
}
