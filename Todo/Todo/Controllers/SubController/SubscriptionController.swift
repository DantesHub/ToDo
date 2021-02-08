//
//  SubscriptionController.swift
//  Todo
//
//  Created by Dante Kim on 1/15/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import TinyConstraints
import Purchases
import StoreKit

class SubscriptionController: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(idx: Int = 0) {
        super.init(nibName: nil, bundle: nil)
        self.idx = idx
    }
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
    var packagesAvailableForPurchase = [Purchases.Package]()
    var topImages = ["group", "infinityGreen", "theme", "dueDate", "unlimitedReminder", "repeatBlue", "files"]
    var topTitles = ["Groups", "No Limits", "Advanced Customization", "Deadline Management", "Unlimited Reminder", "Repeat", "File & Notes"]
    var topDescs = ["Organize your lists into their own dedicated folders", "Be on time and set clear deadlines for your tasks", "Create as many Lists and Tasks as you wish","Get full access to premium wallpapers and customization tools","Receive smart notifications to fully manage your deadlines", "Automatise tasks creation with the repeat feature", "Add relevant information to your tasks"]
    var stories = [""]
    var bottomCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let cv = UICollectionView(frame: .zero
                                  , collectionViewLayout: layout)
        
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        return cv
    }()
    var idx = 0
    let yearlyBox = PriceBox()
    let monthlyBox = PriceBox()
    var continueButton = UIButton()
    var continueDesc = UILabel()
    var header = UIView()
    var onceOnly = false
    let one = RoundView()
    let two = RoundView()
    let three = RoundView()
    var startedTimer = false
    
    let four = RoundView()
    let five = RoundView()
    let six = RoundView()
    let seven = RoundView()
    let successStories = UILabel()
    var dots = [RoundView]()
    let upgradeLabel = UILabel()
    var monthlyPrice: Double = 0
    var yearlyPrice: Double = 0
    var yearlyMonthlyPrice: Double = 0
    let locale = Locale.current

    
    //MARK: - init
    override func viewDidLoad() {
        Purchases.shared.offerings { [self] (offerings, error) in
            if let offerings = offerings {
                let offer = offerings.current
                let packages = offer?.availablePackages
                guard packages != nil else {
                    return
                }
                for i in 0...packages!.count - 1 {
                    let package = packages![i]
                    self.packagesAvailableForPurchase.append(package)
                    let product = package.product
                    let price = product.price
                    let name = product.productIdentifier
                    print(price, "price", name, product.localizedTitle)
                    if name == "ios.premium.monthly.to.do.list.1" {
                        monthlyPrice = round(100 * Double(truncating: price))/100
                        
                    } else if name == "ios.premium.yearly.to.do.list.1" {
                        yearlyPrice = round(100 * Double(truncating: price))/100
                        yearlyMonthlyPrice = (round(100 * (yearlyPrice/12))/100) - 0.01
                    }
                }
            }
        }
        configureUI()
    }
    func scroll() {
    }
    override func viewDidLayoutSubviews() {
    }
    //MARK: - helper funcs
    func startTimer() {
        let _ =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }


    @objc func scrollAutomatically(_ timer1: Timer) {
            for cell in topCollectionView.visibleCells {
                let indexPath: IndexPath? = topCollectionView.indexPath(for: cell)
                if ((indexPath?.row)! < 6){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: 0)

                    topCollectionView.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }  else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: 0)
                    topCollectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }

            }
        
    }
     func configureUI() {
        view.addSubview(header)
        header.leadingToSuperview()
        header.trailingToSuperview()
        header.topToSuperview()
        header.overrideUserInterfaceStyle = .light
        header.backgroundColor = .white
        header.height(view.frame.height * 0.08)
        let headerTitle = UILabel()
        headerTitle.font = UIFont(name: "OpenSans", size: 28)
        headerTitle.text = "To Do Premium"
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

        dots = [one, two, three, four, five, six, seven]
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
        
        
//        successStories.text = "Success Stories"
//        successStories.font = UIFont(name: "OpenSans-Bold", size: 22)
//        view.addSubview(successStories)
//        successStories.centerX(to: view)
//        successStories.topToBottom(of: four, offset: 50)
        let currencySymbol = locale.currencySymbol!

        view.addSubview(upgradeLabel)
        upgradeLabel.font = UIFont(name: "OpenSans-Bold", size: 20)
        upgradeLabel.centerX(to: view)
        upgradeLabel.text = "Upgrade to Premium Offer"
        upgradeLabel.textColor = .darkGray
        upgradeLabel.topToBottom(of: topCollectionView, offset: 40)
        view.addSubview(yearlyBox)
        yearlyBox.topToBottom(of: upgradeLabel, offset: 25)
        yearlyBox.leading(to: view, offset: view.frame.width * 0.10)
        yearlyBox.width(view.frame.width * 0.40)
        yearlyBox.height(view.frame.height * 0.20)
        yearlyBox.selected = true
        yearlyBox.priceLabel.text = "\(currencySymbol)\(yearlyPrice)"
        yearlyBox.yearly = true
        yearlyBox.title.text = "Pay Yearly"
        yearlyBox.smallLabel.text = "(\(currencySymbol)\(yearlyMonthlyPrice)/mo)"
        yearlyBox.width = view.frame.width * 0.40 * 0.43
        yearlyBox.height = view.frame.height * 0.20 * 0.13
        yearlyBox.configure()
        let yearlyGest = UITapGestureRecognizer(target: self, action: #selector(tappedYearly))
        yearlyBox.addGestureRecognizer(yearlyGest)
        
        view.addSubview(monthlyBox)
        monthlyBox.topToBottom(of: upgradeLabel, offset: 25)
        monthlyBox.leadingToTrailing(of: yearlyBox,offset: 5)
        monthlyBox.width(view.frame.width * 0.40)
        monthlyBox.height(view.frame.height * 0.20)
        monthlyBox.selected = false
        monthlyBox.priceLabel.text = "\(currencySymbol)\(monthlyPrice)"
        monthlyBox.yearly = false
        monthlyBox.title.text = "Pay Monthly"
        monthlyBox.smallLabel.text = "(\(currencySymbol)\(monthlyPrice)/mo)"
        monthlyBox.width = view.frame.width * 0.40 * 0.43
        monthlyBox.height = view.frame.height * 0.20 * 0.13
        monthlyBox.configure()
        let monthlyGest = UITapGestureRecognizer(target: self, action: #selector(tappedMonthly))
        monthlyBox.addGestureRecognizer(monthlyGest)
//        bottomCollectionView.leadingToSuperview()
//        bottomCollectionView.trailingToSuperview()
//        bottomCollectionView.topToBottom(of: topCollectionView, offset: 70)
//        bottomCollectionView.height(view.frame.height * 0.25)
//        bottomCollectionView.backgroundColor = .white
//        bottomCollectionView.delegate = self
//        bottomCollectionView.dataSource = self
//        
//        view.addSubview(continueDesc)
//        continueDesc.centerX(to: view)
//        continueDesc.topToBottom(of: bottomCollectionView, offset: 26)
//        continueDesc.font = UIFont(name: "OpenSans", size: 6)
//        continueDesc.text = "7 day free trial, then $3.99 a month"
//        continueDesc.textColor = .systemBlue
        
        view.addSubview(continueButton)
        continueButton.leading(to: view, offset: 30)
        continueButton.trailing(to: view, offset: -30)
        continueButton.topToBottom(of: yearlyBox, offset: view.frame.height * 0.05)
        continueButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        continueButton.height(self.view.frame.height * 0.08)
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.backgroundColor = lightPurple
        continueButton.layer.cornerRadius = 15
        continueButton.addTarget(self, action: #selector(tappedContinue), for: .touchUpInside)
  
        let privacy = UILabel()
        let terms = UILabel()
        

        privacy.textColor = .lightGray
        terms.textColor = .lightGray
        
        privacy.text = "Privacy Policy"
        terms.text = "Terms of Use"
        privacy.font = UIFont(name: "OpenSans", size: 4)
        terms.font = UIFont(name: "OpenSans", size: 4)
        view.addSubview(privacy)
        view.addSubview(terms)
        privacy.trailing(to: view, offset: -(view.frame.width * 0.075))
        terms.leading(to: view, offset: view.frame.width * 0.075)
        privacy.topToBottom(of: continueButton, offset: 30)
        terms.topToBottom(of: continueButton, offset: 30)
        privacy.isUserInteractionEnabled = true
        terms.isUserInteractionEnabled = true
        let privacyGest = UITapGestureRecognizer(target: self, action: #selector(tappedPrivacy))
        privacy.addGestureRecognizer(privacyGest)
        let termsGest = UITapGestureRecognizer(target: self, action: #selector(tappedTerms))
        terms.addGestureRecognizer(termsGest)
        print(idx, "jujutsu")
        topCollectionView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .right, animated: false)
    }

    @objc func tappedYearly()  {
        yearlyBox.selected = true
        yearlyBox.configure()
        monthlyBox.selected = false
        monthlyBox.configure()
    }
    @objc func tappedMonthly() {
        monthlyBox.selected = true
        monthlyBox.configure()
        yearlyBox.selected = false
        yearlyBox.configure()
    }
    
    @objc func tappedPrivacy() {
        print("fda")
        if let url = URL(string: "http://alarmandcalm.fun/index.php/alarm-calm-privacy-policy/") {
            UIApplication.shared.open(url)
        }
    }
    @objc func tappedTerms() {
        if let url = URL(string: "http://alarmandcalm.fun/index.php/alarm-calm-terms-of-use") {
            UIApplication.shared.open(url)
        }
    }
 

    @objc func tappedContinue(sender:UIButton) {
        print(packagesAvailableForPurchase)
        var package = packagesAvailableForPurchase[0]
        if yearlyBox.selected {
             package = packagesAvailableForPurchase.last { (package) -> Bool in
                return package.product.productIdentifier == "ios.premium.yearly.to.do.list.1"
             }!
        } else {
             package = packagesAvailableForPurchase.last { (package) -> Bool in
                return package.product.productIdentifier == "ios.premium.monthly.to.do.list.1"
             }!
        }
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            if purchaserInfo?.entitlements.all["premium"]?.isActive == true {
                // Unlock that great "pro" content
                UserDefaults.standard.setValue(true, forKey: "isPro")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func tappedBack() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
