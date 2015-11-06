//
//  HeroSessionLogViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/5/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroSessionLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var sessionLogTable: UITableView!
    
    var heroDisplayed = Hero?()
    var switchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sessionLogTable.reloadData()
        print(heroDisplayed!.name)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (heroDisplayed?.log.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sessionLogCell")
        cell?.textLabel!.text = heroDisplayed!.log[indexPath.row].name
        cell?.detailTextLabel!.text = heroDisplayed!.log[indexPath.row].date
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        let destVC: LogDetailViewController = segue.destinationViewController as! LogDetailViewController
         destVC.heroDisplayed = heroDisplayed
        if segue.identifier == "viewSessionLogSegue" {
            let selectedIndex = sessionLogTable.indexPathForCell(sender as! UITableViewCell)
            switchMode = true
            destVC.activateEditMode = switchMode
            destVC.sessionName = heroDisplayed!.log[(selectedIndex?.row)!].name
            destVC.date = heroDisplayed!.log[(selectedIndex?.row)!].date
            destVC.notes = heroDisplayed!.log[(selectedIndex?.row)!].notes
            destVC.heroLogDisplayed = heroDisplayed!.log[(selectedIndex?.row)!]
      
        }
       
    }
    
    func unwindForSegueHeroSession(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
          sessionLogTable.reloadData()
    }
  

}
