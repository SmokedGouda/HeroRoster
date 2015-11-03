//
//  HeroModel.swift
//  HeroRosterApp
//
//  Created by Craig Carlson on 11/3/15.
//  Copyright © 2015 Craig Carlson. All rights reserved.
//

import Foundation

struct HeroStats {
    let heroClass = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Gunslinger", "Magus", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]
    let race = ["Dwarf", "Elf", "Gnome", "Half-Elf", "Half-Orc", "Halfling", "Human"]
    let gender = ["Male", "Female"]
    let level = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
}



class Hero {
    var name: String
    var number: String
    var heroClass: String
    var race: String
    var gender: String
    var level: String
    var log = [SessionLog]()
    var usedLogNames = [String]()
    
    init(name: String, number: String, heroClass: String, race: String, gender: String, level: String) {
        self.name = name
        self.number = number
        self.heroClass = heroClass
        self.race = race
        self.gender = gender
        self.level = level
    }
    
    func addSessionLog(logToAdd: SessionLog) {
        if usedLogNames.contains(logToAdd.name) == true {
            print("That log name already exists.  Please choose another")
        } else {
            log.append(logToAdd)
            usedLogNames.append(logToAdd.name)
        }
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
    }
}

class SessionLog {
    var name: String
    var date: String
    var notes: String
    
    init(name: String, date: String, notes: String) {
        self.name = name
        self.date = date
        self.notes = notes
    }
}

class Roster {
    var userName: String
    var heros = [Hero]()
    var usedHeroNames = [String]()
    
    init(userName: String) {
        self.userName = userName
    }
    
    func addHeroToRoster(heroToAdd: Hero) {
        if usedHeroNames.contains(heroToAdd.name) == true {
            print("That hero names already exists.  Please choose another")
        } else {
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
        let currentHeroName = heroToUpdate.name
        heroToUpdate.name = newName
        heroToUpdate.number = newNumber
        heroToUpdate.heroClass = newHeroClass
        heroToUpdate.race = newRace
        heroToUpdate.gender = newGender
        heroToUpdate.level = newLevel
        
        if currentHeroName != heroToUpdate.name {
            print("I'm updating the usedHeroNames array by removing \(currentHeroName) and replacing it with \(newName)")
            for (index, value) in usedHeroNames.enumerate() {
                if currentHeroName == value {
                    usedHeroNames.removeAtIndex(index)
                }
            }
            usedHeroNames.append(newName)
        }
        return heroToUpdate
    }
    
}

