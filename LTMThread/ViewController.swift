//
//  ViewController.swift
//  LTMThread
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stateLabel: UILabel!

    var thread:Thread?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init
        thread = Thread(target: self, selector: #selector(tache), object: nil)
        print("thread init")
        
        NotificationCenter.default.addObserver(self, selector:#selector(threadTermine), name:NSNotification.Name.NSThreadWillExit , object: nil)
    }
    
    // le thread va sortir
    func threadTermine() {
        print("thread Termine")
        thread = Thread(target: self, selector: #selector(tache), object: nil)
        print("thread init")
    }
    
    // le thread s'exécute ici
    func tache() {
        var cpt:Int = 0
        while(true) {
            cpt += 1
            print("cpt = \(cpt)")
            Thread.sleep(forTimeInterval: 0.1) // 100 ms
            if( thread?.isCancelled)! {
                print("thread exit")
                Thread.exit()
                return
            }
        }
    }
    
    @IBAction func startThreadButton(_ sender: UIButton) {
        guard (thread != nil) else { // contrat
            print("thread = nil")
            return
        }
        
        //start
        thread!.start()
        stateLabel.text = "start thread"
        print("start thread")
    }
    
    @IBAction func stopThreadButton(_ sender: UIButton) {
        guard (thread != nil) else {
            print("thread = nil")
            return
        }
        
        thread!.cancel()
        print("Demande d'arrêt du thread")
        stateLabel.text = "stop thread"
        
        //Thread.sleep(forTimeInterval: 1.0)
    }
}

