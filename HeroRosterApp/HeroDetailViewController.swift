//
//  HeroDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class HeroDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var heroDetailTable: UITableView!
    @IBOutlet weak var heroNameTextField: UITextField!
    @IBOutlet weak var heroNumberTextField: UITextField!
    @IBOutlet weak var editHeroButton: UIButton!
    
    var activeRoster = Roster?()
    var statToDisplay = Int()
    var classDisplayed = String()
    var raceDisplayed = String()
    var genderDisplayed = String()
    var levelDisplayed = String()
    let detailsToDisplay = HeroStatTableViewTitles()
    var heroDisplayed = Hero?()
    var cellLabel = String()
    var tableEditState = false
    var heroNameBeforeEdit = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroNameTextField.enabled = false
        heroNumberTextField.enabled = false
        
        
       
        heroNameTextField.text = heroDisplayed?.name
        heroNumberTextField.text = heroDisplayed?.number
        
        heroNameBeforeEdit = heroNameTextField.text!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        heroDetailTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("heroCell") as UITableViewCell!
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
        
        cell.textLabel!.text = detailsToDisplay.statTitles[indexPath.row]
        let statLabel = cell.textLabel!.text
        let buttonLabel = editHeroButton.titleLabel!.text!
        
        switch statLabel! {
        case "Class":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().heroClass[statToDisplay]
            } else if buttonLabel == "Save" {
                cell.detailTextLabel!.text = classDisplayed
            } else {
                cell.detailTextLabel!.text = heroDisplayed?.heroClass
            }
            cell.detailTextLabel?.hidden = false
            classDisplayed = cell.detailTextLabel!.text!

        case "Race":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().race[statToDisplay]
            } else if buttonLabel == "Save" {
                cell.detailTextLabel!.text = raceDisplayed
            } else {
                cell.detailTextLabel!.text = heroDisplayed?.race
            }
            cell.detailTextLabel?.hidden = false
            raceDisplayed = cell.detailTextLabel!.text!
          
        case "Gender":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().gender[statToDisplay]
            } else if buttonLabel == "Save" {
                cell.detailTextLabel!.text = genderDisplayed
            } else {
                cell.detailTextLabel!.text = heroDisplayed?.gender
            }
            cell.detailTextLabel?.hidden = false
            genderDisplayed = cell.detailTextLabel!.text!
            
        case "Level":
            if cellLabel == statLabel {
                cell.detailTextLabel!.text = HeroStats().level[statToDisplay]
            } else if buttonLabel == "Save"{
                cell.detailTextLabel!.text = levelDisplayed
            } else {
                cell.detailTextLabel!.text = heroDisplayed?.level
            }
            cell.detailTextLabel?.hidden = false
            levelDisplayed = cell.detailTextLabel!.text!
            
        default:
            print("not a valid return")
        }
        return cell
    }
  
    @IBAction func editHeroButtonPressed(sender: UIButton) {
        let buttonLabel = editHeroButton.titleLabel!.text!
        switch buttonLabel {
            case "Edit Hero":
                editHeroButton.setTitle("Save", forState: UIControlState.Normal)
                tableEditState = true
                heroNameTextField.enabled = true
                heroNumberTextField.enabled = true
                heroDetailTable.reloadData()
            
            default:
               
               if heroNameTextField.text != heroNameBeforeEdit {
                    if activeRoster!.usedHeroNames.contains(heroNameTextField.text!) == true {
                        let alert = UIAlertController(
                            title: "Can't edit hero!", message: "That name has already been used.  Please choose another one.", preferredStyle: .Alert)
                        let action = UIAlertAction(
                            title: "Ok", style: .Default, handler: nil)
                        alert.addAction(action)
                        presentViewController(alert, animated: true, completion: nil)
                    } else {
                        for (index, value) in activeRoster!.usedHeroNames.enumerate(){
                            if heroNameBeforeEdit == value {
                                activeRoster!.usedHeroNames.removeAtIndex(index)
                            }
                        }
                        activeRoster!.usedHeroNames.append(heroNameTextField.text!)
                        print(activeRoster!.usedHeroNames)
                        heroNameBeforeEdit = heroNameTextField.text!
                        saveEditedHero()
                    }
                } else {
                    saveEditedHero()
                }
        }
    }
    
    func saveEditedHero() {
        editHeroButton.setTitle("Edit Hero", forState: UIControlState.Normal)
        tableEditState = false
        heroNameTextField.enabled = false
        heroNumberTextField.enabled = false
        heroDetailTable.reloadData()
        let updatedHeroName = heroNameTextField.text
        let updatedHeroNumber = heroNumberTextField.text
        activeRoster?.updateHero(heroDisplayed!, newName: updatedHeroName!, newNumber: updatedHeroNumber!, newHeroClass: classDisplayed, newRace: raceDisplayed, newGender: genderDisplayed, newLevel: levelDisplayed)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // This segue will display the appropriate tableview based on which cell was touched.
        // This segue will also send the string value of the touched cell over to the next view so that the user can see which one is still active by displaying a checkmark.
        if segue.identifier == "sessionTableSegue" {
            let destVC: HeroSessionLogViewController = segue.destinationViewController as! HeroSessionLogViewController
            destVC.heroDisplayed = heroDisplayed
        }
        
        if segue.identifier == "heroStatOptionsSegueTwo" {
            let destVC: HeroStatOptionsViewController = segue.destinationViewController as! HeroStatOptionsViewController
            
            let selectedIndex = heroDetailTable.indexPathForCell(sender as! UITableViewCell)
            cellLabel = detailsToDisplay.statTitles[(selectedIndex?.row)!]
            destVC.navBarTitle = cellLabel
            switch cellLabel {
            case "Class":
                destVC.heroStatsArrayToDisplay = HeroStats().heroClass
                destVC.statFromPreviousView = classDisplayed
                
            case "Race":
                destVC.heroStatsArrayToDisplay = HeroStats().race
                destVC.statFromPreviousView = raceDisplayed
                
            case "Gender":
                destVC.heroStatsArrayToDisplay = HeroStats().gender
                destVC.statFromPreviousView = genderDisplayed
                
            case "Level":
                destVC.heroStatsArrayToDisplay = HeroStats().level
                destVC.statFromPreviousView = levelDisplayed
                
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
}
