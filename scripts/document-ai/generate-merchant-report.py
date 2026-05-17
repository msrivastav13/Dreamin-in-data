"""
Generate a Pronto Merchant Performance Report PDF with charts, tables, and KPIs.
This demonstrates Document AI's ability to extract structured data from complex documents
containing mixed content (text, charts, tables, numbers).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np
from datetime import datetime

OUTPUT_PATH = "../../document-ai-samples/merchant-performance-report.pdf"

# Report data for Sakura Ramen House
MERCHANT = "Sakura Ramen House"
REPORT_PERIOD = "Q1 2026 (January - March)"
REPORT_DATE = "April 5, 2026"
MERCHANT_ID = "PRN-MER-2024-0887"
TIER = "Plus"
ACCOUNT_MANAGER = "Jessica Chen"

# Monthly metrics
months = ["January", "February", "March"]
orders = [487, 523, 612]
revenue = [14610, 15690, 18360]
avg_order_value = [30.00, 30.00, 30.00]
avg_prep_time = [16.2, 15.8, 14.9]
customer_rating = [4.6, 4.7, 4.8]
on_time_rate = [92.3, 94.1, 96.2]
cancellation_rate = [1.8, 1.4, 1.1]

# Top items
top_items = [
    ("Tonkotsu Ramen", 412, "$14.50", "$5,974"),
    ("Spicy Miso Ramen", 387, "$15.00", "$5,805"),
    ("Gyoza (6pc)", 298, "$8.50", "$2,533"),
    ("Chicken Karaage", 245, "$10.00", "$2,450"),
    ("Edamame", 189, "$5.50", "$1,040"),
]

# Peak hours
hours = list(range(11, 22))
order_volume = [12, 35, 42, 28, 15, 18, 45, 58, 52, 38, 22]

with PdfPages(OUTPUT_PATH) as pdf:
    # Page 1: Cover / Summary
    fig, ax = plt.subplots(figsize=(8.5, 11))
    ax.axis('off')

    ax.text(0.5, 0.92, "PRONTO", fontsize=32, fontweight='bold', ha='center',
            color='#00b37a', family='sans-serif')
    ax.text(0.5, 0.87, "Merchant Performance Report", fontsize=20, ha='center',
            color='#1a1a2e', family='sans-serif')
    ax.text(0.5, 0.82, f"Confidential — Internal Use Only", fontsize=10, ha='center',
            color='#7a7a8a', style='italic')

    # Summary box
    summary_y = 0.72
    ax.text(0.1, summary_y, "Report Summary", fontsize=14, fontweight='bold', color='#1a1a2e')
    summary_y -= 0.04

    summary_fields = [
        ("Merchant Name:", MERCHANT),
        ("Merchant ID:", MERCHANT_ID),
        ("Partnership Tier:", TIER),
        ("Report Period:", REPORT_PERIOD),
        ("Report Generated:", REPORT_DATE),
        ("Account Manager:", ACCOUNT_MANAGER),
    ]
    for label, value in summary_fields:
        summary_y -= 0.035
        ax.text(0.12, summary_y, label, fontsize=10, color='#4a4a5a', fontweight='bold')
        ax.text(0.42, summary_y, value, fontsize=10, color='#1a1a2e')

    # KPIs
    kpi_y = 0.42
    ax.text(0.1, kpi_y, "Q1 2026 Key Performance Indicators", fontsize=14, fontweight='bold', color='#1a1a2e')
    kpi_y -= 0.05

    kpis = [
        ("Total Orders:", "1,622"),
        ("Total Revenue:", "$48,660"),
        ("Average Order Value:", "$30.00"),
        ("Customer Rating:", "4.7 / 5.0"),
        ("Average Prep Time:", "15.6 minutes"),
        ("On-Time Delivery Rate:", "94.2%"),
        ("Cancellation Rate:", "1.4%"),
        ("Repeat Customer Rate:", "62.3%"),
        ("New Customers Acquired:", "234"),
        ("Commission Paid (25%):", "$12,165"),
        ("Net Payout to Merchant:", "$36,495"),
    ]
    for label, value in kpis:
        kpi_y -= 0.033
        ax.text(0.12, kpi_y, label, fontsize=9.5, color='#4a4a5a')
        ax.text(0.52, kpi_y, value, fontsize=9.5, color='#1a1a2e', fontweight='bold')

    pdf.savefig(fig)
    plt.close()

    # Page 2: Order Volume & Revenue Charts
    fig, axes = plt.subplots(2, 1, figsize=(8.5, 11))
    fig.suptitle(f"{MERCHANT} — Order & Revenue Trends", fontsize=14, fontweight='bold', y=0.96)

    # Orders bar chart
    ax1 = axes[0]
    bars = ax1.bar(months, orders, color='#00b37a', width=0.5)
    ax1.set_title("Monthly Order Volume", fontsize=11, fontweight='bold', pad=10)
    ax1.set_ylabel("Number of Orders")
    ax1.set_ylim(0, 700)
    for bar, val in zip(bars, orders):
        ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 10, str(val),
                ha='center', fontsize=10, fontweight='bold')
    ax1.spines['top'].set_visible(False)
    ax1.spines['right'].set_visible(False)

    # Revenue line chart
    ax2 = axes[1]
    ax2.plot(months, revenue, marker='o', color='#1a1a2e', linewidth=2, markersize=8)
    ax2.fill_between(months, revenue, alpha=0.1, color='#00b37a')
    ax2.set_title("Monthly Revenue ($)", fontsize=11, fontweight='bold', pad=10)
    ax2.set_ylabel("Revenue ($)")
    ax2.set_ylim(12000, 20000)
    for i, (m, r) in enumerate(zip(months, revenue)):
        ax2.annotate(f"${r:,}", (m, r), textcoords="offset points", xytext=(0, 12),
                    ha='center', fontsize=10, fontweight='bold')
    ax2.spines['top'].set_visible(False)
    ax2.spines['right'].set_visible(False)

    plt.tight_layout(rect=[0, 0, 1, 0.94])
    pdf.savefig(fig)
    plt.close()

    # Page 3: Performance Metrics
    fig, axes = plt.subplots(2, 2, figsize=(8.5, 11))
    fig.suptitle(f"{MERCHANT} — Performance Metrics", fontsize=14, fontweight='bold', y=0.96)

    # Customer rating
    ax = axes[0, 0]
    ax.plot(months, customer_rating, marker='s', color='#f5a623', linewidth=2, markersize=8)
    ax.set_title("Customer Rating", fontsize=10, fontweight='bold')
    ax.set_ylim(4.0, 5.0)
    ax.set_ylabel("Rating (out of 5)")
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # On-time rate
    ax = axes[0, 1]
    ax.bar(months, on_time_rate, color='#4a90d9', width=0.5)
    ax.set_title("On-Time Delivery Rate (%)", fontsize=10, fontweight='bold')
    ax.set_ylim(85, 100)
    ax.set_ylabel("Percentage")
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Prep time
    ax = axes[1, 0]
    ax.plot(months, avg_prep_time, marker='^', color='#e74c3c', linewidth=2, markersize=8)
    ax.set_title("Average Prep Time (min)", fontsize=10, fontweight='bold')
    ax.set_ylim(12, 18)
    ax.set_ylabel("Minutes")
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    # Peak hours
    ax = axes[1, 1]
    ax.bar([f"{h}:00" for h in hours], order_volume, color='#00b37a', width=0.6)
    ax.set_title("Orders by Hour (Q1 Avg)", fontsize=10, fontweight='bold')
    ax.set_ylabel("Avg Orders")
    ax.tick_params(axis='x', rotation=45, labelsize=7)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.tight_layout(rect=[0, 0, 1, 0.94])
    pdf.savefig(fig)
    plt.close()

    # Page 4: Top Items Table & Recommendations
    fig, ax = plt.subplots(figsize=(8.5, 11))
    ax.axis('off')

    ax.text(0.5, 0.95, f"{MERCHANT} — Top Selling Items & Recommendations",
            fontsize=14, fontweight='bold', ha='center', color='#1a1a2e')

    # Table
    table_data = [["Rank", "Item", "Orders", "Price", "Revenue"]]
    for i, (item, qty, price, rev) in enumerate(top_items, 1):
        table_data.append([str(i), item, str(qty), price, rev])

    table = ax.table(cellText=table_data[1:], colLabels=table_data[0],
                     cellLoc='center', loc='upper center',
                     bbox=[0.05, 0.65, 0.9, 0.25])
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    for (i, j), cell in table.get_celld().items():
        if i == 0:
            cell.set_facecolor('#00b37a')
            cell.set_text_props(color='white', fontweight='bold')
        else:
            cell.set_facecolor('#f8f8fc' if i % 2 == 0 else 'white')

    # Recommendations
    rec_y = 0.58
    ax.text(0.08, rec_y, "Account Manager Recommendations", fontsize=12, fontweight='bold', color='#1a1a2e')
    rec_y -= 0.04

    recommendations = [
        "1. UPGRADE ELIGIBLE: Based on Q1 volume (1,622 orders), Sakura Ramen House qualifies for Premium tier upgrade. Projected savings: $1,800/quarter at current volume.",
        "2. PEAK HOUR OPTIMIZATION: Consider offering a 'Lunch Rush' promotion (11:30-1:30 PM) to further capitalize on the highest-traffic window. Suggested: 10% off orders over $25.",
        "3. MENU EXPANSION: Gyoza and Karaage sides show strong attach rates (58%). Recommend adding 2-3 more appetizer options to increase average order value.",
        "4. PREP TIME IMPROVEMENT: Excellent trend from 16.2 to 14.9 min. If maintained below 15 min for Q2, eligible for 'Speed Badge' visibility boost.",
        "5. DELIVERY RADIUS: Current 4-mile radius captures 89% of potential demand. Expanding to 5 miles would add ~40 orders/week from the Marina district.",
    ]

    for rec in recommendations:
        rec_y -= 0.05
        ax.text(0.08, rec_y, rec, fontsize=8.5, color='#2d2d3d', wrap=True,
                verticalalignment='top', transform=ax.transAxes,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#f4f4f8', edgecolor='none'))
        rec_y -= 0.03

    # Footer
    ax.text(0.5, 0.05, f"Report generated: {REPORT_DATE} | Pronto Merchant Analytics",
            fontsize=8, ha='center', color='#7a7a8a', style='italic')
    ax.text(0.5, 0.02, "This report is confidential and intended for internal use only.",
            fontsize=7, ha='center', color='#c4c4d0')

    pdf.savefig(fig)
    plt.close()

print(f"Report generated: {OUTPUT_PATH}")
