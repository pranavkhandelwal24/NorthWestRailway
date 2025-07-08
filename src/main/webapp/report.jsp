<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>

<%
    // Prevent direct access
    if (request.getAttribute("users") == null) {
        response.sendRedirect("member.jsp");
        return;
    }

    // Get attributes with null checks
    List<String> users = (List<String>) request.getAttribute("users");
    Map<String, Map<String, Integer>> userStats = (Map<String, Map<String, Integer>>) request.getAttribute("userStats");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String reportPeriod = (String) request.getAttribute("reportPeriod");
    Map<String, Integer> totals = (Map<String, Integer>) request.getAttribute("totals");
    String currentDate = (String) request.getAttribute("currentDate");
    
    // Get user info from session
    String userName = (String) session.getAttribute("username");
    String userFullName = (String) session.getAttribute("fullName"); 
    
    // Initialize defaults if null
    if (users == null) users = Collections.emptyList();
    if (userStats == null) userStats = Collections.emptyMap();
    if (totals == null) totals = Collections.emptyMap();
    if (startDate == null) startDate = "N/A";
    if (endDate == null) endDate = "N/A";
    if (reportPeriod == null) reportPeriod = "Report";
    if (currentDate == null || currentDate.equals("01.01.1970")) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
        currentDate = sdf.format(new java.util.Date());
    }
    if (userName == null) userName = "System";
    if (userFullName == null) userFullName = "System User";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NWR Department Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/member.css">
    <style>
        /* Report-specific styles */
        .report-container {
            max-width: 100%;
            margin: 30px auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .report-header {
            padding: 25px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.2);
        }
        
        .report-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 5px;
            letter-spacing: 1px;
        }
        
        .report-period {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        
        .report-date {
            font-size: 16px;
            background: rgba(255,255,255,0.2);
            display: inline-block;
            padding: 8px 20px;
            border-radius: 30px;
            margin-bottom: 10px;
        }
        
        .report-generated {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .report-table-container {
            overflow-x: auto;
            padding: 20px;
        }
        
        .report-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        
        .report-table th, .report-table td {
            border: 1px solid #ddd;
            padding: 10px 12px;
            text-align: center;
            vertical-align: middle;
        }
        
        .report-table th {
            background-color: #f5f5f5;
            font-weight: 600;
            color: #333;
            position: sticky;
            top: 0;
        }
        
        .report-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        .report-table tr:hover {
            background-color: #f1f1f1;
        }
        
        .report-table .total-row {
            font-weight: bold;
            background-color: #e9e9e9 !important;
        }
        
        .report-footer {
            padding: 15px 25px;
            background-color: #f5f5f5;
            border-top: 1px solid #ddd;
            text-align: right;
            font-size: 14px;
            color: #666;
        }
        
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            padding: 20px;
            background-color: #f5f5f5;
            border-top: 1px solid #ddd;
        }
        
        .btn-success {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 20 px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-success:hover {
            background-color: #218838;
        }

        /* Export Dialog Styles */
        .export-dialog {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        
        .export-dialog.active {
            opacity: 1;
            visibility: visible;
        }
        
        .export-dialog-content {
            background: white;
            padding: 25px;
            border-radius: 8px;
            width: 400px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            transform: translateY(-20px);
            transition: all 0.3s ease;
        }
        
        .export-dialog.active .export-dialog-content {
            transform: translateY(0);
        }

        .export-dialog-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .export-options {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 20px;
        }

        .export-option {
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .export-option:hover {
            border-color: #28a745;
        }

        .export-option.selected {
            border-color: #28a745;
            background-color: rgba(40, 167, 69, 0.1);
        }

        .export-option-title {
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 5px;
        }

        .export-option-desc {
            font-size: 13px;
            color: #666;
            padding-left: 25px;
        }

        .export-dialog-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .export-dialog-buttons button {
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }

        .export-dialog-close {
            background: #f5f5f5;
            border: 1px solid #ddd;
        }

        .export-dialog-close:hover {
            background: #e9e9e9;
        }

        .export-dialog-confirm {
            background: #28a745;
            color: white;
            border: none;
        }

        .export-dialog-confirm:hover {
            background: #218838;
        }
        
        /* Notification Styles */
.notification {
    position: relative;
    padding: 18px 25px;
    border-radius: 12px;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    display: flex;
    align-items: center;
    animation: slideIn 0.4s forwards;
    max-width: 450px;
    z-index: 10000;
    margin-bottom: 15px;
    border-left: 6px solid;
    background: white;
    transform: translateX(100%);
    opacity: 0;
    transition: all 0.4s ease;
}

.notification.show {
    transform: translateX(0);
    opacity: 1;
}

.notification.hide {
    transform: translateX(100%);
    opacity: 0;
}

.notification-success {
    border-left-color: #28a745;
    background: linear-gradient(to right, rgba(212, 237, 218, 0.9), white 30%);
}

.notification-error {
    border-left-color: #dc3545;
    background: linear-gradient(to right, rgba(248, 215, 218, 0.9), white 30%);
}

.notification-icon {
    font-size: 28px;
    margin-right: 20px;
    min-width: 40px;
    text-align: center;
}

.notification-success .notification-icon {
    color: #28a745;
}

.notification-error .notification-icon {
    color: #dc3545;
}

.notification-content {
    flex-grow: 1;
}

.notification-title {
    font-weight: 700;
    font-size: 1.1rem;
    margin-bottom: 5px;
}

.notification-message {
    font-size: 1rem;
    line-height: 1.4;
}

.notification-close {
    background: none;
    border: none;
    color: #6c757d;
    font-size: 1.2rem;
    cursor: pointer;
    padding: 5px;
    margin-left: 15px;
    transition: all 0.3s;
}

.notification-close:hover {
    color: #343a40;
    transform: scale(1.1);
}

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}
        
        
        
        @media print {
            @page {
                size: A4 landscape;
            }
            .report-table {
                width: 100% !important;
                table-layout: fixed !important;
            }
            .report-table th,
            .report-table td {
                font-size: 10px;
                padding: 4px 6px;
                word-break: break-word;
            }
        }
        
        @media print {
            body {
                background: white;
                padding: 0;
                margin: 0;
            }
            
            .report-container {
                box-shadow: none;
                border: none;
                margin: 0;
                padding: 0;
            }
            
            .action-buttons {
                display: none;
            }
            
            .report-table th {
                background-color: #f5f5f5 !important;
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
        }
        
        @media (max-width: 768px) {
            .report-table th, .report-table td {
                padding: 8px 10px;
                font-size: 13px;
            }
            
            .report-title {
                font-size: 20px;
            }
            
            .report-period {
                font-size: 18px;
            }
            
            .action-buttons {
                flex-wrap: wrap;
            }
            
            .export-dialog-content {
                width: 90%;
                max-width: 350px;
            }
        }

        /* Notification styles */
        
    </style>
</head>
<body>

<!-- Export Dialog -->
<div id="exportDialog" class="export-dialog">
    <div class="export-dialog-content">
        <div class="export-dialog-title">
            <i class="fas fa-file-export"></i> Select Export Format
        </div>
        
        <div class="export-options">
            <div class="export-option selected" data-format="xlsx">
                <div class="export-option-title">
                    <i class="fas fa-file-excel"></i> Excel Workbook (.xlsx)
                </div>
                <div class="export-option-desc">
                    Modern format with better compatibility. May have some formatting limitations.
                </div>
            </div>
            
            <div class="export-option" data-format="xls">
                <div class="export-option-title">
                    <i class="fas fa-file-excel"></i> Excel 97-2003 (.xls)
                </div>
                <div class="export-option-desc">
                    Legacy format with basic formatting preserved (borders, headers, etc.)
                </div>
            </div>
        </div>
        
        <div class="export-dialog-buttons">
            <button class="export-dialog-close">Cancel</button>
            <button class="export-dialog-confirm">Download</button>
        </div>
    </div>
</div>


<!-- Report Content -->
<div class="report-container">
    <!-- Report Header -->
    <div class="report-header">
        <div class="report-title">NORTH WESTERN RAILWAY</div>
        <div class="report-period">CLEARANCE REPORT</div>
        <div class="report-date">PERIOD <%= startDate %> TO <%= endDate %></div>
        <div class="report-generated">Generated on: <%= currentDate %></div>
    </div>
    
    <!-- Report Table -->
    <div class="report-table-container">
        <% if (users.isEmpty()) { %>
            <div style="padding: 40px; text-align: center;">
                <i class="fas fa-file-alt" style="font-size: 3rem; color: #ccc;"></i>
                <h3 style="color: var(--primary); margin: 10px 0;">No Report Data Available</h3>
                <p style="color: var(--gray);">No users found in your department or no data for the selected period</p>
                <a href="member.jsp" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>
        <% } else { %>
            <table class="report-table">
                <thead>
                    <tr>
                        <th rowspan="3" style="min-width: 120px;">Username</th>
                        <th colspan="10" style="text-align: center;">Clearance</th>
                        <th colspan="2" style="text-align: center;"></th>
                        <th colspan="2" style="text-align: center;">Remarks</th>
                    </tr>
                    <tr>
                        <th colspan="2">Opening Balance</th>
                        <th colspan="2">Received</th>
                        <th colspan="2">Vetted</th>
                        <th colspan="2">Returned</th>
                        <th colspan="2">Closing Balance</th>
                        <th colspan="2">Put Up Files</th>
                        <th colspan="2">Files Pending</th>
                    </tr>
                    <tr>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                        <th>E-office</th>
                        <th>IRPSM</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (String user : users) { 
                        Map<String, Integer> userData = userStats.getOrDefault(user, new HashMap<>());
                    %>
                        <tr>
                            <td><%= user %></td>
                            <td><%= userData.getOrDefault("opening_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("opening_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("received_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("received_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("vetted_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("vetted_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("returned_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("returned_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("closing_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("closing_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("putup_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("putup_irpsm", 0) %></td>
                            <td><%= userData.getOrDefault("pending_eoffice", 0) %></td>
                            <td><%= userData.getOrDefault("pending_irpsm", 0) %></td>
                        </tr>
                    <% } %>
                    <tr class="total-row">
                        <td>Total</td>
                        <td><%= totals.getOrDefault("opening_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("opening_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("received_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("received_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("vetted_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("vetted_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("returned_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("returned_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("closing_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("closing_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("putup_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("putup_irpsm", 0) %></td>
                        <td><%= totals.getOrDefault("pending_eoffice", 0) %></td>
                        <td><%= totals.getOrDefault("pending_irpsm", 0) %></td>
                    </tr>
                </tbody>
            </table>
        <% } %>
    </div>
    
    <!-- Action Buttons -->
    <% if (!users.isEmpty()) { %>
        <div class="action-buttons">
            <button onclick="window.print()" class="btn btn-primary">
                <i class="fas fa-print"></i> Print Report
            </button>
            <button id="exportExcelBtn" class="btn btn-success">
                <i class="fas fa-file-excel"></i> Export to Excel
            </button>
            <a href="member.jsp" class="btn btn-primary" style="text-decoration:none;">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
    <% } %>
    
    <!-- Report Footer -->
    <div class="report-footer">
        <p>Generated by <%= userFullName %> (<%= userName %>) using NWR System - <%= currentDate %></p>
    </div>
</div>

<!-- Notification container -->
<div id="notificationContainer" style="position: fixed; top: 20px; right: 20px; max-width: 450px; z-index: 10000; display: flex; flex-direction: column; gap: 15px;"></div>

<!-- SheetJS Library -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
// Safe session variable access
const jsFirstName = '<%= session.getAttribute("fullName") != null ? session.getAttribute("fullName") : "" %>';
const jsUsername = '<%= session.getAttribute("username") != null ? session.getAttribute("username") : "" %>';

let selectedFormat = 'xlsx';
let isExporting = false;

// Show export dialog with animation
function showExportDialog() {
    if (isExporting) return;
    
    const dialog = document.getElementById('exportDialog');
    dialog.classList.add('active');
    
    // Set up option selection
    const options = document.querySelectorAll('.export-option');
    options.forEach(option => {
        option.addEventListener('click', function() {
            options.forEach(opt => opt.classList.remove('selected'));
            this.classList.add('selected');
            selectedFormat = this.dataset.format;
        });
    });
    
    // Close button
    document.querySelector('.export-dialog-close').addEventListener('click', function() {
        dialog.classList.remove('active');
    });
    
    // Confirm button
    document.querySelector('.export-dialog-confirm').addEventListener('click', function() {
        if (isExporting) return;
        isExporting = true;
        dialog.classList.remove('active');
        
        if(selectedFormat === 'xlsx') {
            exportToXLSX();
        } else {
            exportToXLS();
        }
        
        setTimeout(() => { isExporting = false; }, 1000);
    });
}


function exportToXLSX() {
    try {
        const table = document.querySelector('.report-table');
        if (!table) {
            alert('No report table found.');
            return;
        }

        // Clone the table to avoid modifying the original
        const clonedTable = table.cloneNode(true);
        
        // Remove the Actions column if it exists
        const actionHeaderIndex = Array.from(clonedTable.rows[0].cells).findIndex(
            cell => cell.textContent.trim() === 'Actions'
        );
        if (actionHeaderIndex !== -1) {
            for (let row of clonedTable.rows) {
                if (row.cells.length > actionHeaderIndex) {
                    row.deleteCell(actionHeaderIndex);
                }
            }
        }

        // Create workbook and worksheet
        const wb = XLSX.utils.book_new();
        let ws = XLSX.utils.table_to_sheet(clonedTable);

        // Date formatting function
        function formatDate(d) {
            const dd = String(d.getDate()).padStart(2, '0');
            const mm = String(d.getMonth() + 1).padStart(2, '0');
            const yyyy = d.getFullYear();
            return dd + '-' + mm + '-' + yyyy;
        }

        // Get current date and date 30 days ago
        const today = new Date();
        const startDate = new Date(today);
        startDate.setDate(today.getDate() - 30);

        // Create header data with merged cells
        const headerData = [
            ["NORTH WESTERN RAILWAY", , , , , , , , , , , , , , ], // 15 columns
            ["CLEARANCE REPORT", , , , , , , , , , , , , , ],
            ["PERIOD " + formatDate(startDate) + " TO " + formatDate(today), , , , , , , , , , , , , , ],
            [] // empty row
        ];
        
        // Convert the table data to an array of arrays
        const tableData = XLSX.utils.sheet_to_json(ws, {header: 1});
        
        // Combine header and table data
        const allData = [...headerData, ...tableData];
        
        // Add footer
        allData.push([], ["Generated by " + jsFirstName + " (" + jsUsername + ") using NWR System - " + formatDate(today)]);
        
        // Create new worksheet with the combined data
        ws = XLSX.utils.aoa_to_sheet(allData);

        // Add merged cells for headers
        if (!ws['!merges']) ws['!merges'] = [];
        ws['!merges'].push(
            {s: {r: 0, c: 0}, e: {r: 0, c: 14}}, // Merge row 1 (A-O)
            {s: {r: 1, c: 0}, e: {r: 1, c: 14}}, // Merge row 2 (A-O)
            {s: {r: 2, c: 0}, e: {r: 2, c: 14}}  // Merge row 3 (A-O)
        );

        // Set column styles and alignment
        const range = XLSX.utils.decode_range(ws['!ref']);
        
        // Set column widths
        ws['!cols'] = [];
        const headerRow = clonedTable.rows[0];
        for (let i = 0; i < headerRow.cells.length; i++) {
            const width = Math.max(10, Math.min(30, headerRow.cells[i].textContent.length + 2));
            ws['!cols'].push({wch: width});
        }
        
        // Default cell style (center and middle aligned)
        const defaultStyle = {
            alignment: {
                horizontal: 'center',
                vertical: 'center',
                wrapText: true
            }
        };
        
        // Apply default style to all cells
        for (let r = 0; r <= range.e.r; r++) {
            for (let c = 0; c <= range.e.c; c++) {
                const cellRef = XLSX.utils.encode_cell({r, c});
                if (ws[cellRef]) {
                    ws[cellRef].s = {
                        ...defaultStyle,
                        ...(ws[cellRef].s || {})
                    };
                }
            }
        }
        
        // Style the header rows (rows 0-3)
        for (let r = 0; r < 4; r++) {
            const cellRef = XLSX.utils.encode_cell({r, c: 0});
            if (ws[cellRef]) {
                ws[cellRef].s = {
                    font: { bold: true, sz: 12 },
                    alignment: { 
                        horizontal: 'center', 
                        vertical: 'center',
                        wrapText: true
                    }
                };
            }
        }
        
        // Style the table header (row 4)
        for (let c = 0; c <= range.e.c; c++) {
            const cellRef = XLSX.utils.encode_cell({r: 4, c});
            if (ws[cellRef]) {
                ws[cellRef].s = {
                    font: { bold: true, color: { rgb: "FFFFFF" } },
                    fill: { fgColor: { rgb: "0056B3" } },
                    alignment: { 
                        horizontal: 'center', 
                        vertical: 'center',
                        wrapText: true
                    }
                };
            }
        }
        
        // Special handling for username column (left aligned)
        const columnHeaders = allData[4]; // Row with column headers
        if (columnHeaders) {
            const usernameColIndex = columnHeaders.findIndex(
                cell => typeof cell === 'string' && cell.trim().toLowerCase() === 'username'
            );
            if (usernameColIndex !== -1) {
                for (let r = 5; r <= range.e.r; r++) {
                    const cellRef = XLSX.utils.encode_cell({r, c: usernameColIndex});
                    if (ws[cellRef]) {
                        ws[cellRef].s = {
                            ...(ws[cellRef].s || {}),
                            alignment: { 
                                horizontal: 'left', 
                                vertical: 'center',
                                wrapText: true
                            }
                        };
                    }
                }
            }
        }

        // Style the footer row
        const footerRow = range.e.r;
        const footerCellRef = XLSX.utils.encode_cell({r: footerRow, c: 0});
        if (ws[footerCellRef]) {
            ws[footerCellRef].s = {
                alignment: { 
                    horizontal: 'right', 
                    vertical: 'center',
                    wrapText: true
                },
                font: { italic: true }
            };
        }

        // Add the worksheet to the workbook
        XLSX.utils.book_append_sheet(wb, ws, "Clearance Report");

        // Generate filename and save
        const fileName = "NWR_Clearance_Report_" + formatDate(startDate) + "_to_" + formatDate(today) + ".xlsx";
        XLSX.writeFile(wb, fileName);

        showNotification('success', 'Excel file (XLSX) generated successfully.');
    } catch (error) {
        console.error('Export error:', error);
        showNotification('error', 'Failed to generate Excel file: ' + error.message);
    }
}





// Export to XLSX with improved formatting (Not Using Currently)
function exportToXLSXtemp() {
    try {
        const table = document.querySelector('.report-table');
        if (!table) {
            showNotification('error', 'No report table found.');
            return;
        }

        // Create workbook
        const wb = XLSX.utils.book_new();
        
        // Convert table to worksheet
        const ws = XLSX.utils.table_to_sheet(table);
        
        // Add title rows
        XLSX.utils.sheet_add_aoa(ws, [
            ["NORTH WESTERN RAILWAY"],
            ["CLEARANCE REPORT"],
            ["PERIOD <%= startDate %> TO <%= endDate %>"],
            [], // empty row
            ["Generated by " + jsFirstName + " (" + jsUsername + ") using NWR System - <%= currentDate %>"]
        ], { origin: -1 }); // Add above the table

        // Set column widths
        ws['!cols'] = Array(15).fill({wch: 12});
        ws['!cols'][0] = {wch: 20}; // Wider first column for usernames

        // Create filename
        const fileName = "NWR_Clearance_Report_" + 
            "<%= startDate %>".replace(/\./g, '-') + 
            "_to_" + 
            "<%= endDate %>".replace(/\./g, '-') + 
            ".xlsx";

        // Finalize workbook
        XLSX.utils.book_append_sheet(wb, ws, "Clearance Report");
        
        // Export file
        XLSX.writeFile(wb, fileName);

        showNotification('success', 'Excel file (XLSX) generated successfully.');
    } catch (error) {
        console.error('Export error:', error);
        showNotification('error', 'Failed to generate Excel file: ' + error.message);
    }
}

function exportToXLS() {
    try {
        const table = document.querySelector('.report-table');
        if (!table) {
            showNotification('error', 'No report table found.');
            return;
        }

        // Create HTML with table data and styles
        let html = `
        <html xmlns:o="urn:schemas-microsoft-com:office:office" 
              xmlns:x="urn:schemas-microsoft-com:office:excel" 
              xmlns="http://www.w3.org/TR/REC-html40">
        <head>
            <!--[if gte mso 9]>
            <xml>
                <x:ExcelWorkbook>
                    <x:ExcelWorksheets>
                        <x:ExcelWorksheet>
                            <x:Name>NWR Clearance Report</x:Name>
                            <x:WorksheetOptions>
                                <x:DisplayGridlines/>
                                <x:PrintGridlines/>
                            </x:WorksheetOptions>
                            <x:PageSetup>
                                <x:Layout x:Orientation="Landscape"/>
                                <x:PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
                            </x:PageSetup>
                        </x:ExcelWorksheet>
                    </x:ExcelWorksheets>
                </x:ExcelWorkbook>
            </xml>
            <![endif]-->
            <style>
                body { 
                    
                    font-family: Arial, sans-serif; 
                    font-size: 10pt; 
                    margin: 0;
                    padding: 0;
                }
                table { 
                    border-collapse: collapse; 
                    width: 100%; 
                    font-size: 10pt;
                }
                th { 
                    background: #0056b3 !important;
                    color: white !important;
                    padding: 8px !important;
                    text-align: center !important;
                    font-weight: bold !important;
                    border: 1px solid #002a5a !important;
                }
                td { 
                    padding: 6px 8px !important;
                    border: 1px solid #d9d9d9 !important;
                    vertical-align: middle !important;
                    color: #002a5a !important;
                    text-align: center !important;
                    font-size: 9pt;
                }
                tr:nth-child(even) td {
                    background: #f2f8ff !important;
                }
                .report-header { 
                    border: none !important; 
                    background-color: #0056b3 !important; 
                    font-weight: bold !important;
                    color: white !important;
                    font-size: 11pt !important;
                    padding: 10px !important;
                }
                .subject-cell {
                    text-align: left !important;
                    padding-left: 8px !important;
                }
            </style>
        </head>
        <body>
            <table>
                <tr><th class="report-header" colspan="15">NORTH WESTERN RAILWAY</th></tr>
                <tr><th class="report-header" colspan="15">CLEARANCE REPORT</th></tr>
                <tr><th class="report-header" colspan="15">PERIOD <%= startDate %> TO <%= endDate %></th></tr>
                <tr><td colspan="15" style="border:none;">&nbsp;</td></tr>`;

        // Add table headers
        const thead = table.querySelector('thead');
        html += thead.outerHTML;

        // Add table body
        const tbody = table.querySelector('tbody');
        html += tbody.outerHTML;

        // Add footer
        html += '<tr><td colspan="15" style="text-align:right;border:none;padding-top:10px;">Generated by ' + 
                jsFirstName + ' (' + jsUsername + ') using NWR System - <%= currentDate %></td></tr>';

        html += '</table></body></html>';

        // Create blob with UTF-8 BOM
        const blob = new Blob(["\uFEFF" + html], {type: 'application/vnd.ms-excel'});
        const url = URL.createObjectURL(blob);

        // Create download link
        const a = document.createElement('a');
        a.href = url;
        a.download = "NWR_Clearance_Report_" + 
            "<%= startDate %>".replace(/\./g, '-') + 
            "_to_" + 
            "<%= endDate %>".replace(/\./g, '-') + 
            ".xls";

        // Trigger download
        document.body.appendChild(a);
        a.click();

        // Cleanup
        setTimeout(() => {
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }, 100);

        showNotification('success', 'Excel file (XLS) generated successfully.');
    } catch (error) {
        console.error('Export error:', error);
        showNotification('error', 'Failed to generate Excel file: ' + error.message);
    }
}


// Notification function with prevention of duplicates
function showNotification(type, message) {
    const container = document.getElementById('notificationContainer');
    if (!container) return;
    
    // Remove any existing notifications
    container.innerHTML = '';
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    const iconClass = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
    const title = type === 'success' ? 'Success!' : 'Error!';
    
    notification.innerHTML = 
        '<div class="notification-icon">' +
            '<i class="fas ' + iconClass + '"></i>' +
        '</div>' +
        '<div class="notification-content">' +
            '<div class="notification-title">' + title + '</div>' +
            '<div class="notification-message">' + message + '</div>' +
        '</div>' +
        '<button class="notification-close"><i class="fas fa-times"></i></button>';
    
    container.appendChild(notification);
    
    // Trigger the show animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Auto-remove after 5 seconds
    const notificationTimeout = setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 5000);
    
    // Close button handler
    notification.querySelector('.notification-close').onclick = function() {
        clearTimeout(notificationTimeout);
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    };
}

// Initialize export button
document.addEventListener('DOMContentLoaded', function() {
    const exportBtn = document.getElementById('exportExcelBtn');
    if (exportBtn) {
        exportBtn.addEventListener('click', showExportDialog);
    }
});
</script>
</body>
</html>