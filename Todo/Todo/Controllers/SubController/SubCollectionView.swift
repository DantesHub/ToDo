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
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! TopCell
            cell.imgName = topImages[indexPath.row]
            cell.configureUI()
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bottomCell", for: indexPath) as! BottomCell
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: topCollectionView.frame.width, height: topCollectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

          return 0
      }

//      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//          let frameSize = collectionView.frame.size
//          return CGSize(width: frameSize.width - 10, height: frameSize.height)
//      }


}

