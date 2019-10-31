//
//  Screen2Sample.swift
//  CommunicationTest WatchKit Extension
//
//  Created by Parrot on 2019-10-31.
//  Copyright © 2019 Parrot. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

@available(watchOSApplicationExtension 6.0, *)
class Screen2Sample: WKInterfaceController, WCSessionDelegate {
    
    // MARK: Outlets
    // ---------------------
    
    // 1. Outlet for the image view
    @IBOutlet var pokemonImageView: WKInterfaceImage!
    
    // 2. Outlet for the label
    @IBOutlet var nameLabel: WKInterfaceLabel!
    
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var nameButton: WKInterfaceButton!
    
    @IBOutlet var choosePokemonGroup: WKInterfaceGroup!
    
    // MARK: Delegate functions
    // ---------------------
    
    // Default function, required by the WCSessionDelegate on the Watch side
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //@TODO
    }
    
    // 3. Get messages from PHONE
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Message from phone comes in this format: ["course":"MADT"]
        if let selectedPokemon = message["Pokemon"] as? String{
            pokemonImageView.setImage(UIImage(named: selectedPokemon))
            
            UserDefaults.standard.setValue(selectedPokemon, forKey: "Current_Selected_Pokemon")
            UserDefaults.standard.synchronize()
            
            self.nameButton.setHidden(false)
            self.choosePokemonGroup.setHidden(true)
        }
        
    }
    
    // MARK: WatchKit Interface Controller Functions
    // ----------------------------------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        // 1. Check if the watch supports sessions
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        self.nameLabel.setHidden(true)
        self.startButton.setHidden(true)
        self.nameButton.setHidden(true)
        self.choosePokemonGroup.setHidden(false)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // MARK: Actions
    @IBAction func startButtonPressed() {
        print("Start button pressed")
    }
    
    
    @IBAction func selectNameButtonPressed() {
        print("select name button pressed")
        
        self.presentTextInputController(withSuggestions: ["pikachu"], allowedInputMode: .plain) { (arrText) in
            let pockemonName = arrText?.first as? String ?? ""
            if pockemonName.isEmpty{
                self.nameLabel.setHidden(true)
                self.startButton.setHidden(true)
            }else{
                self.nameLabel.setText("My name is \(pockemonName.capitalized)!")
                
                if let selectedPokemon = UserDefaults.standard.value(forKey: "Current_Selected_Pokemon") as? String{
                    UserDefaults.standard.setValue(pockemonName, forKey: selectedPokemon)
                    UserDefaults.standard.synchronize()
                }
                
                self.nameLabel.setHidden(false)
                self.startButton.setHidden(false)
            }
        }
        
    }
    
    
    //MARK: Send Message to phone
    func sendMessage(message : [String : String]){
        WCSession.default.sendMessage(message, replyHandler: nil)
    }
    
}
