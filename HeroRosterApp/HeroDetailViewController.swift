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
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backdropImage: UIImageView!
    @IBOutlet weak var openBookButton: UIBarButtonItem!
    @IBOutlet weak var heroDetailTable: UITableView!
    @IBOutlet weak var heroNameTextField: UITextField!
    @IBOutlet weak var heroNumberTextField: UITextField!
    @IBOutlet weak var addHeroButton: UIButton!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var heroNumberLabel: UILabel!
    
    var userRoster = Roster?()
    var statToDisplay: Int?
    var classDisplayed = String()
    var raceDisplayed = String()
    var genderDisplayed = String()
    var levelDisplayed = String()
    var factionDisplayed = String()
    var prestigePointsDisplayed = String()
    var temporaryStatDisplayed = String()
    
    var classIndex: Int?
    var raceIndex: Int?
    var genderIndex: Int?
    var levelIndex: Int?
    var factionIndex: Int?
    var prestigePointsIndex: Int?
    var temporaryIndex: Int?
    
    var heroDisplayed = Hero?()
    var cellTitleLabel = String()
    var createdHero: Hero?
    var activateEditMode = false
    var tableEditState = true
    var heroNameBeforeEdit = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustBordersOfUiElements()
        hideOpenBookButtonOnNavigationBar()
        if activateEditMode == true {
            switchViewForHeroDetailSettings()
            setViewToStaticMode()
            preloadTextFieldsWithCurrentHeroDetails()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroDetailTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func adjustBordersOfUiElements() {
        heroNameLabel.layer.borderColor = UIColor.blackColor().CGColor
        heroNameLabel.layer.borderWidth = 1.0
        heroNameLabel.layer.cornerRadius = 5
        heroNameLabel.clipsToBounds = true
        heroNumberLabel.layer.borderColor = UIColor.blackColor().CGColor
        heroNumberLabel.layer.borderWidth = 1.0
        heroNumberLabel.layer.cornerRadius = 5
        heroNumberLabel.clipsToBounds = true
        heroNameTextField.layer.borderColor = UIColor.blackColor().CGColor
        heroNameTextField.layer.borderWidth = 1.0
        heroNameTextField.layer.masksToBounds = true
        heroNameTextField.layer.cornerRadius = 5
        heroNumberTextField.layer.borderColor = UIColor.blackColor().CGColor
        heroNumberTextField.layer.borderWidth = 1.0
        heroNumberTextField.layer.masksToBounds = true
        heroNumberTextField.layer.cornerRadius = 5
        heroDetailTable.layer.borderColor = UIColor.blackColor().CGColor
        heroDetailTable.layer.borderWidth = 1.0
        heroDetailTable.layer.cornerRadius = 5
        addHeroButton.layer.borderColor = UIColor.blackColor().CGColor
        addHeroButton.layer.borderWidth = 1.0
        addHeroButton.layer.cornerRadius = 5
    }
    
    func hideOpenBookButtonOnNavigationBar() {
        openBookButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.0)
        openBookButton.enabled = false
    }
    
    func switchViewForHeroDetailSettings() {
        navigationItem.title = "Hero"
        openBookButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        openBookButton.enabled = true
        backgroundImage.image = UIImage(named: heroDisplayed!.heroClass+"Small")
    }
    
    func setViewToStaticMode() {
        addHeroButton.setTitle("Edit Hero", forState: UIControlState.Normal)
        tableEditState = false
        heroNameTextField.enabled = false
        heroNameTextField.alpha = 0.7
        heroNumberTextField.enabled = false
        heroNumberTextField.alpha = 0.7
        heroDetailTable.alpha = 0.7
        heroDetailTable.reloadData()
    }

    func preloadTextFieldsWithCurrentHeroDetails() {
        heroNameTextField.text = heroDisplayed?.name
        heroNumberTextField.text = heroDisplayed?.number
        heroNameBeforeEdit = heroNameTextField.text!
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
        let statTitleLabel = cell.textLabel!.text
        switch statTitleLabel! {
            case "Class":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().heroClass, statDisplayed: classDisplayed, heroDisplayedStat: heroDisplayed?.heroClass, statIndex: classIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    classDisplayed = temporaryStatDisplayed
                    classIndex = temporaryIndex
               }
            case "Race":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().race, statDisplayed: raceDisplayed, heroDisplayedStat: heroDisplayed?.race, statIndex: raceIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    raceDisplayed = temporaryStatDisplayed
                    raceIndex = temporaryIndex
               }
          
            case "Gender":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().gender, statDisplayed: genderDisplayed, heroDisplayedStat: heroDisplayed?.gender, statIndex: genderIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    genderDisplayed = temporaryStatDisplayed
                    genderIndex = temporaryIndex
                }
            
            case "Level":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().level, statDisplayed: levelDisplayed, heroDisplayedStat: heroDisplayed?.level, statIndex: levelIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    levelDisplayed = temporaryStatDisplayed
                    levelIndex = temporaryIndex
                }
            
            case "Faction":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().faction, statDisplayed: factionDisplayed, heroDisplayedStat: heroDisplayed?.faction, statIndex: factionIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    factionDisplayed = temporaryStatDisplayed
                    factionIndex = temporaryIndex
               }
            
            case "Prestige":
                displayContentsOfCell(cell, cellTextLabel: statTitleLabel!, heroStats: HeroStats().prestigePoints, statDisplayed: prestigePointsDisplayed, heroDisplayedStat: heroDisplayed?.prestigePoints, statIndex: prestigePointsIndex)
                if activateEditMode == true || cellTitleLabel == statTitleLabel {
                    prestigePointsDisplayed = temporaryStatDisplayed
                    prestigePointsIndex = temporaryIndex
               }
            
            default:
                "not a valid return"
        }
        return cell
    }
    
    func displayContentsOfCell(cell: UITableViewCell, cellTextLabel: String, heroStats: [String], var statDisplayed: String, heroDisplayedStat: String?, var statIndex: Int?) -> (String, Int?) {
        let cell = cell
        let statTitleLabel = cellTextLabel
        let buttonLabel = addHeroButton.titleLabel!.text!
        if activateEditMode == true {
            if cellTitleLabel == statTitleLabel {
                if statToDisplay != nil {
                    cell.detailTextLabel!.text = heroStats[statToDisplay!]
                }
                statIndex = statToDisplay
            } else if buttonLabel == "Save" {
                cell.detailTextLabel!.text = statDisplayed
            } else {
                cell.detailTextLabel!.text = heroDisplayedStat
                for (index, value) in heroStats.enumerate() {
                    if cell.detailTextLabel!.text == value {
                        statIndex = index
                    }
                }
            }
            cell.detailTextLabel!.hidden = false
            statDisplayed = cell.detailTextLabel!.text!
            temporaryStatDisplayed = statDisplayed
            temporaryIndex = statIndex
        } else {
            if cellTitleLabel == statTitleLabel {
                if statToDisplay != nil {
                    cell.detailTextLabel!.text = heroStats[statToDisplay!]
                } else {
                    cell.detailTextLabel!.text = ""
                }
                cell.detailTextLabel!.hidden = false
                statDisplayed = cell.detailTextLabel!.text!
                statIndex = statToDisplay
                temporaryStatDisplayed = statDisplayed
                temporaryIndex = statIndex
            }
        }
        return (temporaryStatDisplayed, temporaryIndex)
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
  
    @IBAction func addHeroButtonPressed(sender: UIButton) {
        let buttonLabel = addHeroButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Hero":
                setViewToEditMode()
            case "Save":
                if heroNameTextField.text != heroNameBeforeEdit {
                    checkEditedHeroNameAgainstUsedHeroNames()
                } else {
                    saveEditedHero()
                }
            default:
                let newHeroName = heroNameTextField.text
                let newHeroNumber = heroNumberTextField.text
                if newHeroName == "" {
                    displayNameAlert("EmptyName")
                } else if userRoster!.usedHeroNames.contains(newHeroName!) == true {
                    displayNameAlert("DuplicateName")
                } else {
                    createdHero = Hero(name: newHeroName!, number: newHeroNumber!, heroClass: classDisplayed, race: raceDisplayed, gender: genderDisplayed, level: levelDisplayed, faction: factionDisplayed, prestigePoints: prestigePointsDisplayed, log: [], parseObjectId: "", logIds: [])
                    createHeroOnParse(createdHero!)
                }
        }
    }
    
    func setViewToEditMode() {
        addHeroButton.setTitle("Save", forState: UIControlState.Normal)
        tableEditState = true
        heroNameTextField.enabled = true
        heroNameTextField.alpha = 0.8
        heroNumberTextField.enabled = true
        heroNumberTextField.alpha = 0.8
        heroDetailTable.alpha = 0.8
        heroDetailTable.reloadData()
    }
    
    func checkEditedHeroNameAgainstUsedHeroNames() {
        if userRoster!.usedHeroNames.contains(heroNameTextField.text!) == true {
            displayNameAlert("DuplicateName")
        } else {
            updateNameAssociatedWithHerosScenarioRecords()
            updateUsedHeroNamesWithTheEditedHeroName()
            updateNameAssociatedWithHerosLogs()
            userRoster?.updateScenarioRecordsOnParse(userRoster!)
            saveEditedHero()
        }
    }
    
    func displayNameAlert(alertType: String) {
        let title = "Can't save hero"
        var message = String()
        switch alertType {
            case "EmptyName":
                message = "You must provide a name for your hero in order to save it."
            case "DuplicateName":
                message = "That name has already been used.  Please choose another one."
            default:
                "No Message"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateNameAssociatedWithHerosScenarioRecords() {
        for (key, value) in userRoster!.scenarioRecords {
            if value[0] == heroNameBeforeEdit {
                userRoster!.scenarioRecords[key]![0] = heroNameTextField.text!
            }
        }
    }
    
    func updateUsedHeroNamesWithTheEditedHeroName() {
        for (index, value) in userRoster!.usedHeroNames.enumerate(){
            if heroNameBeforeEdit == value {
                userRoster!.usedHeroNames.removeAtIndex(index)
            }
        }
        userRoster!.usedHeroNames.append(heroNameTextField.text!)
        heroNameBeforeEdit = heroNameTextField.text!
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
                }
            }
        }
    }
    
    func saveEditedHero() {
        setViewToStaticMode()
        let updatedHeroName = heroNameTextField.text
        let updatedHeroNumber = heroNumberTextField.text
        userRoster?.updateHero(heroDisplayed!, newName: updatedHeroName!, newNumber: updatedHeroNumber!, newHeroClass: classDisplayed, newRace: raceDisplayed, newGender: genderDisplayed, newLevel: levelDisplayed, newFaction: factionDisplayed, newPrestigePoints: prestigePointsDisplayed)
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
            }
        }
    }

    func createHeroOnParse(heroToCreate: Hero) {
        let parseHero = PFObject(className: "Hero")
        parseHero["owner"] = userRoster!.userName
        parseHero["name"] = heroToCreate.name
        parseHero["number"] = heroToCreate.number
        parseHero["heroClass"] = heroToCreate.heroClass
        parseHero["race"] = heroToCreate.race
        parseHero["gender"] = heroToCreate.gender
        parseHero["level"] = heroToCreate.level
        parseHero["logIds"] = heroToCreate.logIds
        parseHero["faction"] = heroToCreate.faction
        parseHero["prestigePoints"] = heroToCreate.prestigePoints
        parseHero.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if (success) {
                dispatch_async(dispatch_get_main_queue()){
                    let newHeroObjectId = parseHero.objectId!
                    heroToCreate.parseObjectId = newHeroObjectId
                    self.userRoster?.addHeroToRoster(heroToCreate)
                    self.performSegueWithIdentifier("addHeroSegue", sender: self)
                }
            } else {
                print(error)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sessionTableSegue" {
            setViewToStaticMode()
            let destVC: HeroSessionLogViewController = segue.destinationViewController as! HeroSessionLogViewController
            destVC.heroDisplayed = heroDisplayed
            destVC.userRoster = userRoster
        } else if segue.identifier == "heroStatOptionsSegue" {
            let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
            let selectedIndex = heroDetailTable.indexPathForCell(sender as! UITableViewCell)
            cellTitleLabel = HeroStatTableViewTitles().statTitles[(selectedIndex?.row)!]
            destVC.navBarTitle = cellTitleLabel
            switch cellTitleLabel {
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
    
    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) {
        if(unwindSegue.sourceViewController .isKindOfClass(HeroStatOptionsViewController)) {
            let heroStat: HeroStatOptionsViewController = unwindSegue.sourceViewController as! HeroStatOptionsViewController
            statToDisplay = heroStat.chosenStat
        }
    }
}
