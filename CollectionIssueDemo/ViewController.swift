//
//  ViewController.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/13.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openCollectionView(_ sender: UIButton) {
        let vc = CollectionViewEmbeddedViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}

