/* SPDX-License-Identifier: Apache-2.0
Copyright 2016, 2025 Solarius Solutions <contact at solarius.fi>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

The original code was submitted for verification at Etherscan.io on
2016-11-06, under GPLv2 at 0x69f2a483a2ad4b910fa03a0f380d61f6dbe20017.

This 2025 remastered version has been updated to match modern Solidity
coding style, has improved and fixed the comments, and is released under
the Apache License 2.0.
*/

// This was originally written for the 0.3.x series (0.3.6) but was
// updated at the last minute to 0.4.2 and eventually to 0.4.4.
// It has not been tested on any other versions.
pragma solidity 0.4.4;

/// @title Coinia Vy - Virtual limited partnership
/// @dev Designed for Finnish limited partnerships (kommandiittiyhtiö),
/// which have unlimited (general) partners and limited partners.
/// In this implementation, the general partners have the right to change
/// company details, such as the name. It can also be used for unlimited
/// partnerships (avoin yhtiö), which have only unlimited partners, and
/// for unincorporated partnerships (elinkeinoyhtymä, yhtymä), the initial
/// form of this organization.
///
/// This is one of the earliest tokens on Ethereum, based on ERC-20 as of
/// fall 2016. It is not fully compatible with the final EIP-20, but major
/// EIP-20 implementations should be able to work with this token.
///
/// Despite being one of the first, this implementation has some
/// shortcomings, although it works well as an Ethereum token. Most of the
/// shortcomings are related to the godlike powers of each general
/// partner, which could be mitigated by placing each general partner
/// behind a proxy smart contract. A major shortcoming is the lack of the
/// approval mechanism.
///
/// @author Solarius Solutions / Ville Sundell
contract CoiniaVy {
    /// @title A struct for shareholders
    /// @dev The main structure for tracking partners, their stakes,
    /// and their status. This should have been named "Partner" instead.
    ///
    /// For identification purposes, only the name and ID are used
    /// intentionally: the rationale being that an entity would not share
    /// its name and ID with any other entity elsewhere.
    struct Shareholder {
        /// @dev Legal name of the partner
        string name;
        /// @dev Legal identification of the partner (birthday,
        /// registration number, business ID, etc.)
        string id;
        /// @dev Number of shares owned; 0 indicates not a member or an
        /// ex-member
        uint shares;
        /// @dev If true, the partner is limited; if false, the partner
        /// is a general partner
        bool limited;
    }

    /// @dev Implementation-specific internal version number. 0.1 was
    /// chosen as it was the default in reference implementations at the
    /// time.
    string public standard = "Token 0.1";

    /// @dev Addresses of contracts managing projects and voting,
    /// which can be deployed later. One shortcoming is that this is a
    /// list and not a single address. A proxy contract could serve as the
    /// sole project manager.
    address[] public projectManagers;

    /// @dev Addresses of contracts managing the funds,
    /// which can be deployed later. One shortcoming is that this is a
    /// list and not a single address. A proxy contract could serve as the
    /// sole treasury manager.
    address[] public treasuryManagers;

    /// @dev EIP-20 compliant: Total supply of tokens representing the
    /// total number of stakes. Immutable and indivisible.
    uint public totalSupply = 10000;

    /// @dev Organization's address. This can be changed.
    string public home = "PL 18, 30101 Forssa, FINLAND";

    /// @dev Industry of the organization. This can be changed.
    string public industry =
                    "64190 Muu pankkitoiminta / Financial service nec";

    /// @dev The mapping of partners, mistakenly named.
    mapping(address => Shareholder) public shareholders;

    // These statements mark where the contract is tokenized:
    // Editor's note: one of the earliest uses of "tokenize" above.

    /// @dev EIP-20 compliant: Token's name doubles as the name of the
    /// organization in this implementation. Can be changed.
    string public name = "Coinia Vy";

    /// @dev EIP-20 compliant: A three-letter symbol, chosen as CIA
    /// tongue-in-cheek. Immutable.
    string public symbol = "CIA";

    /// @dev EIP-20 compliant: 0 decimals defined, so the stakes are not
    /// divisible. Use a proxy token if division is needed. Immutable.
    uint8 public decimals = 0;

    /// @dev EIP-20 compliant Transfer event for token transfers.
    event Transfer(address indexed from, address indexed to, uint shares);

    /// @dev Event signaling a change to the organization's (and token's)
    /// name.
    event ChangedName(address indexed who, string to);

    /// @dev Event signaling a change to the organization's ID.
    event ChangedId(address indexed who, string to);

    /// @dev Event signaling the resignation of a partner.
    event Resigned(address indexed who);

    /// @dev Event signaling a change in a partner's liability status.
    event SetLimited(address indexed who, bool limited);

    /// @dev Event signaling a change of the organization's industry.
    event SetIndustry(string indexed newIndustry);

    /// @dev Event signaling a change of the organization's legal
    /// residence.
    event SetHome(string indexed newHome);

    /// @dev Event signaling a change of the company's legal name.
    event SetName(string indexed newName);

    /// @dev Event signaling that a manager has been added.
    event AddedManager(address indexed manager);

    /// @dev Modifier for functions requiring authorization.
    /// Previously, a msg.value check was used but is no longer needed.
    modifier ifAuthorised() {
        if (shareholders[msg.sender].shares == 0) throw;
        _;
    }

    /// @dev Modifier to check if the user is a general partner.
    modifier ifGeneralPartner() {
        if (shareholders[msg.sender].limited == true) throw;
        _;
    }

    /// @dev Constructor. It is quick and dirty because Ethereum's 2016
    /// DDoS difficulties made deployment hard. Everything is hardcoded so
    /// this contract can be deployed using any tool (not all support
    /// arguments).
    function CoiniaVy() {
        shareholders[this] = Shareholder(name, "2755797-6", 0, false);
        shareholders[msg.sender] = Shareholder(
            "Coinia OÜ",
            "14111022",
            totalSupply,
            false
        );
    }

    /// @dev Here we "tokenize" our contract so wallets can use it as a
    /// token.
    /// @param target Address whose balance we want to query
    function balanceOf(address target) constant returns (uint256 balance) {
        return shareholders[target].shares;
    }

    /// @notice This transfers `amount` shares to `target`. This action is
    /// irreversible; are you okay with this?
    /// @dev This transfers shares from the current shareholder to another
    /// account, and creates a new shareholder entry if it does not exist.
    /// @param target Address of the account which will receive the
    /// shares
    /// @param amount Number of shares to transfer, where 0 means none, 1
    /// means one share, and so on
    function transfer(address target, uint256 amount) ifAuthorised {
        if (amount == 0 || shareholders[msg.sender].shares < amount) throw;

        shareholders[msg.sender].shares -= amount;
        if (shareholders[target].shares > 0) {
            shareholders[target].shares += amount;
        } else {
            shareholders[target].shares = amount;
            shareholders[target].limited = true;
        }

        Transfer(msg.sender, target, amount);
    }

    /// @dev This function allows a user to change their own name.
    /// Ethereum is anonymous by design, but there might be legal reasons
    /// for a user to do this.
    /// @param newName User's new name
    function changeName(string newName) ifAuthorised {
        shareholders[msg.sender].name = newName;
        ChangedName(msg.sender, newName);
    }

    /// @dev This function allows a user to change their own ID (e.g.,
    /// business ID, birthday). Ethereum is anonymous by design, but there
    /// might be legal reasons for a user to do this.
    /// @param newId User's new ID
    function changeId(string newId) ifAuthorised {
        shareholders[msg.sender].id = newId;
        ChangedId(msg.sender, newId);
    }

    /// @notice WARNING: This will remove your existence from the company;
    /// this action is irreversible and immediate. It will not terminate
    /// the company. Are you absolutely sure?
    /// @dev Required by Finnish law: a person must be able to resign from
    /// a company. This does not terminate the company.
    ///
    /// NOTE: The check for non-empty is intentional, as we don't want
    /// random people who never owned a token to resign.
    function resign() {
        if (
            bytes(shareholders[msg.sender].name).length == 0 ||
            shareholders[msg.sender].shares > 0
        ) throw;

        shareholders[msg.sender].name = "Resigned member";
        shareholders[msg.sender].id = "Resigned member";

        Resigned(msg.sender);
    }

    /// @notice This sets a member's liability status to either limited or
    /// unlimited liability. Beware that this has legal implications, and
    /// the decision must be made with the other general partners.
    /// @dev This function defines whether a member is a limited partner
    /// or a general partner.
    /// @param target The user whose status we want to change
    /// @param isLimited Whether the target will be a limited partner
    function setLimited(
        address target,
        bool isLimited
    ) ifAuthorised ifGeneralPartner {
        shareholders[target].limited = isLimited;
        SetLimited(target, isLimited);
    }

    /// @dev Sets the industry of the company. This might have legal
    /// implications.
    /// @param newIndustry The new industry in which the company will
    /// operate
    function setIndustry(string newIndustry) ifAuthorised ifGeneralPartner {
        industry = newIndustry;
        SetIndustry(newIndustry);
    }

    /// @dev Sets the company's legal "home", which likely has legal
    /// implications, for example determining where court sessions are
    /// held.
    /// @param newHome New home of the company
    function setHome(string newHome) ifAuthorised ifGeneralPartner {
        home = newHome;
        SetHome(newHome);
    }

    /// @dev Sets the company's legal name. This likely has legal
    /// implications.
    /// @param newName New name of the company
    function setName(string newName) ifAuthorised ifGeneralPartner {
        shareholders[this].name = newName;
        name = newName;
        SetName(newName);
    }

    /// @dev Adds a new treasury manager to the end of the list.
    /// @param newManager Address of the new treasury manager
    function addTreasuryManager(
        address newManager
    ) ifAuthorised ifGeneralPartner {
        treasuryManagers.push(newManager);
        AddedManager(newManager);
    }

    /// @dev Adds a new project manager to the end of the list.
    /// @param newManager Address of the new project manager
    function addProjectManager(
        address newManager
    ) ifAuthorised ifGeneralPartner {
        projectManagers.push(newManager);
        AddedManager(newManager);
    }

    /// @dev Default fallback function included for clarity.
    function() {
        throw;
    }
}
