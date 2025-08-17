param (
    [string]$AddonPath = "C:\Users\jesus\Downloads\odoo-ce18-project\Odoo-CE18-Project\addons\custom-addons"  # <-- change this to your Odoo addons path
)

# Module name
$ModuleName = "mrp_laloma"
$ModulePath = Join-Path $AddonPath $ModuleName

# --- Create folder structure ---
New-Item -ItemType Directory -Force -Path $ModulePath | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ModulePath "models") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ModulePath "views") | Out-Null

# --- __manifest__.py ---
$manifest = @"
{
    "name": "Workorder Purchase Link",
    "version": "18.0.1.0.0",
    "summary": "Link Manufacturing Work Orders to Purchase Orders",
    "author": "Your Name",
    "website": "https://yourcompany.com",
    "license": "LGPL-3",
    "depends": ["mrp", "purchase"],
    "data": [
        "views/mrp_workorder_views.xml"
    ],
    "installable": True,
    "application": False
}
"@
Set-Content -Path (Join-Path $ModulePath "__manifest__.py") -Value $manifest -Encoding UTF8

# --- __init__.py (root) ---
$rootInit = 'from . import models'
Set-Content -Path (Join-Path $ModulePath "__init__.py") -Value $rootInit -Encoding UTF8

# --- models/__init__.py ---
$modelsInit = 'from . import mrp_workorder_inherit'
Set-Content -Path (Join-Path $ModulePath "models\__init__.py") -Value $modelsInit -Encoding UTF8

# --- models/mrp_workorder_inherit.py ---
$modelCode = @"
from odoo import fields, models

class MrpWorkorder(models.Model):
    _inherit = "mrp.workorder"

    purchase_order_id = fields.Many2one(
        comodel_name="purchase.order",
        string="Purchase Order",
        help="Link this work order to a related Purchase Order."
    )
"@
Set-Content -Path (Join-Path $ModulePath "models\mrp_workorder_inherit.py") -Value $modelCode -Encoding UTF8

# --- views/mrp_workorder_views.xml ---
$viewCode = @"
<odoo>
    <record id="view_workorder_form_inherit_po" model="ir.ui.view">
        <field name="name">mrp.workorder.form.purchase.link</field>
        <field name="model">mrp.workorder</field>
        <field name="inherit_id" ref="mrp.mrp_workorder_view_form"/>
        <field name="arch" type="xml">
            <xpath expr="//field[@name='production_id']" position="after">
                <field name="purchase_order_id"/>
            </xpath>
        </field>
    </record>
</odoo>
"@
Set-Content -Path (Join-Path $ModulePath "views\mrp_workorder_views.xml") -Value $viewCode -Encoding UTF8

Write-Host "✅ Odoo module '$ModuleName' created successfully at: $ModulePath"
