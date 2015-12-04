//
//  HeroModel.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import Foundation
import Parse

struct HeroStats {
    let heroClass = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Gunslinger", "Magus", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Warlock", "Wizard"]
    let race = ["Dwarf", "Elf", "Gnome", "Half-Elf", "Half-Orc", "Halfling", "Human"]
    let gender = ["Male", "Female"]
    let level = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    let faction = ["Dark Archive", "The Exchange", "Grand Lodge", "Liberty's Edge", "Scarab Sages", "Silver Crusade", "Sovereign Court", "Andoran (Retired)", "Cheliax (Retired)", "Lantern Lodge (Retired)", "Osirion (Retired)", "Qadira (Retired)", "Sczarni (Retired)", "Shadow Lodge (Retired)", "Taldor (Retired)"]
    let prestigePoints = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                        "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                        "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
                        "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
                        "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
                        "50", "51", "52", "53", "54", "55", "56", "57", "58", "59",
                        "60", "61", "62", "63", "64", "65", "66", "67", "68", "69",
                        "70", "71", "72", "73", "74", "75", "76", "77", "78", "79",
                        "80", "81", "82", "83", "84", "85", "86", "87", "88", "89",
                        "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100"]
}

struct HeroStatTableViewTitles {
    let statTitles = ["Class", "Race", "Gender", "Level", "Faction", "Prestige"]
}

class Hero {
    var name: String
    var number: String
    var heroClass: String
    var race: String
    var gender: String
    var level: String
    var faction: String
    var prestigePoints: String
    var log: [SessionLog]
    var parseObjectId: String
    var logIds: [String]
    
    init(name: String, number: String, heroClass: String, race: String, gender: String, level: String, faction: String, prestigePoints: String, log: [SessionLog], parseObjectId: String, logIds: [String]) {
        self.name = name
        self.number = number
        self.heroClass = heroClass
        self.race = race
        self.gender = gender
        self.level = level
        self.faction = faction
        self.prestigePoints = prestigePoints
        self.log = log

        self.parseObjectId = parseObjectId
        self.logIds = logIds
    }
    
    func addSessionLog(logToAdd: SessionLog) {
        log.append(logToAdd)
        if logIds.contains(logToAdd.parseObjectId) == false {
            logIds.append(logToAdd.parseObjectId)
        }
        
    }
    
    func deleteSessionLog(logToDelete: SessionLog) {
        for (index, value) in log.enumerate(){
            if logToDelete.name == value.name {
                log.removeAtIndex(index)
            }
        }
        
        for (index, value) in logIds.enumerate() {
            if logToDelete.parseObjectId == value {
                logIds.removeAtIndex(index)
            }
        }
    }
    
    func updateSessionLog(logToUpdate: SessionLog, newName: String, newDate: String, newNotes: String) -> SessionLog {
        logToUpdate.name = newName
        logToUpdate.date = newDate
        logToUpdate.notes = newNotes
        
        return logToUpdate
    }
}

class SessionLog {
    var name: String
    var date: String
    var notes: String
    var parseObjectId: String
    
    init(name: String, date: String, notes: String, parseObjectId: String) {
        self.name = name
        self.date = date
        self.notes = notes
        self.parseObjectId = parseObjectId
    }
}

class Roster {
    var userName: String
    var heros: [Hero]
    var usedHeroNames: [String]
    var scenarioRecords = [String:[String]]()
    var parseObjectId: String
    
    init(userName: String, heros: [Hero], usedHeroNames: [String], parseObjectId: String) {
        self.userName = userName
        self.heros = heros
        self.usedHeroNames = usedHeroNames
        self.parseObjectId = parseObjectId
    }
    
    func addHeroToRoster(heroToAdd: Hero) {
        if usedHeroNames.contains(heroToAdd.name) == false {
            heros.append(heroToAdd)
            usedHeroNames.append(heroToAdd.name)
        }
    }
    
    func deleteHeroFromRoster(heroToDelete: Hero) {
        
        for (index, value) in heros.enumerate(){
            if heroToDelete.name == value.name {
                heros.removeAtIndex(index)
            }
        }
        
        for (index, value) in usedHeroNames.enumerate() {
            if heroToDelete.name == value {
                usedHeroNames.removeAtIndex(index)
            }
        }
    }
    
    func updateHero(heroToUpdate: Hero, newName: String, newNumber: String, newHeroClass: String, newRace: String, newGender: String, newLevel: String, newFaction: String, newPrestigePoints: String ) -> Hero {
        heroToUpdate.name = newName
        heroToUpdate.number = newNumber
        heroToUpdate.heroClass = newHeroClass
        heroToUpdate.race = newRace
        heroToUpdate.gender = newGender
        heroToUpdate.level = newLevel
        heroToUpdate.faction = newFaction
        heroToUpdate.prestigePoints = newPrestigePoints
        
        return heroToUpdate
    }
    
    func updateScenarioRecordsOnParse(currentRoster: Roster) {
        let query = PFQuery(className: "Roster")
        query.getObjectInBackgroundWithId(currentRoster.parseObjectId) {
            (Roster: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let roster = Roster {
                roster["scenarioRecords"] = currentRoster.scenarioRecords
                roster.saveInBackground()
            }
        }
    }
}

