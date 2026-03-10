-- =============================================================
-- Title: Automated Material Shortage Early-Warning Script
-- Purpose: Identify PCBA components with stock-out risk within 30 days.
-- Logic: (On-Hand + Open POs) - (Planned Requirements) < Safety Stock
-- =============================================================

SELECT 
    m.Part_Number, 
    m.Description, 
    m.Safety_Stock,
    inv.On_Hand_Qty,
    COALESCE(SUM(po.Quantity), 0) AS Open_PO_Qty,
    COALESCE(SUM(req.Required_Qty), 0) AS Total_Demand,
    -- Calculate Projected Inventory
    (inv.On_Hand_Qty + COALESCE(SUM(po.Quantity), 0) - COALESCE(SUM(req.Required_Qty), 0)) AS Projected_Inventory
FROM 
    Material_Master m
JOIN 
    Inventory_Table inv ON m.Part_Number = inv.Part_Number
LEFT JOIN 
    Purchase_Orders po ON m.Part_Number = po.Part_Number 
    AND po.Due_Date <= DATEADD(day, 30, GETDATE())
LEFT JOIN 
    Production_Requirements req ON m.Part_Number = req.Part_Number 
    AND req.Plan_Date <= DATEADD(day, 30, GETDATE())
GROUP BY 
    m.Part_Number, m.Description, m.Safety_Stock, inv.On_Hand_Qty
HAVING 
    (inv.On_Hand_Qty + COALESCE(SUM(po.Quantity), 0) - COALESCE(SUM(req.Required_Qty), 0)) < m.Safety_Stock;
