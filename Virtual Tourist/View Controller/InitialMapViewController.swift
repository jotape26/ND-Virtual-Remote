//
//  InitialMapViewController.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit

class InitialMapViewController: UIViewController {

    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    
    var deleteLabelShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func editButtonClicked(_ sender: Any) {
        deleteLabelShowing = !deleteLabelShowing
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    self.labelBottomConstraint.priority = UILayoutPriority(rawValue: self.deleteLabelShowing ? 751 : 251)
                    self.view.layoutIfNeeded()
                })
            }
    }
    
}

