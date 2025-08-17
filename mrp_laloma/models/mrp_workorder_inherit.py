from odoo import fields, models

class MrpWorkorder(models.Model):
    _inherit = "mrp.workorder"

    purchase_order_id = fields.Many2one(
        comodel_name="purchase.order",
        string="Purchase Order",
        help="Link this work order to a related Purchase Order."
    )
