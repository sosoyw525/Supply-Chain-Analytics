# Supply Chain Analytics - Material Management Toolkit

## Project Overview
This repository contains a collection of SQL scripts and data logic designed to optimize **PCBA Material Planning** and **NPI (New Product Introduction)** workflows.

## Key Feature: Automated Shortage Early-Warning System
The primary SQL script in this project solves the "reactive firefighting" problem in supply chain planning. 

### Core Logic:
- **Inventory Integration:** Joins Material Master, Inventory, Open POs, and Production Requirements.
- **Risk Identification:** Calculates **Projected Available Balance (PAB)** on a 30-day rolling window.
- **Actionable Alerts:** Triggers a "Critical" status when projected stock levels fall below the mandated **Safety Stock**.

## Technical Stack
- **Languages:** SQL (PostgreSQL/T-SQL)
- **Concepts:** MRP Logic, Safety Stock Optimization, Lead-time Mitigation, VMI.
