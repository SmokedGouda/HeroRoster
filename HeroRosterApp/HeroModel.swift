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
}

struct HeroStatTableViewTitles {
    let statTitles = ["Class", "Race", "Gender", "Level"]
}

class Hero {
    var name: String
    var number: String
    var heroClass: String
    var race: String
    var gender: String
    var level: String
    var log: [SessionLog]
    var usedLogNames: [String]
    var parseObjectId: String
    var logIds: [String]
    
    init(name: String, number: String, heroClass: String, race: String, gender: String, level: String, log: [SessionLog], usedLogNames: [String], parseObjectId: String, logIds: [String]) {
        self.name = name
        self.number = number
        self.heroClass = heroClass
        self.race = race
        self.gender = gender
        self.level = level
        self.log = log
        self.usedLogNames = usedLogNames
        self.parseObjectId = parseObjectId
        self.logIds = logIds
    }
    
    func addSessionLog(logToAdd: SessionLog) {
        log.append(logToAdd)
        usedLogNames.append(logToAdd.name)
        logIds.append(logToAdd.parseObjectId)
        
    }
    
    func deleteSessionLog(logToDelete: SessionLog) {
        for (index, value) in log.enumerate(){
            if logToDelete.name == value.name {
                log.removeAtIndex(index)
            }
        }
        
        for (index, value) in usedLogNames.enumerate() {
            if logToDelete.name == value {
                usedLogNames.removeAtIndex(index)
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
    
    init(userName: String, heros: [Hero], usedHeroNames: [String]) {
        self.userName = userName
        self.heros = heros
        self.usedHeroNames = usedHeroNames
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
    
    func updateHero(heroToUpdate: Hero, newName: String, newNumber: String, newHeroClass: String, newRace: String, newGender: String, newLevel: String ) -> Hero {
        heroToUpdate.name = newName
        heroToUpdate.number = newNumber
        heroToUpdate.heroClass = newHeroClass
        heroToUpdate.race = newRace
        heroToUpdate.gender = newGender
        heroToUpdate.level = newLevel
        
        return heroToUpdate
    }
}

