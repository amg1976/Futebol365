//
//  DetailViewController.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var item: FPTGame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = item?.description
    }

}
