-- =============================================================
-- PROJECT: Automated Material Shortage Early-Warning Tool
-- FUNCTION: Proactive Stock-out Risk Identification (30-Day Window)
-- =============================================================

-- 1. DEFINE OUTPUT COLUMNS: Select the key attributes needed for shortage analysis
SELECT 
    m.Part_Number,      -- Unique identifier for the component
    m.Description,      -- Material description (e.g., IC, Resistor, Capacitor)
    m.Safety_Stock,     -- The minimum inventory level required to buffer against uncertainty
    inv.On_Hand_Qty,    -- Current physical stock available in the warehouse

    -- 2. CALCULATE IN-TRANSIT SUPPLY: Sum up all open Purchase Orders arriving within 30 days
    COALESCE(SUM(po.Quantity), 0) AS Open_PO_Qty,

    -- 3. CALCULATE TOTAL DEMAND: Sum up all production requirements (MPS/Orders) for the next 30 days
    COALESCE(SUM(req.Required_Qty), 0) AS Total_Demand,

    -- 4. PROJECTED INVENTORY: Final formula to predict stock levels (Current + Supply - Demand)
    (inv.On_Hand_Qty + COALESCE(SUM(po.Quantity), 0) - COALESCE(SUM(req.Required_Qty), 0)) AS Projected_Inventory

-- 5. DATA SOURCE MAPPING: Connect the master data with real-time inventory and transactional tables
FROM 
    Material_Master m
JOIN 
    Inventory_Table inv ON m.Part_Number = inv.Part_Number

-- 6. LINK SUPPLY DATA: Join with Purchase Orders, filtering for the 30-day lead-time window
LEFT JOIN 
    Purchase_Orders po ON m.Part_Number = po.Part_Number 
    AND po.Due_Date <= DATEADD(day, 30, GETDATE())

-- 7. LINK DEMAND DATA: Join with Production Requirements, filtering for the 30-day planning horizon
LEFT JOIN 
    Production_Requirements req ON m.Part_Number = req.Part_Number 
    AND req.Plan_Date <= DATEADD(day, 30, GETDATE())

-- 8. DATA AGGREGATION: Group results by part number to consolidate multiple POs or Demand lines
GROUP BY 
    m.Part_Number, m.Description, m.Safety_Stock, inv.On_Hand_Qty

-- 9. CRITICAL ALERT FILTER: Only show items where the projected inventory is below the safety stock
HAVING 
    (inv.On_Hand_Qty + COALESCE(SUM(po.Quantity), 0) - COALESCE(SUM(req.Required_Qty), 0)) < m.Safety_Stock;
