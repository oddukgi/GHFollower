//
//  GFContributionsVC.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

class GFContributionsVC: UIViewController {
    
    static let headerElementKind = "header-element-kind"

    /// - Tag: OrthogonalBehavior

    var contributions = [Contribution]()
    var contrubution2DArray = [[Contribution]]()
    var months        = [String]()
    var monthTitle    = ""
    
    var dataSource: UICollectionViewDiffableDataSource<Int, Contribution>! = nil
    var collectionView: UICollectionView! = nil

    
    
    init( contributions: [Contribution], months: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.contributions = contributions
        self.months        = months
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // convert2DArray()
      //  insertTitle()
        trimmingTitle()
        configureHierarchy()
        configureDataSource()
    }
    
   
    
    func convert2DArray() {
        
        let totCol = contributions.count / 7
        var i = 0
        var col = 0


        for row in 0..<contributions.count {
            if row % 7 == 0 && col < totCol {
                contrubution2DArray.append( [] )
                i = row
                for i in i..<(i + 7) {
                    
            
                    contrubution2DArray[col].append(contributions[i])
                }
                
                col += 1
            }
            
        }
    }
    
    func trimmingTitle() {
        
        monthTitle = months.joined(separator: "\t\t\t\t")
    }
    
    func insertTitle() {
        
        var index = 1
        var date = ""
        for col in 0..<contrubution2DArray.count {
            
            for row in 0..<contrubution2DArray[col].count {
                
                if contrubution2DArray[col][row].contributionDate.filterDate() && index < months.count {
                    
                    print("Col: \(col), Row: \(row)")
                    print(contrubution2DArray[col][row].contributionDate)
                    let contribution = Contribution(title: months[index],contributionDate: "",contributionColor:"")
                    
                    if row < 7 && (col < contrubution2DArray.count - 1) {
                    
                        let tmp = col+1
                        date = contrubution2DArray[tmp][0].contributionDate
                    }
                    else if row == 0 {
                        date = contrubution2DArray[col][0].contributionDate
                    }
                    
                    print(date)
                    if let i = self.contributions.firstIndex(where: { $0.contributionDate.contains(date) }) {
                        print("Array Index: \(i)")
                        contributions.insert(contribution, at: i)
                    }

                    
                    index += 1
                }
            }
            
        }
    }
}

extension GFContributionsVC {

    func createLayout() -> UICollectionViewLayout {

        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            /// title
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let groupHeight = NSCollectionLayoutDimension.absolute(50)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: groupHeight)
            
            let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(0.3)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 2.0, bottom: 5.0, trailing: 2.0)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)),
                                                                 subitem: trailingItem,
                                                                 count: 7)

            let containerGroupFractionalWidth =  CGFloat(0.8)
            var group: NSCollectionLayoutGroup!
            
            if sectionIndex == 0 {
                group = NSCollectionLayoutGroup.horizontal(layoutSize:  groupSize, subitem: item, count: 1)
            } else {
            
            group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                  heightDimension: .fractionalHeight(0.5)),
                subitems: [trailingGroup])
                
            }
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section

        }, configuration: config)
        return layout
    }
}

extension GFContributionsVC {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MonthTitleCell.self, forCellWithReuseIdentifier: MonthTitleCell.reuseIdentifier )
        collectionView.register(CommitCell.self, forCellWithReuseIdentifier: CommitCell.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <Int, Contribution>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath,
                data: Contribution) -> UICollectionViewCell? in

            // Get a cell of the desired kind.

                
            let section = indexPath.section
                
            if section == 0 {
                
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MonthTitleCell.reuseIdentifier, for: indexPath) as? MonthTitleCell
                    else { fatalError("Cannot create new cell") }
                cell.lbMonth.text = self.monthTitle
                
                
                return cell
            }
            else {
                
                
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommitCell.reuseIdentifier, for: indexPath) as? CommitCell
                    else { fatalError("Cannot create new cell") }
                
            // Populate the cell with our item description.
                cell.contentView.backgroundColor = UIColor(hexString: data.contributionColor)
                cell.contentView.layer.borderColor = UIColor.black.cgColor
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.cornerRadius = 8
                
                return cell
            }
            // Return the cell.
    
        }
        
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contribution>()
   
        let item = Contribution(title:"",contributionDate: "",contributionColor:"")
    
        let sections = Array(0..<2)
        
        for section in sections {
            snapshot.appendSections([section])
            section == 0 ? snapshot.appendItems([item]): snapshot.appendItems(contributions)
        }
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

extension GFContributionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
