//
//  TagsViewController.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/16/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKit
import CoreLocation

class TagsViewController: UITableViewController {

    var uniqueTagsClosestToFarthest : [Tag]!
    var selectedTag : Tag?
    
    override func viewDidLoad() {
        uniqueTagsClosestToFarthest = []
        
        self.navigationItem.title = "Tags"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("newTagButton"))
        tableView.allowsMultipleSelection = false
        if let user = UserBucket.loggedInUser() {
            if user.hasTag() {
                selectedTag = user.tag!
            } else {
                selectedTag = nil
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refreshTable"), name: "didRefreshLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refreshTable"), name: "didRefreshUsers", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshTable()
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey("seenTableBefore") {
            let alert = UIAlertController(title: nil, message: "Tap a tag to display its name and a marker at your location on the map, or tap the + at top right to add one if you don't see what you're looking for. Tap again to untag yourself and remove the marker from the map.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { action in
                alert.dismissViewControllerAnimated(true, completion: {
                    defaults.setBool(true, forKey: "seenTableBefore")
                    defaults.synchronize()
                })
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refreshTable() {
        self.filterAndSortTags()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        if (index < uniqueTagsClosestToFarthest.count){
            let tag = uniqueTagsClosestToFarthest[index]
            cell.textLabel!.text = tag.name
            
            if selectedTag? != nil && selectedTag!.equalsTag(tag) {
                cell.accessoryType = .Checkmark
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniqueTagsClosestToFarthest.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let clickedTag = uniqueTagsClosestToFarthest[indexPath.row]
        let loggedInUser = UserBucket.loggedInUser()!
        if selectedTag? != nil && selectedTag!.equalsTag(clickedTag){
            selectedTag = nil
            loggedInUser.tag = nil
        } else {
            selectedTag = clickedTag
            loggedInUser.tag = clickedTag
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.refreshTable()
        loggedInUser.remoteUpdateAsync { error in
            if error != nil {
                println(error)
            } else {
                self.refreshTable()
            }
        }
    }
    
    func newTagButton() {
        var inputTextField: UITextField?
        
        let alert = UIAlertController(title: "Add New Tag", message: "Enter a name for this tag.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.addTag(inputTextField!.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addTag(name: String) {
        if let user = UserBucket.loggedInUser() {
            var tag = Tag()
            tag.name = name
            if arrayContainsTag(uniqueTagsClosestToFarthest, tag: tag){
                tag = uniqueTagsClosestToFarthest.filter({ $0.name.lowercaseString == name.lowercaseString }).first!
                selectedTag = tag
                user.tag = tag
                refreshTable()
                user.remoteUpdateAsync { error in }
            } else {
                user.tag = tag
                selectedTag = tag
                uniqueTagsClosestToFarthest.insert(tag, atIndex: 0)
                tableView.reloadData()
                tag.remoteCreateAsync { error in
                    if error != nil {
                        println(error)
                    } else {
                        user.remoteUpdateAsync { error in }
                    }
                }
            }
        } // yuck
    }
    
    private func filterAndSortTags() {
        uniqueTagsClosestToFarthest = uniqueTags(UserBucket.allUsers()
            .filter({ $0.hasTag() && $0.hasLocation() })
            .sorted({ $0.isCloserThan($1) })
            .map({ $0.tag! }))
    }
    
    private func uniqueTags(arrayToFilter: [Tag]) -> [Tag] {
        var uniqueTags = [] as [Tag]
        for tag in arrayToFilter {
            if !arrayContainsTag(uniqueTags, tag: tag) {
                uniqueTags.append(tag)
            }
        } // ew
        return uniqueTags
    }
    
    private func arrayContainsTag(array: [Tag], tag: Tag) -> Bool {
        if array.count > 0 {
            return array.filter({ $0.equalsTag(tag) }).count > 0
        }
        else { return false }
    }
}
