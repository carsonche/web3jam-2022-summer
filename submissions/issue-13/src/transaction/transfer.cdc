// import NonFungibleToken from 0xNonFungibleToken
// import TicketNFT from 0xProfile

/// This transaction is for transferring and NFT from
/// one account to another

import NonFungibleToken from 0xNonFungibleToken
// import MetadataViews from 0x631e88ae7f1d7c20
import TicketNFT from 0xTicketNFT


// import TicketNFT from 0xTicketNFT
// import NonFungibleToken from 0xNonFungibleToken

transaction(recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: &TicketNFT.Collection

    /// Reference of the collection to deposit the NFT to
    let depositRef: &{NonFungibleToken.CollectionPublic}

    prepare(signer: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer
            .borrow<&TicketNFT.Collection>(from: TicketNFT.CollectionStoragePath)
            ?? panic("Account does not store an object at the specified path")

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the receivers collection
        self.depositRef = recipient
            .getCapability(TicketNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

    }

    execute {

        // withdraw the NFT from the owner's collection
        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        self.depositRef.deposit(token: <-nft)
    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
        self.depositRef.getIDs().contains(withdrawID): "The reciever should now own the NFT"
    }
}