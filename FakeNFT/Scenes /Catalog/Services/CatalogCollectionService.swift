//
//  CatalogCollectionService.swift
//  FakeNFT
//
//  Created by Eugene Kolesnikov on 13.11.2023.
//

import Foundation

protocol CatalogCollectionServiceProtocol {
    func fetchCatalog(completion: @escaping (Result<[Catalog], Error>) -> Void)
}

final class CatalogCollectionService: CatalogCollectionServiceProtocol {

    // MARK: - Public properties
    private var catalog: [Catalog] = []

    // MARK: - Private properties
    private let request = CatalogRequest()
    private let networkClient: NetworkClient
    private var task: NetworkTask?

    init(networkClient: NetworkClient) {
        self.networkClient = DefaultNetworkClient()
    }

    // MARK: - Public methods
    func fetchCatalog(completion: @escaping (Result<[Catalog], Error>) -> Void) {

        networkClient.send(
            request: request,
            type: [CatalogResult].self,
            onResponse: { [weak self] (result: Result<[CatalogResult], Error>)  in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch result {
                    case .success(let catalogRes):
                        catalog += catalogRes.map {
                            Catalog(
                                name: $0.name,
                                coverURL: URL(string: $0.cover),
                                nfts: $0.nfts,
                                desription: $0.description,
                                authorID: $0.author,
                                id: $0.id)
                        }
                        completion(.success((catalog)))
                    case .failure(let error):
                        completion(.failure((error)))
                    }
                }
            })
    }
}
