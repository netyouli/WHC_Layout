//
//  WHC_AutoLayout.swift
//  WHC_Layout
//
//  Created by WHC on 16/7/4.
//  Copyright © 2016年 吴海超. All rights reserved.
//
//  Github <https://github.com/netyouli/WHC_Layout>

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif


#if os(iOS) || os(tvOS)
    public typealias WHC_LayoutRelation = NSLayoutRelation
    public typealias WHC_LayoutAttribute = NSLayoutAttribute
    public typealias WHC_VIEW = UIView
    public typealias WHC_COLOR = UIColor
    public typealias WHC_LayoutPriority = UILayoutPriority
#else
    public typealias WHC_LayoutRelation = NSLayoutConstraint.Relation
    public typealias WHC_LayoutAttribute = NSLayoutConstraint.Attribute
    public typealias WHC_VIEW = NSView
    public typealias WHC_COLOR = NSColor
    public typealias WHC_LayoutPriority = NSLayoutConstraint.Priority
#endif

extension WHC_VIEW {
    
    private struct WHC_LayoutAssociatedObjectKey {
        
        static var kAttributeLeft           = "WHCLayoutAttributeLeft"
        static var kAttributeLeftL          = "WHCLayoutAttributeLeftL"
        static var kAttributeLeftG          = "WHCLayoutAttributeLeftG"
        static var kAttributeRight          = "WHCLayoutAttributeRight"
        static var kAttributeRightL         = "WHCLayoutAttributeRightL"
        static var kAttributeRightG         = "WHCLayoutAttributeRightG"
        static var kAttributeTop            = "WHCLayoutAttributeTop"
        static var kAttributeTopG           = "WHCLayoutAttributeTopG"
        static var kAttributeTopL           = "WHCLayoutAttributeTopL"
        static var kAttributeBottom         = "WHCLayoutAttributeBottom"
        static var kAttributeBottomG        = "WHCLayoutAttributeBottomG"
        static var kAttributeBottomL        = "WHCLayoutAttributeBottomL"
        static var kAttributeLeading        = "WHCLayoutAttributeLeading"
        static var kAttributeLeadingG       = "WHCLayoutAttributeLeadingG"
        static var kAttributeLeadingL       = "WHCLayoutAttributeLeadingL"
        static var kAttributeTrailing       = "WHCLayoutAttributeTrailing"
        static var kAttributeTrailingG      = "WHCLayoutAttributeTrailingG"
        static var kAttributeTrailingL      = "WHCLayoutAttributeTrailingL"
        static var kAttributeWidth          = "WHCLayoutAttributeWidth"
        static var kAttributeWidthG         = "WHCLayoutAttributeWidthG"
        static var kAttributeWidthL         = "WHCLayoutAttributeWidthL"
        static var kAttributeHeight         = "WHCLayoutAttributeHeight"
        static var kAttributeHeightG        = "WHCLayoutAttributeHeightG"
        static var kAttributeHeightL        = "WHCLayoutAttributeHeightL"
        static var kAttributeCenterX        = "WHCLayoutAttributeCenterX"
        static var kAttributeCenterXG       = "WHCLayoutAttributeCenterXG"
        static var kAttributeCenterXL       = "WHCLayoutAttributeCenterXL"
        static var kAttributeCenterY        = "WHCLayoutAttributeCenterY"
        static var kAttributeCenterYG       = "WHCLayoutAttributeCenterYG"
        static var kAttributeCenterYL       = "WHCLayoutAttributeCenterYL"
        static var kAttributeLastBaselineG  = "WHCLayoutAttributeLastBaselineG"
        static var kAttributeLastBaselineL  = "WHCLayoutAttributeLastBaselineL"
        static var kAttributeLastBaseline   = "WHCLayoutAttributeLastBaseline"
        static var kAttributeFirstBaseline  = "WHCLayoutAttributeFirstBaseline"
        static var kAttributeFirstBaselineL = "WHCLayoutAttributeFirstBaselineL"
        static var kAttributeFirstBaselineG = "WHCLayoutAttributeFirstBaselineG"
        
        static var kCurrentConstraints     = "kCurrentConstraints"
    }
    
