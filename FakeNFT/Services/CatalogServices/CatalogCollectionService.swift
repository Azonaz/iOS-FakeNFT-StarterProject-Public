//
//  CatalogCollectionService.swift
//  FakeNFT
//
//  Created by Eugene Kolesnikov on 13.11.2023.
//

import Foundation

protocol CatalogCollectionServiceProtocol {
    func loadNftForCollection(id: String, completion: @escaping (Result<Nft, Error>) -> Void)
    func fetchAuthorProfile(id: String, completion: @escaping (Result<Author, Error>) -> Void)
}

final class CatalogCollectionService: CatalogCollectionServiceProtocol {

    // MARK: - Public properties
    private var catalog: [Catalog] = []

    // MARK: - Private properties
    private let networkClient: NetworkClient
    private let storage: NftStorage = NftStorageImpl.shared

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public methods
    func loadNftForCollection(id: String, completion: @escaping (Result<Nft, Error>) -> Void) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }

        let request = NFTRequest(id: id)
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.async { [weak self] in
            guard let self = self else { return }
            networkClient.send(
                request: request,
                type: Nft.self,
                onResponse: { (result: Result<Nft, Error>) in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        switch result {
                        case .success(let nft):
                            storage.saveNft(nft)
                            completion(.success(nft))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
        }
    }

    func fetchAuthorProfile(id: String, completion: @escaping (Result<Author, Error>) -> Void) {
        let request = AuthorRequest(id: id)
        let queue = DispatchQueue.global(qos: .userInteractive)

        queue.async { [weak self] in
            guard let self = self else { return }
            networkClient.send(
                request: request,
                type: Author.self,
                onResponse: { (result: Result<Author, Error>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let author):
                            completion(.success(author))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            )
        }
    }
}