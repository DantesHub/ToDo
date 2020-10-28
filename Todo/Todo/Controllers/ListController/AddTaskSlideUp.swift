//
//  AddTaskSlideUp.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit

extension ListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskSlideCell, for: indexPath) as! TaskSlideCell
        switch tappedIcon {
        case "addToList":
            print("addToList")
        case "priority":
            if indexPath.row == 3 {
                cell.icon.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 40, height: 40))
            } else {
                cell.icon.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(priorities[indexPath.row])
            }
            cell.nameLabel.text = "Priority 1"
        case "reminder":
            print("reminder")
        default:
            print("default")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SliderSectionHeader
                sectionHeader.label.text = "TRENDING"
                return sectionHeader
           } else { //No footer in this case but can add option for that
                return UICollectionReusableView()
           }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          return CGSize(width: slideUpView.frame.width, height: 50)
      }
      
    
}
