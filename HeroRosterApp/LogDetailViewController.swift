//
//  LogDetailViewController.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/6/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import UIKit

class LogDetailViewController: UIViewController {

    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextView!
    @IBOutlet weak var buttonText: UIButton!
    
    var heroDisplayed = Hero?()
    var heroLogDisplayed = SessionLog?()
    var sessionName = String()
    var date = String()
    var notes = String()
    var sessionLogNameBeforeEdit = String()
    var activateEditMode = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print(heroDisplayed!.name)
        
        sessionNameTextField.text = sessionName
        dateTextField.text = date
        notesTextField.text = notes
        sessionLogNameBeforeEdit = sessionNameTextField.text!
        if activateEditMode == true {
            buttonText.setTitle("Edit Log", forState: UIControlState.Normal)
            sessionNameTextField.enabled = false
            dateTextField.enabled = false
            notesTextField.editable = false
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
  
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let buttonLabel = buttonText.titleLabel!.text!
        switch buttonLabel {
            
            case "Edit Log":
                buttonText.setTitle("Save", forState: UIControlState.Normal)
                sessionNameTextField.enabled = true
                dateTextField.enabled = true
                notesTextField.editable = true
            
            case "Save":
                
                if sessionNameTextField.text != sessionLogNameBeforeEdit {
                    if heroDisplayed!.usedLogNames.contains(sessionNameTextField.text!) == true {
                        let alert = UIAlertController(
                            title: "Can't add session!", message: "That session name has already been used.  Please choose another one.", preferredStyle: .Alert)
                        let action = UIAlertAction(
                            title: "Ok", style: .Default, handler: nil)
                        alert.addAction(action)
                        presentViewController(alert, animated: true, completion: nil)
                    } else {
                        for (index, value) in heroDisplayed!.usedLogNames.enumerate(){
                            if sessionLogNameBeforeEdit == value {
                                heroDisplayed!.usedLogNames.removeAtIndex(index)
                            }
                        }
                        heroDisplayed!.usedLogNames.append(sessionNameTextField.text!)
                        print(heroDisplayed!.usedLogNames)
                        sessionLogNameBeforeEdit = sessionNameTextField.text!
                        saveEditedLog()

                    }
                } else {
                    saveEditedLog()
            }
            
            default:
                sessionName = sessionNameTextField.text!
                date = dateTextField.text!
                notes = notesTextField.text!
                let newSessionLog = SessionLog(name: sessionName, date: date, notes: notes)
                heroDisplayed?.addSessionLog(newSessionLog)
        }
    }
    
    func saveEditedLog() {
        buttonText.setTitle("Edit Log", forState: UIControlState.Normal)
        sessionNameTextField.enabled = false
        dateTextField.enabled = false
        notesTextField.editable = false
        let updatedSessionName = sessionNameTextField.text
        let updatedDate = dateTextField.text
        let updatedNotes = notesTextField.text
        heroDisplayed?.updateSessionLog(heroLogDisplayed!, newName: updatedSessionName!, newDate: updatedDate!, newNotes: updatedNotes)

        
    }

}
