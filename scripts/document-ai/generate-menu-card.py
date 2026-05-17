"""
Generate a styled restaurant menu card PNG for Sakura Ramen House.
Demonstrates Document AI extraction from a visually rich image with
multiple sections, prices, descriptions, and layout complexity.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch
import numpy as np

OUTPUT_PATH = "../../document-ai-samples/sakura-ramen-menu.png"

fig, ax = plt.subplots(1, 1, figsize=(8.5, 14))
ax.set_xlim(0, 8.5)
ax.set_ylim(0, 14)
ax.axis('off')
fig.patch.set_facecolor('#1a1a2e')
ax.set_facecolor('#1a1a2e')

# Background texture - subtle pattern
for i in range(0, 85, 4):
    for j in range(0, 140, 4):
        if (i + j) % 8 == 0:
            ax.plot(i/10, j/10, '.', color='#2d2d3d', markersize=1)

# Header area
header_bg = FancyBboxPatch((0.3, 12.2), 7.9, 1.6, boxstyle="round,pad=0.1",
                            facecolor='#00b37a', edgecolor='none', alpha=0.9)
ax.add_patch(header_bg)

ax.text(4.25, 13.35, "SAKURA RAMEN HOUSE", fontsize=22, fontweight='bold',
        ha='center', color='white', family='sans-serif')
ax.text(4.25, 12.85, "— M E N U —", fontsize=12, ha='center',
        color='#e6f9f2', family='sans-serif', style='italic')
ax.text(4.25, 12.45, "742 Evergreen Terrace, San Francisco  |  (415) 555-0187",
        fontsize=7.5, ha='center', color='#c4f0e0', family='sans-serif')

# Decorative line
ax.plot([1, 7.5], [12.0, 12.0], color='#00b37a', linewidth=1.5, alpha=0.6)

# --- SIGNATURE RAMEN SECTION ---
section_y = 11.5
ax.text(0.6, section_y, "SIGNATURE RAMEN", fontsize=13, fontweight='bold',
        color='#00b37a', family='sans-serif')
ax.plot([0.6, 7.9], [section_y - 0.15, section_y - 0.15], color='#3d3d4d', linewidth=0.5)

items_ramen = [
    ("Tonkotsu Ramen", "$14.50", "Rich pork bone broth, chashu pork, soft-boiled egg, bamboo shoots, green onions, black garlic oil"),
    ("Spicy Miso Ramen", "$15.00", "House-made miso blend, ground pork, bean sprouts, corn, butter, chili threads"),
    ("Shoyu Ramen", "$13.50", "Clear soy-based broth, chicken chashu, nori, menma, scallions, yuzu zest"),
    ("Vegetable Tantanmen", "$14.00", "Creamy sesame broth, bok choy, shiitake mushrooms, crispy tofu, chili oil (V)"),
    ("Black Garlic Ramen", "$16.00", "48-hour pork broth, black garlic mayu, woodear mushrooms, ajitama egg, nori"),
]

y = section_y - 0.5
for name, price, desc in items_ramen:
    ax.text(0.8, y, name, fontsize=10, fontweight='bold', color='#ffffff', family='sans-serif')
    ax.text(7.9, y, price, fontsize=10, fontweight='bold', color='#00b37a', ha='right', family='sans-serif')
    y -= 0.3
    ax.text(0.8, y, desc, fontsize=7.5, color='#9a9aaa', family='sans-serif', style='italic')
    y -= 0.5

# --- APPETIZERS SECTION ---
section_y = y - 0.2
ax.text(0.6, section_y, "APPETIZERS", fontsize=13, fontweight='bold',
        color='#00b37a', family='sans-serif')
ax.plot([0.6, 7.9], [section_y - 0.15, section_y - 0.15], color='#3d3d4d', linewidth=0.5)

items_appetizers = [
    ("Gyoza (6 pieces)", "$8.50", "Pan-fried pork & cabbage dumplings, ponzu dipping sauce"),
    ("Chicken Karaage", "$10.00", "Japanese fried chicken, kewpie mayo, shichimi togarashi, lemon wedge"),
    ("Edamame", "$5.50", "Steamed soybeans, Maldon sea salt, sesame oil drizzle"),
    ("Takoyaki (6 pieces)", "$9.00", "Octopus fritters, bonito flakes, takoyaki sauce, Japanese mayo, aonori"),
    ("Crispy Pork Bao (2)", "$11.00", "Steamed buns, braised pork belly, pickled daikon, hoisin, cilantro"),
]

y = section_y - 0.5
for name, price, desc in items_appetizers:
    ax.text(0.8, y, name, fontsize=10, fontweight='bold', color='#ffffff', family='sans-serif')
    ax.text(7.9, y, price, fontsize=10, fontweight='bold', color='#00b37a', ha='right', family='sans-serif')
    y -= 0.3
    ax.text(0.8, y, desc, fontsize=7.5, color='#9a9aaa', family='sans-serif', style='italic')
    y -= 0.5

# --- SIDES & RICE SECTION ---
section_y = y - 0.2
ax.text(0.6, section_y, "SIDES & RICE", fontsize=13, fontweight='bold',
        color='#00b37a', family='sans-serif')
ax.plot([0.6, 7.9], [section_y - 0.15, section_y - 0.15], color='#3d3d4d', linewidth=0.5)

items_sides = [
    ("Steamed White Rice", "$3.00", "Japanese short-grain rice"),
    ("Garlic Fried Rice", "$6.50", "Wok-fried with egg, garlic chips, scallions, sesame"),
    ("Extra Chashu (3 slices)", "$4.50", "Braised pork belly, torched to order"),
    ("Ajitama Egg", "$2.50", "Marinated soft-boiled egg, 6-minute cook"),
]

y = section_y - 0.5
for name, price, desc in items_sides:
    ax.text(0.8, y, name, fontsize=10, fontweight='bold', color='#ffffff', family='sans-serif')
    ax.text(7.9, y, price, fontsize=10, fontweight='bold', color='#00b37a', ha='right', family='sans-serif')
    y -= 0.3
    ax.text(0.8, y, desc, fontsize=7.5, color='#9a9aaa', family='sans-serif', style='italic')
    y -= 0.5

# --- DRINKS SECTION ---
section_y = y - 0.2
ax.text(0.6, section_y, "DRINKS", fontsize=13, fontweight='bold',
        color='#00b37a', family='sans-serif')
ax.plot([0.6, 7.9], [section_y - 0.15, section_y - 0.15], color='#3d3d4d', linewidth=0.5)

items_drinks = [
    ("Ramune Soda", "$4.00", "Japanese marble soda — Original, Strawberry, or Melon"),
    ("Japanese Iced Tea", "$3.50", "Cold-brewed hojicha, lightly sweetened"),
    ("Asahi Draft Beer", "$7.00", "Japanese lager, 16oz pour"),
    ("Sake Flight (3)", "$14.00", "Rotating selection — ask your server"),
    ("Matcha Latte", "$5.50", "Ceremonial-grade matcha, oat milk, lightly sweetened"),
]

y = section_y - 0.5
for name, price, desc in items_drinks:
    ax.text(0.8, y, name, fontsize=10, fontweight='bold', color='#ffffff', family='sans-serif')
    ax.text(7.9, y, price, fontsize=10, fontweight='bold', color='#00b37a', ha='right', family='sans-serif')
    y -= 0.3
    ax.text(0.8, y, desc, fontsize=7.5, color='#9a9aaa', family='sans-serif', style='italic')
    y -= 0.5

# Footer
ax.plot([1, 7.5], [0.7, 0.7], color='#00b37a', linewidth=1, alpha=0.4)
ax.text(4.25, 0.4, "(V) = Vegetarian  |  Please inform us of any allergies",
        fontsize=7, ha='center', color='#7a7a8a', family='sans-serif')
ax.text(4.25, 0.15, "Prices exclude tax. 18% gratuity added to parties of 6+.",
        fontsize=6.5, ha='center', color='#5a5a6a', family='sans-serif')

plt.tight_layout(pad=0.2)
plt.savefig(OUTPUT_PATH, dpi=200, bbox_inches='tight', facecolor='#1a1a2e')
plt.close()

print(f"Menu card generated: {OUTPUT_PATH}")
