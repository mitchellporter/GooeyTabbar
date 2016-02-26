//
//  ViewController.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

let trendingDictionary = [
    "name":"TRENDING",
    "backgroundColor":UIColor(red:0.945,  green:0.800,  blue:0.012, alpha:1),
    "imageName":"trending-image-filter-menu"
]

let famousPeopleDictionary = [
    "name":"FAMOUS PEOPLE",
    "backgroundColor":UIColor(red:1,  green:0.380,  blue:0.380, alpha:1),
    "imageName":"famous-people-image-filter-menu"
]

let schoolSpiritDictionary = [
    "name":"SCHOOL SPIRIT",
    "backgroundColor":UIColor(red:0.486,  green:0.275,  blue:0.969, alpha:1),
    "imageName":"school-spirit-image-filter-menu"
]

let popCultureDictionary = [
    "name":"POP CULTURE",
    "backgroundColor":UIColor(red:0.275,  green:0.863,  blue:0.969, alpha:1),
    "imageName":"pop-culture-image-filter-menu"
]

let placesDictionary = [
    "name":"PLACES",
    "backgroundColor":UIColor(red:0.388,  green:0.510,  blue:0.976, alpha:1),
    "imageName":"places-image-filter-menu"
]

let animalsDictionary = [
    "name":"ANIMALS",
    "backgroundColor":UIColor(red:0.322,  green:0.800,  blue:0.494, alpha:1),
    "imageName":"animals-image-filter-menu"
]

let holidaysDictionary = [
    "name":"HOLIDAYS",
    "backgroundColor":UIColor(red:0.188,  green:0.271,  blue:0.365, alpha:1),
    "imageName":"holidays-image-filter-menu"
]

let kidsDictionary = [
    "name":"KIDS",
    "backgroundColor":UIColor(red:0.863,  green:0.318,  blue:0.604, alpha:1),
    "imageName":"kids-image-filter-menu"
]

let defaultFilterMenuData = [
    trendingDictionary,
    famousPeopleDictionary,
    schoolSpiritDictionary,
    popCultureDictionary,
    placesDictionary,
    animalsDictionary,
    holidaysDictionary,
    kidsDictionary
]


class ViewController: UIViewController {

    var menu : TabbarMenu!
    var selectedFilterMenuData = defaultFilterMenuData
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
    
    func setup() {
        menu.dataSource = self
        menu.delegate = self
    }
  
  override func viewDidAppear(animated: Bool) {
    menu = TabbarMenu(tabbarHeight: 40.0)
    menu.dataSource = self
    menu.delegate = self
    menu.setupCollectionView()
    menu.setUpViews()
  }
  
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension ViewController: TabbarMenuDataSource, TabbarMenuDelegate {
    func numberOfFilterRows() -> Int {
        return selectedFilterMenuData.count
    }
    
    func filterDataForRow(row: Int) -> [String : AnyObject] {
        return selectedFilterMenuData[row]
    }
    
    func didSelectFilterRow(indexPath: NSIndexPath) {
        
        //        // Part 1 - Play with cell z-index + cell movements
        //        let selectedCell = filterMenu.collectionView.cellForItemAtIndexPath(indexPath)
        //        selectedCell?.layer.zPosition = 10.0
        //
        //        let visibleCells = filterMenu.collectionView.visibleCells
        //        let visibleIndexPaths = filterMenu.collectionView.indexPathsForVisibleItems()
        //
        //        for visibleIndexPath in visibleIndexPaths {
        //            if visibleIndexPath.row < indexPath.row {
        //                print("cell above selected cell")
        //                let cellAbove = filterMenu.collectionView.cellForItemAtIndexPath(visibleIndexPath)
        //                UIView.animateWithDuration(2.0, animations: { () -> Void in
        //                    selectedCell?.frame = cellAbove!.frame
        //                })
        //            }
        //        }
        
        // Part 2
        //1. Move cells up until the top of the selected cell reaches the nav bar
        
        //1. User taps cell
        //2. Make a copy of default data,
        // remove selected filter category,
        // set copy as selected data,
        // reload table view
        
        //        let selectedFilterData = selectedFilterMenuData[row]
        //
        //        var defaultData = defaultFilterMenuData
        //        defaultData.removeAtIndex(row+1)
        //
        //        selectedFilterMenuData = defaultData
        //        UIView.animateWithDuration(1.0, delay: 0.0, options: [], animations: { () -> Void in
        //            //
        //            self.filterMenu.alpha = 0.0
        //            }, completion: { (completed) -> Void in
        //                //
        //                self.filterMenu.showing = false
        //                self.filterMenu.tableView.reloadData()
        //        })
        //
        //        // Update nav bar
        //        navBarView.filterIconImageView.image = UIImage(named: selectedFilterData["imageName"] as! String)
        //        navBarView.filterLabel.text = selectedFilterData["name"] as? String
        //        navBarView.backgroundColor = selectedFilterData["backgroundColor"] as? UIColor
    }
}
