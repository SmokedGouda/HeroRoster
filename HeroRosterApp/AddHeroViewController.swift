//
//  AddHeroViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class AddHeroViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heroStatsTable: UITableView!
    @IBOutlet weak var heroNameField: UITextField!
    @IBOutlet weak var heroNumberField: UITextField!
    @IBOutlet weak var heroNumberLabel: UILabel!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var addHeroButton: UIButton!
    
    var statToDisplay = Int()
    var classSelected = String()
    var raceSelected = String()
    var genderSelected = String()
    var levelSelected = String()
    // Index variables below are used to determine where the checkmark will be placed when the HeroStatOpionsViewController is segued to.  The values will be set in the tableView cellForRowAtIndexPath function
    var classIndex: Int?
    var raceIndex: Int?
    var genderIndex: Int?
    var levelIndex: Int?
    
    var createdHero: Hero?
    var cellLabel = String()
    var activeRoster = Roster?()
    var newHeroObjectId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundTheLabelsAndButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroStatsTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroCell") as UITableViewCell!
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(17)
        if cell.detailTextLabel!.text == "Detail" {
            cell.detailTextLabel?.hidden = true
        }
        cell.textLabel!.text = HeroStatTableViewTitles().statTitles[indexPath.row]
        let statLabel = cell.textLabel!.text
        switch statLabel! {
        case "Class":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().heroClass[statToDisplay]
                cell.detailTextLabel?.hidden = false
                classSelected = cell.detailTextLabel!.text!
                classIndex = statToDisplay
            }
        case "Race":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().race[statToDisplay]
                cell.detailTextLabel?.hidden = false
                raceSelected = cell.detailTextLabel!.text!
                raceIndex = statToDisplay
            }
        case "Gender":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().gender[statToDisplay]
                cell.detailTextLabel?.hidden = false
                genderSelected = cell.detailTextLabel!.text!
                genderIndex = statToDisplay
            }
        case "Level":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().level[statToDisplay]
                cell.detailTextLabel?.hidden = false
                levelSelected = cell.detailTextLabel!.text!
                levelIndex = statToDisplay
            }
        default:
            print("not a valid return")
        }
        return cell
    }
    
    @IBAction func addHeroButtonPressed(sender: UIButton) {
        let newHeroName = heroNameField.text
        let newHeroNumber = heroNumberField.text
        if activeRoster!.usedHeroNames.contains(newHeroName!) == true {
            displayDuplicateNameAlert()
        } else {
            createdHero = Hero(name: newHeroName!, number: newHeroNumber!, heroClass: classSelected, race: raceSelected, gender: genderSelected, level: levelSelected, log: [], usedLogNames: [], parseObjectId: "", logIds: [])
            createHeroOnParse(createdHero!)
            self.performSegueWithIdentifier("addHeroSegue", sender: self)
        }
    }
    
    func displayDuplicateNameAlert() {
        let alert = UIAlertController(
            title: "Can't add hero!", message: "That name has already been used.  Please choose another one.", preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func createHeroOnParse(heroToCreate: Hero) {
        let parseHero = PFObject(className: "Hero")
        parseHero["owner"] = activeRoster!.userName
        parseHero["name"] = heroToCreate.name
        parseHero["number"] = heroToCreate.number
        parseHero["heroClass"] = heroToCreate.heroClass
        parseHero["race"] = heroToCreate.race
        parseHero["gender"] = heroToCreate.gender
        parseHero["level"] = heroToCreate.level
        parseHero["logIds"] = heroToCreate.logIds
        
        parseHero.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if (success) {
                dispatch_async(dispatch_get_main_queue()){
                    print("hero saved to parse")
                    self.newHeroObjectId = parseHero.objectId!
                    heroToCreate.parseObjectId = self.newHeroObjectId
                    self.activeRoster?.addHeroToRoster(heroToCreate)
                }
            } else {
                print("hero did not save to parse")
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // This segue will display the appropriate tableview based on which cell was touched.
        if segue.identifier == "heroStatOptionsSegue" {
            let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
            let selectedIndex = heroStatsTable.indexPathForCell(sender as! UITableViewCell)
            cellLabel = HeroStatTableViewTitles().statTitles[(selectedIndex?.row)!]
            destVC.navBarTitle = cellLabel
            switch cellLabel {
            case "Class":
                destVC.heroStatsArrayToDisplay = HeroStats().heroClass
                destVC.lastSelectedRow = classIndex
            
            case "Race":
                destVC.heroStatsArrayToDisplay = HeroStats().race
                destVC.lastSelectedRow = raceIndex
            
            case "Gender":
                destVC.heroStatsArrayToDisplay = HeroStats().gender
                destVC.lastSelectedRow = genderIndex
            
            case "Level":
                destVC.heroStatsArrayToDisplay = HeroStats().level
                destVC.lastSelectedRow = levelIndex
            
            default:
                print("no action")
            }
        }
    }
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(HeroStatOptionsViewController)) {
            let heroStat: HeroStatOptionsViewController = unwindSegue.sourceViewController as! HeroStatOptionsViewController
            statToDisplay = heroStat.chosenStat
        }
    }
    
    func roundTheLabelsAndButtons () {
        heroNameLabel.layer.cornerRadius = 5
        heroNameLabel.clipsToBounds = true
        heroNumberLabel.layer.cornerRadius = 5
        heroNumberLabel.clipsToBounds = true
        heroStatsTable.layer.cornerRadius = 5
        addHeroButton.layer.cornerRadius = 5
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }

}
