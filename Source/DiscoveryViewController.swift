//
//  DiscoveryViewController.swift
//  edX
//
//  Created by Zeeshan Arif on 11/19/18.
//  Copyright © 2018 edX. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {
    
    private enum segment: Int {
        case courses = 0
        case programs = 1
    }
    
    private var environment: RouterEnvironment
    private let segmentControlHeight: CGFloat = 40.0
    private var bottomSpace: CGFloat {
        guard let bottomBar = bottomBar else { return StandardVerticalMargin }
        return bottomBar.frame.height + StandardVerticalMargin
    }
    private var segmentTitleTextStyle: OEXTextStyle {
        return OEXTextStyle(weight : .normal, size: .small, color: self.environment.styles.neutralDark())
    }
    private let bottomBar: UIView?
    private let searchQuery: String?
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Strings.courses, Strings.programs])
        let styles = self.environment.styles
        control.selectedSegmentIndex = segment.courses.rawValue
        control.tintColor = styles.primaryBaseColor()
        control.setTitleTextAttributes([NSForegroundColorAttributeName: styles.neutralWhite()], for: .selected)
        control.setTitleTextAttributes([NSForegroundColorAttributeName: styles.neutralBlack()], for: .normal)
        return control
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var coursesController: UIViewController = {
        return self.environment.config.courseEnrollmentConfig.type == .Webview ? OEXFindCoursesViewController(environment: self.environment, showBottomBar: false, bottomBar: self.bottomBar, searchQuery: self.searchQuery) : CourseCatalogViewController(environment: self.environment)
    }()
    
    lazy var programsController: UIViewController = {
        return FindProgramsViewController(with: self.environment, showBottomBar: false, bottomBar: self.bottomBar)
    }()
    
    init(with environment: RouterEnvironment, bottomBar: UIView?, searchQuery: String?) {
        self.environment = environment
        self.bottomBar = bottomBar
        self.searchQuery = searchQuery
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if environment.session.currentUser != nil {
            bottomBar?.removeFromSuperview()
        }
    }
    
    private func setupView() {
        addSubViews()
        setupConstraints()
        setupBottomBar()
        view.backgroundColor = environment.styles.standardBackgroundColor()
        segmentedControl.oex_addAction({ [weak self] control in
            if let segmentedControl = control as? UISegmentedControl {
                switch segmentedControl.selectedSegmentIndex {
                case segment.courses.rawValue:
                    self?.coursesController.view.isHidden = false
                    self?.programsController.view.isHidden = true
                    break
                case segment.programs.rawValue:
                    self?.programsController.view.isHidden = false
                    self?.coursesController.view.isHidden = true
                    break
                default:
                    assert(true, "Invalid Segment ID, Remove this segment index OR handle it in the ThreadType enum")
                }
            }
            else {
                assert(true, "Invalid Segment ID, Remove this segment index OR handle it in the ThreadType enum")
            }
        }, for: .valueChanged)
        
        navigationItem.title = Strings.discover
        
    }
    
    private func addSubViews() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        addChildViewController(coursesController)
        didMove(toParentViewController: self)
        coursesController.view.frame = containerView.frame
        containerView.addSubview(coursesController.view)
        
        addChildViewController(programsController)
        didMove(toParentViewController: self)
        programsController.view.frame = containerView.frame
        containerView.addSubview(programsController.view)
        programsController.view.isHidden = true
    }
    
    private func setupBottomBar() {
        
        guard let bottomBar = bottomBar,
            environment.session.currentUser == nil else { return }
        view.addSubview(bottomBar)
        bottomBar.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        bottomBar.bringSubview(toFront: view)
        
    }
    
    private func setupConstraints() {
        
        segmentedControl.snp.makeConstraints { make in
            make.height.equalTo(segmentControlHeight)
            make.leading.equalTo(view).offset(StandardHorizontalMargin)
            make.trailing.equalTo(view).inset(StandardHorizontalMargin)
            make.top.equalTo(view).offset(StandardVerticalMargin)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(segmentedControl.snp.bottom).offset(StandardVerticalMargin)
            make.bottom.equalTo(view).offset(bottomSpace)
        }
        
    }
    
}
