//
//  GFContributionsVC.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/07/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit
import SwiftSoup

class GFContributionsVC: UIViewController {
    
    
    private let baseURL = "https://github.com/users/"
    static let headerElementKind = "header-element-kind"
    typealias Item = (text: String, html: String)

    /// - Tag: OrthogonalBehavior

    var username      = ""
    var contributions = [Contribution]()
    var contrubution2DArray = [[Contribution]]()
    var months        = [String]()
    var monthTitle    = ""
    // current document
    var document: Document = Document.init("")
    // item founds
    var items: [String] = []
    var dataSource: UICollectionViewDiffableDataSource<Int, Contribution>! = nil
    var collectionView: UICollectionView! = nil

    
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username      = username
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        getContributionCalendar()
      
    }
    
    func trimmingTitle() {
        
        monthTitle = months.joined(separator: "\t\t\t\t")
    }
    
    func getContributionCalendar() {
        NetworkManager.shared.getContributionDate(for: username) { [weak self] contribution in
            guard let self = self else { return }
            //데이터 받으면 업데이트
            self.contributions = contribution
            self.months = NetworkManager.shared.months
            self.configureDataSource()
            
        }
 
    }
  
    
}

extension GFContributionsVC {

     func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in


            let verticalItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.9 / 7.0)))
            
            verticalItem.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize:
                NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9 / 7.0), heightDimension: .fractionalHeight(0.9)),
                                                                                   subitem: verticalItem, count: 7)
            //  heightDimension = (verticalgroup width * 0.4) * 2
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                   heightDimension: .fractionalHeight(1.05)),subitems: [verticalGroup])
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

            return section

        }
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
       // collectionView.delegate = self
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <Int, Contribution>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath,
                data: Contribution) -> UICollectionViewCell? in

            // Get a cell of the desired kind
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
    
        
        
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contribution>()

        snapshot.appendSections([0])
        snapshot.appendItems(self.contributions)
 
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

//extension GFContributionsVC: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//    }
//}
//


