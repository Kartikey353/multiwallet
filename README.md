# What is a Multisignature wallet?  

A multisignature wallet is an account that requires some m-of-n quorum of approved private keys to approve a transaction before it is executed.  


Ethereum implements multisignature wallets slightly differently than Bitcoin does. In Ethereum, multisignature wallets are implemented as a smart contract, that each of the approved external accounts sends a transaction to in order to "sign" a group transaction.  

Implementing the Contract
============

I have implement the contract on remix id on local test network provided by ide. 


#What in this project 
=====================

1) A scalable multi-signature wallet contract, which requires a minimum of 60% authorization by the signatory wallets to perform a transaction. 

2) Access registry contract that stores the signatories of this multi-sig wallet by address. This access registry contract has its own admin. Capable of adding, revoking, renouncing, and transfer of signatory functionalities.



Admin.sol file contains all functions related to admin capability.  

#Steps 
=======

1)deploy admin.sol frist you have to add at least 2 owner in this file. 


2) then deploy main.sol for further transactions.
