//
//  ViewController.swift
//  DOCheckbox
//
//  Created by Daiki Okumura on 2015/05/16.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//

import UIKit

class ParentViewController: UITableViewController, UITextFieldDelegate  {
    
    var style: DOCheckboxStyle = .default
    
    var actionMap: [[(_ selectedIndexPath: IndexPath) -> Void]] {
        return [
            // Alert style alerts.
            [
                self.showDefault,
                self.showSquare,
                self.showSquareFill,
                self.showRoundedSquare,
                self.showRoundedSquareFill,
                self.showCircle,
                self.showCircleFill
            ],
            // Action sheet style alerts.
            [
                self.showSquare
            ]
        ]
    }
    
    func showDefault(_: IndexPath) {
        self.style = .default
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showSquare(_: IndexPath) {
        self.style = .square
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showSquareFill(_: IndexPath) {
        self.style = .filledSquare
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showRoundedSquare(_: IndexPath) {
        self.style = .roundedSquare
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showRoundedSquareFill(_: IndexPath) {
        self.style = .filledRoundedSquare
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showCircle(_: IndexPath) {
        self.style = .circle
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    func showCircleFill(_: IndexPath) {
        self.style = .filledCircle
        self.performSegue(withIdentifier: "showChildView", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "showChildView") {
            let childViewController = segue.destination as! ChildViewController
            childViewController.style = self.style
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let action = actionMap[indexPath.section][indexPath.row]
        
        action(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
