//
//  HeroDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit
import Parse

class HeroDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heroDetailTable: UITableView!
    @IBOutlet weak var heroNameTextField: UITextField!
    @IBOutlet weak var heroNumberTextField: UITextField!
    @IBOutlet weak var editHeroButton: UIButton!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroNumberLabel: UILabel!
    
    var activeRoster = Roster?()
    var statToDisplay = Int()
    var classDisplayed = String()
    var raceDisplayed = String()
    var genderDisplayed = String()
    var levelDisplayed = String()
    var factionDisplayed = String()
    var prestigePointsDisplayed = String()
    // Index variables below are used to determine where the checkmark will be placed when the HeroStatOpionsViewController is segued to.  The values will be set in the tableView cellForRowAtIndexPath function
    var classIndex: Int?
    var raceIndex: Int?
    var genderIndex: Int?
    var levelIndex: Int?
    var factionIndex: Int?
    var prestigePointsIndex: Int?
    
    var heroDisplayed = Hero?()
    var cellLabel = String()
    var tableEditState = Bool?()
    var heroNameBeforeEdit = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundTheLabelsAndButtons()
        setViewToStaticMode()
        heroNameTextField.text = heroDisplayed?.name
        heroNumberTextField.text = heroDisplayed?.number
        heroNameBeforeEdit = heroNameTextField.text!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroDetailTable.reloadData()
        print(heroDisplayed!.logIds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroCell") as UITableViewCell!
        cell!.textLabel!.font = UIFont.boldSystemFontOfSize(17)
        cell!.detailTextLabel!.font = UIFont.boldSystemFontOfSize(17)
        if cell.detailTextLabel!.text == "Detail" {
            cell.detailTextLabel?.hidden = true
        }
        if tableEditState == true {
            heroDetailTable.allowsSelection = true
            cell.accessoryType = .DisclosureIndicator
        } else {
            heroDetailTable.allowsSelection = false
            cell.accessoryType = .None
        }
        
        cell.textLabel!.text = HeroStatTableViewTitles().statTitles[indexPath.row]
        let buttonLabel = editHeroButton.titleLabel!.text!
        let statLabel = cell.textLabel!.text
        switch statLabel! {
            case "Class":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().heroClass[statToDisplay]
                    classIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = classDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.heroClass
                    for (index, value) in HeroStats().heroClass.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            classIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                classDisplayed = cell.detailTextLabel!.text!
            
            case "Race":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().race[statToDisplay]
                    raceIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = raceDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.race
                    for (index, value) in HeroStats().race.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            raceIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                raceDisplayed = cell.detailTextLabel!.text!
          
            case "Gender":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().gender[statToDisplay]
                    genderIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = genderDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.gender
                    for (index, value) in HeroStats().gender.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            genderIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                genderDisplayed = cell.detailTextLabel!.text!
            
            case "Level":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().level[statToDisplay]
                    levelIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = levelDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.level
                    for (index, value) in HeroStats().level.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            levelIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                levelDisplayed = cell.detailTextLabel!.text!
            
            case "Faction":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().faction[statToDisplay]
                    factionIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = factionDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.faction
                    for (index, value) in HeroStats().faction.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            factionIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                factionDisplayed = cell.detailTextLabel!.text!
            
            case "Prestige":
                if cellLabel == statLabel {
                    cell.detailTextLabel!.text = HeroStats().prestigePoints[statToDisplay]
                    prestigePointsIndex = statToDisplay
                } else if buttonLabel == "Save" {
                    cell.detailTextLabel!.text = prestigePointsDisplayed
                } else {
                    cell.detailTextLabel!.text = heroDisplayed?.prestigePoints
                    for (index, value) in HeroStats().prestigePoints.enumerate() {
                        if cell.detailTextLabel!.text == value {
                            prestigePointsIndex = index
                        }
                    }
                }
                cell.detailTextLabel?.hidden = false
                prestigePointsDisplayed = cell.detailTextLabel!.text!
            
            default:
                "not a valid return"
        }
        return cell
    }
  
    @IBAction func editHeroButtonPressed(sender: UIButton) {
        let buttonLabel = editHeroButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Hero":
                setViewToEditMode()
            
            default:
                if heroNameTextField.text != heroNameBeforeEdit {
                    checkEditedHeroNameAgainstUsedHeroNames()
                } else {
                    saveEditedHero()
                }
        }
    }
    
    func checkEditedHeroNameAgainstUsedHeroNames() {
        if activeRoster!.usedHeroNames.contains(heroNameTextField.text!) == true {
            displayDuplicateNameAlert()
        } else {
            updateNameAssociatedWithHerosScenarioRecords()
            updateUsedHeroNamesWithTheEditedHeroName()
            updateNameAssociatedWithHerosLogs()
            activeRoster?.updateScenarioRecordsOnParse(activeRoster!)
            saveEditedHero()
        }
    }
    
    func displayDuplicateNameAlert() {
        let alert = UIAlertController(
            title: "Can't save edited hero", message: "That name has already been used.  Please choose another one.", preferredStyle: .Alert)
        let action = UIAlertAction(
            title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateUsedHeroNamesWithTheEditedHeroName() {
        for (index, value) in activeRoster!.usedHeroNames.enumerate(){
            if heroNameBeforeEdit == value {
                activeRoster!.usedHeroNames.removeAtIndex(index)
            }
        }
        activeRoster!.usedHeroNames.append(heroNameTextField.text!)
        heroNameBeforeEdit = heroNameTextField.text!
    }
    
    func updateNameAssociatedWithHerosScenarioRecords() {
        for (key, value) in activeRoster!.scenarioRecords {
            if value[0] == heroNameBeforeEdit {
                activeRoster!.scenarioRecords[key]![0] = heroNameTextField.text!
            }
        }
    }
    
    func saveEditedHero() {
        setViewToStaticMode()
        let updatedHeroName = heroNameTextField.text
        let updatedHeroNumber = heroNumberTextField.text
        activeRoster?.updateHero(heroDisplayed!, newName: updatedHeroName!, newNumber: updatedHeroNumber!, newHeroClass: classDisplayed, newRace: raceDisplayed, newGender: genderDisplayed, newLevel: levelDisplayed, newFaction: factionDisplayed, newPrestigePoints: prestigePointsDisplayed)
        updateHeroOnParse()
    }
    
    func updateHeroOnParse() {
        let query = PFQuery(className:"Hero")
        query.getObjectInBackgroundWithId(heroDisplayed!.parseObjectId) {
            (Hero: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let hero = Hero {
                hero["name"] = self.heroNameTextField.text
                hero["number"] = self.heroNumberTextField.text
                hero["heroClass"] = self.classDisplayed
                hero["race"] = self.raceDisplayed
                hero["gender"] = self.genderDisplayed
                hero["level"] = self.levelDisplayed
                hero["faction"] = self.factionDisplayed
                hero["prestigePoints"] = self.prestigePointsDisplayed
                hero.saveInBackground()
                print("hero updated on parse")
            }
        }
    }
    
    func updateNameAssociatedWithHerosLogs() {
        for objectId in heroDisplayed!.logIds {
            let query = PFQuery(className:"Log")
            query.getObjectInBackgroundWithId(objectId) {
                (Log: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let log = Log {
                    log["logForHero"] = self.heroNameTextField.text
                    log.saveInBackground()
                    print("logId \(objectId) updated with hero's new name on parse")
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // This segue will display a tableview with all of the hero's session logs.
        if segue.identifier == "sessionTableSegue" {
            setViewToStaticMode()
            let destVC: HeroSessionLogViewController = segue.destinationViewController as! HeroSessionLogViewController
            destVC.heroDisplayed = heroDisplayed
            destVC.activeRoster = activeRoster
        }
        // This segue will display the appropriate tableview based on which cell was touched.
        if segue.identifier == "heroStatOptionsSegueTwo" {
            let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
            let selectedIndex = heroDetailTable.indexPathForCell(sender as! UITableViewCell)
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
                
                case "Faction":
                    destVC.heroStatsArrayToDisplay = HeroStats().faction
                    destVC.lastSelectedRow = factionIndex
                
                case "Prestige":
                    destVC.heroStatsArrayToDisplay = HeroStats().prestigePoints
                    destVC.lastSelectedRow = prestigePointsIndex
                
                default:
                    "no action"
            }
        }
    }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if(unwindSegue.sourceViewController .isKindOfClass(HeroStatOptionsViewController)) {
            let heroStat: HeroStatOptionsViewController = unwindSegue.sourceViewController as! HeroStatOptionsViewController
            
            statToDisplay = heroStat.chosenStat
        }
    }
    
    func roundTheLabelsAndButtons() {
        heroNameLabel.layer.cornerRadius = 5
        heroNameLabel.clipsToBounds = true
        heroNumberLabel.layer.cornerRadius = 5
        heroNumberLabel.clipsToBounds = true
        heroDetailTable.layer.cornerRadius = 5
        editHeroButton.layer.cornerRadius = 5
    }
    
    func setViewToStaticMode() {
        editHeroButton.setTitle("Edit Hero", forState: UIControlState.Normal)
        tableEditState = false
        heroNameTextField.enabled = false
        heroNumberTextField.enabled = false
        heroDetailTable.reloadData()
    }
    
    func setViewToEditMode() {
        editHeroButton.setTitle("Save", forState: UIControlState.Normal)
        tableEditState = true
        heroNameTextField.enabled = true
        heroNumberTextField.enabled = true
        heroDetailTable.reloadData()
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
}
