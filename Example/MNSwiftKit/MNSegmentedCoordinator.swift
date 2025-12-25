import UIKit

final class MNSegmentedCoordinator: NSObject {

    // MARK: - Callbacks

    var onPageChanged: ((Int) -> Void)?
    var onScrollProgress: ((Int, CGFloat) -> Void)?

    // MARK: - Private

    private let pageViewController: UIPageViewController
    private weak var scrollView: UIScrollView?

    private var items: [MNPageItem]
    private var currentIndex: Int = 0
    private var cache: [String: UIViewController] = [:]

    private let factory: (MNPageItem) -> UIViewController

    // MARK: - Init

    init(
        pageViewController: UIPageViewController,
        items: [MNPageItem],
        factory: @escaping (MNPageItem) -> UIViewController
    ) {
        self.pageViewController = pageViewController
        self.items = items
        self.factory = factory
        super.init()

        pageViewController.dataSource = self
        pageViewController.delegate = self
        hookScrollView()
    }
}

extension MNSegmentedCoordinator {

    func setInitialIndex(_ index: Int) {
        currentIndex = clamp(index)
        reload(animated: false)
    }

    func select(index: Int, animated: Bool) {
        let target = clamp(index)
        guard target != currentIndex else { return }

        let direction: UIPageViewController.NavigationDirection =
            target > currentIndex ? .forward : .reverse

        currentIndex = target
        pageViewController.setViewControllers(
            [viewController(at: target)],
            direction: direction,
            animated: animated
        )
    }

    func insert(item: MNPageItem, at index: Int) {
        let index = max(0, min(index, items.count))
        items.insert(item, at: index)

        if index <= currentIndex {
            currentIndex += 1
        }
        reload(animated: false)
    }

    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }

        let removed = items.remove(at: index)
        cache.removeValue(forKey: removed.id)

        if items.isEmpty { return }

        if index == currentIndex {
            currentIndex = min(index, items.count - 1)
        } else if index < currentIndex {
            currentIndex -= 1
        }
        reload(animated: false)
    }
}

private extension MNSegmentedCoordinator {

    func clamp(_ index: Int) -> Int {
        max(0, min(index, items.count - 1))
    }

    func viewController(at index: Int) -> UIViewController {
        let item = items[index]

        if let cached = cache[item.id] {
            return cached
        }

        let vc = factory(item)
        cache[item.id] = vc
        return vc
    }

    func reload(animated: Bool) {
        guard items.indices.contains(currentIndex) else { return }

        pageViewController.setViewControllers(
            [viewController(at: currentIndex)],
            direction: .forward,
            animated: animated
        )
    }

    func hookScrollView() {
        for view in pageViewController.view.subviews {
            if let scroll = view as? UIScrollView {
                scroll.delegate = self
                scrollView = scroll
                break
            }
        }
    }

    func index(of vc: UIViewController) -> Int? {
        cache.first(where: { $0.value === vc })
            .flatMap { key, _ in
                items.firstIndex(where: { $0.id == key })
            }
    }
}

extension MNSegmentedCoordinator: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController) else { return nil }
        let prev = index - 1
        return prev >= 0 ? self.viewController(at: prev) : nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController) else { return nil }
        let next = index + 1
        return next < items.count ? self.viewController(at: next) : nil
    }
}

extension MNSegmentedCoordinator: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let vc = pageViewController.viewControllers?.first,
              let index = index(of: vc)
        else { return }
        
        currentIndex = index
        onPageChanged?(index)
    }
}

extension MNSegmentedCoordinator: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        
        print("===============================")
        
        //print("---\(scrollView.frame.width)-----\(scrollView.contentOffset.x)")

        let progress = (scrollView.contentOffset.x - width) / width
        onScrollProgress?(currentIndex, progress)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("--------------------------------")
        if decelerate {
            print("1111111111111111111111111111111111111111111111")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("****************************************")
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("2222222222222222222222222222222222")
    }
}

