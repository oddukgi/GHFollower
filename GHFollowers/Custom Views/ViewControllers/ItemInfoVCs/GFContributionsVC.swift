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
  
    var username      = ""
    var contributions = [Contribution]()
    var contrubution2DArray = [[Contribution]]()
    var months        = [String]()
    var monthTitle    = ""

    var document: Document = Document.init("")

    var items: [String] = []
    var dataSource: UICollectionViewDiffableDataSource<Int, Contribution>! = nil
    var collectionView: UICollectionView! = nil
    var containerView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
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
        configureActivityIndicator()
        getContributionCalendar()
      
    }
      
    // MARK: - ActivityIndicator
    func configureActivityIndicator() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha           = 0
        
        UIView.animate(withDuration: 0.25) { self.containerView.alpha = 0.8 }
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -20)
        ])
    
    }

    
    func hideIndicatorView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
         self.containerView.removeFromSuperview()
         self.containerView = nil
        }

    }
    func trimmingTitle() {
        
        monthTitle = months.joined(separator: "\t\t\t\t")
    }
    
    func getContributionCalendar() {    

        self.activityIndicator.startAnimating()

        NetworkManager.shared.getContributionDate(for: username) { [weak self] contribution in
            guard let self = self else { return }
   
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.hideIndicatorView()
            }

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
                NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9 / 7.0), heightDimension: .fractionalHeight(0.9)), subitem: verticalItem,count: 7)
            //  heightDimension = (verticalgroup width * 0.4) * 2
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.38),
                                                   heightDimension: .fractionalHeight(0.9)),subitems: [verticalGroup])
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuous
 
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
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <Int, Contribution>(collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath,
                data: Contribution) -> UICollectionViewCell? in

                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommitCell.reuseIdentifier, for: indexPath) as? CommitCell
                    else { fatalError("Cannot create new cell") }

                cell.contentView.backgroundColor = UIColor(hexString: data.contributionColor)
                
                return cell
        }
  
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contribution>()

        snapshot.appendSections([0])
        snapshot.appendItems(self.contributions)
 
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}


