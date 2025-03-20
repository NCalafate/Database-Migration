# AdventureWorks Database Migration Project

## Table of Contents
- [Introduction](#introduction)
- [Requirements Specification](#requirements-specification)
- [Relational Model](#relational-model)
- [Database Layout](#database-layout)
- [Data Migration Verification](#data-migration-verification)
- [Programming](#programming)
- [Indexes](#indexes)
- [Backup and Recovery](#backup-and-recovery)
- [Security and Access Control](#security-and-access-control)
- [Concurrency Control](#concurrency-control)
- [MongoDB Integration](#mongodb-integration)
- [Demonstration](#demonstration)
- [Conclusions](#conclusions)

---

## Introduction
The purpose of this project is to restructure the AdventureWorks group, particularly focusing on the cycling equipment company, AdventureWorks. The main objective is to develop a new system to efficiently manage product sales, replacing the old Excel-based method with a modern solution using SQL Server Management Studio.

Key aspects of this project include:
- Designing and implementing an ER model using ERDPlus, tailored to the needs of AdventureWorks.
- Transferring old data to the new system without any data loss.
- Implementing new procedures to streamline operations, including centralized customer management and a personal account system.

## Requirements Specification
| ID | Description | Implemented (Y/N) |
|----|------------|------------------|
| R2.1.1.1 | Design an ER Model covering the business entities from the dataset analysis. | Y |
| R2.1.1.2 | Products are organized into subcategories grouped under general categories. | Y |
| R2.1.1.3 | Customers authenticate via email and password. | Y |
| R2.1.1.4 | The system generates and sends a new password to customers requesting recovery. | Y |
| R2.1.1.5 | Customers must answer a security question to recover their password. | Y |

For the full list of requirements, refer to the project documentation.

## Relational Model
The project includes:
- An **Entity-Relationship Diagram (ERD)** built with ERDPlus.
- A **Relational Model Diagram** defining database relationships.

## Database Layout
### Tables and Storage Requirements
Tables are organized in schemas such as `Defaults`, `Users`, `Orders`, `Products`, and `Logs`, each with specific purposes.

### Filegroups
Each schema is stored in its respective filegroup with defined size limits and growth parameters.

### Schemas Overview
- **Defaults**: Stores predefined data like occupations, security questions, and sales territories.
- **Users**: Contains customer-related data including delivery addresses and account authentication.
- **Orders**: Manages customer orders and purchased products.
- **Products**: Stores product details, categories, and specifications.
- **Logs**: Maintains administrative logs and error handling.
- **Monitoring**: Tracks schema changes and table space usage.

## Data Migration Verification
### Original Database Queries
Data was imported from old Excel files into the new database using SQL Server's Flat File Import feature. Checks were performed to ensure correct collation (`SQL_Latin1_General_CP1_CI_AS`) and data type assignments.

### New Database Queries
Tests included:
- Verifying customer addresses.
- Matching customer counts between old and new databases.
- Ensuring imported sales records align with the correct customers.

## Programming
### Views
- **CustomerPurchases**: Retrieves purchases of a specific customer.
- **TotalSalesPerYear**: Aggregates total sales per year.
- **SalesPerCategoryPerCountry**: Shows total sales by product category per country.

### Stored Procedures
- **sp_ErrorHandling**: Centralized error management.
- **sp_UpdateAccess**: Modifies user access levels.
- **sp_NewPassword**: Handles password recovery.
- **sp_RecordTableSpaceUsage**: Logs table space usage over time.

### Triggers
- **tr_RecoveryPassword**: Simulates email notifications for password recovery requests.

## Indexes
Indexes were created to optimize data retrieval:
- `idx_City`: Speeds up address-related queries.
- `idx_OrderDate`: Optimizes sales record lookups.
- `idx_CategoryKey`: Enhances category-based queries.
- `idx_Color`: Improves filtering by product color.

## Backup and Recovery
### Backup Strategy
- **Full Backup**: Weekly on Sundays at midnight.
- **Differential Backup**: Every 12 hours.
- **Transaction Log Backup**: Every hour.

### Recovery Scenarios
1. **Complete Database Loss**
   - Restore the latest full backup.
   - Apply the latest differential backup.
   - Apply transaction log backups.
2. **Partial Data Loss**
   - Restore the latest full backup.
   - Apply the latest differential backup.
   - Apply transaction log backups to restore lost records.

## Security and Access Control
### User Roles
- **AdminUser**: Full access to all database functions.
- **SalesPersonUser**: Full access to sales-related tables, read-only access to others.
- **SalesTerritoryUser**: Can only view `Business.SoutheastSales`.

### Encryption
- Passwords, security questions, and answers are hashed using SHA-256 with unique salts.

## Concurrency Control
Transaction isolation levels were applied to ensure data integrity:
- **READ COMMITTED**: Used for adding products to sales.
- **REPEATABLE READ**: Prevents mid-transaction data changes.
- **SERIALIZABLE**: Ensures consistency in stock updates and annual sales calculations.

## MongoDB Integration
MongoDB was used to offload reporting queries from the SQL Server database. Implemented queries include:
- **Sales history by city**
- **Total product sales per month/year**
- **Product quantities by model**

## Demonstration
### Execution Order
1. `Create Database.sql`
2. `Procedures, Functions, and Triggers.sql`
3. `Views.sql`
4. `Migration.sql`
5. `Demonstrations.sql`

MongoDB setup requires exporting data from SQL Server to JSON and importing it into MongoDB.

## Conclusions
The project successfully transitioned AdventureWorks to a modern database system. All data was migrated without loss, and new functionalities were integrated to enhance efficiency and security. The system now includes:
- **Improved data integrity and security measures**
- **Optimized queries and indexing for performance**
- **A NoSQL reporting solution for sales data**

With this implementation, AdventureWorks is equipped with a scalable and future-proof data management system.
