//
//  InterfaceController.swift
//  CommunicationTest WatchKit Extension
//
//  Created by Parrot on 2019-10-26.
//  Copyright © 2019 Parrot. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    // MARK: Outlets
    // ---------------------
    
    // Imageview for the pokemon
    @IBOutlet var pokemonImageView: WKInterfaceImage!
    // Label for Pokemon name (Albert is hungry)
    @IBOutlet var nameLabel: WKInterfaceLabel!
    // Label for other messages (HP:100, Hunger:0)
    @IBOutlet var outputLabel: WKInterfaceLabel!
    
    
    var gameUpdateTimer : Timer?
    let updateTime : Int = 5 //Seconds
    var hungerPoints : Int = 0
    var HPPoints : Int = 100
    
    // MARK: Delegate functions
    // ---------------------
    
    // Default function, required by the WCSessionDelegate on the Watch side
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //@TODO
    }
    
    // 3. Get messages from PHONE
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WATCH: Got message from Phone")
        // Message from phone comes in this format: ["course":"MADT"]
    }
    
    
    
    
    // MARK: WatchKit Interface Controller Functions
    // ----------------------------------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        // 1. Check if teh watch supports sessions
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.startTimer()
        self.setupInfo()
    }
    
    override func willDisappear() {
        super.willDisappear()
        
        self.stopTimer()
    }
    
    
    func setupInfo(){
        let selectedPokemon = UserDefaults.standard.value(forKey: "Current_Selected_Pokemon") as? String ?? ""
        let pokemonName = UserDefaults.standard.value(forKey: selectedPokemon) as? String ?? ""
        
        nameLabel.setText("\(pokemonName.capitalized) is hungry")
        pokemonImageView.setImage(UIImage(named: selectedPokemon))
        
        outputLabel.setText("HP:\((self.HPPoints < 0) ? 0 : self.HPPoints), Hunger:\((self.hungerPoints < 0) ? 0 : self.hungerPoints)")
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: Timer
    func startTimer(){
        self.stopTimer()
        gameUpdateTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(updateTime), repeats: true, block: { (timerObj) in
            self.hungerPoints += 10
            if self.hungerPoints >= 80{
                self.HPPoints -= 5
                if self.HPPoints <= 0{
                    self.presentAlert(withTitle: "Oops!!", message: "Your pokemon die due to poor health", preferredStyle: .alert, actions: [
                        WKAlertAction(title: "Okay", style: .default, handler: {
                            self.dismiss()
                        })])
                }
            }
            
            self.setupInfo()
        })
    }
    
    func stopTimer(){
        if gameUpdateTimer != nil{
            gameUpdateTimer?.invalidate()
            gameUpdateTimer = nil
        }
        
    }
    
    // MARK: Actions
    // ---------------------
    
    
    // MARK: Functions for Pokemon Parenting
    @IBAction func feedButtonPressed() {
        print("Feed button pressed")
        
        if self.hungerPoints < 12{
            self.presentAlert(withTitle: "Warning", message: "You don't have enough hunger points", preferredStyle: .alert, actions: [
                WKAlertAction(title: "Okay", style: .default, handler: {
                    
                })])
            return
        }
        
        self.hungerPoints -= 12
        self.setupInfo()
    }
    
    @IBAction func hibernateButtonPressed() {
        print("Hibernate button pressed")
        
        let selectedPokemon = UserDefaults.standard.value(forKey: "Current_Selected_Pokemon") as? String ?? ""
        let pokemonName = UserDefaults.standard.value(forKey: selectedPokemon) as? String ?? ""
        self.sendMessage(message: ["Hibernate":true,
                                   "Selected_Pokemon":selectedPokemon,
                                   "Pokemon_Name":pokemonName])
        
    }
    
    //MARK: Send Message to phone
    func sendMessage(message : [String : Any]){
        WCSession.default.sendMessage(
            message,
            replyHandler: {
                (_ replyMessage: [String: Any]) in
                print("Message sent, put something here if u are expecting a reply from the phone")
        }, errorHandler: { (error) in
            print("Error while sending message: \(error)")
        })
    }
    
}
