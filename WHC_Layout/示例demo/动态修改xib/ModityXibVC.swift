//
//  ModityXibVC.swift
//  WHC_AutoLayoutKit(Swift)
//
//  Created by WHC on 16/7/26.
//  Copyright © 2016年 WHC. All rights reserved.
//

/*********************************************************
 *  gitHub:https://github.com/netyouli/WHC_Layout *
 *  本人其他优秀开源库：https://github.com/netyouli          *
 *********************************************************/

import UIKit

class ModityXibVC: UIViewController {

    @IBOutlet weak var testView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testView.whc_Height(400)
            .whc_Width(300)
            .whc_CenterEqual(self.view)
        UIView.animate(withDuration: 1) { 
            self.view.layoutIfNeeded()
        }
        
        let txt = UILabel()
        self.view.addSubview(txt)
        txt.whc_Left(10)
        .whc_Width(100)
        .whc_LessOrEqual()
        .whc_Width(50)
        .whc_GreaterOrEqual()
        .whc_Height(30)
        .whc_Bottom(50)
        
        txt.text = "宽度"
        txt.backgroundColor = UIColor.gray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
