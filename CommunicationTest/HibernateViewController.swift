//
//  HibernateViewController.swift
//  CommunicationTest
//
//  Created by Parrot on 31/10/19.
//  Copyright © 2019 Parrot. All rights reserved.
//

import UIKit
import WatchConnectivity

class HibernateViewController: UIViewController, WCSessionDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var lblPockemonName: UILabel!
    @IBOutlet weak var pockemonImageView: UIImageView!
    
    
    // MARK: Required WCSessionDelegate variables
    // ------------------------------------------
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //@TODO
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //@TODO
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //@TODO
    }
    
    // MARK: Receive messages from Watch
    // -----------------------------------
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let isHibernate = message["Hibernate"] as? Bool{
                if isHibernate{
                    let selectedPokemon = message["Selected_Pokemon"] as? String ?? ""
                    UserDefaults.standard.setValue(selectedPokemon, forKey: "Current_Selected_Pokemon")
                    
                    let pokemonName = message["Pokemon_Name"] as? String ?? ""
                    UserDefaults.standard.setValue(pokemonName, forKey: selectedPokemon)
                    UserDefaults.standard.synchronize()
                    
                    self.setupInfo()
                }
            }
        }
        
    }
    
    // MARK: Default ViewController functions
    // -----------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }else {
            print("Phone does not support WCSession")
        }
        
        self.setupInfo()
    }
    
    func setupInfo(){
        
        let selectedPokemon = UserDefaults.standard.value(forKey: "Current_Selected_Pokemon") as? String ?? ""
        let pokemonName = UserDefaults.standard.value(forKey: selectedPokemon) as? String ?? ""
        
        self.lblPockemonName.text = "\(pokemonName.capitalized) is hibernating"
        self.pockemonImageView.image = UIImage(named: selectedPokemon)
        
    }
    
    //MARK: - UIButton Actions
    @IBAction func wakeUpAction(_ sender: UIButton){
        
    }
}
