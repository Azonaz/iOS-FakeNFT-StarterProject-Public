import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        let catalogController = CatalogViewController()

        catalogController.tabBarItem = UITabBarItem(
            title: L10n.Tabbar.catalogTitle,
            image: UIImage(resource: .tabbarCatalogue),
            selectedImage: nil)

        let catalogNavigationController = UINavigationController(rootViewController: catalogController)

        viewControllers = [catalogNavigationController]
        tabBar.unselectedItemTintColor = .black

        let appearance = tabBar.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundEffect = nil
        appearance.backgroundColor = .systemBackground

        tabBar.standardAppearance = appearance
    }
}
