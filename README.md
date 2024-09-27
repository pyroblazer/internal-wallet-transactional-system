# Internal Wallet Transactional System API

By: Ignatius Timothy Manullang (Pyroblazer)

## Objective

The goal of this project is to develop an internal API system that efficiently manages wallet transactions. This includes comprehensive user authentication, the ability to manage stock investments, facilitate team collaborations, and log all interactions related to wallet activities. By establishing this API, we aim to provide a robust framework that enhances financial tracking and decision-making for users and teams alike.

## Tech Stack

| Technology         | Version               |
| ------------------ | --------------------- |
| Ruby (RVM)         | v3.3.4                |
| Ruby On Rails      | v8.0.0.beta1          |
| PostgreSQL         | v16.4                 |

### Explanation of Tech Stack
- **Ruby**: A dynamic, open-source programming language with a focus on simplicity and productivity.
- **Ruby on Rails**: A server-side web application framework written in Ruby, following the MVC architecture, making it easy to develop database-backed applications.
- **PostgreSQL**: A powerful, open-source relational database management system known for its reliability and advanced features.

## Gem Dependencies

| Functionality       | Gem                      | Description |
| ------------------- | ------------------------ | ----------- |
| JWT Authentication  | jwt                      | For secure user authentication using JSON Web Tokens. |
| Password Hashing    | bcrypt                   | Used for securely hashing passwords before storage. |
| Entity Relationships Diagram | rails-erd        | Generates Entity Relationship Diagrams for visualizing database structures. |
| Cross-Origin Requests | rack-cors               | Enables handling of cross-origin requests, essential for APIs. |
| Serialization       | active_model_serializers | Facilitates converting Ruby objects into JSON for API responses. |
| Stock Price Updates | latest_stock_price       | Retrieves up-to-date stock price information from external sources. |
| Debugging           | debug                    | Provides advanced debugging capabilities for the Rails application. |

## Credentials Setup

To secure your application, store your database URLs and API keys in your Rails credentials. Follow these steps to create or edit your credentials:

1. Open the credentials editor with:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```

2. Add the configuration for your local database settings:
   ```yaml
   postgresql:
     rails_max_threads: your_number_of_rails_max_threads
     development:
       url: postgres://username:password@dev_host:dev_port/db_dev?schema=public
     test:
       url: postgres://username:password@test_host:test_port/db_test?schema=public
     production:
       primary:
         url: postgres://username:password@prod_host:prod_port/prod_database
       cache:
         url: postgres://username:password@prod_host:prod_port/prod_cache_database
       queue:
         url: postgres://username:password@prod_host:prod_port/prod_queue_database
       cable:
         url: postgres://username:password@prod_host:prod_port/prod_cable_database

   rapid:
     api_key: "your_rapid_api_key_here"

   jwt:
     secret_key: "your_jwt_secret_key_here"
   ```

3. Save and exit the editor. Ensure that your credentials are secure and not exposed in version control.

## How to Use

1. **Create Local Rails Credentials**: Open your terminal and run:
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   Adjust the database configurations as required, then save the credentials file.

2. **Install Dependencies**: Ensure all necessary gems are installed:
   ```bash
   bundle install
   ```

3. **Set Up the Database**: Create and migrate your database:
   ```bash
   rails db:create db:migrate
   ```

4. **Seed the Database**: Populate the database with initial stock data:
   ```bash
   rails db:seed
   ```

5. **Start the Rails Server**: Launch the application server to start accepting requests:
   ```bash
   rails s
   ```

Here’s the updated API documentation to include `teams/:team_id` endpoints, which mirror the `users/:user_id` endpoints for the same operations.

---

## API Endpoints

### User Management

- **Register**
  - **Endpoint**: `POST /users`
  - **Params**:
    ```json
    {
      "name": "John Doe",
      "email": "johndoe@email.com",
      "password": "password123"
    }
    ```
  - **Description**: Allows a new user to create an account in the system.

- **Login**
  - **Endpoint**: `POST /auth/login`
  - **Params**:
    ```json
    {
      "email": "johndoe@email.com",
      "password": "password123"
    }
    ```
  - **Description**: Authenticates the user and returns a JWT for session management.

- **Logout**
  - **Endpoint**: `POST /auth/logout`
  - **Auth Type**: Bearer Token
  - **Description**: Logs the user out by invalidating the current session token.

### Team Management

- **Create Team**
  - **Endpoint**: `POST /teams`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "name": "First Team"
    }
    ```
  - **Description**: Enables users to create a new team, automatically creating a wallet for the team.

### Stock Operations

- **List Stocks**
  - **Endpoint**: `GET /stocks`
  - **Auth Type**: Bearer Token
  - **Description**: Returns a list of all stocks available in the database.

