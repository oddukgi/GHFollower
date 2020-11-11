//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/03.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {

    enum Section { case main }
    
    var username: String!
    var followers: [Follower]               = []
    var filteredFollowers: [Follower]       = []
    
    var page                                = 1
    var hasMoreFollowers                    = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    var searchController: UISearchController!
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    var lastScrollPosition: CGFloat = 0

    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title         = username
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
       
    }

    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
       
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func configureSearchController() {
        searchController                                      = UISearchController()
        searchController.searchResultsUpdater                 = self
        searchController.searchBar.placeholder                = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController                       = searchController
    }
 
    func checkFollowersCount(followers: [Follower]) {
        if followers.count < 100 {
            hasMoreFollowers = false
        } else {
            hasMoreFollowers = true
        }
    }

    func getFollowers(username: String, page: Int) {
        
        showLoadingView()
        isLoadingMoreFollowers = true
        NetworkManager.shared.getFollowers(for: username, page: page) {[weak self] result in
            
            //#warning("call Dismiss")
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let followers):
                self.updateUI(with: followers)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad Stuff Happened", message: error.rawValue, buttonTitle: "OK")
                
            }
            self.isLoadingMoreFollowers = false
        }
    }
    
    
    func updateUI(with followers: [Follower]) {
        
        DispatchQueue.main.async {
            self.searchController.searchBar.isHidden = false
        }
        self.checkFollowersCount(followers: followers)
        // cause memory leak add [weak self]
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers. Go follow them 😀."
            DispatchQueue.main.async {
                self.searchController.searchBar.isHidden = true
                self.showEmptyStateView(with: message, in: self.view) }
            return
        }
        self.updateData(on: self.followers)
        
    }
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView,cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            return cell
                                                                            
        })
    }
    
    // order item
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }
}

extension FollowerListVC: UICollectionViewDelegate {
    
    /// show search bar when scrollbar reached on last scroll position
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollPosition = scrollView.contentOffset.y
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        print("\(lastScrollPosition) ,ScrollView.Pos.y: \(scrollView.contentOffset.y) ")
        
         if lastScrollPosition < scrollView.contentOffset.y {
             navigationItem.hidesSearchBarWhenScrolling = true
         } else if lastScrollPosition > scrollView.contentOffset.y {
             navigationItem.hidesSearchBarWhenScrolling = false
         }
     }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height

//        print("OffsetY: \(offsetY), contentHeight:\(contentHeight), height: \(height)")
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let activeArray = isSearching ? filteredFollowers : followers
        guard let follower  = dataSource.itemIdentifier(for: indexPath) else {return}
        let destVC          = UserInfoVC(username: follower.login, delegate: self)
        let navController   = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)

    }
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            switch result {
            case .success(let user):
                self.addUserToFavorites(user: user)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
                
            }
        }

    }
    
    
    func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully favorited this user 🎉",
                                                buttonTitle: "Hooray!")
                return
            }
            
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue,
                                            buttonTitle: "OK")
        }
    }
}


//: Bug report - When searchbar text deleted, list item reordered.

extension FollowerListVC : UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
          /// no textfield, show initial follower list
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }
}

extension FollowerListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String) {
        // get followers for that user
         isSearching = false
        self.username = username
        title         = username
        page          = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        getFollowers(username: username, page: page)
    }
}




/// Garbage
//        if offsetY > contentHeight - height {
//          //  guard hasMoreFollowers else { return }
//            page += 1
//            getFollowers(username: username, page: page)
//
//        }

/*  iphone 11
 
    offsetY = 5218.5
    contentHeight = 5907.3
    Height 896
 
    (5907.3 - (1.8 * 896))   < 5218.5
     5907.3 - 1612.8 = 4294.5  < 5218.5
 
 
 */
