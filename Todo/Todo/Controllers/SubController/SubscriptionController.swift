//
//  SubscriptionController.swift
//  Todo
//
//  Created by Dante Kim on 1/15/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints

class SubscriptionController: UIViewController {
    var topCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = lightGray
        return cv
    }()
    var topImages = ["group", "infinityGreen", "theme", "infinityGreen", "notif", "repeatBlue", "files"]
    var topTitles = ["Groups", "No Limits", "Premium Design", "Due Date", "Unlimited Reminder", "Repeat", "File & Notes"]
    var bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        return cv
    }()
    var continueButton = UIButton()
    var header = UIView()
    let one = RoundView()
    let two = RoundView()
    let three = RoundView()
    let four = RoundView()
    let five = RoundView()
    let six = RoundView()
    let seven = RoundView()
    //MARK: - init
    override func viewDidLoad() {
        configureUI()
        
    }
    
    //MARK: - helper funcs
    private func configureUI() {
        view.addSubview(header)
        header.leadingToSuperview()
        header.trailingToSuperview()
        header.topToSuperview()
        header.backgroundColor = .white
        header.height(view.frame.height * 0.10)
        let headerTitle = UILabel()
        headerTitle.font = UIFont(name: "OpenSans", size: 28)
        headerTitle.text = "Go Premium!"
        header.addSubview(headerTitle)
        headerTitle.center(in: header)
        
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "arrow")?.resize(targetSize: CGSize(width: 30, height: 30)).rotate(radians: -.pi/2), for: .normal)
        header.addSubview(backButton)
        backButton.leading(to: header,offset: 15)
        backButton.centerY(to: header)
        backButton.addTarget(self, action: #selector(tappedBack), for: .touchUpInside)
        
        view.backgroundColor = .white
        view.addSubview(topCollectionView)
        view.addSubview(bottomCollectionView)
        topCollectionView.register(TopCell.self, forCellWithReuseIdentifier: "topCell")
        bottomCollectionView.register(BottomCell.self, forCellWithReuseIdentifier: "bottomCell")
        topCollectionView.leadingToSuperview()
        topCollectionView.trailingToSuperview()
        topCollectionView.topToBottom(of: header)
        topCollectionView.height(view.frame.height * 0.30)
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        let dots = [one, two, three, four, five, six, seven]
        for dot in dots {
            view.addSubview(dot)
            dot.width(8)
            dot.height(8)
            dot.backgroundColor = .lightGray
            dot.topToBottom(of: topCollectionView, offset: -25)
        }
        
        one.trailingToLeading(of: two, offset: -12)
        two.trailingToLeading(of: three, offset: -12)
        three.trailingToLeading(of: four, offset: -12)
        four.centerX(to: view)
        five.leadingToTrailing(of: four, offset: 12)
        six.leadingToTrailing(of: five, offset: 12)
        seven.leadingToTrailing(of: six, offset: 12)
     
        
        bottomCollectionView.leadingToSuperview()
        bottomCollectionView.trailingToSuperview()
        bottomCollectionView.topToBottom(of: topCollectionView, offset: 20)
        bottomCollectionView.height(view.frame.height * 0.30)
        bottomCollectionView.backgroundColor = .red
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
    }

    
    @objc func tappedBack() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
