//
//  TopCollectionView.swift
//  Todo
//
//  Created by Dante Kim on 1/15/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit

extension SubscriptionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return topImages.count
        } else {
            return 4
        }
    }

    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      if !onceOnly {
        let indexToScrollTo = IndexPath(item: idx, section: 0)
        self.topCollectionView.scrollToItem(at: indexToScrollTo, at: .right, animated: false)
        onceOnly = true
        self.startTimer()
      } else {
        if collectionView == topCollectionView {
            var newDots = dots.map { $0 }
            let selectedDot = newDots.remove(at: indexPath.row)
            selectedDot.backgroundColor = .black
            for dot in newDots {
                dot.backgroundColor = .lightGray
            }
        }
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! TopCell
            cell.imgName = topImages[indexPath.row]
            cell.title.text = topTitles[indexPath.row]
            cell.desc.text = topDescs[indexPath.row]
            cell.configureUI()
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bottomCell", for: indexPath) as! BottomCell
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == topCollectionView {
            return CGSize(width: topCollectionView.frame.width, height: topCollectionView.frame.height)
        } else {
            return CGSize(width: bottomCollectionView.frame.width * 0.85, height: bottomCollectionView.frame.height * 0.80)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bottomCollectionView {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
            let combinedItemWidth = (numberOfItems * flowLayout.itemSize.width) + ((numberOfItems - 1)  * flowLayout.minimumInteritemSpacing)
            let padding = (collectionView.frame.width - combinedItemWidth) / 7
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bottomCollectionView {
            return bottomCollectionView.frame.width * 0.07
        }
          return 0
      }

//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//          let frameSize = collectionView.frame.size
//          return CGSize(width: frameSize.width - 10, height: frameSize.height)
//      }


}

