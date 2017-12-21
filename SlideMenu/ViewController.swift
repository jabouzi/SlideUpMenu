//
//  ViewController.swift
//  PullDownSample
//
//  Created by Dinesh Kumar on 15/08/16.
//  Copyright © 2016 Organization. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Create a lazy table view
    lazy var pullDownTableView : TableView = {
        let pullDownTableView = TableView(frame:self.view.frame)
        pullDownTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell_id")
        pullDownTableView.delegate = self
        pullDownTableView.dataSource = self
        pullDownTableView.rowHeight = 80.0
        pullDownTableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return pullDownTableView
    }()
    
    // 3. Gesture Handling
    private(set) lazy var swipeDownGesture: UISwipeGestureRecognizer = {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipeGestures(_:)))
        swipeGesture.direction = .Down
        return swipeGesture
    }()
    private(set) lazy var swipeUpGesture: UISwipeGestureRecognizer = {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipeGestures(_:)))
        swipeGesture.direction = .Up
        return swipeGesture
    }()
    
    func handleSwipeGestures(sender : UISwipeGestureRecognizer) {
        setMainViewExpanded(sender.direction == .Down, animated: true)
    }
    
    func setMainViewExpanded(expanded: Bool, animated: Bool) {
        let topInset = pullDownTableView.contentInset.top
        let yOffset = expanded ? -topInset : -topOffset
        pullDownTableView.setContentOffset(CGPointMake(0, yOffset), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(swipeUpGesture)
        view.addGestureRecognizer(swipeDownGesture)
        
        // Create and add the pull down table view
        self.view.addSubview(pullDownTableView)
        
        //Set background color to contrasting color
        view.backgroundColor = UIColor.darkGrayColor()
        pullDownTableView.backgroundColor = UIColor.clearColor()
        
    }
    
    // 2.
    var topOffset: CGFloat = 0.0
    private let kTopWindowAspectRatio : CGFloat = 3.0/4.0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Calculate the top offset and set it if not corectly set
        if(topOffset != CGRectGetWidth(pullDownTableView.bounds) * kTopWindowAspectRatio) {
            topOffset = CGRectGetWidth(pullDownTableView.bounds) * kTopWindowAspectRatio
            // Setup table view insets and offsets
            let topInset = CGRectGetHeight(pullDownTableView.bounds)
            pullDownTableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
            pullDownTableView.contentOffset = CGPointMake(0, -topOffset)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("cell_id")!
    }
}

extension ViewController : UIScrollViewDelegate,UITableViewDelegate {
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yInset = scrollView.contentInset.top
        
        if scrollView.contentOffset.y > -topOffset && targetContentOffset.memory.y < -topOffset {
            targetContentOffset.memory.y = scrollView.contentOffset.y
            scrollView.setContentOffset(CGPointMake(0, -topOffset), animated: true)
        }
        else if  -topOffset > targetContentOffset.memory.y   && targetContentOffset.memory.y > (-topOffset + (topOffset - yInset)/2) {
            targetContentOffset.memory.y = scrollView.contentOffset.y
            scrollView.setContentOffset(CGPointMake(0, -topOffset), animated: true)
            
        }
        else if   (-topOffset + (topOffset - yInset)/2) > targetContentOffset.memory.y {
            targetContentOffset.memory.y = scrollView.contentOffset.y
            scrollView.setContentOffset(CGPointMake(0, -yInset), animated: true)
        }
    }
}

class TableView: UITableView {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return subviews.first?.hitTest(point, withEvent: event)
    }
}
