//
//  LayoutGuideVC.swift
//  WHC_Layout
//
//  Created by WHC on 2018/1/18.
//  Copyright © 2018年 WHC. All rights reserved.
//

import UIKit

class LayoutGuideVC: UIViewController {
    
    private lazy var view1 = UIView()
    private lazy var view2 = UIView()
    private lazy var view3 = UIView()
    
    private lazy var guide1 = UILayoutGuide()
    private lazy var guide2 = UILayoutGuide()
    private lazy var guide3 = UILayoutGuide()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "UILayoutGuide, safeAreaLayoutGuide"
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        make()
        guide1.whc_Top(0, true)
        .whc_Left(10, true)
        .whc_Right(10, true)
        .whc_Height(30)
        
        view1.whc_Left(10)
        .whc_Top(0, toView: guide1)
        .whc_Right(0)
        .whc_Height(50)

        guide2.whc_Left(10)
        .whc_Top(0, toView: view1)
        .whc_Right(10)
        .whc_HeightEqual(guide1)

        view2.whc_Left(10)
        .whc_Right(10)
        .whc_Top(0, toView: guide2)
        .whc_HeightEqual(view1)

        guide3.whc_Left(10)
        .whc_RightEqual(guide2)
        .whc_Top(0, toView: view2)
        .whc_HeightEqual(guide2)

        view3.whc_Left(10)
        .whc_RightEqual(view2)
        .whc_Top(0, toView: guide3)
        .whc_HeightEqual(view2)
    }

    private func make() {
        view1.backgroundColor = UIColor.red
        view2.backgroundColor = UIColor.orange
        view3.backgroundColor = UIColor.gray
        
        self.view.addSubview(view1)
        self.view.addSubview(view2)
        self.view.addSubview(view3)
        
        self.view.addLayoutGuide(guide1)
        self.view.addLayoutGuide(guide2)
        self.view.addLayoutGuide(guide3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
