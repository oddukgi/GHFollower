//
//  UserInfoVC.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/15.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

protocol UserInfoVCDelegate: class {
    func didRequestFollowers(for username: String)
}

class UserInfoVC: GFDataLoadingVC {

    let scrollView  = UIScrollView()
    let contentView = UIView()
    
    let headerView  = UIView()
    
    let itemViewCalendar = UIView()
    let itemViewProfile = UIView()
    let itemViewFollower = UIView()
    let dateLabel   = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    var username: String!
    weak var delegate: UserInfoVCDelegate!
    var contributionData: [Contribution] = []
    var months: [String] = []
    var users: User!
   
    init(username: String, delegate: UserInfoVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureScrollView()
        layoutUI()
        runTask()
    
    }
    
    // MARK: - Refactoring
    
    func configureVC() {
         view.backgroundColor = .systemBackground
         let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
         navigationItem.title = username
         navigationItem.rightBarButtonItem = doneButton
    }

    // contentView Scrolling
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 800)
        ])
    }
    
    func getUserInfo(completion: @escaping (User) -> Void) {
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                //After(deadline: .now() + .milliseconds(300))
            case .success(let user):
                completion(user)
             
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong!", message: error.rawValue, buttonTitle: "OK")
                completion(User())
            }
        }
    }
    
    func getContributionData(completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.getContributionDate(for: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.contributionData = data
            
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "failed to fetch!", message: error.rawValue, buttonTitle: "OK")
               
            }
            
            completion(!self.contributionData.isEmpty)
        }
    }
    
    func getTitleMonth(for user: User) {
        NetworkManager.shared.getMonth(for: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.months = data
                
                DispatchQueue.main.async {
                    self.configureUIElements(with: user)
                }
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "failed to fetch!", message: error.rawValue, buttonTitle: "OK")
                
            }
            
        
        }
    }
  
    func configureUIElements(with user: User) {
        // github contribution
        self.add(childVC: GFContributionsVC(contributions: contributionData, months: months), to: itemViewCalendar )
        self.add(childVC: GFRepoItemVC(user: user, delegate: self), to: self.itemViewProfile)
        self.add(childVC: GFFollowerItemVC(user: user, delegate: self), to: self.itemViewFollower)
        self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
        self.dateLabel.text = "GitHub since \(user.createdAt.convertToMonthYearFormat())"
    
    }
    
    func layoutUI() {
        let padding: CGFloat    = 25
        let calendarHeight: CGFloat = 235
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView, itemViewCalendar, itemViewProfile, itemViewFollower, dateLabel]
        
        for itemView in itemViews {
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
               
            itemViewCalendar.topAnchor.constraint(equalTo: headerView.bottomAnchor,constant: padding),
            itemViewCalendar.heightAnchor.constraint(equalToConstant: calendarHeight),
             
            itemViewProfile.topAnchor.constraint(equalTo: itemViewCalendar.bottomAnchor,constant: padding),
            itemViewProfile.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewFollower.topAnchor.constraint(equalTo: itemViewProfile.bottomAnchor,constant: padding),
            itemViewFollower.heightAnchor.constraint(equalToConstant: itemHeight),
               
            dateLabel.topAnchor.constraint(equalTo: itemViewFollower.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    @objc func dismissVC() {
       dismiss(animated: true)
    }

    func runTask() {
      
        DispatchQueue.background(background: {
            self.getUserInfo { users in
                self.users = users
            }
       
        }, completion:{
             
            self.getContributionData { _ in
                
                if self.users != nil {
                    self.getTitleMonth(for: self.users)
                }
            }
                         
        })

    }
}

extension UserInfoVC: GFRepoItemVCDelegate {
    
    func didTapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid!", buttonTitle: "OK")
            return
        }
        
        presentSafariVC(with: url)
    }
}

extension UserInfoVC: GFFollowerItemVCDelegate {
    
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGFAlertOnMainThread(title: "No followers", message: "This user has no followers. What a shame!",
                                       buttonTitle: "😭")
            return
        }
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }
}