- **Invest in a Stock (User)**
  - **Endpoint**: `POST /users/:user_id/stocks/invest`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "stock_id": "c6c10b8d-dab7-4e3d-b29e-80d28e88d82d",
      "amount": 100
    }
    ```
  - **Description**: Allows a user to invest a specified amount in a particular stock.

- **Invest in a Stock (Team)**
  - **Endpoint**: `POST /teams/:team_id/stocks/invest`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "stock_id": "c6c10b8d-dab7-4e3d-b29e-80d28e88d82d",
      "amount": 100
    }
    ```
  - **Description**: Allows a team to invest a specified amount in a particular stock.

- **Update Stock Price (User)**
  - **Endpoint**: `POST /users/:user_id/stocks/update_price`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "stock_id": "c6c10b8d-dab7-4e3d-b29e-80d28e88d82d",
      "new_price": 150
    }
    ```
  - **Description**: Updates the price of a stock for a user, affecting profit/loss calculations.

- **Update Stock Price (Team)**
  - **Endpoint**: `POST /teams/:team_id/stocks/update_price`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "stock_id": "c6c10b8d-dab7-4e3d-b29e-80d28e88d82d",
      "new_price": 150
    }
    ```
  - **Description**: Updates the price of a stock for a team, affecting profit/loss calculations.

### Wallet Management

- **Show Wallet (User)**
  - **Endpoint**: `GET /users/:user_id/wallets`
  - **Auth Type**: Bearer Token
  - **Description**: Retrieves the wallet details for a specified user.

- **Show Wallet (Team)**
  - **Endpoint**: `GET /teams/:team_id/wallets`
  - **Auth Type**: Bearer Token
  - **Description**: Retrieves the wallet details for a specified team.

- **Wallet Funds Deposit (User)**
  - **Endpoint**: `POST /users/:user_id/wallets/deposit`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "amount": 1000
    }
    ```
  - **Description**: Increases the wallet balance of a user by the specified amount.

- **Wallet Funds Deposit (Team)**
  - **Endpoint**: `POST /teams/:team_id/wallets/deposit`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "amount": 1000
    }
    ```
  - **Description**: Increases the wallet balance of a team by the specified amount.

- **Wallet Funds Transfer (User)**
  - **Endpoint**: `POST /users/:user_id/wallets/transfer`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "amount": 100,
      "receiver_wallet_id": "f8b5d7e8-67f2-4b57-a823-bb663f8905e4"
    }
    ```
  - **Description**: Transfers funds from the user's wallet to another specified wallet.

- **Wallet Funds Transfer (Team)**
  - **Endpoint**: `POST /teams/:team_id/wallets/transfer`
  - **Auth Type**: Bearer Token
  - **Params**:
    ```json
    {
      "amount": 100,
      "receiver_wallet_id": "f8b5d7e8-67f2-4b57-a823-bb663f8905e4"
    }
    ```
  - **Description**: Transfers funds from the team's wallet to another specified wallet.

### Transaction Management

- **Get Transaction History (User)**
  - **Endpoint**: `GET /users/:user_id/wallets/transactions`
  - **Auth Type**: Bearer Token
  - **Description**: Provides a history of all transactions associated with the user's wallet.

- **Get Transaction History (Team)**
  - **Endpoint**: `GET /teams/:team_id/wallets/transactions`
  - **Auth Type**: Bearer Token
  - **Description**: Provides a history of all transactions associated with the team's wallet.

### Stock Prices (Using the latest_stock_price gem)

- **Show All Stock Prices**
  - **Endpoint**: `GET /stocks/price_all`
  - **Auth Type**: Bearer Token
  - **Description**: Fetches and displays the latest prices for all stocks available in the database.

## Features Overview

- **User Management**: Users can register, log in, and log out of the system, with secure JWT authentication.
- **Wallet Management**: Each user and team has an automatically created wallet, which allows them to view balances, top up, and transfer funds.
- **Stock Investment**: Users and teams can invest in stocks, update stock prices, and track profit/loss.
- **Transaction Logging**: All wallet transactions are recorded in the transactions table, ensuring traceability.
- **Stock Price Retrieval**: The integrated stock price retrieval feature keeps users informed of the latest stock values.

## Database Schema

- **Users, Teams, and Stocks**: Each of these entities has a dedicated table that holds relevant information such as identifiers, attributes, and associations.
- **Wallets Table**: This table is linked to users, teams, and stocks through polymorphic associations, enabling dynamic relationships.
- **Transactions Table**: This table logs all transfers between wallets, with references to both the sender and receiver for accountability.
