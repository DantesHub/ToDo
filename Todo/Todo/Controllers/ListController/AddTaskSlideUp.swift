//
//  AddTaskSlideUp.swift
//  Todo
//
//  Created by Dante Kim on 10/28/20.
//  Copyright © 2020 Alarm & Calm. All rights reserved.
//

import UIKit
import RealmSwift

extension ListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let lists = uiRealm.objects(ListObject.self)
        if tappedIcon == "Add to a List" {
            return lists.count
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.taskSlideCell, for: indexPath) as! TaskSlideCell
        switch tappedIcon {
        //only present in favorite, scheduled and all tasks
        case "Add to a List":
            let lists = uiRealm.objects(ListObject.self)
            for list in lists {
                cell.nameLabel.text = list.name
            }
        case "Priority":
            if indexPath.row == 3 {
                cell.icon.image = UIImage(named: "flag")?.resize(targetSize: CGSize(width: 40, height: 40))
            } else {
                cell.icon.image = UIImage(named: "flagFilled")?.resize(targetSize: CGSize(width: 40, height: 40)).withTintColor(priorities[indexPath.row])
            }
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
            cell.nameLabel.text = "Priority 1"
        case "Reminder":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
        case "Due":
            cell.nameLabel.text = dates[indexPath.row]
            cell.icon.image = UIImage(named: dates[indexPath.row])?.resize(targetSize: CGSize(width: 30, height: 30))
            cell.layer.addBorder(edge: .bottom, color: lightGray, thickness: 0.25)
        default:
            print("default")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch tappedIcon {
        //only present in favorite, scheduled and all tasks
        case "Add to a List":
            let  lists = uiRealm.objects(ListObject.self)
        case "Priority":
            selectedPriority = priorities[indexPath.row]
            addTaskField.addButton(leftButton: .prioritized, toolBarDelegate: self)
            if !firstAppend {
                scrollView.contentSize.width = scrollView.contentSize.width + 150
            } else {
                firstAppend = false
            }
            slideUpViewTapped()
            addTaskField.becomeFirstResponder()
        case "Reminder":
            print("reminder")
        case "Due":
            print("due")
        default:
            print("default")
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SliderSectionHeader
            sectionHeader.label.text = tappedIcon
            sectionHeader.reloadDelegate = self
            return sectionHeader
        } else { //No footer in this case but can add option for that
            return UICollectionReusableView()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 10, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: slideUpView.frame.width, height: 50)
    }
    
    
}
