//
//  ViewController.swift
//  MelfImageProcess
//
//  Created by 范志勇 on 2022/10/4.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func processImage1(_ sender: UIButton) {
        let imageFileName = "bee"
        let ext = "jpg"
        
        guard let imageURL = Bundle.main.url(forResource: imageFileName, withExtension: ext) else {
            return
        }
        
        let vc = ImageProcessViewController()
        vc.origionImageURL = imageURL

        // full screen
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
}

