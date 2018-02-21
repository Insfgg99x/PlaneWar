//
//  GameViewController.swift
//  SprieKitDemo
//
//  Created by xgf on 2018/1/30.
//  Copyright © 2018年 xgf. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let skv = self.view as! SKView
        skv.showsFPS = true
        skv.showsNodeCount = true
        
        let scene = HomeScene.init(size: skv.bounds.size)
        skv.presentScene(scene)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
