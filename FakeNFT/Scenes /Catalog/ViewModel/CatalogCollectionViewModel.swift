//
//  CatalogCollectionViewModel.swift
//  FakeNFT
//
//  Created by Eugene Kolesnikov on 07.11.2023.
//

import Foundation
import Combine

protocol CatalogCollectionViewModelProtocol: AnyObject {
    var nftsLoadingIsCompleted: Bool { get }
    var nftsLoaderPuublisher: Published<Bool>.Publisher { get }
    var nfts: [Nft] { get }
    var catalogCollection: Catalog { get }
    var author: Author? { get }
    var authorPublisher: Published<Author?>.Publisher { get }
    var networkError: Error? { get }
    var networkErrorPublisher: Published<Error?>.Publisher { get }
    func calculateCollectionViewHeight() -> CGFloat
    func fetchData()
}

final class CatalogCollectionViewModel: CatalogCollectionViewModelProtocol {

    //MARK: - public properties
    @Published var nftsLoadingIsCompleted: Bool = false
    @Published var author: Author?
    @Published var networkError: Error?
    var nftsLoaderPuublisher: Published<Bool>.Publisher { $nftsLoadingIsCompleted }
    var authorPublisher: Published<Author?>.Publisher { $author }
    var networkErrorPublisher: Published<Error?>.Publisher { $networkError }
    var nfts: [Nft] = []
    var catalogCollection: Catalog

    //MARK: - private properties
    private let collectionService: CatalogCollectionService

    init(catalogCollection: Catalog, service: CatalogCollectionService) {
        self.catalogCollection = catalogCollection
        self.collectionService = service
        fetchData()
    }

    //MARK: - public methods
    func fetchData() {
        networkError = nil
        if !nftsLoadingIsCompleted {
            fetchNfts()
        }
        if author == nil {
            fetchAuthorProfile()
        }
    }

    func calculateCollectionViewHeight() -> CGFloat {
        let numberOfCells = catalogCollection.nfts.count
        let height = 192
        let spacing = 9
        var result: Int = 0
        if numberOfCells % 3 == 0 {
            result = ((numberOfCells / 3)) * height + ((numberOfCells / 3) * spacing)
        } else {
            result = (numberOfCells / 3 + 1) * height + ((numberOfCells / 3) * spacing)
        }
        return CGFloat(result)
    }

    //MARK: - private methods
    private func fetchNfts() {
        catalogCollection.nfts.forEach { id in
            collectionService.loadNftForCollection(id: String(id)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let nft):
                    self.nfts.append(nft)
                    if nfts.count == catalogCollection.nfts.count {
                        nftsLoadingIsCompleted = true
                    }
                case .failure(let error):
                    if networkError == nil && !nftsLoadingIsCompleted {
                        networkError = error
                    }
                }
            }
        }
    }

    private func fetchAuthorProfile() {
        collectionService.fetchAuthorProfile(id: catalogCollection.authorID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let authorLink):
                self.author = authorLink
            case .failure(let error):
                if networkError == nil && author == nil {
                    networkError = error
                }
            }
        }
    }
}