    /// 当前添加的约束对象
    private var currentConstraint: NSLayoutConstraint! {
        set {
            objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kCurrentConstraints, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let value = objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kCurrentConstraints)
            if value != nil {
                return value as! NSLayoutConstraint
            }
            return nil
        }
    }
    
    //MARK: - 移除约束 -
    
    /// 获取约束对象视图
    ///
    /// - Parameter constraint: 约束对象
    /// - Returns: 返回约束对象视图
    private func whc_MainViewConstraint(_ constraint: NSLayoutConstraint!) -> WHC_VIEW! {
        var view: WHC_VIEW!
        if constraint != nil {
            if constraint.secondAttribute == .notAnAttribute ||
                constraint.secondItem == nil {
                if let v = constraint.firstItem as? WHC_VIEW {
                    view = v
                }
            }else if constraint.firstAttribute == .notAnAttribute ||
                constraint.firstItem == nil {
                if let v = constraint.secondItem as? WHC_VIEW {
                    view = v
                }
            }else {
                let firstItem = constraint.firstItem as? WHC_VIEW
                let secondItem = constraint.secondItem as? WHC_VIEW
                if let sameSuperView = mainSuperView(view1: secondItem, view2: firstItem) {
                    view = sameSuperView
                }else if let sameSuperView = mainSuperView(view1: firstItem, view2: secondItem) {
                    view = sameSuperView
                }else {
                    view = secondItem
                }
            }
        }
        return view
    }
    
    
    /// 通用移除视图约束
    ///
    /// - Parameters:
    ///   - attribute: 约束属性
    ///   - mainView: 主视图
    private func whc_CommonRemoveConstraint(_ attribute: WHC_LayoutAttribute, mainView: WHC_VIEW!, to: WHC_VIEW!) {
        switch (attribute) {
        case .firstBaseline:
            if let constraint = self.firstBaselineConstraint() {
                removeCache(constraint: constraint).setFirstBaselineConstraint(nil)
            }
            if let constraint = self.firstBaselineLessConstraint() {
                removeCache(constraint: constraint).setFirstBaselineLessConstraint(nil)
            }
            if let constraint = self.firstBaselineGreaterConstraint() {
                removeCache(constraint: constraint).setFirstBaselineGreaterConstraint(nil)
            }
        case .lastBaseline:
            if let constraint = self.lastBaselineConstraint() {
                removeCache(constraint: constraint).setLastBaselineConstraint(nil)
            }
            if let constraint = self.lastBaselineLessConstraint() {
                removeCache(constraint: constraint).setLastBaselineLessConstraint(nil)
            }
            if let constraint = self.lastBaselineGreaterConstraint() {
                removeCache(constraint: constraint).setLastBaselineGreaterConstraint(nil)
            }
        case .centerY:
            if let constraint = self.centerYConstraint() {
                removeCache(constraint: constraint).setCenterYConstraint(nil)
            }
            if let constraint = self.centerYLessConstraint() {
                removeCache(constraint: constraint).setCenterYLessConstraint(nil)
            }
            if let constraint = self.centerYGreaterConstraint() {
                removeCache(constraint: constraint).setCenterYGreaterConstraint(nil)
            }
        case .centerX:
            if let constraint = self.centerXConstraint() {
                removeCache(constraint: constraint).setCenterXConstraint(nil)
            }
            if let constraint = self.centerXLessConstraint() {
                removeCache(constraint: constraint).setCenterXLessConstraint(nil)
            }
            if let constraint = self.centerXGreaterConstraint() {
                removeCache(constraint: constraint).setCenterXGreaterConstraint(nil)
            }
        case .trailing:
            if let constraint = self.trailingConstraint() {
                removeCache(constraint: constraint).setTrailingConstraint(nil)
            }
            if let constraint = self.trailingLessConstraint() {
                removeCache(constraint: constraint).setTrailingLessConstraint(nil)
            }
            if let constraint = self.trailingGreaterConstraint() {
                removeCache(constraint: constraint).setTrailingGreaterConstraint(nil)
            }
        case .leading:
            if let constraint = self.leadingConstraint() {
                removeCache(constraint: constraint).setLeadingConstraint(nil)
            }
            if let constraint = self.leadingLessConstraint() {
                removeCache(constraint: constraint).setLeadingLessConstraint(nil)
            }
            if let constraint = self.leadingGreaterConstraint() {
                removeCache(constraint: constraint).setLeadingGreaterConstraint(nil)
            }
        case .bottom:
            if let constraint = self.bottomConstraint() {
                removeCache(constraint: constraint).setBottomConstraint(nil)
            }
            if let constraint = self.bottomLessConstraint() {
                removeCache(constraint: constraint).setBottomLessConstraint(nil)
            }
            if let constraint = self.bottomGreaterConstraint() {
                removeCache(constraint: constraint).setBottomGreaterConstraint(nil)
            }
        case .top:
            if let constraint = self.topConstraint() {
                removeCache(constraint: constraint).setTopConstraint(nil)
            }
            if let constraint = self.topLessConstraint() {
                removeCache(constraint: constraint).setTopLessConstraint(nil)
            }
            if let constraint = self.topGreaterConstraint() {
                removeCache(constraint: constraint).setTopGreaterConstraint(nil)
            }
        case .right:
            if let constraint = self.rightConstraint() {
                removeCache(constraint: constraint).setRightConstraint(nil)
            }
            if let constraint = self.rightLessConstraint() {
                removeCache(constraint: constraint).setRightLessConstraint(nil)
            }
            if let constraint = self.rightGreaterConstraint() {
                removeCache(constraint: constraint).setRightGreaterConstraint(nil)
            }
        case .left:
            if let constraint = self.leftConstraint() {
                removeCache(constraint: constraint).setLeftConstraint(nil)
            }
            if let constraint = self.leftLessConstraint() {
                removeCache(constraint: constraint).setLeftLessConstraint(nil)
            }
            if let constraint = self.leftGreaterConstraint() {
                removeCache(constraint: constraint).setLeftGreaterConstraint(nil)
            }
        case .width:
            if let constraint = self.widthConstraint() {
                removeCache(constraint: constraint).setWidthConstraint(nil)
            }
            if let constraint = self.widthLessConstraint() {
                removeCache(constraint: constraint).setWidthLessConstraint(nil)
            }
            if let constraint = self.widthGreaterConstraint() {
                removeCache(constraint: constraint).setWidthGreaterConstraint(nil)
            }
        case .height:
            if let constraint = self.heightConstraint() {
                removeCache(constraint: constraint).setHeightConstraint(nil)
            }
            if let constraint = self.heightLessConstraint() {
                removeCache(constraint: constraint).setHeightLessConstraint(nil)
            }
            if let constraint = self.heightGreaterConstraint() {
                removeCache(constraint: constraint).setHeightGreaterConstraint(nil)
            }
        default:
            break;
        }
        mainView?.constraints.forEach({ (constraint) in
            if let linkView = (to != nil ? to : mainView) {
                if (constraint.firstItem === self && constraint.firstAttribute == attribute && (constraint.secondItem === linkView || constraint.secondItem == nil)) || (constraint.firstItem === linkView && constraint.secondItem === self && constraint.secondAttribute == attribute) {
                    mainView.removeConstraint(constraint)
                }
            }
        })
    }
    
    
    /// 遍历视图约束并删除指定约束约束
    ///
    /// - Parameters:
    ///   - attr: 约束属性
    ///   - view: 约束视图
    ///   - removeSelf: 是否删除自身约束
    private func whc_SwitchRemoveAttr(_ attr: WHC_LayoutAttribute, view: WHC_VIEW!, to: WHC_VIEW!,  removeSelf: Bool) {
        #if os(iOS) || os(tvOS)
            switch (attr) {
            case .leftMargin,
                 .rightMargin,
                 .topMargin,
                 .bottomMargin,
                 .leadingMargin,
                 .trailingMargin,
                 .centerXWithinMargins,
                 .centerYWithinMargins,
                 
                 .firstBaseline,
                 .lastBaseline,
                 .centerY,
                 .centerX,
                 .trailing,
                 .leading,
                 .bottom,
                 .top,
                 .right,
                 .left:
                self.whc_CommonRemoveConstraint(attr, mainView: view, to: to)
            case .width,
                 .height:
                if removeSelf {
                    self.whc_CommonRemoveConstraint(attr, mainView: self, to: to)
                }
                self.whc_CommonRemoveConstraint(attr, mainView: view, to: to)
            default:
                break;
            }
        #else
            switch (attr) {
            case .firstBaseline,
                 .lastBaseline,
                 .centerY,
                 .centerX,
                 .trailing,
                 .leading,
                 .bottom,
                 .top,
                 .right,
                 .left:
                self.whc_CommonRemoveConstraint(attr, mainView: view, to: to)
            case .width,
                 .height:
                if removeSelf {
                    self.whc_CommonRemoveConstraint(attr, mainView: self, to: to)
                }
                self.whc_CommonRemoveConstraint(attr, mainView: view, to: to)
            default:
                break;
            }
            
        #endif
        
    }
    
    
    /// 重置视图约束（删除自身与其他视图关联的约束）
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_ResetConstraints() -> WHC_VIEW {
        if let constraint = self.firstBaselineConstraint() {
            removeCache(constraint: constraint).setFirstBaselineConstraint(nil)
        }
        if let constraint = self.firstBaselineLessConstraint() {
            removeCache(constraint: constraint).setFirstBaselineLessConstraint(nil)
        }
        if let constraint = self.firstBaselineGreaterConstraint() {
            removeCache(constraint: constraint).setFirstBaselineGreaterConstraint(nil)
        }
        
        
        if let constraint = self.lastBaselineConstraint() {
            removeCache(constraint: constraint).setLastBaselineConstraint(nil)
        }
        if let constraint = self.lastBaselineLessConstraint() {
            removeCache(constraint: constraint).setLastBaselineLessConstraint(nil)
        }
        if let constraint = self.lastBaselineGreaterConstraint() {
            removeCache(constraint: constraint).setLastBaselineGreaterConstraint(nil)
        }
        
        
        if let constraint = self.centerYConstraint() {
            removeCache(constraint: constraint).setCenterYConstraint(nil)
        }
        if let constraint = self.centerYLessConstraint() {
            removeCache(constraint: constraint).setCenterYLessConstraint(nil)
        }
        if let constraint = self.centerYGreaterConstraint() {
            removeCache(constraint: constraint).setCenterYGreaterConstraint(nil)
        }
        
        
        if let constraint = self.centerXConstraint() {
            removeCache(constraint: constraint).setCenterXConstraint(nil)
        }
        if let constraint = self.centerXLessConstraint() {
            removeCache(constraint: constraint).setCenterXLessConstraint(nil)
        }
        if let constraint = self.centerXGreaterConstraint() {
            removeCache(constraint: constraint).setCenterXGreaterConstraint(nil)
        }
        
        
        if let constraint = self.trailingConstraint() {
            removeCache(constraint: constraint).setTrailingConstraint(nil)
        }
        if let constraint = self.trailingLessConstraint() {
            removeCache(constraint: constraint).setTrailingLessConstraint(nil)
        }
        if let constraint = self.trailingGreaterConstraint() {
            removeCache(constraint: constraint).setTrailingGreaterConstraint(nil)
        }
        
        
        if let constraint = self.leadingConstraint() {
            removeCache(constraint: constraint).setLeadingConstraint(nil)
        }
        if let constraint = self.leadingLessConstraint() {
            removeCache(constraint: constraint).setLeadingLessConstraint(nil)
        }
        if let constraint = self.leadingGreaterConstraint() {
            removeCache(constraint: constraint).setLeadingGreaterConstraint(nil)
        }
        
        
        if let constraint = self.bottomConstraint() {
            removeCache(constraint: constraint).setBottomConstraint(nil)
        }
        if let constraint = self.bottomLessConstraint() {
            removeCache(constraint: constraint).setBottomLessConstraint(nil)
        }
        if let constraint = self.bottomGreaterConstraint() {
            removeCache(constraint: constraint).setBottomGreaterConstraint(nil)
        }
        
        
        if let constraint = self.topConstraint() {
            removeCache(constraint: constraint).setTopConstraint(nil)
        }
        if let constraint = self.topLessConstraint() {
            removeCache(constraint: constraint).setTopLessConstraint(nil)
        }
        if let constraint = self.topGreaterConstraint() {
            removeCache(constraint: constraint).setTopGreaterConstraint(nil)
        }
        
        
        if let constraint = self.rightConstraint() {
            removeCache(constraint: constraint).setRightConstraint(nil)
        }
        if let constraint = self.rightLessConstraint() {
            removeCache(constraint: constraint).setRightLessConstraint(nil)
        }
        if let constraint = self.rightGreaterConstraint() {
            removeCache(constraint: constraint).setRightGreaterConstraint(nil)
        }

        
        if let constraint = self.leftConstraint() {
            removeCache(constraint: constraint).setLeftConstraint(nil)
        }
        if let constraint = self.leftLessConstraint() {
            removeCache(constraint: constraint).setLeftLessConstraint(nil)
        }
        if let constraint = self.leftGreaterConstraint() {
            removeCache(constraint: constraint).setLeftGreaterConstraint(nil)
        }
        
        
        if let constraint = self.widthConstraint() {
            removeCache(constraint: constraint).setWidthConstraint(nil)
        }
        if let constraint = self.widthLessConstraint() {
            removeCache(constraint: constraint).setWidthLessConstraint(nil)
        }
        if let constraint = self.widthGreaterConstraint() {
            removeCache(constraint: constraint).setWidthGreaterConstraint(nil)
        }
        
        
        if let constraint = self.heightConstraint() {
            removeCache(constraint: constraint).setHeightConstraint(nil)
        }
        if let constraint = self.heightLessConstraint() {
            removeCache(constraint: constraint).setHeightLessConstraint(nil)
        }
        if let constraint = self.heightGreaterConstraint() {
            removeCache(constraint: constraint).setHeightGreaterConstraint(nil)
        }
        return self
    }
    
    
    /// 清除自身与其他视图关联的所有约束
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_ClearConstraints() -> WHC_VIEW {
        autoreleasepool {
            var constraints = self.constraints
            for constraint in constraints {
                if constraint.firstItem === self &&
                    constraint.secondAttribute == .notAnAttribute {
                    self.removeConstraint(constraint)
                }
            }
            let superView = self.superview
            if superView != nil {
                constraints = superView!.constraints
                for constraint in constraints {
                    if constraint.firstItem === self ||
                        constraint.secondItem === self {
                        superView!.removeConstraint(constraint)
                    }
                }
            }
        }
        self.whc_ResetConstraints()
        return self
    }
    
    
    /// 移除与指定视图指定的相关约束集合
    ///
    /// - Parameters:
    ///   - view: 指定视图
    ///   - attrs: 约束属性集合
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_RemoveFrom(_ view: WHC_VIEW!, attrs:WHC_LayoutAttribute ...) -> WHC_VIEW {
        for attr in attrs {
            if attr != .notAnAttribute {
                self.whc_SwitchRemoveAttr(attr, view: view, to: nil ,removeSelf: false)
            }
        }
        return self
    }
    
    
    /// 移除与指定关联视图的约束
    ///
    /// - Parameters:
    ///   - view: 关联的视图
    ///   - attrs: 要移除的集合
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_RemoveTo(_ view: WHC_VIEW!, attrs:WHC_LayoutAttribute ...) -> WHC_VIEW {
        for attr in attrs {
            if attr != .notAnAttribute {
                self.whc_SwitchRemoveAttr(attr, view: self.superview, to: view ,removeSelf: false)
            }
        }
        return self
    }
    
    /// 移除与自身或者父视图指定的相关约束集合
    ///
    /// - Parameter attrs: 约束属性集合
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_RemoveAttrs(_ attrs: WHC_LayoutAttribute ...) -> WHC_VIEW {
        for attr in attrs {
            if attr != .notAnAttribute {
                self.whc_SwitchRemoveAttr(attr, view: self.superview, to: nil, removeSelf: true)
            }
        }
        return self
    }
    
    //MARK: - 设置当前约束优先级 -
    
    
    /// 修改视图约束优先级
    ///
    /// - Parameter priority: 约束优先级
    /// - Returns: 返回当前视图
    @discardableResult
    private func whc_HandleConstraints(priority: WHC_LayoutPriority) -> WHC_VIEW {
        if let constraints = self.currentConstraint, constraints.priority != priority {
            if constraints.priority == WHC_LayoutPriority.required {
                if let mainView = whc_MainViewConstraint(constraints) {
                    let tmpConstraints = NSLayoutConstraint(item: constraints.firstItem!, attribute: constraints.firstAttribute, relatedBy: constraints.relation, toItem: constraints.secondItem, attribute: constraints.secondAttribute, multiplier: constraints.multiplier, constant: constraints.constant)
                    tmpConstraints.priority = priority
                    mainView.removeConstraint(constraints)
                    mainView.addConstraint(tmpConstraints)
                    self.currentConstraint = tmpConstraints
                    self.setCacheConstraint(nil, attribute: constraints.firstAttribute, relation: constraints.relation)
                    self.setCacheConstraint(tmpConstraints, attribute: tmpConstraints.firstAttribute, relation: tmpConstraints.relation)
                }
            }else {
                constraints.priority = priority
            }
        }
        return self
    }
    
    private func whc_HandleConstraintsRelation(_ relation: WHC_LayoutRelation) -> WHC_VIEW {
        if let constraints = self.currentConstraint, constraints.relation != relation {
            let tmpConstraints = NSLayoutConstraint(item: constraints.firstItem ?? 0, attribute: constraints.firstAttribute, relatedBy: relation, toItem: constraints.secondItem, attribute: constraints.secondAttribute, multiplier: constraints.multiplier, constant: constraints.constant)
            if let mainView = whc_MainViewConstraint(constraints) {
                mainView.removeConstraint(constraints)
                self.setCacheConstraint(nil, attribute: constraints.firstAttribute, relation: constraints.relation)
                mainView.addConstraint(tmpConstraints)
                self.setCacheConstraint(tmpConstraints, attribute: tmpConstraints.firstAttribute, relation: tmpConstraints.relation)
                self.currentConstraint = tmpConstraints
            }
        }
        return self
    }
    
    
    /// 设置当前约束小于等于
    ///
    /// - Returns: 当前视图
    @discardableResult
    public func whc_LessOrEqual() -> WHC_VIEW {
        return whc_HandleConstraintsRelation(.lessThanOrEqual)
    }
    
    /// 设置当前约束大于等于
    ///
    /// - Returns: 当前视图
    @discardableResult
    public func whc_GreaterOrEqual() -> WHC_VIEW {
        return whc_HandleConstraintsRelation(.greaterThanOrEqual)
    }
    
    /// 设置当前约束的低优先级
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_PriorityLow() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            return whc_HandleConstraints(priority: .defaultLow)
        #else
            return whc_HandleConstraints(priority: .defaultLow)
        #endif
    }
    
    /// 设置当前约束的高优先级
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_PriorityHigh() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            return whc_HandleConstraints(priority: .defaultHigh)
        #else
            return whc_HandleConstraints(priority: .defaultHigh)
        #endif
    }
    
    
    /// 设置当前约束的默认优先级
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_PriorityRequired() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            return whc_HandleConstraints(priority: .required)
        #else
            return whc_HandleConstraints(priority: .required)
        #endif
    }
    
    /// 设置当前约束的合适优先级
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_PriorityFitting() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            return whc_HandleConstraints(priority: .fittingSizeLevel)
        #else
            return whc_HandleConstraints(priority: .fittingSizeCompression)
        #endif
    }
    
    /// 设置当前约束的优先级
    ///
    /// - Parameter value: 优先级大小(0-1000)
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Priority(_ value: CGFloat) -> WHC_VIEW {
        return whc_HandleConstraints(priority: WHC_LayoutPriority(Float(value)))
    }
    
    //MARK: -自动布局公开接口api -
    
    /// 设置左边距(默认相对父视图)
    ///
    /// - Parameter space: 左边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Left(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .left, constant: space)
    }
    
    /// 设置左边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 左边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Left(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.right
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .left
        }
        return self.constraintWithItem(self, attribute: .left, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: space)
    }
    
    /// 设置左边距相等指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LeftEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_LeftEqual(view, offset: 0)
    }
    
    /// 设置左边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LeftEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.left
        return self.constraintWithItem(self, attribute: .left, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: offset)
    }
    
    /// 设置右边距(默认相对父视图)
    ///
    /// - Parameter space: 右边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Right(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .right, constant: 0 - space)
    }
    
    /// 设置右边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 右边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Right(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.left
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .right
        }
        return self.constraintWithItem(self, attribute: .right, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: 0 - space)
    }
    
    /// 设置右边距相等指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_RightEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_RightEqual(view, offset: 0)
    }
    
    /// 设置右边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_RightEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.right
        return self.constraintWithItem(self, attribute: .right, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: 0.0 - offset)
    }
    
    /// 设置左边距(默认相对父视图)
    ///
    /// - Parameter space: 左边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Leading(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .leading, constant: space)
    }
    
    /// 设置左边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 左边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Leading(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.trailing
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .leading
        }
        return self.constraintWithItem(self, attribute: .leading, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: space)
    }
    
    /// 设置左边距相等指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LeadingEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_LeadingEqual(view, offset: 0)
    }
    
    /// 设置左边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LeadingEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.leading
        return self.constraintWithItem(self, attribute: .leading, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: offset)
    }
    
    /// 设置右间距(默认相对父视图)
    ///
    /// - Parameter space: 右边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Trailing(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .trailing, constant: 0.0 - space)
    }
    
    /// 设置右间距与指定视图
    ///
    /// - Parameters:
    ///   - space: 右边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Trailing(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.leading
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .trailing
        }
        return self.constraintWithItem(self, attribute: .trailing, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: 0 - space)
    }
    
    /// 设置右对齐相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_TrailingEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_TrailingEqual(view, offset: 0)
    }
    
    /// 设置右对齐相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_TrailingEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.trailing
        return self.constraintWithItem(self, attribute: .trailing, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: 0.0 - offset)
    }
    
    /// 设置顶边距(默认相对父视图)
    ///
    /// - Parameter space: 顶边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Top(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .top, constant: space)
    }
    
    /// 设置顶边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 顶边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Top(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.bottom
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .top
        }
        return self.constraintWithItem(self, attribute: .top, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: space)
    }
    
    /// 设置顶边距相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_TopEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_TopEqual(view, offset: 0)
    }
    
    /// 设置顶边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_TopEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.top
        return self.constraintWithItem(self, attribute: .top, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: offset)
    }
    
    /// 设置底边距(默认相对父视图)
    ///
    /// - Parameter space: 底边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Bottom(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .bottom, constant: 0 - space)
    }
    
    /// 设置底边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 底边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Bottom(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.top
        return self.constraintWithItem(self, attribute: .bottom, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: space)
    }
    
    /// 设置底边距相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_BottomEqual(_ view: WHC_VIEW) -> WHC_VIEW {
        return self.whc_BottomEqual(view, offset: 0)
    }
    
    /// 设置底边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_BottomEqual(_ view: WHC_VIEW, offset: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.bottom
        return self.constraintWithItem(self, attribute: .bottom, related: .equal, toItem: view, toAttribute: &toAttribute, multiplier: 1, constant: 0.0 - offset)
    }
    
    
    /// 设置宽度
    ///
    /// - Parameter width: 宽度
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Width(_ width: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.notAnAttribute
        return self.constraintWithItem(self, attribute: .width, related: .equal, toItem: nil, toAttribute: &toAttribute, multiplier: 0, constant: width)
    }
    
    /// 设置宽度相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_WidthEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .width, constant: 0)
    }
    
    /// 设置宽度按比例相等与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - ratio: 比例
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_WidthEqual(_ view: WHC_VIEW!, ratio: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .width, multiplier: ratio, constant: 0)
    }
    
    /// 设置自动宽度
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_WidthAuto() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            if let label = self as? UILabel {
                if label.numberOfLines == 0 {
                    label.numberOfLines = 1
                }
            }else if let stackView = self as? WHC_StackView {
                stackView.whc_AutoWidth = true
            }
        #endif
        if widthConstraint() != nil ||
            widthLessConstraint() != nil {
            return whc_Width(0).whc_GreaterOrEqual()
        }
        var toAttribute = WHC_LayoutAttribute.notAnAttribute
        return self.constraintWithItem(self, attribute: .width, related: .greaterThanOrEqual, toItem: nil, toAttribute: &toAttribute, multiplier: 1, constant: 0)
    }
    
    /// 设置视图自身高度与宽度的比
    ///
    /// - Parameter ratio: 比例
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_HeightWidthRatio(_ ratio: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.width
        return self.constraintWithItem(self, attribute: .height, related: .equal, toItem: self, toAttribute: &toAttribute, multiplier: ratio, constant: 0)
    }
    
    /// 设置高度
    ///
    /// - Parameter height: 高度
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Height(_ height: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(nil, attribute: .height, constant: height)
    }
    
    /// 设置高度相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_HeightEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .height, constant: 0)
    }
    
    
    /// 设置高度按比例相等与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - ratio: 比例
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_HeightEqual(_ view: WHC_VIEW!, ratio: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .height, multiplier: ratio, constant: 0)
    }
    
    /// 设置自动高度
    ///
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_HeightAuto() -> WHC_VIEW {
        #if os(iOS) || os(tvOS)
            if let label = self as? UILabel {
                if label.numberOfLines != 0 {
                    label.numberOfLines = 0
                }
            }else if let stackView = self as? WHC_StackView {
                stackView.whc_AutoHeight = true
            }
        #endif
        if heightConstraint() != nil ||
            heightLessConstraint() != nil {
            return whc_Height(0).whc_GreaterOrEqual()
        }
        var toAttribute = WHC_LayoutAttribute.notAnAttribute
        return self.constraintWithItem(self, attribute: .height, related: .greaterThanOrEqual, toItem: nil, toAttribute: &toAttribute, multiplier: 1, constant: 0)
    }
    
    /// 设置视图自身宽度与高度的比
    ///
    /// - Parameter ratio: 比例
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_WidthHeightRatio(_ ratio: CGFloat) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.height
        return self.constraintWithItem(self, attribute: .width, related: .equal, toItem: self, toAttribute: &toAttribute, multiplier: ratio, constant: 0)
    }
    
    /// 设置中心x(默认相对父视图)
    ///
    /// - Parameter x: 中心x偏移量（0与父视图中心x重合）
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterX(_ x: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .centerX, constant: x)
    }
    
    /// 设置中心x相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterXEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .centerX, constant: 0)
    }
    
    /// 设置中心x相等并偏移x与指定视图
    ///
    /// - Parameters:
    ///   - x: x偏移量（0与指定视图重合）
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterX(_ x: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(toView, attribute: .centerX, constant: x)
    }
    
    /// 设置中心y偏移(默认相对父视图)
    ///
    /// - Parameter y: 中心y坐标偏移量（0与父视图重合）
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterY(_ y: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .centerY, constant: y)
    }
    
    /// 设置中心y相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterYEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .centerY, constant: 0)
    }
    
    /// 设置中心y相等并偏移x与指定视图
    ///
    /// - Parameters:
    ///   - y: y偏移量（0与指定视图中心y重合）
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterY(_ y: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.constraintWithItem(toView, attribute: .centerY, constant: y)
    }
    
    /// 设置顶部基线边距(默认相对父视图,相当于y)
    ///
    /// - Parameter space: 顶部基线边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_FirstBaseLine(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .firstBaseline, constant: 0 - space)
    }
    
    /// 设置顶部基线边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 间距
    ///   - toView: 指定视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_FirstBaseLine(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.lastBaseline
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .firstBaseline
        }
        return self.constraintWithItem(self, attribute: .firstBaseline, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: 0 - space)
    }
    
    /// 设置顶部基线边距相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_FirstBaseLineEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_FirstBaseLineEqual(view, offset: 0)
    }
    
    /// 设置顶部基线边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_FirstBaseLineEqual(_ view: WHC_VIEW!, offset: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .firstBaseline, constant: offset)
    }
    
    /// 设置底部基线边距(默认相对父视图)
    ///
    /// - Parameter space: 间隙
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LastBaseLine(_ space: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(self.superview, attribute: .lastBaseline, constant: 0 - space)
    }
    
    /// 设置底部基线边距与指定视图
    ///
    /// - Parameters:
    ///   - space: 间距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LastBaseLine(_ space: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        var toAttribute = WHC_LayoutAttribute.firstBaseline
        if !sameSuperview(view1: toView, view2: self).1 {
            toAttribute = .lastBaseline
        }
        return self.constraintWithItem(self, attribute: .lastBaseline, related: .equal, toItem: toView, toAttribute: &toAttribute, multiplier: 1, constant: 0 - space)
    }
    
    /// 设置底部基线边距相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LastBaseLineEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_LastBaseLineEqual(view, offset: 0)
    }
    
    /// 设置底部基线边距相等并偏移与指定视图
    ///
    /// - Parameters:
    ///   - view: 相对视图
    ///   - offset: 偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_LastBaseLineEqual(_ view: WHC_VIEW!, offset: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(view, attribute: .lastBaseline, constant: 0.0 - offset)
    }
    
    /// 设置中心偏移(默认相对父视图)x,y = 0 与父视图中心重合
    ///
    /// - Parameters:
    ///   - x: 中心x偏移量
    ///   - y: 中心y偏移量
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Center(_ x: CGFloat, y: CGFloat) -> WHC_VIEW {
        return self.whc_CenterX(x).whc_CenterY(y)
    }
    
    /// 设置中心偏移x,y = 0 与指定视图中心重合
    ///
    /// - Parameters:
    ///   - x: 中心x偏移量
    ///   - y: 中心y偏移量
    ///   - toView: 指定视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Center(_ x: CGFloat, y: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_CenterX(x, toView: toView).whc_CenterY(y, toView: toView)
    }
    
    /// 设置中心相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_CenterEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_CenterXEqual(view).whc_CenterYEqual(view)
    }
    
    /// 设置frame(默认相对父视图)
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - width: 宽度
    ///   - height: 高度
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Frame(_ left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> WHC_VIEW {
        return self.whc_Left(left).whc_Top(top).whc_Width(width).whc_Height(height)
    }
    
    /// 设置frame与指定视图
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - width: 宽度
    ///   - height: 高度
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Frame(_ left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_Left(left, toView: toView).whc_Top(top, toView: toView).whc_Width(width).whc_Height(height)
    }
    
    
    /// 设置frame与view相同
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    public func whc_FrameEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_LeftEqual(view).whc_TopEqual(view).whc_SizeEqual(view)
    }
    
    /// 设置size
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - height: 高度
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_Size(_ width: CGFloat, height: CGFloat) -> WHC_VIEW {
        return self.whc_Width(width).whc_Height(height)
    }
    
    /// 设置size相等与指定视图
    ///
    /// - Parameter view: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_SizeEqual(_ view: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_WidthEqual(view).whc_HeightEqual(view)
    }
    
    /// 设置frame (默认相对父视图，宽高自动)
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - right: 右边距
    ///   - bottom: 底边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoSize(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) -> WHC_VIEW {
        return self.whc_Left(left).whc_Top(top).whc_Right(right).whc_Bottom(bottom)
    }
    
    /// 设置frame与指定视图（宽高自动）
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - right: 右边距
    ///   - bottom: 底边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoSize(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_Left(left, toView: toView).whc_Top(top, toView: toView).whc_Right(right, toView: toView).whc_Bottom(bottom, toView: toView)
    }
    
    /// 设置frame (默认相对父视图，宽度自动)
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - right: 右边距
    ///   - height: 高度
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoWidth(left: CGFloat, top: CGFloat, right: CGFloat, height: CGFloat) -> WHC_VIEW {
        return self.whc_Left(left).whc_Top(top).whc_Right(right).whc_Height(height)
    }
    
    /// 设置frame与指定视图（宽度自动）
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - right: 右边距
    ///   - height: 高度
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoWidth(left: CGFloat, top: CGFloat, right: CGFloat, height: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_Left(left, toView: toView).whc_Top(top, toView: toView).whc_Right(right, toView: toView).whc_Height(height)
    }
    
    /// 设置frame (默认相对父视图，高度自动)
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - width: 宽度
    ///   - bottom: 底边距
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoHeight(left: CGFloat, top: CGFloat, width: CGFloat, bottom: CGFloat) -> WHC_VIEW {
        return self.whc_Left(left).whc_Top(top).whc_Width(width).whc_Bottom(bottom)
    }
    
    /// 设置frame与指定视图（自动高度）
    ///
    /// - Parameters:
    ///   - left: 左边距
    ///   - top: 顶边距
    ///   - width: 宽度
    ///   - bottom: 底边距
    ///   - toView: 相对视图
    /// - Returns: 返回当前视图
    @discardableResult
    public func whc_AutoHeight(left: CGFloat, top: CGFloat, width: CGFloat, bottom: CGFloat, toView: WHC_VIEW!) -> WHC_VIEW {
        return self.whc_Left(left, toView: toView).whc_Top(top, toView: toView).whc_Width(width).whc_Bottom(bottom, toView: toView)
    }
    
    //MARK: -私有方法-
    
    private func setLeftConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setLeftConstraint(constraint)
        case .greaterThanOrEqual:
            setLeftGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setLeftLessConstraint(constraint)
        }
    }
    
    private func leftConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return leftConstraint()
        case .greaterThanOrEqual:
            return leftGreaterConstraint()
        case .lessThanOrEqual:
            return leftLessConstraint()
        }
    }
    
    private func setLeftConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeft, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leftConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeft) as? NSLayoutConstraint
    }
    
    private func setLeftLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeftL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leftLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeftL) as? NSLayoutConstraint
    }
    
    private func setLeftGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeftG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leftGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeftG) as? NSLayoutConstraint
    }
    
    private func setRightConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setRightConstraint(constraint)
        case .greaterThanOrEqual:
            setRightGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setRightLessConstraint(constraint)
        }
    }
    
    private func rightConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return rightConstraint()
        case .greaterThanOrEqual:
            return rightGreaterConstraint()
        case .lessThanOrEqual:
            return rightLessConstraint()
        }
    }
    
    private func setRightConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRight, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func rightConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRight) as? NSLayoutConstraint
    }
    
    private func setRightLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRightL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func rightLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRightL) as? NSLayoutConstraint
    }
    
    private func setRightGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRightG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func rightGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeRightG) as? NSLayoutConstraint
    }
    
    private func setTopConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setTopConstraint(constraint)
        case .greaterThanOrEqual:
            setTopGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setTopLessConstraint(constraint)
        }
    }
    
    private func topConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return topConstraint()
        case .greaterThanOrEqual:
            return topGreaterConstraint()
        case .lessThanOrEqual:
            return topLessConstraint()
        }
    }
    
    private func setTopConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTop, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func topConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTop) as? NSLayoutConstraint
    }
    
    private func setTopLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTopL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func topLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTopL) as? NSLayoutConstraint
    }
    
    private func setTopGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTopG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func topGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTopG) as? NSLayoutConstraint
    }
    
    private func setBottomConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setBottomConstraint(constraint)
        case .greaterThanOrEqual:
            setBottomGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setBottomLessConstraint(constraint)
        }
    }
    
    private func bottomConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return bottomConstraint()
        case .greaterThanOrEqual:
            return bottomGreaterConstraint()
        case .lessThanOrEqual:
            return bottomLessConstraint()
        }
    }
    
    private func setBottomConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottom, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func bottomConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottom) as? NSLayoutConstraint
    }
    
    private func setBottomLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottomL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func bottomLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottomL) as? NSLayoutConstraint
    }
    
    private func setBottomGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottomG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func bottomGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeBottomG) as? NSLayoutConstraint
    }
    
    private func setLeadingConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setLeadingConstraint(constraint)
        case .greaterThanOrEqual:
            setLeadingGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setLeadingLessConstraint(constraint)
        }
    }
    
    private func leadingConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return leadingConstraint()
        case .greaterThanOrEqual:
            return leadingGreaterConstraint()
        case .lessThanOrEqual:
            return leadingLessConstraint()
        }
    }
    
    private func setLeadingConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeading, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leadingConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeading) as? NSLayoutConstraint
    }
    
    private func setLeadingLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeadingL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leadingLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeadingL) as? NSLayoutConstraint
    }
    
    private func setLeadingGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeadingG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func leadingGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLeadingG) as? NSLayoutConstraint
    }
    
    private func setTrailingConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setTrailingConstraint(constraint)
        case .greaterThanOrEqual:
            setTrailingGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setTrailingLessConstraint(constraint)
        }
    }
    
    private func trailingConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return trailingConstraint()
        case .greaterThanOrEqual:
            return trailingGreaterConstraint()
        case .lessThanOrEqual:
            return trailingLessConstraint()
        }
    }
    
    private func setTrailingConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailing, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func trailingConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailing) as? NSLayoutConstraint
    }
    
    private func setTrailingLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailingL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func trailingLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailingL) as? NSLayoutConstraint
    }
    
    private func setTrailingGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailingG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func trailingGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeTrailingG) as? NSLayoutConstraint
    }
    
    private func setWidthConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setWidthConstraint(constraint)
        case .greaterThanOrEqual:
            setWidthGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setWidthLessConstraint(constraint)
        }
    }
    
    private func widthConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return widthConstraint()
        case .greaterThanOrEqual:
            return widthGreaterConstraint()
        case .lessThanOrEqual:
            return widthLessConstraint()
        }
        
    }
    
    private func setWidthConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidth, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func widthConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidth) as? NSLayoutConstraint
    }
    
    private func setWidthLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidthL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func widthLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidthL) as? NSLayoutConstraint
    }
    
    private func setWidthGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidthG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func widthGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeWidthG) as? NSLayoutConstraint
    }
    
    private func setHeightConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setHeightConstraint(constraint)
        case .greaterThanOrEqual:
            setHeightGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setHeightLessConstraint(constraint)
        }
    }
    
    private func heightConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return heightConstraint()
        case .greaterThanOrEqual:
            return heightGreaterConstraint()
        case .lessThanOrEqual:
            return heightLessConstraint()
        }
    }
    
    private func setHeightConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeight, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func heightConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeight) as? NSLayoutConstraint
    }
    
    private func setHeightLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeightL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func heightLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeightL) as? NSLayoutConstraint
    }
    
    private func setHeightGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeightG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func heightGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeHeightG) as? NSLayoutConstraint
    }
    
    private func setCenterXConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setCenterXConstraint(constraint)
        case .greaterThanOrEqual:
            setCenterXGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setCenterXLessConstraint(constraint)
        }
    }
    
    private func centerXConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return centerXConstraint()
        case .greaterThanOrEqual:
            return centerXGreaterConstraint()
        case .lessThanOrEqual:
            return centerXLessConstraint()
        }
    }
    
    private func setCenterXConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterX, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerXConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterX) as? NSLayoutConstraint
    }
    
    private func setCenterXLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterXL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerXLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterXL) as? NSLayoutConstraint
    }
    
    private func setCenterXGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterXG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerXGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterXG) as? NSLayoutConstraint
    }
    
    private func setCenterYConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setCenterYConstraint(constraint)
        case .greaterThanOrEqual:
            setCenterYGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setCenterYLessConstraint(constraint)
        }
    }
    
    private func centerYConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return centerYConstraint()
        case .greaterThanOrEqual:
            return centerYGreaterConstraint()
        case .lessThanOrEqual:
            return centerYLessConstraint()
        }
    }
    
    private func setCenterYConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterY, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerYConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterY) as? NSLayoutConstraint
    }
    
    private func setCenterYLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterYL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerYLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterYL) as? NSLayoutConstraint
    }
    
    private func setCenterYGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterYG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func centerYGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeCenterYG) as? NSLayoutConstraint
    }
    
    private func setLastBaselineConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setLastBaselineConstraint(constraint)
        case .greaterThanOrEqual:
            setLastBaselineGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setLastBaselineLessConstraint(constraint)
        }
    }
    
    private func lastBaselineConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return lastBaselineConstraint()
        case .greaterThanOrEqual:
            return lastBaselineGreaterConstraint()
        case .lessThanOrEqual:
            return lastBaselineLessConstraint()
        }
    }
    
    private func setLastBaselineConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaseline, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func lastBaselineConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaseline) as? NSLayoutConstraint
    }
    
    private func setLastBaselineLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaselineL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func lastBaselineLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaselineL) as? NSLayoutConstraint
    }
    
    private func setLastBaselineGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaselineG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func lastBaselineGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeLastBaselineG) as? NSLayoutConstraint
    }
    
    private func setFirstBaselineConstraint(_ constraint: NSLayoutConstraint!, relation: WHC_LayoutRelation) {
        switch relation {
        case .equal:
            setFirstBaselineConstraint(constraint)
        case .greaterThanOrEqual:
            setFirstBaselineGreaterConstraint(constraint)
        case .lessThanOrEqual:
            setFirstBaselineLessConstraint(constraint)
        }
    }
    
    private func firstBaselineConstraint(_ relation: WHC_LayoutRelation) -> NSLayoutConstraint! {
        switch relation {
        case .equal:
            return firstBaselineConstraint()
        case .greaterThanOrEqual:
            return firstBaselineGreaterConstraint()
        case .lessThanOrEqual:
            return firstBaselineLessConstraint()
        }
    }
    
    private func setFirstBaselineConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaseline, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func firstBaselineConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaseline) as? NSLayoutConstraint
    }
    
    private func setFirstBaselineLessConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaselineL, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func firstBaselineLessConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaselineL) as? NSLayoutConstraint
    }
    
    private func setFirstBaselineGreaterConstraint(_ constraint: NSLayoutConstraint!) {
        objc_setAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaselineG, constraint, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func firstBaselineGreaterConstraint() -> NSLayoutConstraint! {
        return objc_getAssociatedObject(self, &WHC_LayoutAssociatedObjectKey.kAttributeFirstBaselineG) as? NSLayoutConstraint
    }
    
    private func constraintWithItem(_ item: WHC_VIEW!,
                                    attribute: WHC_LayoutAttribute,
                                    constant: CGFloat) -> WHC_VIEW {
        var toAttribute = attribute
        return self.constraintWithItem(self,
                                       attribute: attribute,
                                       toItem: item,
                                       toAttribute: &toAttribute,
                                       constant: constant)
    }
    
    private func constraintWithItem(_ item: WHC_VIEW!,
                                    attribute: WHC_LayoutAttribute,
                                    multiplier: CGFloat,
                                    constant: CGFloat) -> WHC_VIEW {
        var toAttribute = attribute
        return self.constraintWithItem(self,
                                       attribute: attribute,
                                       toItem: item,
                                       toAttribute: &toAttribute ,
                                       multiplier: multiplier,
                                       constant: constant)
    }
    
    private func constraintWithItem(_ item: WHC_VIEW!,
                                    attribute: WHC_LayoutAttribute,
                                    toItem: WHC_VIEW!,
                                    toAttribute: inout WHC_LayoutAttribute,
                                    constant: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(item,
                                       attribute: attribute,
                                       toItem: toItem,
                                       toAttribute: &toAttribute,
                                       multiplier: 1,
                                       constant: constant)
    }
    
    private func constraintWithItem(_ item: WHC_VIEW!,
                                    attribute: WHC_LayoutAttribute,
                                    toItem: WHC_VIEW!,
                                    toAttribute: inout WHC_LayoutAttribute,
                                    multiplier: CGFloat,
                                    constant: CGFloat) -> WHC_VIEW {
        return self.constraintWithItem(item,
                                       attribute: attribute,
                                       related: .equal,
                                       toItem: toItem,
                                       toAttribute: &toAttribute,
                                       multiplier: multiplier,
                                       constant: constant)
    }
    
    private func constraintWithItem(_ item: WHC_VIEW!,
                                    attribute: WHC_LayoutAttribute,
                                    related: WHC_LayoutRelation,
                                    toItem: WHC_VIEW!,
                                    toAttribute: inout WHC_LayoutAttribute,
                                    multiplier: CGFloat,
                                    constant: CGFloat) -> WHC_VIEW {
        
        var firstAttribute = attribute
        if toItem == nil {
            toAttribute = .notAnAttribute
        }else if item == nil {
            firstAttribute = .notAnAttribute
        }
        if self.translatesAutoresizingMaskIntoConstraints {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        item?.translatesAutoresizingMaskIntoConstraints = false
        switch firstAttribute {
        case .left:
            if let leading = self.leadingConstraint() {
                removeCache(constraint: leading).setLeadingConstraint(nil)
            }
            if let leading = self.leadingLessConstraint() {
                removeCache(constraint: leading).setLeadingLessConstraint(nil)
            }
            if let leading = self.leadingGreaterConstraint() {
                removeCache(constraint: leading).setLeadingGreaterConstraint(nil)
            }
            if let left = self.leftConstraint(related) {
                if (left.firstAttribute == firstAttribute &&
                    left.secondAttribute == toAttribute &&
                    left.firstItem === item &&
                    left.secondItem === toItem &&
                    left.relation == related &&
                    left.multiplier == multiplier) {
                    left.constant = constant
                    return self
                }
                removeCache(constraint: left).setLeftConstraint(nil, relation: related)
            }
        case .right:
            if let trailing = self.trailingConstraint() {
                removeCache(constraint: trailing).setTrailingConstraint(nil)
            }
            if let trailing = self.trailingLessConstraint() {
                removeCache(constraint: trailing).setTrailingLessConstraint(nil)
            }
            if let trailing = self.trailingGreaterConstraint() {
                removeCache(constraint: trailing).setTrailingGreaterConstraint(nil)
            }
            
            if let right = self.rightConstraint(related) {
                if (right.firstAttribute == firstAttribute &&
                    right.secondAttribute == toAttribute &&
                    right.firstItem === item &&
                    right.secondItem === toItem &&
                    right.relation == related &&
                    right.multiplier == multiplier) {
                    right.constant = constant
                    return self
                }
                removeCache(constraint: right).setRightConstraint(nil, relation: related)
            }
        case .top:
            if let firstBaseline = self.firstBaselineConstraint() {
                removeCache(constraint: firstBaseline).setFirstBaselineConstraint(nil)
            }
            if let firstBaseline = self.firstBaselineLessConstraint() {
                removeCache(constraint: firstBaseline).setFirstBaselineLessConstraint(nil)
            }
            if let firstBaseline = self.firstBaselineGreaterConstraint() {
                removeCache(constraint: firstBaseline).setFirstBaselineGreaterConstraint(nil)
            }
            if let top = self.topConstraint(related) {
                if (top.firstAttribute == firstAttribute &&
                    top.secondAttribute == toAttribute &&
                    top.firstItem === item &&
                    top.secondItem === toItem &&
                    top.relation == related &&
                    top.multiplier == multiplier) {
                    top.constant = constant
                    return self
                }
                removeCache(constraint: top).setTopConstraint(nil, relation: related)
            }
        case .bottom:
            if let lastBaseline = self.lastBaselineConstraint() {
                removeCache(constraint: lastBaseline).setLastBaselineConstraint(nil)
            }
            if let lastBaseline = self.lastBaselineLessConstraint() {
                removeCache(constraint: lastBaseline).setLastBaselineLessConstraint(nil)
            }
            if let lastBaseline = self.lastBaselineGreaterConstraint() {
                removeCache(constraint: lastBaseline).setLastBaselineGreaterConstraint(nil)
            }
            if let bottom = self.bottomConstraint(related) {
                if (bottom.firstAttribute == firstAttribute &&
                    bottom.secondAttribute == toAttribute &&
                    bottom.firstItem === item &&
                    bottom.secondItem === toItem &&
                    bottom.relation == related &&
                    bottom.multiplier == multiplier) {
                    bottom.constant = constant
                    return self
                }
                removeCache(constraint: bottom).setBottomConstraint(nil, relation: related)
            }
        case .leading:
            if let left = self.leftConstraint() {
                removeCache(constraint: left).setLeftConstraint(nil)
            }
            if let left = self.leftLessConstraint() {
                removeCache(constraint: left).setLeftLessConstraint(nil)
            }
            if let left = self.leftGreaterConstraint() {
                removeCache(constraint: left).setLeftGreaterConstraint(nil)
            }
            if let leading = self.leadingConstraint(related) {
                if (leading.firstAttribute == firstAttribute &&
                    leading.secondAttribute == toAttribute &&
                    leading.firstItem === item &&
                    leading.secondItem === toItem &&
                    leading.relation == related &&
                    leading.multiplier == multiplier) {
                    leading.constant = constant
                    return self
                }
                removeCache(constraint: leading).setLeadingConstraint(nil, relation: related)
            }
        case .trailing:
            if let right = self.rightConstraint() {
                removeCache(constraint: right).setRightConstraint(nil)
            }
            if let right = self.rightLessConstraint() {
                removeCache(constraint: right).setRightLessConstraint(nil)
            }
            if let right = self.rightGreaterConstraint() {
                removeCache(constraint: right).setRightGreaterConstraint(nil)
            }
            if let trailing = self.trailingConstraint(related) {
                if (trailing.firstAttribute == firstAttribute &&
                    trailing.secondAttribute == toAttribute &&
                    trailing.firstItem === item &&
                    trailing.secondItem === toItem &&
                    trailing.relation == related &&
                    trailing.multiplier == multiplier) {
                    trailing.constant = constant
                    return self
                }
                removeCache(constraint: trailing).setTrailingConstraint(nil, relation: related)
            }
        case .width:
            if let width = self.widthConstraint(related) {
                if (width.firstAttribute == firstAttribute &&
                    width.secondAttribute == toAttribute &&
                    width.firstItem === item &&
                    width.secondItem === toItem &&
                    width.relation == related &&
                    width.multiplier == multiplier) {
                    width.constant = constant
                    return self
                }
                removeCache(constraint: width).setWidthConstraint(nil, relation: related)
            }
        case .height:
            if let height = self.heightConstraint(related) {
                if (height.firstAttribute == firstAttribute &&
                    height.secondAttribute == toAttribute &&
                    height.firstItem === item &&
                    height.secondItem === toItem &&
                    height.relation == related &&
                    height.multiplier == multiplier) {
                    height.constant = constant
                    return self
                }
                removeCache(constraint: height).setHeightConstraint(nil, relation: related)
            }
        case .centerX:
            if let centerX = self.centerXConstraint(related) {
                if (centerX.firstAttribute == firstAttribute &&
                    centerX.secondAttribute == toAttribute &&
                    centerX.firstItem === item &&
                    centerX.secondItem === toItem &&
                    centerX.relation == related &&
                    centerX.multiplier == multiplier) {
                    centerX.constant = constant
                    return self
                }
                removeCache(constraint: centerX).setCenterXConstraint(nil, relation: related)
            }
        case .centerY:
            if let centerY = self.centerYConstraint(related) {
                if (centerY.firstAttribute == firstAttribute &&
                    centerY.secondAttribute == toAttribute &&
                    centerY.firstItem === item &&
                    centerY.secondItem === toItem &&
                    centerY.relation == related &&
                    centerY.multiplier == multiplier) {
                    centerY.constant = constant
                    return self
                }
                removeCache(constraint: centerY).setCenterYConstraint(nil, relation: related)
            }
        case .lastBaseline:
            if let bottom = self.bottomConstraint() {
                removeCache(constraint: bottom).setBottomConstraint(nil)
            }
            if let bottom = self.bottomLessConstraint() {
                removeCache(constraint: bottom).setBottomLessConstraint(nil)
            }
            if let bottom = self.bottomGreaterConstraint() {
                removeCache(constraint: bottom).setBottomGreaterConstraint(nil)
            }
            if let lastBaseline = self.lastBaselineConstraint(related) {
                if (lastBaseline.firstAttribute == firstAttribute &&
                    lastBaseline.secondAttribute == toAttribute &&
                    lastBaseline.firstItem === item &&
                    lastBaseline.secondItem === toItem &&
                    lastBaseline.relation == related &&
                    lastBaseline.multiplier == multiplier) {
                    lastBaseline.constant = constant
                    return self
                }
                removeCache(constraint: lastBaseline).setLastBaselineConstraint(nil, relation: related)
            }
        case .firstBaseline:
            if let top = self.topConstraint() {
                removeCache(constraint: top).setTopConstraint(nil)
            }
            if let top = self.topLessConstraint() {
                removeCache(constraint: top).setTopLessConstraint(nil)
            }
            if let top = self.topGreaterConstraint() {
                removeCache(constraint: top).setTopGreaterConstraint(nil)
            }
            if let firstBaseline = self.firstBaselineConstraint(related) {
                if (firstBaseline.firstAttribute == firstAttribute &&
                    firstBaseline.secondAttribute == toAttribute &&
                    firstBaseline.firstItem === item &&
                    firstBaseline.secondItem === toItem &&
                    firstBaseline.relation == related &&
                    firstBaseline.multiplier == multiplier) {
                    firstBaseline.constant = constant
                    return self
                }
                removeCache(constraint: firstBaseline).setFirstBaselineConstraint(nil, relation: related)
            }
        default:
            break
        }
        let superView = mainSuperView(view1: toItem, view2: item)
        if superView == nil {
            return self
        }
        let constraint = NSLayoutConstraint(item: item,
                                            attribute: attribute,
                                            relatedBy: related,
                                            toItem: toItem,
                                            attribute: toAttribute,
                                            multiplier: multiplier,
                                            constant: constant)
        setCacheConstraint(constraint, attribute: attribute, relation: related)
        superView!.addConstraint(constraint)
        self.currentConstraint = constraint
        return self
    }
    
    @discardableResult
    private func removeCache(constraint: NSLayoutConstraint?) -> WHC_VIEW {
        whc_MainViewConstraint(constraint)?.removeConstraint(constraint!)
        return self
    }
    
    private func mainSuperView(view1: WHC_VIEW?, view2: WHC_VIEW?) -> WHC_VIEW? {
        if view1 == nil && view2 != nil {
            return view2
        }
        if view1 != nil && view2 == nil {
            return view1
        }
        if view1 == nil && view2 == nil {
            return nil
        }
        if view1!.superview != nil && view2!.superview == nil {
            return view2
        }
        if view1!.superview == nil && view2!.superview != nil {
            return view1
        }
        if let mainView = sameSuperview(view1: view1, view2: view2).0 {
            return mainView
        }else if let mainView = sameSuperview(view1: view2, view2: view1).0 {
            return mainView
        }
        return nil
    }
    
    private func checkSubSuperView(superv: WHC_VIEW?, subv: WHC_VIEW?) -> WHC_VIEW? {
        var superView: WHC_VIEW?
        if let spv = superv, let sbv = subv, let sbvspv = sbv.superview, spv !== sbv {
            func scanSubv(_ subvs: [WHC_VIEW]?) -> WHC_VIEW? {
                var superView: WHC_VIEW?
                if let tmpsubvs = subvs, !tmpsubvs.isEmpty {
                    if tmpsubvs.contains(sbvspv) {
                        superView = sbvspv
                    }
                    if superView == nil {
                        var sumSubv = [WHC_VIEW]()
                        tmpsubvs.forEach({ (sv) in
                            sumSubv.append(contentsOf: sv.subviews)
                        })
                        superView = scanSubv(sumSubv)
                    }
                }
                return superView
            }
            if scanSubv([spv]) != nil {
                superView = spv
            }
        }
        return superView
    }
    
    private func sameSuperview(view1: WHC_VIEW?, view2: WHC_VIEW?) -> (WHC_VIEW?, Bool) {
        var tempToItem = view1
        var tempItem = view2
        if tempToItem != nil && tempItem != nil {
            if checkSubSuperView(superv: view1, subv: view2) != nil {
                return (view1, false)
            }
            if checkSubSuperView(superv: view2, subv: view1) != nil {
                return (view2, false)
            }
        }
        let checkSameSuperview: ((WHC_VIEW, WHC_VIEW) -> Bool) = {(tmpSuperview, singleView) in
            var tmpSingleView: WHC_VIEW? = singleView
            while let tempSingleSuperview = tmpSingleView?.superview {
                if tmpSuperview === tempSingleSuperview {
                    return true
                }else {
                    tmpSingleView = tempSingleSuperview
                }
            }
            return false
        }
        while let toItemSuperview = tempToItem?.superview,
            let itemSuperview = tempItem?.superview  {
                if toItemSuperview === itemSuperview {
                    return (toItemSuperview, true)
                }else {
                    tempToItem = toItemSuperview
                    tempItem = itemSuperview
                    if tempToItem?.superview == nil && tempItem?.superview != nil {
                        if checkSameSuperview(tempToItem!, tempItem!) {
                            return (tempToItem, true)
                        }
                    }else if tempToItem?.superview != nil && tempItem?.superview == nil {
                        if checkSameSuperview(tempItem!, tempToItem!) {
                            return (tempItem, true)
                        }
                    }
                }
        }
        return (nil, false)
    }
    
    private func setCacheConstraint(_ constraint: NSLayoutConstraint!, attribute: WHC_LayoutAttribute, relation: WHC_LayoutRelation) {
        switch (attribute) {
        case .firstBaseline:
            self.setFirstBaselineConstraint(constraint, relation: relation)
        case .lastBaseline:
            self.setLastBaselineConstraint(constraint, relation: relation)
        case .centerY:
            self.setCenterYConstraint(constraint, relation: relation)
        case .centerX:
            self.setCenterXConstraint(constraint, relation: relation)
        case .trailing:
            self.setTrailingConstraint(constraint, relation: relation)
        case .leading:
            self.setLeadingConstraint(constraint, relation: relation)
        case .bottom:
            self.setBottomConstraint(constraint, relation: relation)
        case .top:
            self.setTopConstraint(constraint, relation: relation)
        case .right:
            self.setRightConstraint(constraint, relation: relation)
        case .left:
            self.setLeftConstraint(constraint, relation: relation)
        case .width:
            self.setWidthConstraint(constraint, relation: relation)
        case .height:
            self.setHeightConstraint(constraint, relation: relation)
        default:
            break;
        }
    }
    
    #if os(iOS) || os(tvOS)
    
    class WHC_Line: WHC_VIEW {
        
    }
    
    struct WHC_Tag {
        static let kLeftLine = 100000
        static let kRightLine = kLeftLine + 1
        static let kTopLine = kRightLine + 1
        static let kBottomLine = kTopLine + 1
    }
    
    private func createLineWithTag(_ lineTag: Int)  -> WHC_Line! {
        var line: WHC_Line!
        for view in self.subviews {
            if view is WHC_Line && view.tag == lineTag {
                line = view as! WHC_Line
                break
            }
        }
        if line == nil {
            line = WHC_Line()
            line.tag = lineTag
            self.addSubview(line)
        }
        return line
    }
    
    //MARK: -自动添加底部线和顶部线-
    @discardableResult
    public func whc_AddBottomLine(_ height: CGFloat, color: WHC_COLOR) -> WHC_VIEW {
        return self.whc_AddBottomLine(height, color: color, marge: 0)
    }
    
    @discardableResult
    public func whc_AddBottomLine(_ height: CGFloat, color: WHC_COLOR, marge: CGFloat) -> WHC_VIEW {
        let line = self.createLineWithTag(WHC_Tag.kBottomLine)
        line?.backgroundColor = color
        return line!.whc_Right(marge).whc_Left(marge).whc_Height(height).whc_Bottom(0)
    }
    
    @discardableResult
    public func whc_AddTopLine(_ height: CGFloat, color: WHC_COLOR) -> WHC_VIEW {
        return self.whc_AddTopLine(height, color: color, marge: 0)
    }
    
    @discardableResult
    public func whc_AddTopLine(_ height: CGFloat, color: WHC_COLOR, marge: CGFloat) -> WHC_VIEW {
        let line = self.createLineWithTag(WHC_Tag.kTopLine)
        line?.backgroundColor = color
        return line!.whc_Right(marge).whc_Left(marge).whc_Height(height).whc_Top(0)
    }
    
    #endif
}

