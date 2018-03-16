//
//  ViewController.swift
//  BallBreakerMini
//
//  Created by Eduard Lev on 3/15/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var panGesture: UIPanGestureRecognizer!
    var itemBehavior: UIDynamicItemBehavior!
    var gamesLost: Int = 0

    @IBOutlet weak var gamesLostLabelOutlet: UILabel!
    @IBOutlet weak var paddleBarOutlet: UIView!
    @IBOutlet weak var ballOutlet: UIView!
    @IBOutlet weak var paddleBarFrameView: UIView!
    @IBOutlet weak var startGameButtonOutlet: UIButton!
    @IBOutlet weak var resetGameButtonOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        gamesLostLabelOutlet.text = String(gamesLost)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        paddleBarOutlet.addGestureRecognizer(panGesture)
    }

    @IBAction func startGameDidTouchUpInside(_ sender: UIButton) {
        startGame()
        sender.isHidden = true
    }

    @IBAction func resetGameButtonAction(_ sender: UIButton) {
        resetGame()
        sender.isHidden = true
    }

    func startGame() {
        // Creates animator
        animator = UIDynamicAnimator(referenceView: view)
        let push = UIPushBehavior(items: [ballOutlet], mode: UIPushBehaviorMode.instantaneous)
        push.active = true
        push.magnitude = 0.1
        push.angle = 2.2
        animator.addBehavior(push)

        // Creates collision and adds ball, as well as defines a boundary frame
        collision = UICollisionBehavior(items: [ballOutlet])
        collision.collisionDelegate = self
        createFrameCollisionBoundaries()
        collision.addBoundary(withIdentifier: "paddleBar" as NSCopying,
                              for: UIBezierPath(rect: paddleBarOutlet.frame))
        animator.addBehavior(collision)

        itemBehavior = UIDynamicItemBehavior(items: [ballOutlet])
        itemBehavior.friction = 0
        itemBehavior.elasticity = 1
        itemBehavior.resistance = 0
        itemBehavior.density = 0.5
        animator.addBehavior(itemBehavior)
    }

    func createFrameCollisionBoundaries() {
        collision.addBoundary(withIdentifier: "leftGameFrame" as NSCopying,
                              for: UIBezierPath(rect: CGRect(x: 1.0,
                                                             y: 0.0,
                                                             width: 1.0,
                                                             height: self.view.frame.size.height)))
        collision.addBoundary(withIdentifier: "rightGameFrame" as NSCopying,
                              for: UIBezierPath(rect: CGRect(x: self.view.frame.size.width-1,
                                                             y: 0,
                                                             width: 1,
                                                             height: self.view.frame.size.height)))
        collision.addBoundary(withIdentifier: "bottomGameFrame" as NSCopying,
                              for: UIBezierPath(rect: CGRect(x: 0,
                                                             y: self.view.frame.size.height-1,
                                                             width: self.view.frame.size.width,
                                                             height: 1)))
        collision.addBoundary(withIdentifier: "topGameFrame" as NSCopying,
                              for: UIBezierPath(rect: CGRect(x: 0.0,
                                                             y: 0.0,
                                                         width: self.view.frame.size.width,
                                                        height: 1.0)))
    }

    func resetGame() {
        gamesLost += 1
        gamesLostLabelOutlet.text = String(gamesLost)
        startGameButtonOutlet.isHidden = false
        resetViews()
    }

    func resetViews() {
        animator.removeAllBehaviors()
        ballOutlet.frame = CGRect(x: self.view.frame.size.width/2 - ballOutlet.frame.size.width/2,
                                  y: 0+self.view.safeAreaInsets.top, width: 20, height: 20)
    }

    @objc func handlePanGesture() {
        print("handle Pan Gesture called")
        print(NSStringFromCGPoint(panGesture.translation(in: paddleBarFrameView)))
        let deltaX = panGesture.translation(in: view).x

        if checkPaddleBarWillBeInBounds(deltaX) {
            paddleBarOutlet.center.x += deltaX
            if collision != nil {
                updatePaddleBarBoundary()
            }
        }
        panGesture.setTranslation(CGPoint(), in: paddleBarFrameView)
    }

    func updatePaddleBarBoundary() {
        collision.removeBoundary(withIdentifier: "paddleBar" as NSCopying)
        collision.addBoundary(withIdentifier: "paddleBar" as NSCopying,
                              for: UIBezierPath(rect: paddleBarOutlet.frame))
    }

    func checkPaddleBarWillBeInBounds(_ delta: CGFloat) -> Bool {
        let newOriginX = paddleBarOutlet.frame.origin.x + delta
        let newEndX = newOriginX + paddleBarOutlet.frame.size.width

        let leftBoundary = paddleBarFrameView.frame.origin.x
        let rightBoundary = paddleBarFrameView.frame.origin.x + paddleBarFrameView.frame.size.width

        if leftBoundary ... rightBoundary ~= newOriginX && leftBoundary...rightBoundary ~= newEndX {
            return true
        } else {
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollisionBehaviorDelegate {

    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem,
                           withBoundaryIdentifier identifier: NSCopying?, at point: CGPoint) {

        guard let identifier = identifier else { return }
        let string = identifier as! String // swiftlint:disable:this force_cast

        if string == "bottomGameFrame" {
            resetGameButtonOutlet.isHidden = false
        }
    }
}
